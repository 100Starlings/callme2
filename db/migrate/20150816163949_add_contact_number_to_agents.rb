class AddContactNumberToAgents < ActiveRecord::Migration[4.2]
  def change
    add_column :agents, :contact_number, :string
  end
end
