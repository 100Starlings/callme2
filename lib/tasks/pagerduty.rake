require "pager_duty"
namespace :pagerduty do
  desc "show who's on call"
  task :on_call, [:level] => :environment do |_t, args|
    args.with_defaults(level: 1)
    on_call_policies = PagerDuty::EscalationPolicy.on_call
    escalation_policy = on_call_policies.find do |ep|
      ep["id"] == ENV["PAGERDUTY_ESCALATION_POLICY"]
    end

    on_call_users = escalation_policy["on_call"]
    puts "On call users: #{on_call_users.map { |oc| oc["user"]["name"] }}"
    level_user = on_call_users.find { |oc| oc["level"].to_i == args.level.to_i }

    fail "No user on call level #{level}" unless level_user

    user = level_user["user"]
    user_id = user["id"]
    puts "Found user on level 1 call: #{user.inspect}"

    contact_methods = PagerDuty::ContactMethod.list(user_id, "contact_methods")
    phone = contact_methods.find { |cm| cm["type"] == "phone" }

    if phone
      puts "+#{phone["country_code"]} #{phone["phone_number"]}"
    else
      puts "No phone contact"
    end
  end
end
