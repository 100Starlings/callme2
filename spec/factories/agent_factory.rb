FactoryGirl.define do
  sequence :name do |n|
    "John #{n}"
  end

  sequence :email do |n|
    "john_#{n}@example.com"
  end

  factory :agent do
    name
    email
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

end
