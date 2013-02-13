CREATE TABLE `call_logs` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `call_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `call_sid` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `calling_number` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `target_number` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `pipes_number` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `duration` int(11) NOT NULL DEFAULT '0',
  `status` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `call_date` (`call_date`),
  KEY `pipes_number` (`pipes_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `call_queue` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `call_time` int(11) NOT NULL,
  `time_left` int(11) NOT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `calling` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `caller` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `processed` tinyint(1) NOT NULL DEFAULT '0',
  `start_date` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `queue_type` int(11) NOT NULL DEFAULT '1',
  `dids_user_phone_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `cdr` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `calldate` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `clid` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `src` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `dst` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `dcontext` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `channel` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `dstchannel` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `lastapp` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `lastdata` varchar(80) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `duration` int(11) NOT NULL DEFAULT '0',
  `billsec` int(11) NOT NULL DEFAULT '0',
  `disposition` varchar(45) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `amaflags` int(11) NOT NULL DEFAULT '0',
  `accountcode` varchar(20) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `userfield` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `uniqueid` varchar(32) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `calldate` (`calldate`),
  KEY `dst` (`dst`),
  KEY `accountcode` (`accountcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `dids` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `usage_state` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `provider` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `provider_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `dids_last_used` (
  `did_id` int(10) unsigned NOT NULL,
  `dids_user_phone_id` int(10) unsigned NOT NULL,
  `number` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `updated_at` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`did_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `dids_user_phones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `did_id` int(11) NOT NULL,
  `user_phone_id` int(11) NOT NULL,
  `current_usage` int(11) NOT NULL DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `expire_state` tinyint(4) NOT NULL DEFAULT '0',
  `time_allotted` int(11) NOT NULL DEFAULT '1200',
  `expiration_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `did_id` (`did_id`),
  KEY `user_phone_id` (`user_phone_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `amount` decimal(8,2) NOT NULL,
  `gateway_trans_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_phone_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_phone_id` (`user_phone_id`),
  CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`user_phone_id`) REFERENCES `user_phones` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `price` decimal(8,2) NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `schema_migrations` (
  `version` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `user_phones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `number` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `index_user_phones_on_number` (`number`),
  CONSTRAINT `user_phones_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `crypted_password` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `salt` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_token` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `remember_token_expires_at` datetime DEFAULT NULL,
  `name` varchar(100) COLLATE utf8_unicode_ci DEFAULT '',
  `email` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `activation_code` varchar(40) COLLATE utf8_unicode_ci DEFAULT NULL,
  `activated_at` datetime DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'passive',
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `receive_notifications` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

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

INSERT INTO schema_migrations (version) VALUES ('20110407000817');

INSERT INTO schema_migrations (version) VALUES ('20110424013842');