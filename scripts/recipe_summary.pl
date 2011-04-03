#!perl

use strict;
use warnings;

use Template;
use Recipe::Recipe;

my $obj = Recipe::Recipe->new( @ARGV );

my $template_file = join '', (<DATA>);
my $template = Template->new();

$template->process( \$template_file, { r => $obj } ) || die $template->error();
#$template->process( 'templates/page.tt', { r => $obj } ) || die $template->error();

__DATA__

Name  : [% r.name %]
Serves: [% r.serves %]

Stats:
	Calories : [% r.round(r.calories) %] kcal (calc: [% r.round(r.calories_calculated) %])
	% Fat    : [% r.pad(2, ' ', r.percentage_calories_from('fat')) %]% - [% r.pad(3, ' ', r.round(r.calories_from('fat'))) %] kcal - [% r.round( r.grams_of('fat') ) %]g
	% Protein: [% r.pad(2, ' ', r.percentage_calories_from('protein')) %]% - [% r.pad(3, ' ', r.round(r.calories_from('protein'))) %] kcal - [% r.round( r.grams_of('protein') ) %]g
	% Carbs  : [% r.pad(2, ' ', r.percentage_calories_from('carbs')) %]% - [% r.pad(3, ' ', r.round(r.calories_from('carbs'))) %] kcal - [% r.round( r.grams_of('carbs') ) %]g


    Cal  F%  P%  C% |  Ingredients:
    ----------------+[% FOREACH i = r.ingredients %]
    [% r.pad(3, ' ', r.round(i.calories_calculated) ) %] [% r.pad(3, ' ',  i.percentage_calories_from('fat') ) %] [% r.pad(3, ' ',  i.percentage_calories_from('protein') ) %] [% r.pad(3, ' ',  i.percentage_calories_from('carbs') ) %] |  [% i.quantity %][% i.serving_units %] [% i.name %][% END %]

[% IF r.directions %]Directions:

[% r.directions %]
[% END %]
