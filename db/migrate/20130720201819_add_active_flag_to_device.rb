class AddActiveFlagToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :active, :boolean
  end
end
