# frozen_string_literal: true

require 'spec_helper'
require_relative '../http_signer'
require 'json'
require 'pry'

SIGNING_KEY = '28cfe47c386456f844def6a497e09cb7de1a52569bd65449792938acf550ca34'
TIMESTAMP = '20230801'

RSpec.describe HttpSigner do
	let(:access_key) { ENV.fetch('HTTPSIGNER_ACCESS_KEY')}
	let(:secret_key) { ENV.fetch('HTTPSIGNER_SECRET_KEY')}
	let(:signing_key) { SIGNING_KEY }
	let(:timestamp) { TIMESTAMP }
  let(:service) { HttpSigner.new(access_key:, secret_key:, timestamp:) }

	describe 'initialization' do
		it 'initializes success fully' do
			expect(service).to be_a(HttpSigner)
		end
	end

  describe 'call' do
		let(:example1) { load_json('example_1.json') }
		let(:example2) { load_json('example_2.json') }
		let(:example3) { load_json('example_3.json') }

    def standard_call_expectations(example)
			frame = example['http_frame']

      # intermediary generation
      returned_canonical_request = service.send(:get_canonical_request, frame)
      expect(returned_canonical_request).to eq(example['canonical_request'])
      returned_string_to_sign = service.send(:string_to_sign, returned_canonical_request)
      expect(returned_string_to_sign).to eq(example['string_to_sign'])

      # call returns expected signature
			expected_signature = example['signature']
			returned_signature = service.call(frame)
			expect(returned_signature).to eq(expected_signature)
    end

		it 'returns the correct signature when the frame has an empty payload' do
      standard_call_expectations(example1)
		end

    it 'returns the correct signature when the frame contains arbitrary headers' do
      standard_call_expectations(example2)
    end

    it 'returns the correct signature when the frame contains arbitrary text with linefeeds' do
      standard_call_expectations(example3)
    end

  end
end

def load_json(filename)
	file_path = File.expand_path("examples/#{filename}", __dir__)
	JSON.parse(File.read(file_path))
end

