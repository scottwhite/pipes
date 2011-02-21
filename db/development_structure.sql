CREATE TABLE `call_queue` (
  `id` int(11) NOT NULL auto_increment,
  `call_time` int(11) NOT NULL,
  `time_left` int(11) NOT NULL,
  `email` varchar(255) collate utf8_unicode_ci NOT NULL,
  `calling` varchar(255) collate utf8_unicode_ci NOT NULL,
  `caller` varchar(255) collate utf8_unicode_ci NOT NULL,
  `processed` tinyint(1) NOT NULL default '0',
  `start_date` datetime NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `queue_type` int(11) NOT NULL default '1',
  `dids_user_phone_id` int(11) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cdr` (
  `id` mediumint(8) unsigned NOT NULL auto_increment,
  `calldate` datetime NOT NULL default '0000-00-00 00:00:00',
  `clid` varchar(80) collate utf8_unicode_ci NOT NULL default '',
  `src` varchar(80) collate utf8_unicode_ci NOT NULL default '',
  `dst` varchar(80) collate utf8_unicode_ci NOT NULL default '',
  `dcontext` varchar(80) collate utf8_unicode_ci NOT NULL default '',
  `channel` varchar(80) collate utf8_unicode_ci NOT NULL default '',
  `dstchannel` varchar(80) collate utf8_unicode_ci NOT NULL default '',
  `lastapp` varchar(80) collate utf8_unicode_ci NOT NULL default '',
  `lastdata` varchar(80) collate utf8_unicode_ci NOT NULL default '',
  `duration` int(11) NOT NULL default '0',
  `billsec` int(11) NOT NULL default '0',
  `disposition` varchar(45) collate utf8_unicode_ci NOT NULL default '',
  `amaflags` int(11) NOT NULL default '0',
  `accountcode` varchar(20) collate utf8_unicode_ci NOT NULL default '',
  `userfield` varchar(255) collate utf8_unicode_ci NOT NULL default '',
  `uniqueid` varchar(32) collate utf8_unicode_ci NOT NULL default '',
  PRIMARY KEY  (`id`),
  KEY `calldate` (`calldate`),
  KEY `dst` (`dst`),
  KEY `accountcode` (`accountcode`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `dids` (
  `id` int(11) NOT NULL auto_increment,
  `phone_number` varchar(100) collate utf8_unicode_ci NOT NULL,
  `usage_state` int(11) NOT NULL default '0',
  `state` varchar(255) collate utf8_unicode_ci default NULL,
  `city` varchar(255) collate utf8_unicode_ci default NULL,
  `zip_code` varchar(255) collate utf8_unicode_ci default NULL,
  `area_code` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `dids_last_used` (
  `did_id` int(10) unsigned NOT NULL,
  `dids_user_phone_id` int(10) unsigned NOT NULL,
  `number` varchar(100) collate utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL default '0000-00-00 00:00:00',
  `updated_at` datetime NOT NULL default '0000-00-00 00:00:00',
  PRIMARY KEY  (`did_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `dids_user_phones` (
  `id` int(11) NOT NULL auto_increment,
  `did_id` int(11) NOT NULL,
  `user_phone_id` int(11) NOT NULL,
  `current_usage` int(11) NOT NULL default '0',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `expire_state` tinyint(4) NOT NULL default '0',
  `time_allotted` int(11) NOT NULL default '1200',
  `expiration_date` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `user_phone_id` (`user_phone_id`),
  KEY `did_id` (`did_id`),
  CONSTRAINT `dids_user_phones_ibfk_1` FOREIGN KEY (`user_phone_id`) REFERENCES `user_phones` (`id`),
  CONSTRAINT `dids_user_phones_ibfk_2` FOREIGN KEY (`did_id`) REFERENCES `dids` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `amount` decimal(8,2) NOT NULL,
  `gateway_trans_id` varchar(255) collate utf8_unicode_ci default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `state` varchar(255) collate utf8_unicode_ci default NULL,
  `city` varchar(255) collate utf8_unicode_ci default NULL,
  `user_phone_id` int(11) default NULL,
  `product_id` int(11) default NULL,
  PRIMARY KEY  (`id`),
  KEY `user_phone_id` (`user_phone_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_phone_id`) REFERENCES `user_phones` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `products` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(255) collate utf8_unicode_ci NOT NULL,
  `price` decimal(8,2) NOT NULL,
  `active` tinyint(1) NOT NULL default '1',
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) collate utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `user_phones` (
  `id` int(11) NOT NULL auto_increment,
  `user_id` int(11) NOT NULL,
  `number` varchar(100) collate utf8_unicode_ci NOT NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  PRIMARY KEY  (`id`),
  KEY `user_id` (`user_id`),
  KEY `index_user_phones_on_number` (`number`),
  CONSTRAINT `user_phones_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_phones_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_phones_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_phones_ibfk_4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_phones_ibfk_5` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_phones_ibfk_6` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL auto_increment,
  `login` varchar(40) collate utf8_unicode_ci default NULL,
  `crypted_password` varchar(40) collate utf8_unicode_ci default NULL,
  `salt` varchar(40) collate utf8_unicode_ci default NULL,
  `remember_token` varchar(40) collate utf8_unicode_ci default NULL,
  `remember_token_expires_at` datetime default NULL,
  `name` varchar(100) collate utf8_unicode_ci default '',
  `email` varchar(100) collate utf8_unicode_ci NOT NULL,
  `activation_code` varchar(40) collate utf8_unicode_ci default NULL,
  `activated_at` datetime default NULL,
  `state` varchar(255) collate utf8_unicode_ci default 'passive',
  `deleted_at` datetime default NULL,
  `created_at` datetime default NULL,
  `updated_at` datetime default NULL,
  `receive_notifications` tinyint(1) NOT NULL default '1',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `index_users_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO schema_migrations (version) VALUES ('20100813173824');

INSERT INTO schema_migrations (version) VALUES ('20100813174958');

INSERT INTO schema_migrations (version) VALUES ('20100813185526');

INSERT INTO schema_migrations (version) VALUES ('20100813185614');

INSERT INTO schema_migrations (version) VALUES ('20100813191824');

INSERT INTO schema_migrations (version) VALUES ('20101007020604');

INSERT INTO schema_migrations (version) VALUES ('20101014015253');

INSERT INTO schema_migrations (version) VALUES ('20101218212121');

INSERT INTO schema_migrations (version) VALUES ('20101231030810');

INSERT INTO schema_migrations (version) VALUES ('20101231211818');

INSERT INTO schema_migrations (version) VALUES ('20110107011854');

INSERT INTO schema_migrations (version) VALUES ('20110202042113');

INSERT INTO schema_migrations (version) VALUES ('20110202044221');

INSERT INTO schema_migrations (version) VALUES ('20110210145644');

INSERT INTO schema_migrations (version) VALUES ('20110218021523');

INSERT INTO schema_migrations (version) VALUES ('20110218035308');

INSERT INTO schema_migrations (version) VALUES ('20110220212019');