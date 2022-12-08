class AddOnCallLevelToAgents < ActiveRecord::Migration[4.2]
  def change
    add_column :agents, :on_call_level, :string
  end
end
