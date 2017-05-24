package Finance::YieldCurve;
# ABSTRACT: Handles interpolation on yield curves for interest rates and dividends

use strict;
use warnings;

our $VERSION = '0.001';

=head1 NAME

Finance::YieldCurve

=head1 SYNOPSIS

 use Finance::YieldCurve;

 my $interest_rates = Finance::YieldCurve->new(
  data => {
   1  => 0.014,
   7  => 0.011,
   14 => 0.012,
  },
  # Either we pass a type:
  # type => 'dividend|yield',
  # or an interpolation:
  # type => 'closest|linear',
 );
 # or we select based on the method:
 my $rate = $interest_rates->find_closest_to(7 * 24 * 60 * 60);
 my $rate = $interest_rates->interpolate(7 * 24 * 60 * 60);

 my $dividends = Finance::YieldCurve->new(
  data => {
   1  => 0.025,
   7  => 0.025,
   14 => 0.028,
  }
 );
 my $rate = $dividends->rate_for(7 * 24 * 60 * 60);

=head1 DESCRIPTION

=cut


use Math::Function::Interpolator;

=head2 rate_for

Get the interpolated rate for this yield curve over the given time period (fractional years).

Example:

 my $rate = $curve->rate_for(7 * 24 * 60 * 60);

=cut

sub rate_for {
    my ($self, $tiy) = @_;

    # timeinyears cannot be undef
    $tiy ||= 0;

    my $interp = Math::Function::Interpolator->new(points => $self->rates);
    return $interp->linear($tiy * 365) / 100;
}

1;
