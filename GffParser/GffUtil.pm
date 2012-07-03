package GffUtil;

use strict;
use warnings;
use Moose;
use namespace::autoclean;


has 'gff' => (isa => 'Bio::Tools::GFF', is => 'rw', required => 1);

#the "_chromsome_size" below will hold the chromosome lengths
has '_chromsome_size' => (
      traits    => ['Hash'],
      is        => 'ro',
      isa       => 'HashRef[Str]',
      default   => sub { {} },
      handles   => {
          _set_chromosome_size  => 'set',
          _get_chromosome_size  => 'get',
          _get_chromosome_names => 'keys'
      }
);


#BUILD is executed after the "new" it will fill up a hash with keys being the 
#chromosome names and values the end position (i.e. the length of the chromosome)
sub BUILD {
    my ($self, $args) = @_;
    
    my $gff = $args->{gff};
    while (my $bio_locatable_seq = $gff->next_segment) {
        $self->_set_chromosome_size($bio_locatable_seq->id, $bio_locatable_seq->end);
    }
}


#Given a feature, return its strand and frame
sub return_frame_and_strand_of_feature {
    my ($self, $feature_object) = @_;
    
    my $feature_strand = $feature_object->strand;
    my $feature_chromosome = $feature_object->seq_id;
    my $feature_start_position = $feature_object->start;
    
    my $feature_frame; #we need to calculate this, see below
    
    
    ##############################################
    #Calculate the frame of the feature using its strand and position info and the chromosome size
    ##############################################
    
    
    #This is a feature on the forward strand.
    if ($feature_strand == 1) 
    {
        #the frame is simply modulo 3 of the observed position
        $feature_frame = $feature_start_position % 3;
    }
    #This is a feature on the reverse complement strand
    elsif ($feature_strand == -1) 
    {
        #the frame is module 3 of "(chromosome_size - start_position_of_the_feature) modulo 3"
        $feature_frame = ($self->_get_chromosome_size($feature_chromosome) - $feature_start_position) % 3;
    }
    #This should not happen.
    else {
        $feature_frame = $feature_start_position % 3;
    }
    
    return ($feature_strand, $feature_frame);
    
}

1;

__PACKAGE__->meta->make_immutable;
