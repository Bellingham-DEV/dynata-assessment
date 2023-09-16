require 'openssl'
require 'digest'
require 'cgi'

class HttpSigner
  SECRET_ENV = 'HTTPSIGNER_SECRET_KEY'

  def initialize(access_key:, secret_key:, timestamp: nil)
    @access_key = access_key
    @secret_key = secret_key
    @timestamp = timestamp || Time.now.strftime('%Y%m%d')
  end

  def call(http_frame)
    sign(http_frame)[:signature]
  end

  def sign(http_frame)
    return { canonical_request: nil, string_to_sign: nil, signature: nil } if http_frame.nil? || http_frame.empty?

    canonical_request = get_canonical_request(http_frame)
    stringtosign = string_to_sign(canonical_request)
    signature = lowercase(hex(hmac_sha256(signing_key, stringtosign)))

    { canonical_request:, string_to_sign: stringtosign, signature: }
  end

  private

  def string_to_sign(canonical_request)
    lowercase(hex(sha256(canonical_request)))
  end

  def signing_key
    date_key = lowercase(hex(hmac_sha256(@secret_key, @timestamp)))
    lowercase(hex(hmac_sha256(date_key, @access_key)))
  end

  def get_canonical_request(http_frame)
    http_method, path, query, headers, payload = parse_http_frame(http_frame)

    canonical_query = get_canonical_query(query)
    canonical_headers = get_canonical_headers(headers)
    hashed_payload = lowercase(hex(sha256(payload)))

    req = "#{http_method}\n#{path}"
    req += "\n#{canonical_query}" unless canonical_query.empty?
    req += "\n#{canonical_headers}\n\n#{hashed_payload}"
  end


  def parse_http_frame(http_frame)
    header_lines, payload = http_frame.split("\r\n\r\n")
    payload ||= ''
    header_lines = ( header_lines || '' ).split("\r\n")
    http_method, path_and_query, http_version = header_lines[0].split(' ')
    path, query = ( path_and_query || '' ).split('?')
    headers = header_lines[1..-1].map { |x| x.split(': ', 2) }
    headers = combine_params(headers).to_h

    query = (query || '').split('&').map { |x| x.split('=', 2) }
    query = combine_params(query).to_h
    [http_method, path, query, headers, payload]
  end

  def combine_params(params)
    param_hash = params.each_with_object(Hash.new { |h, k| h[k] = [] }) do |(k, v), h|
      h[k] << v
    end
    param_hash.map { |k, v| [k, v.join(',')] }
  end

  def get_canonical_query(query)
    query
      .map { |k, v| [uri_encode(k), v.split(',').map { |x| uri_encode(x) }.join('%2C')] }
      .sort
      .map { |k, v| "#{k}=#{v}" }
      .join('&')
  end

  def get_canonical_headers(headers)
    headers
      .map { |k, v| [lowercase(k), trim(v)] }
      .sort
      .map { |k, v| "#{k}:#{v}" }
      .join("\n")
  end

  def lowercase(value)
    value.downcase
  end

  def hex(value)
    value.unpack1('H*')
  end

  def sha256(value)
    return '' unless value

    Digest::SHA256.digest(value)
  end

  def hmac_sha256(key, value)
    OpenSSL::HMAC.digest('sha256', key, value)
  end

  def trim(value)
    value.strip
  end

  def uri_encode(value)
    already_encoded = CGI.unescape(value) != value.gsub('+', ' ')
    encoded = CGI.escape(value.gsub('+',' ')).gsub('+', '%20')

    return encoded if !(value =~ /\A[a-zA-Z0-9\-\.\_\~]*\z/).nil? ||
                      value.each_codepoint.any? { |codepoint| codepoint > 127 }

    return value if already_encoded

    encoded
  end
end

