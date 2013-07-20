## Agent
# models the support agent (not necessarily a user of the system)
# An agent has an identifier (name), and can be on call.
# An agent also has many devices on which she can be contacted.
#
class Agent < ActiveRecord::Base
  # Associations
  has_many :devices

  # Scopes
  scope :on_call, -> { where(on_call: true) }
  scope :not_on_call, -> { where("agents.on_call IS NULL OR agents.on_call = ?", false) }

end
