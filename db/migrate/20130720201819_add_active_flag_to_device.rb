class AddActiveFlagToDevice < ActiveRecord::Migration[4.2]
  def change
    add_column :devices, :active, :boolean
  end
end
