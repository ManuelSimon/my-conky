#!/usr/bin/perl
#Script Name: howLong.pl
#Author: Nathan Handler <nhandler @ubuntu.com>
 
use strict;
use warnings;
use Date::Manip;
 
my $target=$ARGV[0] || "June 22, 2013";
my $delta = DateCalc(ParseDate("now"),ParseDate($target),1);
 
$delta=~s/^[+-]//;
my($y,$m,$w,$d,$h,$min,$s) = split(/:/,$delta,7);

$y = sprintf("%02d", $y);
$m = sprintf("%02d", $m);
$w = sprintf("%02d", $w);
$d = sprintf("%02d", $d);
$h = sprintf("%02d", $h);
$min = sprintf("%02d", $min);
$s = sprintf("%02d", $s);
 
print $y . "y " if($y>0);
print $m . "m " if($m>0);
print $w . "w " if($w>0);
print $d . "d " if($d>0);
print "$h:$min:$s" if($h>0||$min>0||$s>0);</nhandler>
