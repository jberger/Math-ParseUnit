package Math::ParseUnit;

use strict;
use warnings;

use Marpa::XS;
use Data::Dumper;

use Math::ParseUnit::Tokenizer qw/tokenize/;

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
    my ($op, $qr);# = (shift, shift);
    if ($_[0] =~ m#\*|/#) {
      $op = shift;
    } else {
      $op = '*';
    }

    $qr = shift;

    #print STDERR Dumper [$ql, $op, $qr];

    my $is_mult = $op eq '*';

    while ( my ($unit, $power) = each %{ $qr->{units} } ) {
      $ql->{units}{$unit} += $is_mult ? $power : - $power;
    }

    if ($qr->{value}) {
      $ql->{value} *= $is_mult ? $qr->{value} : ( 1 / $qr->{value} );
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

  #print STDERR Dumper [$quant, $op, $num];

  #if ($num > 1) {
    foreach my $unit (keys %{ $quant->{units} }) {
      #print STDERR "$unit: $num\n";
      $quant->{units}{$unit} *= $num;
    }
    $quant->{value} **= $num;
  #} elsif ($num > 0) {
  #  foreach my $unit (keys %{ $quant->{units} }) {
  #    $quant->{units}{$unit} /= -$num;
  #  }
  #  $quant->{value} **= $num;
  #} else {
  #  $quant->{value} = 1;
  #  $quant->{units} = {};
  #}

  #print STDERR Dumper \$quant;

  return $quant;
}

1;

