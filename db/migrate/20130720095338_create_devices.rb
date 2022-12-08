class CreateDevices < ActiveRecord::Migration[4.2]
  def change
    create_table :devices do |t|
      t.string :name
      t.string :address
      t.references :agent, index: true
    end
  end
end
