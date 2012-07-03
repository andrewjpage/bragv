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
use GffUtil;
use Data::Dumper;

my($file, $mode, $help, $name );

GetOptions(
   'f|file=s'  => \$file,
   'm|six_frames'       => \$mode,
   'n|name=s'  => \$name,
   'h|help'                    => \$help,
    );

($file && (-e $file) && $name) or die <<USAGE;

Usage: $0
  -f|file         <file>
  -m|six_frames   <flag for six frames>
  -n|name         <track name>
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


my $gff_util = GffUtil->new(gff => $gffio);


my @all_tracks;


#create the  perl datastructure, sort by start position
my $nodes;
my $c = 1;

$gffio = Bio::Tools::GFF->new(-file => $file , -gff_version => 3);
while (my $bio_locatable_seq = $gffio->next_segment) {
  
  my $details = {name => $name, chromosome_name => $bio_locatable_seq->id,length => $bio_locatable_seq->end,strand => 1,frame => 0};
  push(@all_tracks, $details);
  $details = {name => $name, chromosome_name => $bio_locatable_seq->id,length => $bio_locatable_seq->end,strand => 1,frame => 1};
  push(@all_tracks, $details);
  $details = {name => $name, chromosome_name => $bio_locatable_seq->id,length => $bio_locatable_seq->end,strand => 1,frame => 2};
  push(@all_tracks, $details);
  $details = {name => $name, chromosome_name => $bio_locatable_seq->id,length => $bio_locatable_seq->end,strand => -1,frame => 0};
  push(@all_tracks, $details);
  $details = {name => $name, chromosome_name => $bio_locatable_seq->id,length => $bio_locatable_seq->end,strand => -1,frame => 1};
  push(@all_tracks, $details);
  $details = {name => $name, chromosome_name => $bio_locatable_seq->id,length => $bio_locatable_seq->end,strand => -1,frame => 2};
  push(@all_tracks, $details);

}

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
    

    my ($frame, $strand) = $gff_util->return_frame_and_strand_of_feature($feat);

    my $json_frame ;
    next if $strand == 0;
    if($mode == 0)
    {
       $strand = 1;
       $frame = 0;
    }
    
    my $feature_array = get_feature_array($strand, $frame, $feat->seq_id, \@all_tracks);
    push(@{$feature_array}, { s => $feat->start, e => $feat->end, n => $feat->primary_tag, i =>  $gene_id } );

}

open(OUT, "+>", $file.".json");
my $jsontext = encode_json(\@all_tracks);
print OUT $jsontext;

sub get_feature_array
{
  my($strand, $frame, $seq_id, $all_tracks) = @_;
  
  for my $track (@$all_tracks)
  {

    if($strand == $track->{strand} && $frame == $track->{frame} && $seq_id eq $track->{chromosome_name} )
    {
      unless(defined($track->{features}))
      {
        $track->{features} = [];
      }
      
      return $track->{features};
    }
  }
  return undef;
}
