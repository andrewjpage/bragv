use strict;
use warnings;
use Bio::Tools::GFF;
use JSON;

my $gffio = Bio::Tools::GFF->new(-file => $ARGV[0] , -gff_version => 3);
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