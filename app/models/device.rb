# Device
# represents a point of contact for an Agent. It will typically be a 
# phone number.
# A Device has a name and an address.
#
class Device < ActiveRecord::Base
  # Validations
  validates :name, presence: true
  validates :address, presence: true

  # Associations
  belongs_to :agent

  # Scopes
  scope :active, -> { where(active: true) }

  def to_s
    "#{name}: #{address}"
  end
end
