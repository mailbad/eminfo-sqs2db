package DB;
use DBI;
use XML::Simple;
# use Smart::Comments;

our @ISA = qw(Exporter);
our @EXPORT = qw/db_update/;
our @EXPORT_OK = qw/db_update/;

$DB::VERSION = '1.0.0';


$| = 1;

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

  my ($eminfo_id, $eminfo_name, $plugin, $level, $summary); 
  if ($table eq 'postlog') {
	my $xml = XMLin($text);
	$eminfo_id = $xml->{'eminfo_id'};
	$eminfo_name = $xml->{'eminfo_gname'};
	$plugin = $xml->{'eminfo_plugin_config'}->{'basic'}->{'name'};
	$level = $xml->{'eminfo_plugin_result'}->{'level'};
	$summary = $xml->{'eminfo_plugin_result'}->{'body'}->{'summary'};
	### $xml
	### $eminfo_id
	### $eminfo_name
	### $plugin
	### $level
	### $summary
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
		$sql=$connect->prepare("update $table set content='$text', name='$eminfo_name', level='$level', summary='$summary', time=UNIX_TIMESTAMP() where id='$eminfo_id' and plugin='$plugin';");
	} elsif ($table eq 'heartbeat') {
		$sql=$connect->prepare("update $table set content='$text', time=UNIX_TIMESTAMP() where id='$eminfo_id';");
	}
  } else {	    # insert
	if ($table eq 'postlog') {
		$sql=$connect->prepare("insert $table (id,name,time,plugin,level,summary,content) values ('$eminfo_id','$eminfo_name',UNIX_TIMESTAMP(),'$plugin','$level','$summary','$text');");
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
