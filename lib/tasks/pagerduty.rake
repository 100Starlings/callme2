require "pager_duty"
namespace :pagerduty do
  desc "show which number to call for level (default 1)"
  task :callnumber, [:level] => :environment do |_t, args|
    args.with_defaults(level: 1)
    on_calls = PagerDuty::OnCalls.list(nil, nil, "?include[]=users&include[]=contact_methods")
    active_on_calls = on_calls.select do |ep|
      ep["escalation_policy"]["id"] == ENV["PAGERDUTY_ESCALATION_POLICY"]
    end

    puts "On call users: #{active_on_calls.map { |oc| oc["user"]["name"] }}"
    level_user = active_on_calls.find { |oc| oc["escalation_level"].to_i == args.level.to_i }

    fail "No user on call level #{args.level}" unless level_user

    user = level_user["user"]
    user_id = user["id"]
    puts "Found user on level #{args.level} call: #{user.inspect}"

    contact_methods = user["contact_methhods"]
    phone = contact_methods.find { |cm| cm["type"] == "phone_contact_method" }

    if phone
      puts "+#{phone["country_code"]} #{phone["address"]}"
    else
      puts "No phone contact"
    end
  end

  desc "update agents and contact data from PagerDuty"
  task refresh: :environment do
    on_calls = PagerDuty::OnCalls.list(nil, nil, "?include[]=users&include[]=contact_methods")
    active_on_calls = on_calls.select do |oc|
      oc["escalation_policy"]["id"] == ENV["PAGERDUTY_ESCALATION_POLICY"]
    end

    puts "On call users: #{active_on_calls.map { |oc| oc["user"]["summary"] }}"
    Agent.update_all on_call_level: nil
    active_on_calls.each do |oc|
      user = oc["user"]
      id = user["id"]
      agent = Agent.find_or_initialize_by(pagerduty_id: id)

      agent.name = user["name"]
      agent.on_call_level = oc["escalation_level"].to_i
      agent.email = user["email"]

      contact_methods = user["contact_methods"]
      phone = contact_methods.find { |c| c["type"] == "phone_contact_method" }
      if phone
        agent.contact_number = "+#{phone["country_code"]} #{phone["address"]}"
      end

      unless agent.save
        puts "Agent with errors: #{agent.inspect}"
        puts "  errors: #{agent.errors.full_messages}"
      end
    end
  end
end
