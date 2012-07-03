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

my %all_tracks;


my $nodes;
my $c = 1;
my %snp_sites;
open(IN, $file);
while(<IN>)
{
  chomp;
  my $line = $_;
  my @snp_details  = split(/\t/,$line);
  my $name = $snp_details[1];

  unless(defined($all_tracks{$name}))
  {
    my $details = {name => $name, chromosome_name => "",length => 0,strand => 1,frame => 0, features => []};
    $all_tracks{$name} = $details ;
  }
  
  push(@{$all_tracks{$name}{features}}, { s => $snp_details[0], e => $snp_details[0], n => "SNP", i =>  $c } );
  $c++;
}

my @snp_sites = values %all_tracks;

      my $jsontext = encode_json(\@snp_sites);
      open(my $fh, "+>", $file.".snps.json");
      print {$fh} $jsontext;
      close($fh);
