package Recipe::Ingredient;

use strict;
use warnings;
use Moose;
use File::Slurp;
use YAML::XS;

my %calories_per_gram = (
	fat     => 9,
	protein => 4,
	carbs   => 4
);

for (qw/name serving_units/) {
	has $_ => ( is => 'ro', isa => 'Str', required => 1 );
}

for (qw/
	serving_size
	protein
	fat
	carbs
	calories
	quantity
	/) {
	has $_ => ( is => 'rw', isa => 'Num', required => 1 );
}

around BUILDARGS => sub {
	my ($orig, $class, $file, $quantity) = @_;

	die "You must provide me an ingredient key" unless $file;

	my $filename = "ingredients/$file.yaml";
	my $file_content = read_file( $filename ) || die "Can't read [$filename]";

	my $data = Load( $file_content );
	$data->{'quantity'} = $quantity;

	return $data;
};

sub BUILD {
	my ( $self ) = @_;
	my $ratio = $self->quantity / $self->serving_size;

	$self->$_( $self->$_ * $ratio ) for qw(protein fat carbs calories);
}

sub calories_calculated {
	my $self = shift;
	my $count = 0;
	$count += $self->calories_from( $_ ) for qw(protein fat carbs);
	return $count;
}

sub calories_from {
	my ( $self, $part ) = @_;
	return $self->$part * $calories_per_gram{ $part };
}

sub percentage_calories_from {
	my ( $self, $part ) = @_;
	my $calories = $self->$part * $calories_per_gram{ $part };
	my $total_calories = $self->calories_calculated;
	return 0 unless $total_calories;
	return int( (100 * ( $calories / $total_calories ) ) + 0.5 );
}

1;