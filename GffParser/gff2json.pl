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
    $c++;
    push(@$nodes, { s => $feat->start, e => $feat->end, n => $feat->primary_tag, i =>  $c } );
}


#convert to json and write to file
my $jsontext = to_json($nodes);
open(FHD, ">out.json.txt") or die $!;
print FHD $jsontext;
close FHD;