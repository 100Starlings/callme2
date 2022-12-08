class AddPagerDutyIdToAgents < ActiveRecord::Migration[4.2]
  def change
    add_column :agents, :pagerduty_id, :string
  end
end
