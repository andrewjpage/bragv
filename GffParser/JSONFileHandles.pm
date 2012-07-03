
package JSONFileHandles;
use Moose;


# required inputs
has 'six_frames'  => ( is => 'rw', isa => 'Bool',                        default   => 0 );
has 'input_filename' => ( is => 'rw', isa => 'Str',                        required   => 1 );

# outputs
has 'file_handles' => (is => 'rw', lazy => 1, builder => '_build_file_handles');


sub _build_file_handles
{
  my($self) = @_;
  my %output_file_handles;
  
  if(defined($self->six_frames) && $self->six_frames == 1)
  {
    $output_file_handles{1}{0} = $self->_open_file('p',0);
    $output_file_handles{1}{1} = $self->_open_file('p',1);
    $output_file_handles{1}{2} = $self->_open_file('p',2);
    $output_file_handles{-1}{0} = $self->_open_file('n',0);
    $output_file_handles{-1}{1} = $self->_open_file('n',1);
    $output_file_handles{-1}{2} = $self->_open_file('n',2);
  }
  else
  {
    $output_file_handles{1}{0} = $self->_open_file('all',"frames");
    $output_file_handles{1}{1} = $output_file_handles{1}{0} ;
    $output_file_handles{1}{2} = $output_file_handles{1}{0} ;
    $output_file_handles{-1}{0} = $output_file_handles{1}{0} ;
    $output_file_handles{-1}{1} = $output_file_handles{1}{0} ;
    $output_file_handles{-1}{2} = $output_file_handles{1}{0} ;
  }
  return \%output_file_handles;
}

sub _open_file
{
  my($self, $strand, $frame) = @_;
  my $file_handle;
  open($file_handle, "+>","".$self->input_filename."_".$strand."_".$frame.".json");
  return $file_handle;
}

1;
