module PagerDuty
  class Resource < Base
    def self.find(id, opts = {})
      response = api.get(path_for(id), opts)
      resource = load(response.body)
      new(resource)
    end
  end
end
