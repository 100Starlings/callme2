FactoryGirl.define do
  factory :device do
    sequence(:name) { |n| "phone #{n}" }
    sequence(:address) { |n| "555 123456#{n}" }
  end

  factory :active_device, parent: :device do
    active true
  end
end
