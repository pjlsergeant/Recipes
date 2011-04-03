package Recipe::Recipe;

use strict;
use warnings;
use Moose;
use File::Slurp;
use Recipe::Ingredient;
use YAML::XS;

has 'name'   => ( is => 'ro', isa => 'Str', required => 1 );
has 'serves' => ( is => 'ro', isa => 'Int', required => 1 );
has 'directions'  => ( is => 'ro', isa => 'ArrayRef', required => 0 );
has 'ingredients' => ( is => 'ro', isa => 'Ref', required => 1 );
has 'otheringredients' => ( is => 'ro', isa => 'ArrayRef',
	default => sub {[]} );

around BUILDARGS => sub {
	my ($orig, $class, $file) = @_;

	die "You must provide me a recipe key" unless $file;

	my $filename = "recipes/$file.yaml";
	my $file_content = read_file( $filename ) || die "Can't read [$filename]";

	my $data = Load( $file_content );

	my @ingredients = map {
		Recipe::Ingredient->new( $_->{'key'}, $_->{'quantity'} );
	} @{$data->{'ingredients'}};
	$data->{'ingredients'} = \@ingredients;

	return $data;
};

sub calories {
	my $self = shift;
	my $count = 0;

	$count += $_->calories for @{ $self->ingredients };
	return $count / $self->serves;
}

sub calories_calculated {
	my $self = shift;
	my $count = 0;

	$count += $_->calories_calculated for @{ $self->ingredients };
	return $count / $self->serves;
}

sub grams_of {
	my ($self, $part) = @_;
	my $count = 0;

	$count += $_->$part for @{ $self->ingredients };
	return $count / $self->serves;
}

sub calories_from {
	my ($self, $part) = @_;
	my $count = 0;

	$count += $_->calories_from( $part ) for @{ $self->ingredients };
	return $count / $self->serves;
}

sub percentage_calories_from {
	my ($self, $part) = @_;

	my $count = $self->calories_from( $part );
	return int( (100 * ( $count / $self->calories_calculated ) ) + 0.5 );
}

sub round {
	my ( $self, $number, $digits ) = @_;

	# Deal with undefined numbers without generating warnings
	return 0 unless defined( $number );
	# Don't attempt to round if what we received isn't numeric
	return $number unless $number =~ m/^[\d\.\-]+$/;

	# Deal with different precisions
	$digits = 0 unless $digits;
	my $multiplier = 10 ** $digits;
	$number *= $multiplier;

	# Round up or down, depending on if number is positive or negative
	my $round = ($number < 0) ? -.5 : .5;
	$number = int($number + $round);

	# Return to starting multiplier
	$number /= $multiplier;
	if ( $number =~ m/\./ ) {
		$number =~ s/0+$//;
	}
	return $number;
}

sub pad {
	my ( $self, $count, $pad, $item ) = @_;
	my $diff = $count - length($item);
	if ( $diff > 0 ) {
		return ( $pad x $diff ) . $item;
	} else {
		return $item;
	}
}

1;