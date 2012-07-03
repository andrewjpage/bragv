#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'uninitialized';
use Bio::Tools::GFF;
use JSON;
use Getopt::Long;
use JSONFileHandles;
use GffUtil;

my($file, $mode, $help );

GetOptions(
   'f|file=s'  => \$file,
   'h|help'                    => \$help,
    );

($file && (-e $file)) or die <<USAGE;

Usage: $0
  -f|file         <file>
  -h|help         <print this message>

produces a json file
USAGE

my $nodes;
my $c = 1;
my %snp_sites;
open(IN, $file);
while(<IN>)
{
  chomp;
  my $line = $_;
  my @snp_details  = split(/\t/,$line);
  
  push(@{$snp_sites{$snp_details[1]}}, { s => $snp_details[0], e => $snp_details[0], n => "SNP", i =>  $c } );
  $c++;
}

for my $lane_name (keys %snp_sites)
{
      my $jsontext = to_json($snp_sites{$lane_name});
      open(my $fh, "+>", $lane_name.".snps.json");
      print {$fh} $jsontext;
      close($fh);
}