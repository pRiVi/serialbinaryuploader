#!/usr/bin/perl

use strict;
use warnings;

$| = 1;

my $filename     = $ARGV[0];
my $serialdevice = $ARGV[1];
my $pos          = $ARGV[2];
my $sleepvalue   = $ARGV[3] || 0.02;

unless ($filename && $serialdevice && $pos) {
   print $0.": <binaryfile> <serialdevice>\n";
   print "example: ".$0." ppcboot.bin /dev/ttyUSB0 0x40000\n"; 
   exit(1);
}

open(A, "<", $filename) || die("Error opening binaryfile: ".$!);
my $stat = [stat($filename)];
open(OUT, ">", $serialdevice) || die("Error opening serial file: ".$!);

my $i = 0;
my $out = 0;

print OUT "m ".$pos."\n";
while (my $in = sysread(A, my $buf, 1) == 1) {
   print OUT unpack("H2", $buf).($i ? "\n" : "");
   print $out++." of ".$stat->[7]." Bytes (".(int(($out/$stat->[7])*100)/100)."%)\r";
   if ($i++) {
      $i = 0;
      select(undef, undef,undef, $sleepvalue);
   }
}
print "\n";

