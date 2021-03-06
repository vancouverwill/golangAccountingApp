-- run this file to get started

DROP DATABASE IF EXISTS accountancyApp;

create database accountancyApp;

use accountancyApp;


-- create accountHolders table and seed data

CREATE TABLE `accountHolders` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT NULL,
  `jobTitle` varchar(200) DEFAULT NULL,
  `updated` int(11) DEFAULT NULL,
  `created` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8;

INSERT into accountHolders (name, jobTitle, updated, created) VALUES ("Jim Davies", "Sales North East", UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into accountHolders (name, jobTitle, updated, created) VALUES ("Darrel Mathes", "Sales South East", UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into accountHolders (name, jobTitle, updated, created) VALUES ("Michael Rupert", "Sales North West", UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into accountHolders (name, jobTitle, updated, created) VALUES ("Jim Davison", "Sales South West", UNIX_TIMESTAMP(), UNIX_TIMESTAMP());


-- create currencies table and seed data

CREATE TABLE `currencies` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT NULL,
  `exchangeRate` float DEFAULT '1',
  `updated` int(11) DEFAULT NULL,
  `created` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

INSERT into currencies (name, exchangeRate, updated, created) VALUES ("US Dollar", 1.0, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into currencies (name, exchangeRate, updated, created) VALUES ("Canadian Dollar", 0.82, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into currencies (name, exchangeRate, updated, created) VALUES ("UK POUND Sterling", 1.51, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into currencies (name, exchangeRate, updated, created) VALUES ("Euro", 1.12, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());


CREATE TABLE `taxRates` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT NULL,
  `taxRate` float DEFAULT '1',
  `updated` int(11) DEFAULT NULL,
  `created` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

INSERT into taxRates (name, taxRate, updated, created) VALUES ("US Tax", 0.15, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into taxRates (name, taxRate, updated, created) VALUES ("Canadian Tax", 0.3, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into taxRates (name, taxRate, updated, created) VALUES ("Norwegian Tax", 0.6, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());



-- create accounts table and seed data
CREATE TABLE `accounts` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `accountHolderId` int(11) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `address` varchar(400) DEFAULT NULL,
  `currencyId` int(11) DEFAULT 0,
  `taxRateId` int(11) DEFAULT 0,
  `updated` int(11) DEFAULT NULL,
  `created` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8;

INSERT into accounts (accountHolderId, name, address, currencyId, taxRateId,updated, created) VALUES ( (SELECT id AS accountHolderId from accountHolders WHERE `name` = "Jim Davies") , "Miami Parts", "20 Main Street", (SELECT id AS currencyId from currencies WHERE `name` = "US DOLLAR"), (SELECT id AS taxRateId from taxRates WHERE `name` = "US Tax"), UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into accounts (accountHolderId, name, address, currencyId, taxRateId, updated, created) VALUES ( (SELECT id AS accountHolderId from accountHolders WHERE `name` = "Jim Davies") , "Philad WholeSale", "200 Centre Avenue", (SELECT id AS currencyId from currencies WHERE `name` = "US DOLLAR"), (SELECT id AS taxRateId from taxRates WHERE `name` = "US Tax"), UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into accounts (accountHolderId, name, address, currencyId, taxRateId, updated, created) VALUES ( (SELECT id AS accountHolderId from accountHolders WHERE `name` = "Jim Davies") , "Philadelphia All stars", "200 Centre Avenue", (SELECT id AS currencyId from currencies WHERE `name` = "US DOLLAR"), (SELECT id AS taxRateId from taxRates WHERE `name` = "US Tax"), UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into accounts (accountHolderId, name, address, currencyId, taxRateId, updated, created) VALUES ( (SELECT id AS accountHolderId from accountHolders WHERE `name` = "Michael Rupert") , "Kelowna  Brother", "200 Centre Avenue", (SELECT id AS currencyId from currencies WHERE `name` = "Canadian DOLLAR"), (SELECT id AS taxRateId from taxRates WHERE `name` = "Canadian Tax"), UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into accounts (accountHolderId, name, address, currencyId, taxRateId, updated, created) VALUES ( (SELECT id AS accountHolderId from accountHolders WHERE `name` = "Michael Rupert") , "Surrey  Buy Buy Buy", "200 Centre Avenue", (SELECT id AS currencyId from currencies WHERE `name` = "Canadian DOLLAR"), (SELECT id AS taxRateId from taxRates WHERE `name` = "Canadian Tax"), UNIX_TIMESTAMP(), UNIX_TIMESTAMP());
INSERT into accounts (accountHolderId, name, address, currencyId, taxRateId, updated, created) VALUES ( (SELECT id AS accountHolderId from accountHolders WHERE `name` = "Michael Rupert") , "Victoria  Shop Shop", "200 Centre Avenue", (SELECT id AS currencyId from currencies WHERE `name` = "Canadian DOLLAR"), (SELECT id AS taxRateId from taxRates WHERE `name` = "Canadian Tax"), UNIX_TIMESTAMP(), UNIX_TIMESTAMP());



-- create transactions table and seed data
CREATE TABLE `transactions` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `accountId` int(11) DEFAULT NULL,
  `details` varchar(500) DEFAULT NULL,
  `paymentOrProduct` enum('payment','product') DEFAULT 'product',
  `amount` decimal(8,2) DEFAULT NULL,
  `date` DATE DEFAULT NULL,
  `updated` int(11) DEFAULT NULL,
  `created` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
ALTER TABLE accountHolders ADD `currencyId` int(11) DEFAULT 0;

ALTER TABLE accountHolders ADD `taxRateId` int(11) DEFAULT 0;


UPDATE accountHolders AS ah
JOIN accounts AS a ON a.accountHolderId = ah.id 
SET ah.currencyId = a.currencyId, ah.taxRateId = a.taxRateId;


ALTER TABLE accounts ADD `type` enum('tax','revenue','payment','commission') DEFAULT 'payment';

ALTER TABLE accounts DROP COLUMN currencyId;
ALTER TABLE accounts DROP COLUMN taxRateId;
ALTER TABLE accounts DROP COLUMN name;
ALTER TABLE accounts DROP COLUMN address;


INSERT into accountHolders (name, jobTitle, currencyId, taxRateId,updated, created) VALUES ( "Company", "", (SELECT id AS currencyId from currencies WHERE `name` = "US DOLLAR"), (SELECT id AS taxRateId from taxRates WHERE `name` = "US Tax"), UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

ALTER TABLE transactions DROP COLUMN paymentOrProduct;


DELETE FROM transactions;
DELETE  FROM accounts;

INSERT into accounts (id, updated, created, type)  VALUES (null, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), "payment") ;
INSERT into accounts (id, updated, created, type)  VALUES (null, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), "revenue") ;
INSERT into accounts (id, updated, created, type)  VALUES (null, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), "tax") ;
INSERT into accounts (id, updated, created, type)  VALUES (null, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), "commission") ;

ALTER TABLE accounts DROP COLUMN accountHolderId;

rename Table accounts TO accountTypes;

ALTER TABLE transactions ADD `accountTypeId` int not null;

ALTER TABLE transactions ADD `accountHolderId` int not null;

ALTER TABLE transactions DROP COLUMN accountId;