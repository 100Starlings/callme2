## Agent
# models the support agent (not necessarily a user of the system)
# An agent has an identifier (name), and can be on call.
#
class Agent < ActiveRecord::Base
  scope :on_call, -> { where(on_call: true) }
  scope :not_on_call, -> { where("agents.on_call IS NULL OR agents.on_call = ?", false) }

end
