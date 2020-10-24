require 'spec_helper'

describe Confluence::Api::Client do
  it 'has a version number' do
    expect(Confluence::Api::Client::VERSION).not_to be nil
  end

  describe 'instance methods' do
    subject(:instance) { described_class.new(user, pass, url) }
    let(:user) { 'confluence-user-identifier' }
    let(:pass) { 'confluence-api-key' }
    let(:url) { 'confluence-url' }

    let(:dummy_connection) { double(:connection) }
    let(:dummy_request) { double(:request, headers: {}) } 

    describe '#create_attachment' do
      let(:page_id) { 1234 }
      let(:random_hex) { 'deadbeefdeadbeef' }
      let(:comment) { nil }

      before :each do
        allow(instance).to receive(:conn).and_return(dummy_connection)
        allow(dummy_connection).to receive(:post).and_yield(dummy_request)
        allow(SecureRandom).to receive(:hex).with(8).and_return(random_hex)
        allow(dummy_request).to receive(:url)
        allow(dummy_request).to receive(:body=)

        if comment.nil?
          instance.create_attachment(page_id, file_info)
        else
          instance.create_attachment(page_id, file_info, comment)
        end
      end

      context 'using a filename to identify the file' do
        let(:file_info) { File.expand_path('../../../fixtures/example.txt',  __FILE__) }
        let(:expected_content) do
          <<-TEXT
-------------------------deadbeefdeadbeef\r
Content-Disposition: form-data; name="file"; filename="example.txt"\r
Content-Type: text/plain\r
\r
This is a simple example text file.\r
-------------------------deadbeefdeadbeef--\r
          TEXT
        end

        it 'submits what is expected' do
          expect(dummy_connection).to have_received(:post)
          expect(dummy_request.headers).to eq({
            'content-type' => "multipart/form-data; boundary=-----------------------#{ random_hex }",
            'X-Atlassian-Token' => 'nocheck'
          })
          expect(dummy_request).to have_received(:url).with("rest/api/content/#{ page_id }/child/attachment")
          expect(dummy_request).to have_received(:body=).with expected_content
        end

        context 'and it includes a comment' do
          let(:comment) { 'Silly Little Comment' }

          let(:expected_content) do
            <<-TEXT
-------------------------deadbeefdeadbeef\r
Content-Disposition: form-data; name="file"; filename="example.txt"\r
Content-Type: text/plain\r
\r
This is a simple example text file.\r
-------------------------deadbeefdeadbeef\r
Content-Disposition: form-data; name="comment"\r
\r
Silly Little Comment\r
-------------------------deadbeefdeadbeef--\r
            TEXT
          end
  
          it 'submits what is expected' do
            expect(dummy_request).to have_received(:body=).with expected_content
          end
        end
      end

      context 'using a hash to identify the file' do
        let(:file_info) do
          {
            name: 'sample.txt',
            type: 'text/plain',
            content: <<-CONTENT
This is some lovely LOVELY content.
            CONTENT
          }
        end

        let(:expected_content) do
          <<-TEXT
-------------------------deadbeefdeadbeef\r
Content-Disposition: form-data; name="file"; filename="sample.txt"\r
Content-Type: text/plain\r
\r
This is some lovely LOVELY content.
\r
-------------------------deadbeefdeadbeef--\r
          TEXT
        end

        it 'submits what is expected' do
          expect(dummy_connection).to have_received(:post)
          expect(dummy_request.headers).to eq({
            'content-type' => "multipart/form-data; boundary=-----------------------#{ random_hex }",
            'X-Atlassian-Token' => 'nocheck'
          })
          expect(dummy_request).to have_received(:url).with("rest/api/content/#{ page_id }/child/attachment")
          expect(dummy_request).to have_received(:body=).with expected_content
        end
      end
    end
  end
end
