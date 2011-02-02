class CreateTableCallQueue < ActiveRecord::Migration
  def self.up
    create_table :call_queue do |t|
      t.integer :call_time, null: false
      t.integer :time_left, null: false
      t.string :email, :calling, :caller, null: false
      t.boolean :processed, null: false, default: false
      t.datetime :start_date, null: true
      t.timestamps
    end
  end

  def self.down
    drop_table :call_queue
  end
end
