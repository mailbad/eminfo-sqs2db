package CONFIG;
# use Smart::Comments;

our @ISA = qw(Exporter);
our @EXPORT = qw/conf_read/;
our @EXPORT_OK = qw/conf_read/;

$CONFIG::VERSION = '1.0.0';

$| = 1;

# Read value by [section].key 
# Example: 	print &conf_read('db','user');
#
sub conf_read {
  my ($section, $key, $file) = @_;
  return undef if (!$section || !$key);
  $file = "/usr/local/eminfo-sqs2db/conf/sqs2db.ini" if !$file;

  ### file: $file
  ### section: $section
  ### key: $key

  unless (open FH, "<$file") {
	return undef;
  }

  my $result = '';
  my $flag = 0;
  while (<FH>) {
	if (m/\A\s*\[\s*($section)\s*\]\s*\Z/) {
		$flag = 1;
		next;
	}
 	if (m/\A\s*\[\s*(\w+)\s*\]\s*\Z/) {
		last if $flag == 1;
	}
	if (m/\A\s*$key\s*=\s*(.+)\s*\Z/) {
		if ($flag == 1) {
			$result = $1;
			last;
		}
	}
  }

  ### result: $result
  return $result;
}

1;
