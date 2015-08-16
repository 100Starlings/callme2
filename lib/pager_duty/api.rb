require "httparty"

module PagerDuty
  # Simple wrapper for the PagerDuty API
  # Initialize a new object with the PagerDuty subdomain and token,
  # then call `get` or `post` on the desired endpoint.
  # See here for documentation of the API:
  # https://developer.pagerduty.com/documentation/code
  class API
    include HTTParty

    format :json

    def initialize(domain, token)
      @options = {
        headers: {
          "Authorization" => "Token token=#{token}",
          "Content-type"  => "application/json",
        },
      }

      @domain = domain
    end

    def get(req, opts = {})
      make_request("get", req, opts)
    end

    def post(req, opts = {})
      make_request("post", req, opts)
    end

    private

    def make_request(method, req, opts)
      opts = opts.merge(@options)
      puts "#{method.upcase} #{url_for(req)} #{opts.inspect}"
      self.class.send(method, url_for(req), opts)
    end

    def url_for(req)
      "https://#{@domain}.pagerduty.com/api/v1/#{req}"
    end
  end
end
