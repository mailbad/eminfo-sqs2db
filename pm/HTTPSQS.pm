package HTTPSQS;
use IO::Socket::SSL qw(debug0);   # debug0 ~ debug30
#use Smart::Comments;

our @ISA = qw(Exporter);
our @EXPORT = qw/sqs_get/;
our @EXPORT_OK = qw/sqs_get/;

$HTTPSQS::VERSION = '1.0.0';


$| = 1;

#my %config = ( host=>'127.0.0.1', port=>'1218' );
#my $result = &sqs_get("/?charset=utf-8&name=eminfo_postdata&auth=123qaz&opt=get", %config);
#print "$result\n";

# Get message from httpsqs
# Usage: 	&sqs_get( {request_string}  %{sqs_server_conf} )
# Example:	my %config=( host=>'127.0.0.1', port=>'1218' );
#		&sqs_get("/?charset=utf-8&name=eminfo_postdata&auth=123qaz&opt=get", %config);

sub sqs_get {
  my $query = shift;
  my %sqs_conf = @_;
  ### $query
  ### %sqs_conf

  return undef if (!%sqs_conf || !$query);

  my $result = '';

  my $connect = IO::Socket::SSL->new(
	'PeerAddr'		=> $sqs_conf{'host'} || '127.0.0.1',
	'PeerPort'		=> $sqs_conf{'port'} || 1218,
	'Timeout'		=> $sqs_conf{'tmout'} || 10,
	'SSL_verify_mode'	=> 'SSL_VERIFY_NONE',
	#'SSL_ca_path'		=> '/etc/ssl/certs',
  );
  unless ($connect) {
	# print "$!:$SSL_ERROR\n";
	close $connect;
	return undef;
  }

  my $request = "GET $query HTTP/1.1\r\n";
  $request .= "Host: $sqs_conf{'host'}\r\n";
  $request .= "Connection: close\r\n";
  $request .= "\r\n" ;
  ### $request

  print $connect $request;
  my $flag_header_end = 0;
  while (<$connect>) {
	if ($flag_header_end == 0) {
		$flag_header_end = 1 if (/\A\s*\Z/);
		next;
	} else {
		$result .= $_;
	}
  }

  return $result;
}

1;
