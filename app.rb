require 'sinatra'
require 'logger'

require_relative 'http_signer'

class Front < Sinatra::Base
  DEFAULT_TIMESTAMP = '20230801'

  configure do
    set :server, :thin
    set :port, 3000
    set :bind, '0.0.0.0'
    set :logger, Logger.new(STDOUT)
  end

  before do
    env["rack.logger"] = settings.logger
  end

  get '/' do
    @http_frame = ''
    @timestamp = DEFAULT_TIMESTAMP
    @signed = {canonical_request: nil, string_to_sign: nil, signature: nil}
    erb :index
  end

  post '/test' do
    logger.info "Parameters: #{params.inspect}"
    @timestamp = params[:timestamp] || DEFAULT_TIMESTAMP
    service = HttpSigner.new(access_key: ENV.fetch('HTTPSIGNER_ACCESS_KEY'),
                             secret_key: ENV.fetch('HTTPSIGNER_SECRET_KEY'),
                             timestamp: @timestamp)
    @http_frame = params[:http_frame].gsub('\r\n','')
    @signed = service.sign(@http_frame)
    erb :index
  end

end

Front.start!
