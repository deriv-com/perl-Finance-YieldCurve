package Finance::YieldCurve;
# ABSTRACT: Handles interpolation on yield curves for interest rates and dividends

use strict;
use warnings;

our $VERSION = '0.001';

=head1 NAME

Finance::YieldCurve - provides methods for interpolation on interest rates or dividends

=head1 SYNOPSIS

 use Finance::YieldCurve;

 my $rates = Finance::YieldCurve->new(
  data => {
   1  => 0.014,
   7  => 0.011,
   14 => 0.012,
  },
 );
 # For dividends, we return the closest value with no interpolation
 my $rate = $interest_rates->find_closest_to(7 * 24 * 60 * 60);
 # For interest rates, we interpolate linearly between the points
 my $rate = $interest_rates->interpolate(7 * 24 * 60 * 60);

=head1 DESCRIPTION

Handles interpolation methods for different types of yield curve.

Instantiate with a set of data points, then use either the L</find_closest_to>
or L</interpolate> methods to find the appropriate value for a given time (measured
in years).

=cut

use Moo;

use Math::Function::Interpolator;

=head1 ATTRIBUTES

=head2 data

The data points, as a hashref of days => value.

=cut

has data => (
    is => 'ro'
);

=head1 METHODS

=head2 interpolate

Get the interpolated rate for this yield curve over the given time period (fractional years).

Example:

 my $rate = $curve->interpolate(7 * 24 * 60 * 60);

=cut

sub interpolate {
    my ($self, $tiy) = @_;

    # timeinyears cannot be undef
    $tiy ||= 0;

    my $interp = Math::Function::Interpolator->new(points => $self->data);
    return $interp->linear($tiy * 365) / 100;
}

=head2 find_closest_to

Returns the closest point to the request value.

Example:

 my $rate = $curve->find_closest_to(7 * 24 * 60 * 60);

=cut

sub find_closest_to {
    my ($self, $tiy) = @_;

    # If we have undef or zero, bail out early
    return 0 unless $tiy;

    # Handle discrete dividend
    my ($nearest_yield_days_before, $nearest_yield_before) = (0, 0);
    my $days_to_expiry = $tiy * 365.0;
    my $rates = $self->data;
    my @sorted_expiries = sort { $a <=> $b } keys(%$rates);
    foreach my $day (@sorted_expiries) {
        if ($day <= $days_to_expiry) {
            $nearest_yield_days_before = $day;
            $nearest_yield_before      = $rates->{$day};
            next;
        }
        last;
    }

    # Re-annualize
    my $discrete_points = $nearest_yield_before * $nearest_yield_days_before / 365;

    return $discrete_points * 365 / ($days_to_expiry * 100);
}

1;
