require "json"

module PagerDuty
  class Base
    include PagerDuty::Config

    attr_reader :data

    def self.path_for(id, action = nil)
      "#{@path}/#{id}/#{action}".gsub("//", "/")
    end

    def self.path=(p)
      @path = p
    end

    def self.api
      PagerDuty::API.new(domain, token)
    end

    def self.load(text)
      json = JSON.parse(text)
      root_key = json.keys.first
      json[root_key]
    end

    def initialize(json)
      @data = json
    end

    def [](symbol)
      @data[symbol]
    end
  end
end
