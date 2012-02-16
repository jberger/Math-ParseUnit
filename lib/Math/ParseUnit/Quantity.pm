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

1;


