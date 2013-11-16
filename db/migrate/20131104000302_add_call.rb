class AddCall < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :sid
      t.string :from, :to
      t.string :status
      t.string :direction
      t.integer :duration
      t.string :recording_url
      t.string :recording_duration
      t.timestamps
    end
  end
end
