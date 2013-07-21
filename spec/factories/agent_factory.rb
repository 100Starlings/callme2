FactoryGirl.define do
  sequence :name do |n|
    "John #{n}"
  end

  factory :agent do
    name
  end

  factory :on_call_agent, parent: :agent do
    ignore do
       devices_count 1
    end

    after(:create) do |agent, evaluator|
      FactoryGirl.create_list(:active_device, evaluator.devices_count, :agent => agent)
      agent.on_call!
    end
  end

  factory :device do
    name "phone"
    address "555 123456"
  end

  factory :active_device, parent: :device do
    active true
  end

end
