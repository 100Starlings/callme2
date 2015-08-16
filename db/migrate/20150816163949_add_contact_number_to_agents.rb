class AddContactNumberToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :contact_number, :string
  end
end
