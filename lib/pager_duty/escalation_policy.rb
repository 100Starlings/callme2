module PagerDuty
  class EscalationPolicy < Resource
    class OnCall < PagerDuty::Collection
      self.path = "escalation_policies/on_call"
    end

    self.path = "escalation_policies"

    def self.on_call
      OnCall.list
    end
  end
end
