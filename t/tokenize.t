use strict;
use warnings;

use Test::More;

use Math::ParseUnit::Tokenizer qw/tokenize/;

use File::chdir;

my @tests = do {
  local $CWD;
  push @CWD, 't';
  do 'data.pl';
};

foreach my $test (@tests) {
  is_deeply(tokenize($test->[0]), $test->[1], "Properly tokenized $test->[0]");
}

done_testing;

