class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string  :name
      t.boolean :on_call

      t.timestamps
    end
  end
end
