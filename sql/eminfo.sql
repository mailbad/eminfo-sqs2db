--
-- Database: `eminfo`
--

SET NAMES utf8;
-- USE eminfo;
-- GRANT SELECT,INSERT,UPDATE ON eminfo.* to eminfo@127.0.0.1 IDENTIFIED BY 'eminfo';
-- FLUSH PRIVILEGES;


-- --------------------------------------------------------

--
-- Table structure for table `dbversion`
--
DROP TABLE IF EXISTS `dbversion`;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `dbversion` (
  `name` varchar(30) NOT NULL,		-- dbname
  `version` varchar(30) NOT NULL 	-- dbversion
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `heartbeat`
--
DROP TABLE IF EXISTS `heartbeat`;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `heartbeat` (
  `id` varchar(10) NOT NULL,		-- eminfo id
  `time` int(11) NOT NULL,		-- upate time
  `content` varchar(128) NOT NULL,  	-- palmus content
  PRIMARY KEY (`id`)			-- primary key
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `heartbeat_archive`
--
DROP TABLE IF EXISTS `heartbeat_archive`;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `heartbeat_archive` (
  `logid` bigint(20) NOT NULL AUTO_INCREMENT,   -- unique log id
  `id` varchar(10) NOT NULL,            -- eminfo id
  `time` int(11) NOT NULL,              -- upate time
  `content` varchar(128) NOT NULL,      -- palmus content
  PRIMARY KEY (`logid`),		-- primary key
  KEY `ik_0` (`id`)			-- index
) ENGINE=MyISAM DEFAULT CHARSET=utf8;                   

--
-- Table structure for table `postlog`
--
DROP TABLE IF EXISTS `postlog`;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `postlog` (
  `id` varchar(10) NOT NULL,		-- eminfo id
  `name` varchar(64) NOT NULL,		-- eminfo name
  `time` int(11) NOT NULL,		-- update time
  `plugin` varchar(64) NOT NULL,  	-- plugin name
  `content` text NOT NULL,		-- xml output
  PRIMARY KEY (`id`,`plugin`),		-- primary key
  KEY `ik_0` (`id`)			-- index
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `postlog_archive`
--
DROP TABLE IF EXISTS `postlog_archive`;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `postlog_archive` (
  `logid` bigint(20) NOT NULL AUTO_INCREMENT, 	-- unique log id
  `id` varchar(10) NOT NULL,            -- eminfo id
  `name` varchar(64) NOT NULL,          -- eminfo name
  `time` int(11) NOT NULL,              -- update time
  `plugin` varchar(64) NOT NULL,        -- plugin name
  `content` text NOT NULL,              -- xml output
  PRIMARY KEY (`logid`),          	-- primary key
  KEY `ik_0` (`id`,`plugin`),		-- index
  KEY `ik_1` (`id`)                     -- index
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `hosts`
--
DROP TABLE IF EXISTS `hosts`;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `hosts` (
  `id` varchar(10) NOT NULL,            -- eminfo id   (trigger from: postlog.id)
  `name` varchar(64) NOT NULL,		-- eminfo name (trigger from: postlog.name)
  `alias` varchar(64) NOT NULL,		-- eminfo alias (set by administrator)
  PRIMARY KEY (`id`)			-- primary key
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `plugins`
--
DROP TABLE IF EXISTS `plugins`;
SET character_set_client = utf8;
CREATE TABLE IF NOT EXISTS `plugins` (
  `id` varchar(10) NOT NULL,            -- eminfo id   (trigger from: postlog.id)
  `plugin` varchar(64) NOT NULL,	-- plugin name (trigger from: postlog.plugin)
  `alias`  varchar(64) NOT NULL,	-- plugin alias (set by administrator)
  PRIMARY KEY (`id`)			-- primary key
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- Table structure for table `host_groups`
--

--
-- Table structure for table `host_group_members`
--

--
-- Table structure for table `plugin_configs`
--
