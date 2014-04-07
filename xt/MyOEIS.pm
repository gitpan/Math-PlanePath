# Copyright 2010, 2011, 2012, 2013, 2014 Kevin Ryde

# MyOEIS.pm is shared by several distributions.
#
# MyOEIS.pm is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the
# Free Software Foundation; either version 3, or (at your option) any later
# version.
#
# MyOEIS.pm is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this file.  If not, see <http://www.gnu.org/licenses/>.

package MyOEIS;
use strict;
use Carp;
use File::Spec;

# uncomment this to run the ### lines
# use Smart::Comments;

my $without;

sub import {
  shift;
  foreach (@_) {
    if ($_ eq '-without') {
      $without = 1;
    } else {
      die __PACKAGE__." unknown option $_";
    }
  }
}

sub read_values {
  my ($anum, %option) = @_;

  if ($without) {
    return;
  }

  my @bvalues;
  my $lo;
  my $filename;
  if (my $seq = eval { require Math::NumSeq::OEIS::File;
                       Math::NumSeq::OEIS::File->new (anum => $anum) }) {
    my $count = 0;
    if (($lo, my $value) = $seq->next) {
      push @bvalues, $value;
      while ((undef, $value) = $seq->next) {
        push @bvalues, $value;
      }
    }
    $filename = $seq->{'filename'};
  } else {
    my $error = $@;
    @bvalues = Math::OEIS::Stripped->anum_to_values($anum);
    if (! @bvalues) {
      MyTestHelpers::diag ("$anum not available: ", $error);
      return;
    }
    $filename = Math::OEIS::Stripped->filename;
  }

  my $desc = "$anum has ".scalar(@bvalues)." values";
  if (@bvalues) { $desc .= " to $bvalues[-1]"; }

  if (my $max_count = $option{'max_count'}) {
    if (@bvalues > $max_count) {
      $#bvalues = $option{'max_count'} - 1;
      $desc .= ", shorten to ".scalar(@bvalues)." values to $bvalues[-1]";
    }
  }

  if (my $max_value = $option{'max_value'}) {
    if ($max_value ne 'unlimited') {
      for (my $i = 0; $i <= $#bvalues; $i++) {
        if ($bvalues[$i] > $max_value) {
          $#bvalues = $i-1;
          if (@bvalues) {
            $desc .= ", shorten to ".scalar(@bvalues)." values to $bvalues[-1]";
          } else {
            $desc .= ", shorten to nothing";
          }
        }
      }
    }
  }
  MyTestHelpers::diag ($desc);

  return (\@bvalues, $lo, $filename);
}

# with Y reckoned increasing downwards
sub dxdy_to_direction {
  my ($dx, $dy) = @_;
  if ($dx > 0) { return 0; }  # east
  if ($dx < 0) { return 2; }  # west
  if ($dy > 0) { return 1; }  # south
  if ($dy < 0) { return 3; }  # north
}


# Search for a line in text file handle $fh.
# $cmpfunc is called &$cmpfunc($line) and it should do a
# comparison $target <=> $line so
#     0  if $target == $line
#    -ve if $target < $line  so $line is after the target
#    +ve if $target > $line  so $line is before the target
sub bsearch_textfile {
  my ($fh, $cmpfunc) = @_;
  my $lo = 0;
  my $hi = -s $fh;
  for (;;) {
    my $mid = ($lo+$hi)/2;
    seek $fh, $mid, 0
      or last;

    # skip partial line
    defined(readline $fh)
      or last; # EOF

    # position start of line
    $mid = tell($fh);
    if ($mid >= $hi) {
      last;
    }

    my $line = readline $fh;
    defined $line
      or last; # EOF

    my $cmp = &$cmpfunc ($line);
    if ($cmp == 0) {
      return $line;
    }
    if ($cmp < 0) {
      $lo = tell($fh);  # $line is before the target, advance $lo
    } else {
      $hi = $mid;       # $line is after the target, reduce $hi
    }
  }

  seek $fh, $lo, 0;
  while (defined (my $line = readline $fh)) {
    my $cmp = &$cmpfunc($line);
    if ($cmp == 0) {
      return $line;
    }
    if ($cmp > 0) {
      return undef;
    }
  }
  return undef;
}

sub compare_values {
  my %option = @_;
  require MyTestHelpers;
  my $anum = $option{'anum'} || croak "Missing anum parameter";
  my $func = $option{'func'} || croak "Missing func parameter";
  my ($bvalues, $lo, $filename) = MyOEIS::read_values
    ($anum,
     max_count => $option{'max_count'},
     max_value => $option{'max_value'});
  my $diff;
  if ($bvalues) {
    if (my $fixup = $option{'fixup'}) {
      &$fixup($bvalues);
    }
    my ($got,@rest) = &$func(scalar(@$bvalues));
    if (@rest) {
      croak "Oops, func return more than just an arrayref";
    }
    if (ref $got ne 'ARRAY') {
      croak "Oops, func return not an arrayref";
    }
    $diff = diff_nums($got, $bvalues);
    if ($diff) {
      MyTestHelpers::diag ("bvalues: ",join_values($bvalues));
      MyTestHelpers::diag ("got:     ",join_values($got));
    }
  }
  if (defined $Test::TestLevel) {
    require Test;
    local $Test::TestLevel = $Test::TestLevel + 1;
    Test::skip (! $bvalues, $diff, undef, "$anum");
  } elsif (defined $diff) {
    print "$diff\n";
  }
}

sub join_values {
  my ($aref) = @_;
  if (! @$aref) { return ''; }
  my $str = $aref->[0];
  foreach my $i (1 .. $#$aref) {
    my $value = $aref->[$i];
    if (! defined $value) { $value = 'undef'; }
    last if length($str)+1+length($value) >= 275;
    $str .= ',';
    $str .= $value;
  }
  return $str;
}

sub diff_nums {
  my ($gotaref, $wantaref) = @_;
  my $diff;
  for (my $i = 0; $i < @$gotaref; $i++) {
    if ($i > @$wantaref) {
      return "want ends prematurely pos=$i";
    }
    my $got = $gotaref->[$i];
    my $want = $wantaref->[$i];
    if (! defined $got && ! defined $want) {
      next;
    }
    if (defined $got != defined $want) {
      if (defined $diff) {
        return "$diff, and more diff";
      }
      $diff = "different pos=$i got=".(defined $got ? $got : '[undef]')
        ." want=".(defined $want ? $want : '[undef]');
    }
    unless ($got =~ /^[0-9.-]+$/) {
      if (defined $diff) {
        return "$diff, and more diff";
      }
      $diff = "not a number pos=$i got='$got'";
    }
    unless ($want =~ /^[0-9.-]+$/) {
      if (defined $diff) {
        return "$diff, and more diff";
      }
      $diff = "not a number pos=$i want='$want'";
    }
    if ($got != $want) {
      if (defined $diff) {
        return "$diff, and more diff";
      }
      $diff = "different pos=$i numbers got=$got want=$want";
    }
  }
  return $diff;
}

# counting from 1 for prime=2
sub ith_prime {
  my ($i) = @_;
  if ($i < 1) {
    croak "Oops, ith_prime() i=$i";
  }
  require Math::Prime::XS;
  my $to = 100;
  for (;;) {
    my @primes = Math::Prime::XS::primes($to);
    if (@primes >= $i) {
      return $primes[$i-1];
    }
    $to *= 2;
  }
}

sub grep_for_values_aref {
  my ($class, $aref) = @_;
  MyOEIS->grep_for_values(array => $aref);
}
sub grep_for_values {
  my ($class, %h) = @_;
  ### grep_for_values_aref() ...
  ### $class

  my $name = $h{'name'};
  if (defined $name) {
    $name = "$name: ";
  }

  my $values_aref = $h{'array'};
  if (@$values_aref == 0) {
    ### empty ...
    return "${name}no match empty list of values\n\n";
  }

  {
    my $join = $values_aref->[0];
    for (my $i = 1; $i <= $#$values_aref && length($join) < 50; $i++) {
      $join .= ','.$values_aref->[$i];
    }
    $name .= "match $join\n";
  }
  
  if (defined (my $value = constant_array(@$values_aref))) {
    return '';
    if ($value != 0) {
    return "${name}constant $value\n\n";
    }
  }

  if (defined (my $diff = constant_diff(@$values_aref))) {
    return "${name}constant difference $diff\n\n";
  }

  my $values_str = join (',',@$values_aref);

  # print "grep $values_str\n";
  # unless (system 'zgrep', '-F', '-e', $values_str, "$ENV{HOME}/OEIS/stripped.gz") {
  #   print "  match $values_str\n";
  #   print "  $name\n";
  #   print "\n"
  # }
  # unless (system 'fgrep', '-e', $values_str, "$ENV{HOME}/OEIS/oeis-grep.txt") {
  #   print "  match $values_str\n";
  #   print "  $name\n";
  #   print "\n"
  # }
  # unless (system 'fgrep', '-e', $values_str, "$ENV{HOME}/OEIS/stripped") {
  #   print "  match $values_str\n";
  #   print "  $name\n";
  #   print "\n"
  # }
  if (my $str = $class->stripped_grep($values_str)) {
    return "$name$str\n";
  }
}

use constant GREP_MAX_COUNT => 8;
my $stripped_mmap;
sub stripped_grep {
  my ($class, $str) = @_;

  if (! defined $stripped_mmap) {
    my $stripped_filename = Math::OEIS::Stripped->filename;
    require File::Map;
    File::Map::map_file ($stripped_mmap, $stripped_filename);
    print "File::Map stripped file length ",length($stripped_mmap),"\n";
  }

  my $ret = '';
  my $count = 0;

  # my $re = $str;
  # { my $count = ($re =~ s{,}{,(\n|}g);
  #   $re .= ')'x$count;
  # }
  # ### $re

  my $orig_str = $str;
  my $abs = '';
  foreach my $mung ('none', 'negate', 'abs', 'half', 'quarter', 'double') {
    if ($ret) { last; }

    if ($mung eq 'none') {

    }  elsif ($mung eq 'negate') {
      $abs = "[NEGATED]\n";
      $str = $orig_str;
      $str =~ s{(^|,)(-?)}{$1.($2?'':'-')}ge;

    } elsif ($mung eq 'half') {
      if ($str =~ /[13579](,|$)/) {
        ### not all even to halve ...
        next;
      }
      $str = join (',', map {$_/2} split /,/, $orig_str);
      $abs = "[HALF]\n";

    } elsif ($mung eq 'quarter') {
      if ($str =~ /[13579](,|$)/) {
        ### not all even to halve ...
        next;
      }
      $str = join (',', map {$_/2} split /,/, $orig_str);
      $abs = "[QUARTER]\n";

    } elsif ($mung eq 'double') {
      $str = join (',', map {$_*2} split /,/, $orig_str);
      $abs = "[DOUBLE]\n";

    } elsif ($mung eq 'abs') {
      $str = $orig_str;
      if (! ($str =~ s/-//g)) {
        ### no negatives to absolute ...
        next;
      }
      if ($str =~ /^(\d+)(,\1)*$/) {
        ### only one value when abs: $1
        next;
      }
      $abs = "[ABSOLUTE VALUES]\n";
    }
    ### $str

    my $pos = 0;
    for (;;) {
      my $found_pos = index($stripped_mmap,$str,$pos);
      ### $found_pos
      last if $found_pos < 0;

      unless (substr($stripped_mmap,$found_pos-1,1) =~ / |,/) {
        $pos = $found_pos+1;
        next;
      }

      if ($count >= GREP_MAX_COUNT) {
        $ret .= "... and more matches\n";
        return $ret;
      }

      my $start = rindex($stripped_mmap,"\n",$found_pos) + 1;
      my $end = index($stripped_mmap,"\n",$found_pos);
      my $line = substr($stripped_mmap,$start,$end-$start);
      my ($anum) = ($line =~ /^(A\d+)/);
      $anum || die "oops, A-number not matched in line: ",$line;

      my $name = Math::OEIS::Names->anum_to_name($anum);
      if (! defined $name) { $name = '[name not found]'; }
      $ret .= $abs; $abs = '';
      $ret .= "$anum $name\n";
      $ret .= "$line\n";

      $pos = $end;
      $count++;
    }
  }
  return $ret;
}

# constant_diff($a,$b,$c,...)
# If all the given values have a constant difference then return that amount.
# Otherwise return undef.
#
sub constant_diff {
  my $diff = shift;
  my $value = shift;
  $diff = $value - $diff;
  while (@_) {
    my $next_value = shift;
    if ($next_value - $value != $diff) {
      return undef;
    }
    $value = $next_value;
  }
  return $diff;
}

# constant_array($a,$b,$c,...)
# If all the given values are all equal then return that value.
# Otherwise return undef.
#
sub constant_array {
  my $value = shift;
  while (@_) {
    my $next_value = shift;
    if ($next_value != $value) {
      return undef;
    }
  }
  return $value;
}


#------------------------------------------------------------------------------

=head1 NAME

Math::OEIS - some Online Encyclopedia of Integer Sequences things

=head1 SYNOPSIS

=head1 FUNCTIONS

=over

=item C<@dirs = Math::OEIS-E<gt>directory_list()>

Return a list of local OEIS directories to look for downloaded sequences and
related files.

If the C<$ENV{'OEIS_PATH'}> environment variable is set then it's used as a
list of directories, split on C<:> or C<;> characters.  C<:> separators is
intended as Unix style, or C<;> for MS-DOS

    OEIS_PATH=/home/foo/OEIS:/var/cache/OEIS

=head1 ENVIRONMENT VARIABLES

=over

=item C<OEIS_PATH>

=back

=cut

{
  package Math::OEIS;
  use strict;

  sub directory_list {
    # my ($class) = @_;
    {
      my $path = $ENV{'OEIS_PATH'};
      if (defined $path) {
        return split /:;/, $path;
      }
    }
    {
      require File::HomeDir;
      my $dir = File::HomeDir->my_home;
      if (defined $dir) {
        return File::Spec->catdir($dir, 'OEIS');
      }
    }
    return ();
  }

  sub find_file {
    my ($class, $filename) = @_;
    foreach my $dir ($class->directory_list) {
      my $fullname = File::Spec->catfile ($dir, $filename);
      if (-e $fullname) {
        return $fullname;
      }
    }
    return undef;
  }
}

#------------------------------------------------------------------------------

{
  package Math::OEIS::SortedFile;
  use strict;
  use Carp 'croak';

  eval q{use Scalar::Util 'weaken'; 1}
    || eval q{sub weaken { $_[0] = undef }; 1 }
      || die "Oops, error making a weaken() fallback: $@";

  # Keep track of all instances which exist and on an ithread CLONE re-open
  # any filehandles in the instances, so they have their own independent file
  # positions in the new thread.
  my %instances;
  sub DESTROY {
    my ($self) = @_;
    delete $instances{$self+0};
  }
  sub CLONE {
    my ($class) = @_;
    foreach my $self (values %instances) {
      $self->close;
    }
  }

  sub new {
    my $class = shift;
    my $self = bless { @_ }, $class;
    weaken($instances{$self+0} = $self);
    return $self;
  }

  sub default_filename {
    my ($class) = @_;
    return Math::OEIS->find_file($class->base_filename);
  }

  sub filename {
    my ($self) = @_;
    if (ref $self && defined $self->{'filename'}) {
      return $self->{'filename'};
    }
    return $self->default_filename;
  }

  sub fh {
    my ($self) = @_;
    return ($self->{'fh'} ||= do {
      my $filename = $self->filename;
      open my $fh, '<', $filename
        or croak "Cannot open ",$filename,": ",$!;
      $fh
    });
  }
  sub close {
    my ($self) = @_;
    if (my $fh = delete $self->{'fh'}) {
      close $fh
        or croak "Cannot close ",$self->filename,": ",$!;
    }
  }

}

=head1 NAME

Math::OEIS::Names - read the OEIS F<names> file

=head1 SYNOPSIS

 my $name = Math::OEIS::Names->anum_to_name('A123456');

=head1 DESCRIPTION

This is an interface to the OEIS F<names> file.  The F<names> file is each
A-number and its name.  The name is a single line desciption (perhaps a
slightly long line).

The F<names> file is sorted by A-number so the lookup is a text file binary
search.

=head1 FUNCTIONS

=over

=item C<$nobj = Math::OEIS::Names-E<gt>new(key =E<gt> value, ...)>

Create and return a new C<Math::OEIS::Names> object to read an OEIS "names"
file.  The optional key/value parameters can be

    filename => $filename         default ~/OEIS/names
    fh       => $filehandle

The default filename is F<~/OEIS/names>, so the F<OEIS> directory under the
user's home directory.  A different filename can be given, or an open
filehandle can be given.

=item C<$name = Math::OEIS::Names-E<gt>anum_to_name($anum)>

=item C<$name = $nobj-E<gt>anum_to_name($anum)>

For a given C<$anum> string such as "A000001" return the sequence name
as a string, or if not found then C<undef>.

C<$name> may contain non-ASCII characters.  In Perl 5.8 and higher C<$name>
is Perl wide chars.  In earlier Perl C<$name> is the native encoding of the
names file (which is UTF-8).

=item C<$filename = $nobj-E<gt>filename()>

Return the names filename from a given C<$nobj> object.

=item C<$filename = Math::OEIS::Names-E<gt>default_filename()>

=item C<$filename = $nobj-E<gt>default_filename()>

Return the default filename which is used if no C<filename> or C<fh> option
is given.  C<default_filename()> can be called either as a class method or
object method.

=item C<Math::OEIS::Names-E<gt>close()>

=item C<$nobj-E<gt>close()>

=back

=head1 SEE ALSO

C<Math::OEIS::Stripped>

=cut

{
  package Math::OEIS::Names;
  use strict;
  use Carp 'croak';
  use Search::Dict;
  use File::Spec;

  use base 'Math::OEIS::SortedFile';
  use base 'Class::Singleton';
  *_new_instance = __PACKAGE__->can('new');

  use constant base_filename => 'names';

  # return A-number string, or undef
  sub line_to_anum {
    my ($line) = @_;
    $line =~ s/^(A\d+).*/$1/
      or return '';  # comment lines
    return $line
  }

  # C<($anum,$name) = Math::OEIS::Names-E<gt>line_split($line)>
  # Split a line from the names file into A-number and name.
  sub line_split {
    my ($self, $line) = @_;
    ### Names line_split(): $line
    $line =~ /^(A\d+)\s*(.*)/
      or return;  # perhaps comment lines
    return ($1, $2)
  }

  use constant::defer _HAVE_ENCODE => sub {
    eval { require Encode; 1 } || 0;
  };

  sub anum_to_name {
    my ($self, $anum) = @_;
    ### $anum
    if (! ref $self) { $self = $self->instance; }
    my $fh = $self->fh || return undef;
    my $pos = Search::Dict::look ($fh, $anum,
                                  { xfrm => sub {
                                      my ($line) = @_;
                                      ### $line
                                      my ($got_anum) = $self->line_split($line)
                                        or return '';
                                      ### $got_anum
                                      return $got_anum;
                                    } });
    if ($pos < 0) { croak 'Error reading names file: ',$!; }

    my $line = readline $fh;
    if (! defined $line) { return undef; }

    my ($got_anum, $name) = $self->line_split($line);
    if ($got_anum ne $anum) { return undef; }

    if (_HAVE_ENCODE) {
      $name = Encode::decode('utf8', $name, Encode::FB_PERLQQ());
    }
    return $name;
  }
}

# sub anum_to_name {
#   my ($class, $anum) = @_;
#   $anum =~ /^A[0-9]+$/ or die "Bad A-number: ", $anum;
#   return `zgrep -e ^$anum $ENV{HOME}/OEIS/names.gz`;
# }

#------------------------------------------------------------------------------

=head1 NAME

Math::OEIS::Stripped - read the OEIS F<stripped> file

=head1 SYNOPSIS

 my @values = Math::OEIS::Names->anum_to_values('A123456');

=head1 DESCRIPTION

This is an interface to the OEIS F<stripped> file.  The F<stripped> file is
each A-number and its sample values.  There's usually up to about 200
characters worth of sample values.

The F<stripped> file is sorted by A-number so the lookup is a text file
binary search.

=head1 FUNCTIONS

=over

=item C<$mos = Math::OEIS::Stripped-E<gt>new(key =E<gt> value, ...)>
  
Create and return a new C<Math::OEIS::Stripped> object to read an OEIS
"stripped" file.  The optional key/value parameters can be

    filename => $filename         default ~/OEIS/stripped
    fh       => $filehandle

The default filename is F<~/OEIS/stripped>, so in an F<OEIS> directory in
the user's home directory.  A different filename can be given, or an open
filehandle can be given.
  
=item C<@values = Math::OEIS::Stripped-E<gt>anum_to_values($anum)>

=item C<$str = Math::OEIS::Stripped-E<gt>anum_to_values_str($anum)>

=item C<@values = $mos-E<gt>anum_to_values($anum)>

=item C<$str = $mos-E<gt>anum_to_values_str($anum)>

Return the values from the stripped file for given C<$anum> (a string such
as "A000001").

C<anum_to_values()> returns a list of values, or no values if not found.
Any values bigger than a usual Perl integer are automatically converted to
C<Math::BigInt> so as to preserve the exact value.

C<anum_to_values_str()> returns a string like "1,2,3,4" or C<undef> if not
found.  The stripped file has a leading comma on its values list, but this
is removed for convenience of subsequent C<split> or similar.

Draft sequences have an empty values list ",,".  The return for them is the
same as "not found", reckoning that it doesn't exist yet.
  
=item C<$filename = $mos-E<gt>filename()>

Return the filename from a given C<$mos> object.

=item C<$filename = Math::OEIS::Stripped-E<gt>default_filename()>

=item C<$filename = $mos-E<gt>default_filename()>
  
Return the default filename which is used if no C<filename> or C<fh> option
is given.  C<default_filename()> can be called either as a class method or
object method.

=item C<Math::OEIS::Stripped-E<gt>close()>

=item C<$mos-E<gt>close()>

=back  

=head1 SEE ALSO

C<Math::OEIS::Names>

=cut

{
  package Math::OEIS::Stripped;
  use strict;
  use Carp 'croak';
  use Search::Dict;
  use File::Spec;

  use base 'Math::OEIS::SortedFile';
  use base 'Class::Singleton';
  *_new_instance = __PACKAGE__->can('new');

  use constant base_filename => 'stripped';

  sub new {
    my $class = shift;
    return $class->SUPER::new (use_bigint => 'if_needed',
                               @_);
  }

  sub anum_to_values {
    my ($self, $anum) = @_;
    if (! ref $self) { $self = $self->instance; }
    my @values;
    my $values_str = $self->anum_to_values_str($anum);
    if (defined $values_str) {
      @values = split /,/, $values_str;
      if ($self->{'use_bigint'}) {
        my $bigint_class = $self->bigint_class_load;
        foreach my $value (@values) {
          unless ($self->{'use_bigint'} eq 'if_needed'
                  && length($value) < 10) {
            $value = Math::BigInt->new($value);  # mutate array
          }
        }
      }
    }
    return @values;
  }
  sub bigint_class_load {
    my ($self) = @_;
    return ($self->{'bigint_class_load'} ||= do {
      require Module::Load;
      my $bigint_class = $self->bigint_class;
      Module::Load::load($bigint_class);
      ### $bigint_class
      $bigint_class
    });
  }

  sub bigint_class {
    my ($self) = @_;
    return ($self->{'bigint_class'} ||= do {
      require Math::BigInt;
      eval { Math::BigInt->import (try => 'GMP') };
      'Math::BigInt'
    });
  }

  sub anum_to_values_str {
    my ($self, $anum) = @_;
    ### anum_to_values_str(): $anum
    if (! ref $self) { $self = $self->instance; }

    my $fh = $self->fh || return undef;
    my $pos = Search::Dict::look
      ($fh, $anum,
       { xfrm => sub {
           my ($line) = @_;
           return ($self->line_to_anum($line) || '');
         } });
    if ($pos < 0) { croak 'Error reading stripped file: ',$!; }

    my $line = readline $fh;
    if (! defined $line) { return undef; }

    my ($got_anum, $values_str) = $self->line_split_anum($line);
    if ($got_anum ne $anum) { return undef; }

    return $values_str;
  }

  # C<$anum = Math::OEIS::Stripped-E<gt>line_split_anum($line)>
  #
  # $line is a line from the stripped file.  Return the A-number string from
  # the line such as "A000001", or C<undef> if unrecognised or a comment
  # line etc.
  #
  sub line_to_anum {
    my ($self, $line) = @_;
    ### $line
    $line =~ s/^(A\d+).*/$1/
      or return '';  # comment lines
    return $line
  }

  # C<($anum,$values_str) = Math::OEIS::Stripped-E<gt>line_split_anum($line)>
  #
  # Split a line from the stripped file into A-number and values string.
  # Any leading comma like ",1,2,3" is removed from $values_str.
  #
  # If C<$line> is a comment or unrecognised then return no values.
  #
  sub line_split_anum {
    my ($self, $line) = @_;
    ### Stripped line_split_anum(): $line
    $line =~ /^(A\d+)\s*,?([0-9].*)/
      or return;  # comment lines or empty
    return ($1, $2)
  }

  # # return list of values, or empty list if not found
  # sub stripped_read_values {
  #   my ($class, $anum) = @_;
  #   open FH, "< " . __PACKAGE__->stripped_filename
  #     or return;
  #   (my $num = $anum) =~ s/^A//;
  #   my $line = bsearch_textfile (\*FH, sub {
  #        my ($line) = @_;
  #        $line =~ /^A(\d+)/ or return -1;
  #        return ($1 <=> $num);
  #      })
  #       || return;
  #
  #   $line =~ s/A\d+ *,?//;
  #   $line =~ s/\s+$//;
  #   return split /,/, $line;
  # }

}

#------------------------------------------------------------------------------


#------------------------------------------------------------------------------

# my @values = Math::OEIS::Stripped->anum_to_values('A000129');
# ### @values

#------------------------------------------------------------------------------

# Return the area enclosed by the curve N=n_start() to N <= $n_limit.
#
# lattice_type => 'triangular'
#    Means take the six-way triangular lattice points as adjacent and
#    measure in X/2 and Y*sqrt(3)/2 so that the points are unit steps.
#
sub path_enclosed_area {
  my ($path, $n_limit, %options) = @_;
  ### path_enclosed_area() ...
  my $points = path_boundary_points($path, $n_limit, %options);
  ### $points
  if (@$points <= 2) {
    return 0;
  }
  require Math::Geometry::Planar;
  my $polygon = Math::Geometry::Planar->new;
  $polygon->points($points);
  return $polygon->area;
}

{
  my %lattice_type_to_divisor = (square => 1,
                                 triangular => 4);

  # Return the length of the boundary of the curve N=n_start() to N <= $n_limit.
  #
  # lattice_type => 'triangular'
  #    Means take the six-way triangular lattice points as adjacent and
  #    measure in X/2 and Y*sqrt(3)/2 so that the points are unit steps.
  #
  sub path_boundary_length {
    my ($path, $n_limit, %options) = @_;
    ### path_boundary_length(): "n_limit=$n_limit"

    my $points = path_boundary_points($path, $n_limit, %options);
    ### $points

    my $lattice_type = ($options{'lattice_type'} || 'square');
    my $triangular_mult = ($lattice_type eq 'triangular' ? 3 : 1);
    my $divisor = ($options{'divisor'} || $lattice_type_to_divisor{$lattice_type});
    my $side = ($options{'side'} || 'all');
    ### $divisor

    my $boundary = 0;
    foreach my $i (($side eq 'all' ? 0 : 1)
                   ..
                   $#$points) {
      ### hypot: ($points->[$i]->[0] - $points->[$i-1]->[0])**2 + $triangular_mult*($points->[$i]->[1] - $points->[$i-1]->[1])**2

      $boundary += sqrt(((  $points->[$i]->[0] - $points->[$i-1]->[0])**2
                         + $triangular_mult
                         * ($points->[$i]->[1] - $points->[$i-1]->[1])**2)
                        / $divisor);
    }
    ### $boundary
    return $boundary;
  }
}
{
  my @dir4_to_dxdy = ([1,0], [0,1], [-1,0], [0,-1]);
  my @dir6_to_dxdy = ([2,0], [1,1], [-1,1], [-2,0], [-1,-1], [1,-1]);
  my %lattice_type_to_dirtable = (square => \@dir4_to_dxdy,
                                  triangular => \@dir6_to_dxdy);

  # Return arrayref of points [ [$x,$y], ..., [$to_x,$to_y]]
  # which are the points on the boundary of the curve from $x,$y to
  # $to_x,$to_y inclusive.
  #
  # lattice_type => 'triangular'
  #    Means take the six-way triangular lattice points as adjacent.
  #
  sub path_boundary_points_ft {
    my ($path, $n_limit, $x,$y, $to_x,$to_y, %options) = @_;
    ### path_boundary_points_ft(): "$x,$y to $to_x,$to_y"
    ### $n_limit

    my $lattice_type = ($options{'lattice_type'} || 'square');
    my $dirtable = $lattice_type_to_dirtable{$lattice_type};
    my $dirmod = scalar(@$dirtable);
    my @points;
    my $dir = $options{'dir'} // ($dirmod - 1);
    my $dirrev = $dirmod / 2 - 1;
    my @n_list = $path->xy_to_n_list($x,$y)
      or die "Oops, no n_list at $x,$y";
    ### initial: "dir=$dir  n_list=".join(',',@n_list)

  TOBOUNDARY: for (;;) {
      foreach my $i (1 .. $dirmod) {
        my ($dx,$dy) = @{$dirtable->[($dir + $i) % $dirmod]};
        my @next_n_list = $path->xy_to_n_list($x+$dx,$y+$dy);
        if (! any_consecutive(\@n_list, \@next_n_list, $n_limit)) {
          ### is boundary: "dxdy = $dx, $dy"
          last TOBOUNDARY;
        }
      }
      my ($dx,$dy) = @{$dirtable->[$dir]};
      if ($x == $to_x && $y == $to_y) {
        $to_x -= $dx;
        $to_y -= $dy;
      }
      $x -= $dx;
      $y -= $dy;
      ### towards boundary: "$x, $y"
    }

    for (;;) {
      ### at: "$x, $y"
      push @points, [$x,$y];
      $dir -= $dirrev;
      $dir %= $dirmod;
      foreach (1 .. $dirmod) {
        my ($dx,$dy) = @{$dirtable->[$dir]};
        my @next_n_list = $path->xy_to_n_list($x+$dx,$y+$dy);
        ### consider: "dir=$dir  next_n_list=".join(',',@next_n_list)
        if (any_consecutive(\@n_list, \@next_n_list, $n_limit)) {
          @n_list = @next_n_list;
          $x += $dx;
          $y += $dy;
          last;
        }
        $dir = ($dir+1) % $dirmod;
      }
      if ($x == $to_x && $y == $to_y) {
        ### stop at: "$x,$y"
        unless ($x == $points[0][0] && $y == $points[0][1]) {
          push @points, [$x,$y];
        }
        last;
      }
    }
    return \@points;
  }
}

# Return arrayref of points [ [$x1,$y1], [$x2,$y2], ... ]
# which are the points on the boundary of the curve N=n_start() to N <= $n_limit
# The final point should be taken to return to the initial $x1,$y1.
#
# lattice_type => 'triangular'
#    Means take the six-way triangular lattice points as adjacent.
#
sub path_boundary_points {
  my ($path, $n_limit, %options) = @_;
  ### path_boundary_points(): "n_limit=$n_limit"
  ### %options

  my $x = 0;
  my $y = 0;
  my $to_x = $x;
  my $to_y = $y;
  if ($options{'side'} && $options{'side'} eq 'right') {
    ($to_x,$to_y) = $path->n_to_xy($n_limit);

  } elsif ($options{'side'} && $options{'side'} eq 'left') {
    ($x,$y) = $path->n_to_xy($n_limit);
  }
  return path_boundary_points_ft($path, $n_limit, $x,$y, $to_x,$to_y, %options);
}

# $aref and $bref are arrayrefs of N values.
# Return true if any pair of values $aref->[a], $bref->[b] are consecutive.
# Values in the arrays which are > $n_limit are ignored.
sub any_consecutive {
  my ($aref, $bref, $n_limit) = @_;
  foreach my $a (@$aref) {
    next if $a > $n_limit;
    foreach my $b (@$bref) {
      next if $b > $n_limit;
      if (abs($a-$b) == 1) {
        return 1;
      }
    }
  }
  return 0;
}

# Return the count of single points in the path from N=Nstart to N=$n_end
# inclusive.  Anything which happends beyond $n_end does not count, so a
# point which is doubled somewhere beyond $n_end is still reckoned as single.
#
sub path_n_to_singles {
  my ($path, $n_end) = @_;
  my $ret = 0;
  foreach my $n ($path->n_start .. $n_end) {
    my ($x,$y) = $path->n_to_xy($n) or next;
    my @n_list = $path->xy_to_n_list($x,$y);
    if (@n_list == 1
        || (@n_list == 2
            && $n == $n_list[0]
            && $n_list[1] > $n_end)) {
      $ret++;
    }
  }
  return $ret;
}

# Return the count of doubled points in the path from N=Nstart to N=$n_end
# inclusive.  Anything which happends beyond $n_end does not count, so a
# point which is doubled somewhere beyond $n_end is not reckoned as doubled
# here.
#
sub path_n_to_doubles {
  my ($path, $n_end) = @_;
  my $ret = 0;
  foreach my $n ($path->n_start .. $n_end) {
    my ($x,$y) = $path->n_to_xy($n) or next;
    my @n_list = $path->xy_to_n_list($x,$y);
    if (@n_list == 2
        && $n == $n_list[0]
        && $n_list[1] <= $n_end) {
      $ret++;
    }
  }
  return $ret;
}

# # Return true if the X,Y point at $n is visited only once.
# sub path_n_is_single {
#   my ($path, $n) = @_;
#   my ($x,$y) = $path->n_to_xy($n) or return 0;
#   my @n_list = $path->xy_to_n_list($x,$y);
#   return scalar(@n_list) == 1;
# }

# Return the count of distinct visited points in the path from N=Nstart to
# N=$n_end inclusive.
#
sub path_n_to_visited {
  my ($path, $n_end) = @_;
  my $ret = 0;
  foreach my $n ($path->n_start .. $n_end) {
    my ($x,$y) = $path->n_to_xy($n) or next;
    my @n_list = $path->xy_to_n_list($x,$y);
    if ($n_list[0] == $n) {  # relying on sorted @n_list
      $ret++;
    }
  }
  return $ret;
}

#------------------------------------------------------------------------------

sub gf_term {
  my ($gf_str, $i) = @_;
  my ($num,$den) = ($gf_str =~ m{(.*)/(.*)}) or die $gf_str;
  $num = Math::Polynomial->new(poly_parse($num));
  $den = Math::Polynomial->new(poly_parse($den));
  my $q;
  foreach (0 .. $i) {
    $q = $num->coeff(0) / $den->coeff(0);
    $num -= $q * $den;
    $num->coeff(0) == 0 or die;
  }
  return $q;
}
sub poly_parse {
  my ($str) = @_;
  ### poly_parse(): $str
  unless ($str =~ /^\s*[+-]/) {
    $str = "+ $str";
  }
  my @coeffs;
  my $end = 0;
  ### $str
  while ($str =~ m{\s*([+-])     # +/- between terms
                   (\s*(-?\d+))? # coefficient
                   ((\s*\*)?     # optional * multiplier
                     \s*x        # variable
                     \s*(\^\s*(\d+))?)?  # optional exponent
                   \s*
                }xg) {
    ### between: $1
    ### coeff  : $2
    ### x      : $4
    $end = pos($str);
    last if ! defined $2 && ! defined $4;
    my $coeff = (defined $2 ? $2 : 1);
    my $power = (defined $7 ? $7
                 : defined $4 ? 1
                 : 0);
    if ($1 eq '-') { $coeff = -$coeff; }
    $coeffs[$power] += $coeff;
    ### $coeff
    ### $power
    ### $end
  }
  ### final coeffs: @coeffs
  $end == length($str)
    or die "parse $str fail at pos=$end";
  foreach (@coeffs) { $_ ||= 0 }
  require Math::Polynomial;
  return Math::Polynomial->new(@coeffs);
}

1;
__END__
