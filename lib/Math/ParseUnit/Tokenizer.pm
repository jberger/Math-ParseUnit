package Math::ParseUnit::Tokenizer;

use strict;
use warnings;

use parent 'Exporter';
our @EXPORT_OK = qw/tokenize/;

my $re_num = qr/
  [+-]?	        # opt sign
  (?:           ## require either
    \d+           # whole part
    |(?=\.\d+)    # or fractional part
  )
  (?:\.\d+)?    # opt decimal part
  (?:[Ee][+-]?\d+)? # opt exponent
/x;

sub _make_tokenizer {
  my $target = shift;
  return sub {
    TOKEN: {
      return ['INTEGER',    $1  ] if $target =~ /\G ([+-]?\d+(?![.Ee])) /gcx;
      return ['NUMBER',     $1  ] if $target =~ /\G ($re_num) /gcx;
      return ['EXP_OP',    '**' ] if $target =~ /\G (?: \*\* | \^ | (?:raised\s+)? to\s+the )/igcx;
      return ['NUM_EXP_OP', 2   ] if $target =~ /\G squared /igcx;
      return ['NUM_EXP_OP', 3   ] if $target =~ /\G cubed /igcx;
      return ['MULT_OP',   '*'  ] if $target =~ /\G (?: \* | x | times )/gcx;
      return ['MULT_OP',   '/'  ] if $target =~ m#\G (?: / | per | over | divided\s+by | divide(?:s)? | upon )#igcx;
      return ['BGROUP'          ] if $target =~ /\G \( | the\s+quantity /gcx;
      return ['EGROUP'          ] if $target =~ /\G \) | all /gcx;
      return ['WORD',      $1   ] if $target =~ /\G (\w+)/gcx;
      redo TOKEN                  if $target =~ /\G \s+ /gcx;
      return ['UNKNOWN',   $1   ] if $target =~ /\G (.) /gcx;
      return;
    }
  }
}

sub tokenize {
  my $target = shift;
  my $tokenizer = _make_tokenizer( $target );

  my $tokens = [];
  while (my $token = $tokenizer->()) {
    push @$tokens, $token;
  }

  return $tokens;
}

1;

