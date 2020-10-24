require "confluence/api/client/version"
require 'json'
require 'faraday'
require 'securerandom'
require 'mime/types'

module Confluence
  module Api
    class Client
      attr_accessor :user, :pass, :url

      def initialize(user, pass, url)
        self.user = user
        self.pass = pass
        self.url  = url
      end

      def get(params)
        response = conn.get('rest/api/content', params)
        JSON.parse(response.body)['results']
      end

      def get_by_id(id)
        response = conn.get('/rest/api/content/' + id)
        JSON.parse(response.body)
      end

      def create(params)
        response = conn.post do |req|
          req.url 'rest/api/content'
          req.headers['Content-Type'] = 'application/json'
          req.body                    = params.to_json
        end
        JSON.parse(response.body)
      end

      def update(id, params)
        response = conn.put do |req|
          req.url "rest/api/content/#{id}"
          req.headers['Content-Type'] = 'application/json'
          req.body                    = params.to_json
        end
        JSON.parse(response.body)
      end

      def create_attachment(page_id, file_info, comment=nil)
        sep = SecureRandom.hex(8)
        file = resolve_file_info_from(file_info)
        boundary = "-----------------------#{ sep }"

        file_section = [
          "Content-Disposition: form-data; name=\"file\"; filename=\"#{ file[:name] }\"",
          "Content-Type: #{ file[:type] }",
          "",
          file[:content],
          ""
        ].join("\r\n")

        content = "--#{ boundary }\r\n"
        content << file_section  
        if comment
          content << "--#{ boundary }\r\n"
          comment_section = [
            "Content-Disposition: form-data; name=\"comment\"",
            "",
            comment,
            ""
          ].join("\r\n")
          content << comment_section
        end
        content << "--#{ boundary }--\r\n"

        response = conn.post do |request|
          request.headers['content-type'] = "multipart/form-data; boundary=#{ boundary }"
          request.headers['X-Atlassian-Token'] = 'nocheck'
          url = "rest/api/content/#{ page_id }/child/attachment"
          request.url url
          request.body = content
        end

        [response.status == 200 ? :ok : :error, JSON.parse(response.body)]
      end

      private

      def resolve_file_info_from file_info
        return file_info if file_info.kind_of?(Hash)

        file_name = file_info.split('/').last

        {
          name: file_name,
          type: MIME::Types.type_for(file_name).first,
          content: File.open(file_info).read
        }
      end

      def conn
        @conn ||= Faraday.new(url: url) do |faraday|
          faraday.request :url_encoded # form-encode POST params
          # faraday.response :logger                  # log requests to STDOUT
          faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
          faraday.basic_auth(user, pass)
        end
      end
    end
  end
end
