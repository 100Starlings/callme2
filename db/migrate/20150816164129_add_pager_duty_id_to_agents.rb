class AddPagerDutyIdToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :pagerduty_id, :string
  end
end
