class AddEmailToAgent < ActiveRecord::Migration
  def change
    add_column :agents, :email, :string
  end
end
