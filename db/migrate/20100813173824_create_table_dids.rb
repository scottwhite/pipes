class CreateTableDids < ActiveRecord::Migration
  def self.up
    create_table :dids do |t|
      t.string  :phone_number, limit: 100 , null: false
      t.integer  :usage_state, default: 0, null: false
      t.string  :state, :city, :zip_code, :area_code
      t.timestamps
    end
  end

  def self.down
    drop_table :dids
  end
end
