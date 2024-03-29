package Math::ParseUnit::Parser;

use strict;
use warnings;

use Marpa::XS;
use Data::Dumper;

use Math::ParseUnit::Tokenizer qw/tokenize/;

use parent 'Exporter';
our @EXPORT_OK = qw/parse/;

my $grammar = Marpa::XS::Grammar->new({
  start => 'EXPRESSION',
  actions => 'Math::ParseUnit::ParserActions',
  default_action => 'default_action',
  rules => [
    ['EXPRESSION', [qw/MULT_RES/]],

    ['EXP_ARG', [qw/BGROUP MULT_RES EGROUP/]],

    {lhs => 'MULT_RES', rhs => [qw/MULT_ARG/], action => 'mult_op', min => 1, separator => 'MULT_OP', keep => 1},

    ['EXP_RES', [qw/EXP_ARG EXP_OP INTEGER/], 'exp_op'],
    ['EXP_RES', [qw/EXP_ARG NUM_EXP_OP/], 'exp_op'],
    ['MULT_ARG', [qw/EXP_RES/]],
    ['MULT_ARG', [qw/EXP_ARG/]],

    ['EXP_ARG', [qw/NUMBER/], 'quantity_from_number'],
    ['EXP_ARG', [qw/WORD/], 'quantity_from_word'],
    ['NUMBER', [qw/INTEGER/]],
  ],
});

$grammar->precompute;

sub parse {
  my $input = shift;
  my $tokens = tokenize( $input );

  my $recce = Marpa::XS::Recognizer->new( { grammar => $grammar } );
  
  foreach my $token (@$tokens) {
    my $res = $recce->read(@$token);
    unless (defined $res) {
      ruby_slippers( $recce, $token )
        or die "Barfed on token @$token";
    }
  }

  my $return = [];
  while (defined( my $value = $recce->value )) {
    push @$return, $$value;
  }

  return $return;
}

sub ruby_slippers {
  my ($recce, $token, $possible) = @_;

  $possible ||= $recce->terminals_expected();

  # implicit multiplication
  if (grep { $_ eq 'MULT_OP'} @$possible) {
    $recce->read('MULT_OP', '*');
  } else {
    return 0;
  }

  $possible = $recce->terminals_expected();

  if (grep { $_ eq $token->[0] } @$possible) {
    my $res = $recce->read(@$token);
  } else {
    return ruby_slippers($recce, $token, $possible);
  }

  return 1;
}

package Math::ParseUnit::ParserActions;

use strict;
use warnings;

use Math::ParseUnit::Quantity;
use Scalar::Util 'looks_like_number';

use Data::Dumper;

sub default_action { 
  my (undef, $first, $second) = @_;

  return $first if defined $first;

  return $second;
}
sub concat {shift; return join('', @_) }

sub quantity_from_word {
  my (undef, $word) = @_;

  my $quant = Math::ParseUnit::Quantity->new(1, {$word => 1});

  return $quant;
}

sub quantity_from_number {
  my (undef, $num) = @_;

  my $quant = Math::ParseUnit::Quantity->new($num, {});

  return $quant;
}

sub mult_op {
  shift;
  my $ql = shift;
  while (@_) {
    my ($op, $qr) = (shift, shift);

    #print STDERR Dumper [$ql, $op, $qr];

    if ( $op eq '*' ) {
      $ql->mult($qr);
    } else {
      $ql->div($qr);
    }

  }

  return $ql;

}

sub exp_op {
  my (undef, $quant, $op, $num) = @_;

  # allow NUM_EXP_OP whose op value is a number
  if (looks_like_number $op) {
    $num = $op;
  }

  $quant->pow($num);

  return $quant;
}

1;

