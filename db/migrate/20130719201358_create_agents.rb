class CreateAgents < ActiveRecord::Migration[4.2]
  def change
    create_table :agents do |t|
      t.string  :name
      t.boolean :on_call

      t.timestamps
    end
  end
end
