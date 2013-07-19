FactoryGirl.define do
  sequence :name do |n|
    "John #{n}"
  end

  factory :agent do
    name
  end

  factory :on_call_agent, parent: :agent do
    on_call true
  end
end
