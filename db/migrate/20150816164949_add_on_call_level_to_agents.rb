class AddOnCallLevelToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :on_call_level, :string
  end
end
