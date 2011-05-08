class CreateCallLogs < ActiveRecord::Migration
  def self.up
    connection.execute(%Q{CREATE TABLE `call_logs` (
      id  mediumint unsigned not null auto_increment,
      `call_date` datetime NOT NULL default '0000-00-00 00:00:00',
      `call_sid` varchar(200) NOT NULL,
      `calling_number` varchar(80) NOT NULL default '',
      `target_number` varchar(80) NOT NULL default '',
      `pipes_number` varchar(80) NOT NULL default '',
      `duration` int(11) NOT NULL default '0',
      `status` varchar(45) NOT NULL default '',
      KEY `call_date` (`call_date`),
      KEY `pipes_number` (`pipes_number`),
      PRIMARY KEY (id)
    )})
  end

  def self.down
    drop_table :call_logs
  end
end
