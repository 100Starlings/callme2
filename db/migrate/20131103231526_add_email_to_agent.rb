class AddEmailToAgent < ActiveRecord::Migration[4.2]
  def change
    add_column :agents, :email, :string
  end
end
