require "confluence/api/client/version"
require 'json'
require 'faraday'

module Confluence
  module Api
    class Client
      attr_accessor :user, :pass, :url, :conn

      def initialize(user, pass, url)
        self.user = user
        self.pass = pass
        self.url  = url
        self.conn = Faraday.new(url: url) do |faraday|
          faraday.request :url_encoded # form-encode POST params
          # faraday.response :logger                  # log requests to STDOUT
          faraday.adapter Faraday.default_adapter # make requests with Net::HTTP
          faraday.basic_auth(self.user, self.pass)
        end
      end

      def get(params)
        response = conn.get('/rest/api/content', params)
        JSON.parse(response.body)['results']
      end

      def get_by_id(id)
        response = conn.get('/rest/api/content/' + id)
        JSON.parse(response.body)
      end

      def create(params)
        response = conn.post do |req|
          req.url '/rest/api/content'
          req.headers['Content-Type'] = 'application/json'
          req.body                    = params.to_json
        end
        JSON.parse(response.body)
      end

      def update(id, params)
        response = conn.put do |req|
          req.url "/rest/api/content/#{id}"
          req.headers['Content-Type'] = 'application/json'
          req.body                    = params.to_json
        end
        JSON.parse(response.body)
      end

    end
  end
end
