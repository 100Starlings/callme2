module PagerDuty
  class Collection < Base
    def self.list(id = nil, action = nil, options="")
      response = api.get(path_for(id, action, options))
      resources = load(response.body)
      resources.map do |resource|
        new(resource)
      end
    end
  end
end
