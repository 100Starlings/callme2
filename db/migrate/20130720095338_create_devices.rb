class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.string :address
      t.references :agent, index: true
    end
  end
end
