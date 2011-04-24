class AddProviderToDids < ActiveRecord::Migration
  def self.up
    add_column :dids, :provider, :string
    add_column :dids, :provider_id, :string
    connection.execute("update dids set provider='voipms'")
  end

  def self.down
    remove_column :dids, :provider
    remove_column :dids, :provider_id
  end
end
