# Imports
use warnings;
use strict;
use File::Find;
use Text::CSV;
use JSON;
use Storable qw(retrieve thaw fd_retrieve);
use List::MoreUtils qw(uniq);
use Data::Clean::JSON qw(clean_json_in_place clone_and_clean_json);
use Data::Structure::Util qw(unbless);
use Data::Diver qw(Dive);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use Compress::Zlib qw(memGunzip);
use File::Slurp;

# The first argument is a directory path
my $directory = $ARGV[0];
die "Not a dir\n" unless -d $directory;

# Remaining arguments are fields to extract
# print STDERR scalar @ARGV[1 .. $#ARGV];
die "Need to extract at least one field!\n" unless scalar @ARGV > 1;
my @column_names = ();
my @paths = ();
foreach my $input(@ARGV[1 .. $#ARGV]){
  my @split = split(/:/, $input);
  die "Each field must consist of a path separated by a field name with a colon (:)\n" unless scalar @split == 2;
  push(@column_names, $split[1]);
  push(@paths, $split[0]);
}

# CSV Writer
my $csv = Text::CSV->new({
  quote_char => undef
});
# All lines of the CSV
my @lines = ();
# Store unzipped files here
# my ($temp_fh, $temp_filename) = tempfile();

# Iterate over each file recursively
find(\&process, $directory);

# Remove duplicates; add header
@lines = uniq(@lines);
$csv->combine(@column_names);
unshift(@lines, $csv->string());
print(join("\n", @lines));

sub process {
  my $zip_file = $_;
  # Ensure file is not a directory and it's just a pure .gz file (not .txt), and it isn't a reg or var file
  return if ($zip_file !~ /\.gz$/) || (-d $zip_file) || ($zip_file =~ /reg\.gz|var\.gz/);

  # Each file consists of a hash with only one key (%root).
  # This key corresponds to the chromosome (e.g. '3', 'X' etc.)
  # Presumably this is because cache was one large hash that has been divided into multiple files
  # The value of each hash entry is an array of genes (@genes)
  my $file;
  # print "SUCCEEDED!" . $zip_file;
  # my $input = read_file($zip_file);
  # # print $input; exit;
  # my $output = memGunzip($input);
  # print $output; exit;
  # my $gz = gzopen($zip_file, "rb");
  gunzip($zip_file, \$file);
  # print ($file); exit;

  # Compress::Zlib::memGunzip($buffer)
  # gunzip($zip_file => \$file);
  # print $file; exit 0;
  my %root = %{thaw($file)};#%{thaw($file)};
  my $key = (keys %root)[0]; #Take the first key since it's the only one in this file
  my @transcripts = @{$root{$key}};

  # For each gene, add a row of the CSV to @lines
  foreach my $transcript (@transcripts){
    my @columns = ();

    foreach my $path(@paths){
      my $value = Dive($transcript, split(/\./, $path));
      unbless($value);
      clean_json_in_place($value);
      push(@columns, JSON::to_json($value, {allow_nonref => 1}));
    }
    # print STDERR scalar @paths;
    $csv->combine(@columns);
    push(@lines, $csv->string());
  }
}
