module PagerDuty
  class Collection < Base
    def self.list(id = nil, action = nil)
      response = api.get(path_for(id, action))
      resources = load(response.body)
      resources.map do |resource|
        new(resource)
      end
    end
  end
end
