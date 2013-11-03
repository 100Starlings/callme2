## Agent
# models the support agent (not necessarily a user of the system)
# An agent has an identifier (name), and can be on call.
# An agent also has many devices on which she can be contacted.
#
class Agent < ActiveRecord::Base
  # Associations
  has_many :devices

  # Scopes
  scope :on_call,  -> { where(on_call: true) }
  scope :off_call, -> { where("agents.on_call IS NULL OR agents.on_call = ?", false) }

  # Validations
  validates :name, presence: true
  #validates :email, presence: true, format: /.+@.+\..+/i
  validate if: :on_call? do
    unless ready?
      errors.add(:on_call, "Agents need at least one active device to be on call")
    end
  end

  accepts_nested_attributes_for :devices, allow_destroy: true

  def on_call!
    if update_attributes on_call: true
      AgentMailer.on_call(self).deliver
    end
  end

  def off_call!
    if update_attributes on_call: false
      AgentMailer.off_call(self).deliver
    end
  end

  def ready?
    devices.active.any?
  end

  def off_call?
    !on_call?
  end
end
