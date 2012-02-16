use strict;
use warnings;

use Test::More;

use Math::ParseUnit::Parser qw/parse/;
use Math::ParseUnit::Quantity;

use Data::Dumper;

my @tests = (
  # individual terms
  ['-1.6e-19' => ['-1.6e-19', {}         ]],
  ['C'        => ['1',        { C => 1 } ]],

  # split value and unit
  ['-1.6e-19 C' => ['-1.6e-19', { C => 1 } ]],

  # handle different constructs for division
  ['-9.8 kg m / s / s'      => [ '-9.8', { kg => 1, 'm' => 1, 's' => -2} ]],
  ['-9.8 kg m / ( s ** 2 )' => [ '-9.8', { kg => 1, 'm' => 1, 's' => -2} ]],
  ['-9.8 kg m / s ** 2'     => [ '-9.8', { kg => 1, 'm' => 1, 's' => -2} ]],
);

foreach my $test (@tests) {
  my ($str, $spec) = @$test;

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

