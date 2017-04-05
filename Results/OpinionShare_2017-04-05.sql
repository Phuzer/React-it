# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.7.12)
# Database: OpinionShare
# Generation Time: 2017-04-05 18:27:20 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table Matches
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Matches`;

CREATE TABLE `Matches` (
  `match_id` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `home` text NOT NULL,
  `visitor` text NOT NULL,
  `home_score` int(8) unsigned DEFAULT NULL,
  `visitor_score` int(8) unsigned DEFAULT NULL,
  `status` text NOT NULL,
  `home_abbr` text,
  `visitor_abbr` text,
  PRIMARY KEY (`match_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `Matches` WRITE;
/*!40000 ALTER TABLE `Matches` DISABLE KEYS */;

INSERT INTO `Matches` (`match_id`, `home`, `visitor`, `home_score`, `visitor_score`, `status`, `home_abbr`, `visitor_abbr`)
VALUES
	(1,'Sweden','Portugal',2,3,'Ended','SWE','POR'),
	(2,'Argentina','Chile',0,0,'Ended','ARG','CHI');

/*!40000 ALTER TABLE `Matches` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table Moments
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Moments`;

CREATE TABLE `Moments` (
  `moment_id` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(8) unsigned NOT NULL,
  `match_id` int(8) unsigned NOT NULL,
  `time` int(11) NOT NULL,
  `real_time` text NOT NULL,
  `multiple_users` tinyint(1) NOT NULL DEFAULT '0',
  `userTestNumber` int(11) NOT NULL,
  PRIMARY KEY (`moment_id`),
  KEY `user_id` (`user_id`),
  KEY `match_id` (`match_id`),
  CONSTRAINT `moments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`),
  CONSTRAINT `moments_ibfk_2` FOREIGN KEY (`match_id`) REFERENCES `Matches` (`match_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `Moments` WRITE;
/*!40000 ALTER TABLE `Moments` DISABLE KEYS */;

INSERT INTO `Moments` (`moment_id`, `user_id`, `match_id`, `time`, `real_time`, `multiple_users`, `userTestNumber`)
VALUES
	(794,120,1,31000,'00:25',0,1),
	(795,120,1,54000,'14:18',1,1),
	(796,120,1,81000,'35:24',1,1),
	(798,120,1,111000,'38:01',1,1),
	(799,121,1,163000,'44:21',1,1),
	(800,119,1,225000,'48:17',1,1),
	(801,119,1,268000,'49:43',1,1),
	(803,119,1,343000,'67:27',1,1),
	(806,120,1,409000,'68:41',1,1),
	(808,119,1,487000,'71:44',1,1),
	(810,119,1,540000,'76:17',1,1),
	(813,120,1,626000,'78:08',1,1),
	(815,120,1,703000,'91:27',0,1),
	(816,121,1,715000,'94:58',1,1),
	(817,120,1,727000,'95:10',1,1),
	(818,123,1,52000,'14:16',1,2),
	(820,123,1,110000,'38:00',0,2),
	(822,123,1,130000,'41:13',1,2),
	(824,123,1,192000,'47:43',0,2),
	(826,124,1,235000,'48:27',0,2),
	(828,123,1,249000,'48:41',1,2),
	(829,123,1,267000,'49:42',0,2),
	(831,122,1,342000,'67:26',1,2),
	(834,123,1,409000,'68:41',0,2),
	(835,123,1,451000,'70:25',1,2),
	(836,123,1,487000,'71:44',1,2),
	(837,123,1,539000,'76:16',1,2),
	(838,123,1,625000,'78:07',1,2),
	(840,123,1,702000,'91:26',0,2),
	(842,122,1,728000,'95:11',0,2),
	(843,127,1,55000,'14:19',1,3),
	(845,126,1,83000,'35:26',1,3),
	(846,128,1,114000,'38:04',1,3),
	(847,126,1,135000,'41:18',0,3),
	(848,128,1,158000,'44:16',1,3),
	(850,128,1,199000,'47:50',0,3),
	(851,127,1,226000,'48:18',1,3),
	(852,127,1,267000,'49:42',0,3),
	(857,127,1,341000,'67:25',1,3),
	(859,126,1,355000,'67:39',0,3),
	(860,126,1,361000,'67:45',0,3),
	(861,126,1,407000,'68:39',0,3),
	(866,128,1,495000,'71:52',1,3),
	(867,128,1,542000,'76:19',1,3),
	(868,126,1,550000,'76:27',0,3),
	(869,126,1,624000,'78:06',1,3),
	(870,128,1,630000,'78:12',1,3),
	(871,128,1,711000,'91:35',0,3),
	(872,126,1,719000,'95:02',1,3),
	(873,131,1,10000,'00:04',1,4),
	(874,131,1,34000,'00:28',0,4),
	(875,130,1,73000,'35:16',1,4),
	(876,130,1,115000,'38:05',1,4),
	(877,129,1,192000,'47:43',1,4),
	(878,129,1,226000,'48:18',0,4),
	(880,131,1,263000,'49:38',1,4),
	(881,131,1,294000,'50:09',1,4),
	(882,131,1,343000,'67:27',1,4),
	(885,131,1,538000,'76:15',1,4),
	(886,131,1,587000,'77:29',1,4),
	(887,131,1,626000,'78:08',1,4),
	(888,130,1,708000,'91:32',1,4),
	(889,131,1,727000,'95:10',1,4),
	(890,133,1,53000,'14:17',1,5),
	(892,132,1,85000,'35:28',0,5),
	(893,133,1,112000,'38:02',1,5),
	(894,132,1,135000,'41:18',1,5),
	(895,132,1,160000,'44:18',0,5),
	(896,133,1,194000,'47:45',1,5),
	(897,132,1,230000,'48:22',1,5),
	(898,133,1,267000,'49:42',1,5),
	(900,133,1,343000,'67:27',1,5),
	(901,134,1,416000,'68:48',1,5),
	(902,132,1,491000,'71:48',1,5),
	(903,133,1,538000,'76:15',1,5),
	(904,134,1,548000,'76:25',1,5),
	(905,133,1,625000,'78:07',1,5),
	(908,134,1,646000,'78:28',0,5),
	(909,134,1,709000,'91:33',1,5),
	(910,134,1,727000,'95:10',0,5),
	(911,135,1,26000,'00:20',1,6),
	(912,135,1,50000,'14:14',0,6),
	(914,135,1,82000,'35:25',1,6),
	(915,137,1,88000,'35:31',0,6),
	(916,137,1,115000,'38:05',1,6),
	(917,135,1,137000,'41:20',1,6),
	(919,135,1,160000,'44:18',0,6),
	(920,136,1,182000,'47:33',0,6),
	(922,135,1,225000,'48:17',0,6),
	(924,135,1,267000,'49:42',1,6),
	(926,137,1,299000,'50:14',0,6),
	(927,136,1,342000,'67:26',1,6),
	(929,135,1,400000,'68:32',1,6),
	(930,136,1,411000,'68:43',0,6),
	(932,136,1,489000,'71:46',1,6),
	(933,136,1,519000,'72:16',0,6),
	(934,136,1,533000,'76:10',1,6),
	(935,137,1,547000,'76:24',0,6),
	(937,135,1,624000,'78:06',1,6),
	(938,137,1,630000,'78:12',0,6),
	(942,135,1,703000,'91:27',0,6),
	(943,137,1,713000,'91:37',0,6),
	(944,135,1,722000,'95:05',1,6),
	(946,139,1,52000,'14:16',0,7),
	(947,139,1,112000,'38:02',1,7),
	(948,139,1,193000,'47:44',1,7),
	(949,139,1,228000,'48:20',0,7),
	(950,138,1,271000,'49:46',1,7),
	(951,139,1,344000,'67:28',1,7),
	(952,138,1,544000,'76:21',1,7),
	(953,138,1,629000,'78:11',1,7),
	(954,138,1,706000,'91:30',0,7),
	(955,141,1,53000,'14:17',1,8),
	(956,141,1,88000,'35:31',0,8),
	(957,141,1,111000,'38:01',1,8),
	(958,141,1,154000,'44:12',0,8),
	(959,140,1,199000,'47:50',0,8),
	(960,141,1,227000,'48:19',1,8),
	(961,141,1,271000,'49:46',0,8),
	(962,140,1,343000,'67:27',1,8),
	(963,140,1,414000,'68:46',0,8),
	(964,141,1,447000,'70:21',0,8),
	(965,141,1,489000,'71:46',0,8),
	(966,140,1,539000,'76:16',1,8),
	(967,141,1,628000,'78:10',1,8),
	(968,140,1,704000,'91:28',0,8),
	(969,142,1,80000,'35:23',0,9),
	(970,143,1,114000,'38:04',1,9),
	(971,143,1,157000,'44:15',0,9),
	(972,143,1,233000,'48:25',0,9),
	(973,143,1,270000,'49:45',1,9),
	(974,143,1,348000,'67:32',0,9),
	(975,143,1,489000,'71:46',1,9),
	(976,143,1,541000,'76:18',1,9),
	(977,142,1,624000,'78:06',0,9),
	(978,142,1,701000,'91:25',1,9),
	(979,147,1,7000,'00:01',1,10),
	(980,147,1,42000,'14:06',1,10),
	(981,148,1,97000,'35:40',1,10),
	(982,148,1,116000,'38:06',1,10),
	(983,147,1,188000,'47:39',0,10),
	(984,147,1,220000,'48:12',0,10),
	(985,148,1,240000,'48:32',1,10),
	(986,148,1,270000,'49:45',1,10),
	(987,148,1,348000,'67:32',1,10),
	(988,147,1,409000,'68:41',0,10),
	(989,147,1,469000,'70:43',0,10),
	(990,148,1,496000,'71:53',1,10),
	(991,147,1,535000,'76:12',0,10),
	(992,148,1,556000,'76:33',1,10),
	(993,147,1,625000,'78:07',1,10),
	(994,147,1,702000,'91:26',0,10),
	(995,147,1,723000,'95:06',0,10),
	(996,149,1,111000,'38:01',1,11),
	(997,150,1,159000,'44:17',1,11),
	(998,150,1,192000,'47:43',0,11),
	(999,149,1,267000,'49:42',1,11),
	(1000,149,1,422000,'68:54',1,11),
	(1001,149,1,459000,'70:33',0,11),
	(1002,150,1,488000,'71:45',1,11),
	(1003,149,1,540000,'76:17',1,11),
	(1004,149,1,670000,'78:52',0,11),
	(1005,149,1,706000,'91:30',1,11),
	(1006,151,1,81000,'35:24',1,12),
	(1007,152,1,112000,'38:02',0,12),
	(1008,152,1,269000,'49:44',1,12),
	(1009,152,1,349000,'67:33',0,12),
	(1010,152,1,496000,'71:53',0,12),
	(1011,151,1,650000,'78:32',0,12),
	(1012,151,1,704000,'91:28',0,12),
	(1013,153,1,86000,'35:29',0,13),
	(1014,153,1,194000,'47:45',0,13),
	(1015,153,1,625000,'78:07',0,13),
	(1016,153,1,707000,'91:31',0,13);

/*!40000 ALTER TABLE `Moments` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table Responses
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Responses`;

CREATE TABLE `Responses` (
  `response_id` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `moment_id` int(8) unsigned DEFAULT NULL,
  `user_id` int(8) unsigned DEFAULT NULL,
  `opinion` text NOT NULL,
  `emotion` text NOT NULL,
  `heartrate` text,
  `userTestNumber` int(11) NOT NULL,
  PRIMARY KEY (`response_id`),
  KEY `moment_id` (`moment_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `responses_ibfk_1` FOREIGN KEY (`moment_id`) REFERENCES `Moments` (`moment_id`),
  CONSTRAINT `responses_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `Responses` WRITE;
/*!40000 ALTER TABLE `Responses` DISABLE KEYS */;

INSERT INTO `Responses` (`response_id`, `moment_id`, `user_id`, `opinion`, `emotion`, `heartrate`, `userTestNumber`)
VALUES
	(159,794,120,'down','angry','',1),
	(160,795,120,'up','connected','',1),
	(161,795,121,'down','unhappy','',1),
	(162,795,119,'up','surprise','',1),
	(163,796,120,'up','angry','',1),
	(164,796,121,'up','connected','',1),
	(165,796,119,'up','surprise',NULL,1),
	(166,798,120,'down','angry','',1),
	(167,798,119,'up','surprise',NULL,1),
	(168,799,121,'down','worry','',1),
	(169,799,119,'up','connected',NULL,1),
	(170,800,119,'down','worry','',1),
	(171,800,120,'up','connected','',1),
	(172,801,119,'up','elation','',1),
	(173,801,120,'up','elation','',1),
	(174,801,121,'up','elation','',1),
	(176,803,119,'down','unhappy','',1),
	(177,803,120,'down','angry','',1),
	(178,803,121,'down','angry','',1),
	(181,806,120,'down','worry','',1),
	(182,806,119,'up','connected','',1),
	(183,806,121,'up','elation','',1),
	(186,808,119,'down','angry','',1),
	(187,808,120,'down','angry','',1),
	(188,808,121,'down','angry','',1),
	(191,810,119,'up','elation','',1),
	(192,810,121,'up','connected','',1),
	(194,810,120,'up','elation',NULL,1),
	(196,813,120,'up','elation','',1),
	(197,813,119,'up','elation','',1),
	(198,813,121,'up','elation',NULL,1),
	(200,815,120,'up','connected','',1),
	(201,816,121,'down','worry','',1),
	(202,817,120,'up','connected','',1),
	(203,817,121,'up','elation','',1),
	(205,817,119,'up','elation',NULL,1),
	(206,816,119,'up','surprise',NULL,1),
	(207,818,123,'up','unhappy','',2),
	(208,818,124,'up','connected','',2),
	(209,818,122,'up','connected','',2),
	(211,820,123,'down','angry','',2),
	(212,820,122,'down','angry','',2),
	(213,822,123,'up','connected','',2),
	(214,822,122,'up','connected','',2),
	(215,822,124,'up','connected','',2),
	(217,820,124,'up','connected',NULL,2),
	(218,824,123,'down','unhappy','',2),
	(219,824,122,'down','angry','',2),
	(221,826,124,'down','angry','',2),
	(222,826,122,'up','worry','',2),
	(223,828,123,'down','worry','',2),
	(224,829,123,'up','elation','',2),
	(225,829,124,'up','elation','',2),
	(226,828,122,'up','elation',NULL,2),
	(227,831,122,'down','worry','',2),
	(228,831,123,'down','angry','',2),
	(230,831,124,'down','angry','',2),
	(232,834,123,'down','worry','',2),
	(236,835,123,'down','worry','',2),
	(237,836,123,'down','unhappy','',2),
	(238,836,122,'down','unhappy',NULL,2),
	(239,837,123,'up','elation','',2),
	(240,837,124,'up','elation','',2),
	(241,837,122,'up','elation',NULL,2),
	(242,835,124,'down','unhappy',NULL,2),
	(243,838,123,'up','elation','',2),
	(244,838,124,'up','elation','',2),
	(245,838,122,'up','connected','',2),
	(248,840,123,'up','surprise','',2),
	(249,840,122,'down','unhappy','',2),
	(250,840,124,'up','connected','',2),
	(251,842,122,'up','elation','',2),
	(253,843,127,'down','angry','',3),
	(254,843,126,'up','connected','',3),
	(255,843,128,'up','connected','',3),
	(256,845,126,'down','angry','',3),
	(257,845,128,'up','connected','',3),
	(258,846,128,'up','connected','',3),
	(259,846,126,'up','unhappy','',3),
	(260,847,126,'down','worry','',3),
	(261,846,127,'up','unhappy',NULL,3),
	(262,848,128,'up','worry','',3),
	(263,848,126,'down','unhappy','',3),
	(264,848,127,'up','connected',NULL,3),
	(266,850,128,'up','unhappy','',3),
	(267,851,127,'up','worry','',3),
	(268,851,128,'up','worry','',3),
	(269,852,127,'up','elation','',3),
	(270,851,126,'up','elation','',3),
	(271,852,128,'up','elation','',3),
	(272,852,126,'up','elation','',3),
	(278,857,127,'down','unhappy','',3),
	(279,857,126,'down','angry','',3),
	(281,857,128,'down','angry','',3),
	(282,859,126,'down','surprise','',3),
	(283,860,126,'down','worry','',3),
	(285,861,126,'down','worry','',3),
	(286,861,127,'down','angry','',3),
	(289,866,127,'down','angry','',3),
	(290,866,126,'down','unhappy','',3),
	(291,866,128,'down','angry','',3),
	(295,867,128,'up','elation','',3),
	(296,867,126,'up','connected','',3),
	(297,868,126,'up','elation','',3),
	(298,869,126,'up','elation','',3),
	(299,869,127,'up','elation','',3),
	(300,870,128,'up','connected','',3),
	(301,870,126,'up','elation','',3),
	(302,870,127,'up','elation',NULL,3),
	(303,871,128,'up','connected','',3),
	(304,872,126,'up','connected','',3),
	(305,872,127,'up','surprise',NULL,3),
	(306,873,131,'up','connected','',4),
	(307,874,131,'up','elation','',4),
	(308,873,129,'up','angry',NULL,4),
	(309,875,130,'up','connected','',4),
	(310,875,129,'up','unhappy',NULL,4),
	(311,875,131,'up','surprise',NULL,4),
	(312,876,130,'down','angry','',4),
	(313,876,129,'down','angry','',4),
	(314,876,131,'up','connected',NULL,4),
	(315,877,129,'down','angry','',4),
	(316,877,130,'down','unhappy','',4),
	(317,878,129,'up','surprise','',4),
	(318,878,130,'down','worry','',4),
	(319,880,131,'up','elation','',4),
	(321,880,129,'up','elation',NULL,4),
	(322,881,131,'up','connected','',4),
	(323,881,129,'up','connected',NULL,4),
	(324,882,131,'down','unhappy','',4),
	(325,882,129,'down','angry',NULL,4),
	(326,882,130,'up','connected','',4),
	(329,885,131,'up','connected','',4),
	(330,885,130,'up','elation','',4),
	(331,885,129,'up','elation',NULL,4),
	(332,886,131,'up','worry','',4),
	(333,887,131,'up','connected','',4),
	(334,886,129,'up','elation',NULL,4),
	(335,887,129,'up','connected',NULL,4),
	(336,888,130,'down','surprise','',4),
	(337,889,131,'up','elation','',4),
	(338,888,129,'up','elation',NULL,4),
	(339,889,129,'up','angry',NULL,4),
	(340,890,133,'up','connected','',5),
	(341,890,132,'up','angry','',5),
	(342,892,132,'down','angry','',5),
	(343,890,134,'down','connected',NULL,5),
	(344,893,133,'down','angry','',5),
	(345,893,132,'down','angry','',5),
	(347,894,132,'up','connected','',5),
	(348,893,134,'down','angry',NULL,5),
	(349,895,132,'up','elation','',5),
	(350,894,134,'down','elation',NULL,5),
	(351,894,133,'down','surprise',NULL,5),
	(352,896,133,'down','unhappy','',5),
	(353,896,134,'up','surprise','',5),
	(354,896,132,'down','surprise','',5),
	(355,897,132,'up','connected','',5),
	(356,897,133,'up','worry','',5),
	(357,897,134,'up','worry',NULL,5),
	(358,898,133,'up','elation','',5),
	(359,898,134,'up','connected','',5),
	(360,898,132,'up','connected','',5),
	(361,900,133,'down','angry','',5),
	(362,900,134,'down','angry','',5),
	(364,900,132,'up','connected',NULL,5),
	(365,901,134,'up','elation','',5),
	(366,901,133,'up','worry',NULL,5),
	(367,901,132,'up','angry',NULL,5),
	(368,902,132,'up','connected','',5),
	(369,902,133,'up','surprise','',5),
	(370,902,134,'down','angry',NULL,5),
	(371,903,133,'up','connected','',5),
	(372,904,134,'up','connected','',5),
	(373,903,134,'up','connected',NULL,5),
	(374,904,132,'down','surprise',NULL,5),
	(375,905,133,'up','elation','',5),
	(376,905,132,'up','connected','',5),
	(377,905,134,'up','connected','',5),
	(379,908,134,'up','connected','',5),
	(381,909,134,'down','surprise','',5),
	(382,909,133,'down','angry','',5),
	(383,910,134,'up','connected','',5),
	(384,909,132,'up','worry',NULL,5),
	(385,911,135,'down','angry','',6),
	(386,912,135,'up','connected','',6),
	(387,912,137,'down','unhappy','',6),
	(388,911,136,'down','connected',NULL,6),
	(389,914,135,'up','connected','',6),
	(390,915,137,'down','unhappy','',6),
	(391,916,137,'down','angry','',6),
	(392,916,135,'down','unhappy','',6),
	(393,914,136,'up','elation',NULL,6),
	(399,917,135,'up','connected','',6),
	(400,917,136,'down','worry','',6),
	(401,919,135,'down','worry','',6),
	(403,920,136,'up','elation','',6),
	(404,920,135,'down','surprise','',6),
	(405,922,135,'up','connected','',6),
	(407,922,137,'up','worry','',6),
	(411,924,135,'up','elation','',6),
	(412,924,137,'up','connected','',6),
	(413,924,136,'up','elation','',6),
	(415,926,137,'up','elation','',6),
	(416,927,136,'down','unhappy','',6),
	(417,927,135,'down','unhappy','',6),
	(418,927,137,'down','unhappy','',6),
	(419,929,135,'down','worry','',6),
	(420,930,136,'up','surprise','',6),
	(421,930,137,'down','worry','',6),
	(422,929,136,'up','surprise',NULL,6),
	(424,932,136,'down','angry','',6),
	(425,932,135,'down','unhappy','',6),
	(426,932,137,'down','angry','',6),
	(427,933,136,'down','angry','',6),
	(428,934,136,'up','elation','',6),
	(429,934,135,'up','elation','',6),
	(430,935,137,'up','connected','',6),
	(431,935,136,'down','worry','',6),
	(432,937,135,'up','elation','',6),
	(433,937,136,'up','elation','',6),
	(434,938,137,'up','connected','',6),
	(436,938,136,'up','connected','',6),
	(437,938,135,'up','connected','',6),
	(439,942,135,'down','surprise','',6),
	(440,943,137,'up','surprise','',6),
	(441,944,135,'up','elation','',6),
	(442,944,136,'up','elation','',6),
	(444,946,139,'up','connected','',7),
	(445,947,139,'down','angry','',7),
	(446,947,138,'down','unhappy','',7),
	(447,948,139,'down','surprise','',7),
	(448,948,138,'down','surprise','',7),
	(449,949,139,'up','connected','',7),
	(450,950,138,'up','connected','',7),
	(451,950,139,'up','elation','',7),
	(452,951,139,'down','unhappy','',7),
	(453,951,138,'down','unhappy','',7),
	(454,952,138,'up','elation','',7),
	(455,952,139,'up','connected','',7),
	(456,953,138,'up','connected','',7),
	(457,953,139,'up','connected','',7),
	(458,954,138,'down','surprise','',7),
	(459,955,141,'up','connected','',8),
	(460,955,140,'down','elation','',8),
	(461,956,141,'down','unhappy','',8),
	(462,957,141,'down','worry','',8),
	(463,957,140,'down','surprise','',8),
	(464,958,141,'up','surprise','',8),
	(465,959,140,'down','surprise','',8),
	(466,960,141,'up','elation','',8),
	(467,960,140,'up','connected','',8),
	(468,961,141,'up','connected','',8),
	(469,962,140,'down','angry','',8),
	(470,962,141,'down','angry','',8),
	(471,963,140,'up','elation','',8),
	(472,964,141,'down','angry','',8),
	(473,965,141,'down','surprise','',8),
	(474,966,140,'up','connected','',8),
	(475,966,141,'up','elation','',8),
	(476,967,141,'up','connected','',8),
	(477,967,140,'up','elation','',8),
	(478,968,140,'down','angry','',8),
	(479,969,142,'up','connected','',9),
	(480,970,143,'down','surprise','',9),
	(481,970,142,'down','angry','',9),
	(482,971,143,'up','connected','',9),
	(483,972,143,'up','connected','',9),
	(484,973,143,'up','connected','',9),
	(485,973,142,'up','elation','',9),
	(486,974,143,'down','unhappy','',9),
	(487,975,143,'down','angry','',9),
	(488,975,142,'down','surprise','',9),
	(489,976,143,'up','angry','',9),
	(490,976,142,'up','surprise','',9),
	(491,977,142,'up','connected','',9),
	(492,978,142,'down','angry','',9),
	(493,978,143,'down','surprise',NULL,9),
	(496,979,148,'down','elation',NULL,10),
	(497,981,148,'up','connected','',10),
	(498,981,147,'up','elation','',10),
	(499,982,148,'up','connected','',10),
	(500,982,147,'up','connected',NULL,10),
	(501,983,147,'up','surprise','',10),
	(502,984,147,'down','worry','',10),
	(503,985,148,'up','connected','',10),
	(504,986,148,'up','elation','',10),
	(505,986,147,'up','elation','',10),
	(506,985,147,'down','angry',NULL,10),
	(507,987,148,'down','angry','',10),
	(508,987,147,'down','unhappy',NULL,10),
	(509,988,147,'down','surprise','',10),
	(510,989,147,'down','worry','',10),
	(511,990,148,'down','angry','',10),
	(512,990,147,'down','unhappy',NULL,10),
	(513,991,147,'up','connected','',10),
	(514,992,148,'up','connected','',10),
	(515,992,147,'up','elation',NULL,10),
	(516,993,147,'up','connected','',10),
	(517,993,148,'up','connected','',10),
	(518,994,147,'down','angry','',10),
	(519,995,147,'up','connected','',10),
	(520,979,147,'down','worry','',10),
	(521,980,147,'down','elation','',10),
	(522,996,149,'down','worry','',11),
	(523,996,150,'down','angry','',11),
	(524,997,150,'up','connected','',11),
	(525,997,149,'up','connected','',11),
	(526,998,150,'down','unhappy','',11),
	(527,999,149,'up','connected','',11),
	(528,999,150,'up','elation','',11),
	(529,1000,149,'down','connected','',11),
	(530,1000,150,'down','elation','',11),
	(531,1001,149,'down','angry','',11),
	(532,1002,150,'up','connected','',11),
	(533,1002,149,'down','unhappy','',11),
	(534,1003,149,'up','elation','',11),
	(535,1003,150,'up','connected','',11),
	(536,1004,149,'up','connected','',11),
	(537,1005,149,'down','surprise','',11),
	(538,1005,150,'down','angry','',11),
	(539,1006,151,'up','connected','',12),
	(540,1006,152,'up','surprise',NULL,12),
	(541,1007,152,'down','angry','',12),
	(542,1008,152,'up','elation','',12),
	(543,1008,151,'up','elation','',12),
	(544,1009,152,'down','unhappy','',12),
	(545,1010,152,'down','angry','',12),
	(546,1011,151,'up','connected','',12),
	(547,1012,151,'down','surprise','',12),
	(548,1013,153,'down','angry','',13),
	(549,1014,153,'down','surprise','',13),
	(550,1015,153,'up','surprise','',13),
	(551,1016,153,'down','unhappy','',13);

/*!40000 ALTER TABLE `Responses` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table Users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `Users`;

CREATE TABLE `Users` (
  `user_id` int(8) unsigned NOT NULL AUTO_INCREMENT,
  `first_name` text NOT NULL,
  `last_name` text NOT NULL,
  `device_token` text,
  `avatar` text NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

LOCK TABLES `Users` WRITE;
/*!40000 ALTER TABLE `Users` DISABLE KEYS */;

INSERT INTO `Users` (`user_id`, `first_name`, `last_name`, `device_token`, `avatar`, `active`)
VALUES
	(119,'Joao','Silva','35ABB712A5B47A92EF3F922097CC74EEC06BCE587449D6D0A03050BBB888DAEF','man1',0),
	(120,'Gabriel','Marcondes','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man3',0),
	(121,'Mr','Potato','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man4',0),
	(122,'Carla','Nave','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','woman1',0),
	(123,'Bruno','Medinas','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man3',0),
	(124,'Raquel','Lucas','35ABB712A5B47A92EF3F922097CC74EEC06BCE587449D6D0A03050BBB888DAEF','woman1',0),
	(126,'João','Matos','35ABB712A5B47A92EF3F922097CC74EEC06BCE587449D6D0A03050BBB888DAEF','man1',0),
	(127,'1234','1234','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man3',0),
	(128,'Iris','Fidalgo','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','woman3',0),
	(129,'Pedro','Rio','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man1',0),
	(130,'Joao','Oliveira','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man3',0),
	(131,'Giuliano','Ragusa','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man4',0),
	(132,'Rui','Pinguinhas','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man4',0),
	(133,'Mauro','Chande','35ABB712A5B47A92EF3F922097CC74EEC06BCE587449D6D0A03050BBB888DAEF','man4',0),
	(134,'Paulo','Faripa','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man4',0),
	(135,'Eduardo','Dias','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man4',0),
	(136,'José','Venâncio','35ABB712A5B47A92EF3F922097CC74EEC06BCE587449D6D0A03050BBB888DAEF','man1',0),
	(137,'Mario','Franco','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man3',0),
	(138,'João','Pedro','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man1',0),
	(139,'Ana','12','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','woman4',0),
	(140,'Joao','Romao','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man4',0),
	(141,'Diogo','Oliveira','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man2',0),
	(142,'Duarte','Cruz','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man3',0),
	(143,'Ivan','Cruz','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man1',0),
	(147,'Pedro','Albuquerque Santos','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man2',0),
	(148,'Francisco','Nunes','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man4',0),
	(149,'Joao','Rodrigo','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man1',0),
	(150,'Pedro','Fixolas','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man3',0),
	(151,'Senhor','daProzis','7A2E5440CD2F3AC543ECCFE2E94FB9B62909B33CC57F35BD01E235ADD46F4B60','man2',0),
	(152,'Joel','Santos','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man4',0),
	(153,'Mario','Mario','8FE646B99778B3EDDF53BB46843C55567814A187F9F377CFC2A0F4B9F883B1B8','man1',1);

/*!40000 ALTER TABLE `Users` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
