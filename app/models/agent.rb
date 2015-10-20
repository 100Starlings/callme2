## Agent
# models the support agent (not necessarily a user of the system)
# An agent has an identifier (name), and can be on call.
# An agent also has many devices on which she can be contacted.
#
class Agent < ActiveRecord::Base
  # Associations
  has_many :devices

  # Scopes
  scope :on_call,  -> { where.not(contact_number: nil, on_call_level: nil) }
  scope :off_call, -> { where(contact_number: nil) }

  # Validations
  validates :name, presence: true
  validates :email, presence: true, format: /.+@.+\..+/i
  validate if: :on_call? do
    unless ready?
      errors.add(:on_call, "Agents need at least one active device to be on call")
    end
  end

  accepts_nested_attributes_for :devices, allow_destroy: true

  def on_call!
    on_call_state(true) unless on_call?
  end

  def off_call!
    on_call_state(false) unless off_call?
  end

  def ready?
    devices.active.any?
  end

  def off_call?
    !on_call?
  end

  private

  def on_call_state(state)
    send_reminder if update_attribute("on_call", state)
  end

  def send_reminder
    reminder = on_call? ? "on_call" : "off_call"
    AgentMailer.send(reminder, self).deliver
  end
end
