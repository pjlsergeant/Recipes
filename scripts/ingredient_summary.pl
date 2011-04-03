#!perl

use strict;
use warnings;

use YAML::Syck;
use Data::Rx;
use Template;
use Recipe::Ingredient;

my $template_file = join '', (<DATA>);
my $template = Template->new();

my $obj = Recipe::Ingredient->new( @ARGV );

$template->process( \$template_file, { i => $obj } ) || die $template->error();

__DATA__
Name    : [% i.name %]
Quantity: [% i.quantity %] [% i.serving_units %]
Calories: [% i.calories %] kcal (calculated: [% i.calories_calculated %] kcal)

           	Protein		Fat		Carbs
     Grams:	[% i.protein %]		[% i.fat %]		[% i.carbs %]
  Calories:	[% i.calories_from('protein') %]		[% i.calories_from('fat') %]		[% i.calories_from('carbs') %]
% Calories:	[% i.percentage_calories_from('protein') %]		[% i.percentage_calories_from('fat') %]		[% i.percentage_calories_from('carbs') %]

