#!/usr/bin/env perl

$in_list = $ARGV[0];

open IL, $in_list;

while ($l = <IL>)
{
	chomp($l);
	$l =~ s/\.wav//;
	$trans = $l;
	#$trans =~ s/0/NO/g;
	#$trans =~ s/1/YES/g;
	#$trans =~ s/\_/ /g;
	#$trans =~ 's/.*_\(.*\)/\1/g'
	$trans =~ s/.*left/left/g;
	$trans =~ s/.*right/right/g;
	$trans =~ s/.*up/up/g;
	$trans =~ s/.*down/down/g;
	$trans =~ s/.*one/one/g;
	$trans =~ s/.*five/five/g;
	$trans =~ s/.*eight/eight/g;
	$trans =~ s/.*zero/zero/g;
	$trans =~ s/.*go/go/g;
	print "$l $trans\n";
}
