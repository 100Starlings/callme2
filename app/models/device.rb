# Device
# represents a point of contact for an Agent. It will typically be a 
# phone number.
# A Device has a name and an address.
#
class Device < ActiveRecord::Base
  # Associations
  belongs_to :agent

  def to_s
    "#{name}: #{address}"
  end
end
