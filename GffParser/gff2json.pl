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


my($file, $mode, $help );

GetOptions(
   'f|file=s'  => \$file,
   'm|six_frames=s'       => \$mode,

   'h|help'                    => \$help,
    );

($file && (-e $file)) or die <<USAGE;

Usage: $0
  -f|file         <file>
  -m|six_frames       <flag for six frames>
  -h|help                  <print this message>

produces a json file
USAGE


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
    
    push(@$nodes, { s => $feat->start, e => $feat->end, n => $feat->primary_tag, i =>  $gene_id } );
}


#convert to json and write to file
my $jsontext = to_json($nodes);
open(FHD, ">out.json.txt") or die $!;
print FHD $jsontext;
close FHD;

sub open_file_handles
{
  my($mode) = @_;
  my %output_file_handles ;
  
  # do six filehandles
  if(defined($mode))
  {
    open($output_file_handles{})
  }
  else
  {
    
  }
}

# takes in the coord and the strand
sub get_file_handle
{
  
}
