package DB;
use DBI;
use XML::Simple;
use Smart::Comments;

our @ISA = qw(Exporter);
our @EXPORT = qw/db_update/;
our @EXPORT_OK = qw/db_update/;

$DB::VERSION = '1.0.0';


$| = 1;

my $xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><!-- eminfo postdata start --><eminfo_postdata><eminfo_id>752148030</eminfo_id><eminfo_gname>dev_bbklab.net</eminfo_gname><eminfo_jobid>sKR5Bmyr</eminfo_jobid><eminfo_jobts>1381128986</eminfo_jobts><eminfo_plugin_config><basic><name>test</name><enable>yes</enable><comment>Just a Test Plugin</comment><frequency>3min</frequency><exec_tmout>1min</exec_tmout><maxerr_times>1</maxerr_times><take_snapshot_type> crit warn unkn tmout </take_snapshot_type><mail_notify_type> crit warn unkn tmout </mail_notify_type><post_notify_type> crit warn unkn succ tmout </post_notify_type><mail_receviers>zhangguangzheng\@eyou.net</mail_receviers><attach_snap_mail>yes</attach_snap_mail><auto_handle_type>none </auto_handle_type><auto_handler>default_handler</auto_handler><debug>yes</debug></basic><userdef><user_defconf> test config value here</user_defconf></userdef></eminfo_plugin_config><eminfo_plugin_result><level>warn</level><type>str</type><body><title>summary </title><summary>title </summary><line size=\"10\" color=\"green\">green line</line><line size=\"8\" color=\"red\">red line</line><line size=\"9\">new line </line></body></eminfo_plugin_result><eminfo_autohandle_result><line size=\"38\">auto handle is disabled. Nothing to do</line></eminfo_autohandle_result><additional></additional></eminfo_postdata><!-- eminfo postdata end -->";
my %dbconn=( dbhost=>'127.0.0.1', dbport=>'3306', database=>'eminfo', dbuser=>'eminfo', dbpass=>'eminfo' );
&db_update('postlog',$xml,%dbconn);

# Update message in db-backend
# Usage: 	&db_update( {xml_text}  %{db_server_conf} )
# Example:	my %dbconn=( dbhost=>'127.0.0.1', dbport=>'3306', database=>'eminfo', dbuser=>'eminfo', dbpass=>'eminfo' );
# 		&db_update('postlog',"{xml postlog content}", %dbconn);
#
sub db_update {
  my $table = shift;
  my $text = shift;
  my %db_conf = @_;
  ### $table
  ### $text
  ### %db_conf

  return undef if (!%db_conf || !$text || !$table);
  return undef if ($table ne 'heartbeat' && $table ne 'postlog');
  
  my $dbhost = $db_conf{'dbhost'} || '127.0.0.1';
  my $dbport = $db_conf{'dbport'} || '3306';
  my $database = $db_conf{'database'} || 'eminfo';
  my $dbuser = $db_conf{'dbuser'} || 'eminfo';
  my $dbpass = $db_conf{'dbpass'} || 'eminfo';
  my $dbcharset = $db_conf{'$dbcharset'} || 'utf8';
  ### $dbhost
  ### $dbport
  ### $database
  ### $dbuser
  ### $dbpass
  ### $dbcharset

  my $result = '';

  my ($connect, $sql);
  $connect = DBI->connect(
	"DBI:mysql:database=$database;host=$dbhost;port=$dbport",
	"$dbuser",
	"$dbpass",
	{ RaiseError => 0, PrintError => 0, AutoCommit => 1 },
  ); 
  unless ($connect) {
	print "connect mysql error: [",DBI->errstr,"]\n";
	return undef;
  }

  unless ($connect->do("set names $dbcharset;")) {
	print "set names $dbcharset error: [",DBI->errstr,"]\n";
	return undef;
  }

  my ($eminfo_id, $plugin); 
  if ($table eq 'postlog') {
	my $xml = XMLin($text);
	$eminfo_id = $xml->{'eminfo_id'};
	$plugin = $xml->{'eminfo_plugin_config'}->{'basic'}->{'name'};
	### $xml
	### $eminfo_id
	### $plugin
  } elsif ($table eq 'heartbeat') {
	$text =~ m/eminfo_id\s*=\s*(\w+)\s+/i;
	$eminfo_id = $1;
  }

  if ($table eq 'postlog') {
  	$sql=$connect->prepare("select count(*) from $table where id='$eminfo_id' and plugin='$plugin';");
  } elsif ($table eq 'heartbeat') {
	$sql=$connect->prepare("select count(*) from $table where id='$eminfo_id';");
  }
  unless ($sql->execute()) {
	print "sql error: [",DBI->errstr,"]\n";
	return undef;
  }

  my $num=($sql->fetchrow_array())[0];
  ### $num

  if ($num >= 1) {  # update
	if ($table eq 'postlog') {
		$sql=$connect->prepare("update $table set content='$text', time=UNIX_TIMESTAMP() where id='$eminfo_id' and plugin='$plugin';");
	} elsif ($table eq 'heartbeat') {
		$sql=$connect->prepare("update $table set content='$text', time=UNIX_TIMESTAMP() where id='$eminfo_id';");
	}
  } else {	    # insert
	if ($table eq 'postlog') {
		$sql=$connect->prepare("insert $table (id,time,plugin,content) values ('$eminfo_id',UNIX_TIMESTAMP(),'$plugin','$text');");
	} elsif ($table eq 'heartbeat') {
		$sql=$connect->prepare("insert $table (id,time,content) values ('$eminfo_id',UNIX_TIMESTAMP(),'$text');");
	}
  }
  unless ($sql->execute()) {
	print "sql error: [",DBI->errstr,"]\n";
	return undef;
  }

  $sql->finish();
  $connect->disconnect();

}

1;
