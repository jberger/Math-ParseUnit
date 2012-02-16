use strict;
use warnings;

use Test::More;

use Math::ParseUnit::Parser qw/parse/;
use Math::ParseUnit::Quantity;

use File::chdir;

use Data::Dumper;

my @tests = do {
  local $CWD;
  push @CWD, 't';
  do 'data.pl';
};

foreach my $test (@tests) {
  next unless @$test == 3;

  my ($str, undef, $spec) = @$test;

  my $res = parse($str);

  my $num_res = scalar @$res;
  is( $num_res, 1, qq/Parse of "$str" produces one result/ );

  #unless ($num_res == 1) {
  #  warn Dumper $res;
  #}

  my $quant = $res->[0];

  isa_ok( $quant, 'Math::ParseUnit::Quantity' );

  is_deeply(
    $quant, 
    Math::ParseUnit::Quantity->new(@$spec), 
    "Properly parses $str",
  );

  #print STDERR Dumper \$quant;
}


done_testing;

