# Copyright 2010, 2011, 2012, 2013 Kevin Ryde

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

sub oeis_directory {
  # my ($class) = @_;
  require File::HomeDir;
  my $dir = File::HomeDir->my_home;
  if (! defined $dir) {
    die 'File::HomeDir says you have no home directory';
  }
  require File::Spec;
  return File::Spec->catdir($dir, 'OEIS');
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
  foreach my $mung ('none', 'negate', 'abs', 'half') {
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

=head1 FUNCTIONS

=over

=item C<$mon = Math::OEIS::Names-E<gt>new(key =E<gt> value, ...)>
  
Create and return a new C<Math::OEIS::Names> object to read an OEIS "names"
file.  The optional key/value parameters can be

    filename => $filename         default ~/OEIS/names
    fh       => $filehandle

The default filename is F<~/OEIS/names>, so the F<OEIS> directory under the
user's home directory.  A different filename can be given, or an open
filehandle can be given.
  
=item C<$name = Math::OEIS::Names-E<gt>anum_to_name($anum)>

For a given C<$anum> string such as "A000001" return the sequence name
as a string, or if not found then C<undef>.
  
=item C<$filename = $mon-E<gt>filename()>

=item C<$filename = Math::OEIS::Names-E<gt>filename()>
  
Return the names filename from a given C<$mon> object, or the default
filename if called as a class method C<Math::OEIS::Names>.

=back  

=head2 BUGS

The current implementation is a text file binary search.  For large numbers
of name lookups an actual database would probably be more efficient.
Perhaps C<Math::OEIS::Names> could automatically look in an SQLite or
similar database if it exists and is up-to-date.

=cut

{
  package Math::OEIS::Names;
  use strict;
  use Carp 'croak';
  use Search::Dict;
  use File::Spec;

  use base 'Class::Singleton';
  *_new_instance = \&new;

  sub new {
    my $class = shift;
    return bless { @_ }, $class;
  }

  sub default_filename {
    my ($class) = @_;
    return File::Spec->catfile (MyOEIS->oeis_directory(), 'names');
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

    return $name;
  }
}

# sub anum_to_name {
#   my ($class, $anum) = @_;
#   $anum =~ /^A[0-9]+$/ or die "Bad A-number: ", $anum;
#   return `zgrep -e ^$anum $ENV{HOME}/OEIS/names.gz`;
# }

#------------------------------------------------------------------------------

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

Return the values from the stripped file for given C<$anum> (a string such
as "A000001").

C<anum_to_values()> returns a list of values, or no values if not found.
C<anum_to_values_str()> returns a string like "1,2,3,4" or C<undef> if not
found.

The stripped file has a leading comma on its values list, but this is
removed from C<anum_to_values_str()> for convenience of subsequent C<split>
or similar.

Draft sequences have an empty values list ",,".  The return for them is the
same as "not found", reckoning that it doesn't exist yet.
  
=item C<$filename = $mos-E<gt>filename()>

=item C<$filename = Math::OEIS::Stripped-E<gt>filename()>
  
Return the stripped filename from a given C<$mos> object, or the default
filename if called as a class method C<Math::OEIS::Stripped>.

=back  

=cut

{
  package Math::OEIS::Stripped;
  use strict;
  use Carp 'croak';
  use Search::Dict;
  use File::Spec;

  use base 'Class::Singleton';
  *_new_instance = \&new;

  sub new {
    my $class = shift;
    return bless { use_bigint => 'if_needed',
                   @_ }, $class;
  }

  sub default_filename {
    my ($class) = @_;
    return File::Spec->catfile (MyOEIS->oeis_directory(), 'stripped');
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

# my @values = Math::OEIS::Stripped->anum_to_values('A000129');
# ### @values

1;
__END__
