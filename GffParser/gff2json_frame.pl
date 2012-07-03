#!/usr/bin/env perl

=head1 NAME

rna_seq_expression

=head1 SYNOPSIS

=head1 DESCRIPTION

This script takes in an aligned sequence file (BAM) and a corresponding annotation file (GFF) and creates a spreadsheet with expression values.
The BAM must be aligned to the same reference that the annotation refers to.

=head1 CONTACT

path-help@sanger.ac.uk

=cut

use strict;
use warnings;
no warnings 'uninitialized';
use Bio::Tools::GFF;
use JSON;
use Getopt::Long;
use JSONFileHandles;


my($file, $mode, $help );

GetOptions(
   'f|file=s'  => \$file,
   'm|six_frames=s'       => \$mode,

   'h|help'                    => \$help,
    );

($file && (-e $file)) or die <<USAGE;

Usage: $0
  -f|file         <file>
  -m|six_frames   <flag for six frames>
  -h|help         <print this message>

produces a json file
USAGE

$mode ||= 0;
my $gffio = Bio::Tools::GFF->new(-file => $file , -gff_version => 3);
my $feature;
# loop over the input stream

my @feats;
while($feature = $gffio->next_feature()) {
    push(@feats, $feature);   
}
$gffio->close();



#create the  perl datastructure, sort by start position
my $nodes;
my $c = 1;
my %file_handles = %{JSONFileHandles->new(input_filename => $file, six_frames => $mode)->file_handles};
my %json_six_frames;
$json_six_frames{1}{0} = [];
$json_six_frames{1}{1} = [];
$json_six_frames{1}{2} = [];
$json_six_frames{-1}{0} = [];
$json_six_frames{-1}{1} = [];
$json_six_frames{-1}{2} = [];

foreach my $feat (sort {$a->start <=> $b->start} @feats) {
    next if !($feat->primary_tag eq 'CDS' ||   $feat->primary_tag eq 'polypeptide');
    
    my($gene_id, @junk);
    if($feat->has_tag('locus_tag'))
    {
      ($gene_id, @junk) = $feat->get_tag_values('locus_tag');
    }
    elsif($feat->has_tag('ID'))
    {
      ($gene_id, @junk) = $feat->get_tag_values('ID');
    }
    else
    {
      $gene_id = $c;
      $c++;
    }
    $gene_id =~ s/^"|"$//g;    
    

    my $strand = 1;
    my $frame = 0;
    my $json_frame ;
    next if $strand == 0;
    if($mode == 0)
    {
       $strand = 1;
       $frame = 0;
       
    }
    push(@{$json_six_frames{$strand}{$frame}}, { s => $feat->start, e => $feat->end, n => $feat->primary_tag, i =>  $gene_id } );

}

for my $strand ((0,1))
{
  for my $frame ((0,1,2))
  {
    if(defined($json_six_frames{$strand}{$frame}) && @{$json_six_frames{$strand}{$frame}} > 0)
    {
      my $jsontext = to_json($json_six_frames{$strand}{$frame});
      my $fh = $file_handles{$strand}{$frame};
      print {$fh} $jsontext;
    }
  }
}