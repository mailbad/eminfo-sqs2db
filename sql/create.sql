
--
-- Database: `eminfo_server`
--


-- --------------------------------------------------------

--
-- Table structure for table `dbversion`
--
CREATE TABLE IF NOT EXISTS `dbversion` (
  `name` varchar(10) character NOT NULL default '',
  `version` varchar(10) character NOT NULL default ''
) ENGINE=MyISAM;

--
-- Table structure for table `eminfo_heartbeat`
--

--
-- Table structure for table `eminfo_postlog`
--

--
-- Table structure for table `hosts`
--
CREATE TABLE IF NOT EXISTS `hosts` (
  `eminfo_id` varchar(16) NOT NULL default '',
  `eminfo_name` varchar(128) NOT NULL default '',
  `eminfo_alias` varchar(128) NOT NULL default '',
  `display_name` varchar(64) NOT NULL default '',
) ENGINE=MyISAM;

--
-- Table structure for table `host_groups`
--

--
-- Table structure for table `host_group_members`
--

--
-- Table structure for table `host_plugins`
--

--
-- Table structure for table `plugin_configs`
--

--
-- Table structure for table `plugin_status`
--

--
-- Table structure for table `plugin_status_log`
--


