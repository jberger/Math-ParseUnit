package Math::ParseUnit::Quantity;

use strict;
use warnings;

sub new {
  my $class = shift;
  my ($value, $units) = @_;

  my $self = {
    value => $value || 1,
    units => {},
  };

  foreach my $unit (keys %$units) {
    $self->{units}{$unit} += $units->{$unit};
  }

  bless $self, $class;

  return $self;
}

sub value { return shift->{value} }
sub units { return shift->{units} }

sub mult {
  my $self = shift;
  my $other = $self->_check_other(shift);

  while ( my ($unit, $power) = each %{ $other->units } ) {
    $self->units->{$unit} += $power;
  }

  if ($other->value) {
    $self->{value} *= $other->value;
  }
}

sub div {
  my $self = shift;
  my $other = $self->_check_other(shift);
  $other->inverse;
  $self->mult($other);
}

sub pow {
  my $self = shift;
  my $num = shift;
  foreach my $unit (keys %{$self->units}) {
    $self->{units}->{$unit} *= $num;
  }
  $self->{value} **= $num;
}

sub inverse {
  my $self = shift;
  $self->pow(-1);
}

sub _check_other {
  my $self = shift;
  my $other = shift;
  if (eval{$other->isa(__PACKAGE__)}) {
    return $other;
  }

  die '_check_other cannot promote to full object yet';
}

1;


