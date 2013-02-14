class CreateTokens < ActiveRecord::Migration
  def self.up
    connection.execute(%Q{CREATE TABLE `request_tokens` (
      id  mediumint unsigned not null auto_increment,
      did_id  mediumint unsigned not null,
      token varchar(200) NOT NULL,
      `created_at` timestamp NOT NULL,
      KEY `token` (`token`),
      PRIMARY KEY (id)
    )})

  end

  def self.down
    drop_table :request_tokens
  end
end
