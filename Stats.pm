package JoeDog::Stats;

use strict;
use vars qw($VERSION $LOCK_EX $LOCK_UN);
our ($ARRAY, $HASH, $GROUP, $UNKNOWN) = (1, 2, 3, 4); 

$VERSION = "1.15"; 
$LOCK_EX = 2;
$LOCK_UN = 8;

=head1 SYNOPSIS

=cut

=item B<JoeDog::Stats>

  A perl module that performs statistical analysis on sets of
  data provided in either hashes or arrays. All calculations 
  are performed on ungrouped data unless you build a frequency
  distribution with $stats->fdistribution($num, [$lo, $hi]);

=cut

=head1 METHODS

=cut

=item B<new>

  my $stats = new JoeDog::Stats(\@array);
  my $stats = new JoeDog::Stats(\%hash); 
  my $stats = new JoeDog::Stats("/path/to/file", [$sep]);
  my $stats = new JoeDog::Stats(); 
  $stats->add(\@arr);
 
  Returns a JoeDog::Stats object; it takes a one-dimensional
  array, a hash or a filename as an argument. All analyses are 
  performed dynamically. There is no need to specify the data 
  type.  Unless you group the data in a frequency distribution, 
  all calculations will occur against ungrouped data. 

  The file should contain a frequency distribution as such:
  #
  #      Range|     (f)
  #-----------+--------
     0.50-0.74|      2
     0.75-0.99|      7
     1.00-1.24|     15
     1.25-1.49|     28
     1.50-1.74|     14
     1.75-1.99|      9
     2.00-2.24|      3
     2.25-2.49|      2 

  The default separator is '|'  If your columns are pipe separated
  then there is no need to specify the optional separator. 

=cut

sub new() {
  my $this  = shift;
  my $data  = shift;
  my $sep   = shift;
  my $class = ref($this) || $this;
  my $self  = {
    'X'     => 0,
    'f'     => 0,
    'fX'    => 0,
    'fXsq'  => 0,
    'LOW'   => 0,
  };
  bless($self, $class);

  $self->{'FREQ'} = {}; 
  if(ref($data) eq 'HASH'){
    $self->{'TYPE'} = $HASH;
    $self->{'DATA'} = $data;
  } elsif(ref($data) eq 'ARRAY'){
    $self->{'TYPE'} = $ARRAY;
    $self->{'DATA'} = $data;
  } else {
    if(!defined($data)){
      $self->{'TYPE'} = $UNKNOWN;
    } else {
      $self->{'TYPE'} = $GROUP;
      $sep = (!defined($sep))?"|":$sep;
      $self->_read_fdistribution($data, $sep);  
    }
  }
  return $self;
}

=item B<add>

  $stats->add(\@arr);
  $stats->add(\%hash);
  $stats->add([120, 230, 111]);
  $stats->add({'a'=>12, 'b'=>23, 'c'=>16});

=cut 

sub add {
  my $this = shift;
  my $data = shift;
 
  if($this->{'TYPE'} == $GROUP){
    return;
  } elsif($this->{'TYPE'} == $HASH){ 
    if(ref($data) eq 'HASH'){
      foreach my $key(keys(%{$data})){
        ${$this->{'DATA'}}{$key} += ${$data}{$key};
      }
    } 
  } elsif($this->{'TYPE'} == $ARRAY){
    if(ref($data) eq 'HASH'){
      foreach my $key(keys(%{$data})){
        push @{$this->{'DATA'}}, ${$data}{$key};
      }
    } elsif(ref($data) eq 'ARRAY'){
      foreach my $key(@{$data}){
        push @{$this->{'DATA'}}, $key;
      }
    } else {
      push @{$this->{'DATA'}}, $data;
    }
  } elsif($this->{'TYPE'} == $UNKNOWN){
    ## we should only hit this once; 
    ## we're going to create an array
    $this->{'TYPE'} = $ARRAY;
    if(ref($data) eq 'HASH'){
      foreach my $key(keys(%{$data})){
        push @{$this->{'DATA'}}, ${$data}{$key};
      }
    } elsif(ref($data) eq 'ARRAY'){
      foreach my $key(@{$data}){
        push @{$this->{'DATA'}}, $key;
      }
    } else {
      push @{$this->{'DATA'}}, $data;
      return;
    } 
  } else {
    warn "ERROR: incompatible data";
    return;
  } 
  return;
}

=item B<fdistribution>

  Use this method to dynamically group the data in a frequency 
  distribution:

  $stats->fdistribution($bins, [$low, $high]);

  Or define your own bins with a hash reference:

  $stat->fdistribution({
    0.50=>0.74, 0.75=>0.99, 1.00=>1.24, 1.25=>1.49,
    1.50=>1.74, 1.75=>1.99, 2.00=>2.24, 2.25=>2.49
  });

  my %hash =  (
    0.50=>0.74, 0.75=>0.99, 1.00=>1.24, 1.25=>1.49,
    1.50=>1.74, 1.75=>1.99, 2.00=>2.49, 2.25=>2.49
  );
  $stat->fdistribution(\%hash); # note: \%hash, must be a ref 
 
  Where $bins is the total number of frequency bins, $low is
  the low value of the first bucket and $high is the high end
  of the distribution. Since the bins are sized proportionately,
  $high may not appear as the high value of the distribution.
  $low and $high are optional. The method will dynamically create
  the buckets if neither value is specified. You may specify $low
  without $high. 

  Example: $stats->fdistribution(8, 130); 

#      Range|      (X)|       (f)|        (fX)|      (fX)^2
#-----------+---------+----------+------------+------------
     130-139|   134.50|      2.00|      269.00|    36180.50
     140-149|   144.50|      8.00|     1156.00|   167042.00
     150-159|   154.50|     20.00|     3090.00|   477405.00
     160-169|   164.50|     15.00|     2467.50|   405903.75
     170-179|   174.50|      9.00|     1570.50|   274052.25
     180-189|   184.50|      7.00|     1291.50|   238281.75
     190-199|   194.50|      3.00|      583.50|   113490.75
     200-209|   204.50|      2.00|      409.00|    83640.50
#-----------+---------+----------+------------+------------
# Totals:   |         |     66.00|    10837.00|  1795996.50Ð

=cut

sub fdistribution {
  my $pnum  = $#_;
  my $this  = shift;
  my $bins  = ($pnum>0)?shift:2;
  my $fmin  = ($pnum>1)?shift:$this->min();
  my $fmax  = ($pnum>2)?shift:(int($this->max()/$bins)+1) * $bins;  
  my ($size, $pad, %hash);

  ##++
  ## Build the structure.
  ## If $bins is a hash, then we recieved a user-defined
  ## structure else we'll create it dynamically.  There are
  ## two types of dynamic structures. If $padd is less than
  ## one, then it's a decimal structure, else it's a integer
  ##--
  if(ref($bins) eq 'HASH'){ 
    # user-defined structure
    $fmax = _bin_total($bins);
    foreach my $key(keys(%{$bins})){
      my $lo  = $key;
      my $hi  = ${$bins}{$key};
      my $mid = $lo + (($hi - $lo)/2);
      $hash{$mid} = {'lo' => $lo, 'hi' => $hi, 'freq' => 0, 'cfreq' => 0}; 
    } 
  } else {                      
    # dynamic bin structure
    $pad  = $this->_bin_size();  
    if($pad < 1){
      # decimal buckets
      $size = sprintf "%.2f", (($fmax - $fmin) / $bins);
      $size = ($size==0)?1:$size;
      for(my $x = ($fmin-$pad); $x < $fmax; $x+=($size)) { 
        my $lo  = sprintf "%.2f", $x + $pad;
        my $hi  = sprintf "%.2f", $x + $size;
        my $mid = $lo + (($hi - $lo)/2);
        $hash{$mid} = {'lo' => $lo, 'hi' => $hi, 'freq' => 0, 'cfreq' => 0};
      } 
    } else { 
      # integer buckets
      $size = int(((($fmax - $fmin) / $bins) - 1)+.5);  
      $size = ($size==0)?1:$size;
      for(my $x = $fmin; $x < $fmax; $x+=($size+$pad)) { 
        my $lo  = $x;
        my $hi  = $x + $size;
        my $mid = $lo + (($hi - $lo)/2);
        $hash{$mid} = {'lo' => $lo, 'hi' => $hi, 'freq' => 0, 'cfreq' => 0};
      } 
    }
  }

  # populate 
  if($this->{'TYPE'} == $ARRAY){
    foreach my $z (@{$this->{'DATA'}}){
      foreach my $k (keys(%hash)){ 
        if($z >= $hash{$k}->{'lo'} && $z <= $hash{$k}->{'hi'}){
          $hash{$k}->{'freq'}++; 
          $this->{'f'}++; 
          $this->{'fX'}   += $k; 
        }
      }
    }
  } elsif($this->{'TYPE'} == $HASH) {
    foreach my $key (keys(%{$this->{'DATA'}})){
      foreach my $k (keys(%hash)){
        if($this->{'DATA'}{$key}>=$hash{$k}->{'lo'} && $this->{'DATA'}{$key}<=$hash{$k}->{'hi'}){
          $hash{$k}->{'freq'}++;
          $this->{'f'}++;
          $this->{'fX'}   += $k;
        }
      }    
    }
  } else {
    die "ERROR: unknown data type: [".$this->{'TYPE'}."]";
    return;
  }

  # calculate cumulative frequency
  # and sigma (fX)^2
  my $sum   = 0;
  my $ttl   = 0;
  my $found = 0;
  foreach my $k (sort{ $a <=> $b } keys(%hash)){ 
    $hash{$k}->{'cfreq'} = ($sum + $hash{$k}->{'freq'});
    for($ttl = $sum; $ttl < $hash{$k}->{'cfreq'} && !$found; $ttl++){
      if($ttl == int(($this->{'f'}/2))){
        $this->{'LOW'} = $hash{$k}->{'lo'};
        $found = 1;
      }
    }
    $sum = $hash{$k}->{'cfreq'}; 
    $this->{'fXsq'} += ($hash{$k}->{'freq'} * $k) * $k;
  }
  $this->{'TYPE'} = $GROUP;
  $this->{'FREQ'} = \%hash;
  return; 
}

=item B<save>

  $stats->frequency(8);
  $stats->save($filename);

  Saves the frequency distribution to $filename. You can read
  it back into memory with new JoeDog::Stats($filename);

=cut

sub save {
  my $this = shift;
  my $file = shift;
  my %hash = %{$this->{'FREQ'}};
  my $msg  = sprintf "#%11s|%10s\n", "Range", "(f)";
  $msg    .= "#-----------+----------+\n";
  foreach my $k (sort{ $a <=> $b } keys(%hash)){
    my $rng = ${$hash{$k}}{'lo'} . "-" . ${$hash{$k}}{'hi'};
    $msg   .= sprintf "%12s|%10.2f\n", $rng, ${$hash{$k}}{'freq'};
  }

  if(open(FILE, ">" . $file)){
    flock(FILE, $LOCK_EX);
    print FILE  $msg;
    flock(FILE, $LOCK_UN);
    close(FILE);
  } else {
    die "ERROR: unable to open file [$file] for writing";
  } 
  return;
}

=item B<fdump>

  $stats->frequency(8);
  $stats->fdump([$sep]);

  Prints the frequency distribution to screen in optional
  $sep separated fields. Uses pipes by default.

#      Range|      (X)|       (f)|        (fX)|      (fX)^2
#-----------+---------+----------+------------+------------
       30-34|    32.00|      3.00|       96.00|     3072.00
       35-39|    37.00|      7.00|      259.00|     9583.00
       40-44|    42.00|     11.00|      462.00|    19404.00
       45-49|    47.00|     22.00|     1034.00|    48598.00
       50-54|    52.00|     40.00|     2080.00|   108160.00
       55-59|    57.00|     24.00|     1368.00|    77976.00
       60-64|    62.00|      9.00|      558.00|    34596.00
       65-69|    67.00|      4.00|      268.00|    17956.00
#-----------+---------+----------+------------+------------
# Totals:   |         |    120.00|     6125.00|   319345.00

=cut

sub fdump {
  my $pnum = $#_;
  my $this = shift;
  my $sep  = ($pnum==1)?shift:"|";
  my %hash = %{$this->{'FREQ'}};
  my $sum  = 0;
  my $sfx  = 0;
  my $fxsq = 0;
  my $msg  = sprintf "#%11s$sep%9s$sep%10s$sep%12s$sep%12s\n", 
             "Range", "(X)", "(f)", "(fX)", "(fX)^2";
  $msg .= "#-----------+---------+----------+------------+------------\n";
  foreach my $k (sort{ $a <=> $b } keys(%hash)){
    my $rng = ${$hash{$k}}{'lo'} . "-" . ${$hash{$k}}{'hi'}; 
    $sfx += ($k * ${$hash{$k}}{'freq'});
    $sum += ${$hash{$k}}{'freq'};
    $fxsq = ((${$hash{$k}}{'freq'} * $k) * $k); 
    $msg .= sprintf "%12s$sep%9.2f$sep%10.2f$sep%12.2f$sep%12.2f\n", 
            $rng, $k, ${$hash{$k}}{'freq'}, 
             ($k * ${$hash{$k}}{'freq'}, $fxsq);
  } 
  $msg .= "#-----------+---------+----------+------------+------------\n";
  $msg .= sprintf "# Totals:   $sep         $sep%10.2f$sep%12.2f$sep%12.2f\n", 
          $this->{'f'}, $this->{'fX'}, $this->{'fXsq'};

  print $msg;
}

=item B<mean>

  my $avg = $stats->mean();

  Returns the arithmatic mean for all the elements stored
  in the array or hash reference passed to the constructor.
  The sum of all elements divided by the number of elements
  Returns a grouped mean if the data was grouped with 
  fdistribution.

=cut

sub mean() {
  my $this = shift;
  if($this->{'TYPE'} == $HASH){
    return $this->_hash_mean(); 
  } elsif($this->{'TYPE'} == $ARRAY) {
    return $this->_array_mean();
  } elsif($this->{'TYPE'} == $GROUP){
    return $this->_grouped_mean();
  } else {
    return 0.0;
  }
}

=item B<gmean> (Geometric Mean)

  my $gmean = $stats->gmean();

  Returns the geomentric mean for all elements stored in 
  the data structure. 
                      __________________ 
  Geometric Mean = \n/(x1)(x2)(x3)...(xn)

=cut

sub gmean() {
  my $this = shift;
  if ($this->{'TYPE'} == $HASH) {
    return $this->_hash_gmean();
  } elsif ($this->{'TYPE'} == $ARRAY) {
    return $this->_array_gmean();
  } else {
    printf STDERR "Geometric mean is unsupported for grouped data\n";
    return 0.0;
  }
}

=item B<median>

  my $med = $stats->median();

  Returns the arithmatic median for all the elements stored
  in the array or hash reference passed to the constructor.
  The midpoint in a series of numbers. For example, the median 
  of 2, 6, 10, 22 and 40 is 10 but the mean is 16.
  Returns a grouped median if the data was grouped with 
  fdistribution.

=cut
sub median() {
  my $this = shift;
  if($this->{'TYPE'} == $HASH){
    return $this->_hash_median(); 
  } elsif($this->{'TYPE'} == $ARRAY) {
    return $this->_array_median();
  } elsif($this->{'TYPE'} == $GROUP) {
    return $this->_grouped_median();
  } else {
    return 0.0;
  }
}

=item B<mode>
 
  my $mode = $stats->mode();
 
  Returns the arithmatic mode for all the elements stored
  in the array or hash reference passed to the constructor.
  The most frequent or common value in the distribution. The 
  mode for the observations (2, 2, 3, 3, 2) is 2.
  Returns a grouped mode if the data was grouped with 
  fdistribution.
 
=cut
sub mode()
{
  my $this = shift;
  if($this->{'TYPE'} == $HASH){
    return $this->_hash_mode();
  } elsif($this->{'TYPE'} == $ARRAY){
    return $this->_array_mode();
  } elsif($this->{'TYPE'} == $GROUP){
    return $this->_grouped_mode();
  } else {
    return 0.0;
  }
} 

=item B<percentile>
  
  my $p = $stats->percentile($n);

  Returns the percentage of scores that are lower than $n. 
  A percentile is any of the 99 values that divide the sorted 
  data into 100 equal parts, so that each part represents 1%
  of the sample or population. Thus the 1st percentile cuts 
  off lowest 1% of data and the 95th percentile cuts off lowest 
  95% of data

=cut
sub percentile()
{
  my $this = shift;
  my $n    = shift;
  if($this->{'TYPE'} == $HASH){
    return $this->_hash_percentile($n);
  } else {
    return $this->_array_percentile($n);
  }
} 

=item B<min>

  my $min = $stats->min();

  Returns the minimum value in the set. Given
  (3, 4, 5, 6, 2)  $stats->min() returns 2

=cut
sub min() 
{
  my $this = shift;
  if($this->{'TYPE'} == $HASH){
    return $this->_hash_min();
  } else {
    return $this->_array_min();
  }
}

=item B<max>
 
  my $max = $stats->max();
 
  Returns the maximum value in the set. Given
  (3, 4, 5, 6, 2)  $stats->max() returns 6
 
=cut
sub max()
{
  my $this = shift;
  if($this->{'TYPE'} == $HASH){
    return $this->_hash_max();
  } else {
    return $this->_array_max();
  }
} 

sub _size()
{
  my $this = shift;
  
  if($this->{'TYPE'} == $HASH){
    return $this->_hash_size();
  } elsif($this->{'TYPE'} == $ARRAY){  
    return scalar(@{$this->{'DATA'}}); 
  } elsif($this->{'TYPE'} == $GROUP){
    return $this->{'f'};
  } elsif($this->{'TYPE'} == $UNKNOWN){  
    return 1; 
  }
  # who knows? 
  # avoid division by zero; 
  return 1; 
}

=item B<variance>

  my $variance = $stats->variance();

  The measure of variation shown by a set of observations defined 
  by the sum of the squares of deviations from the mean, divided 
  by the number of degrees of freedom in the set of observations.
  Returns a grouped variance if the data was grouped with 
  fdistribution.

=cut
sub variance
{
  my $this = shift;
  if($this->{'TYPE'} == $HASH){
    return $this->_hash_variance();
  } elsif($this->{'TYPE'} == $ARRAY){
    return $this->_array_variance();
  } elsif($this->{'TYPE'} == $GROUP){
    return $this->_grouped_variance();
  } else {
    return 0.0;
  }
}

=item B<stddev>

  my $stddev = $stats->stddev();

  The standard deviation is defined as the positive square root of 
  the variance. The variance is a measure in squared units and has 
  little meaning with respect to the data. Thus, the standard deviation 
  is a measure of variability expressed in the same units as the data. 
  Returns a grouped standard deviation if the data was grouped with 
  fdistribution.

=cut
sub stddev {
  my $this = shift;
  return sqrt($this->variance()); 
}

=item B<skewness>

  my $skew = $stats->skewness();

  The pearson skewness coefficient is calculated as follows:
  3(mean minus mode)/standard deviation
  Skewness is a measure of the asymmetry of the probability 
  distribution of a real-valued random variable. Roughly speaking, 
  a distribution has positive skew if the higher tail is longer 
  and negative skew if the lower tail is longer.
  Returns a grouped skewness if the data was grouped with 
  fdistribution.

=cut
sub skewness {
  my $this = shift;
  my $stdd = $this->stddev();

  if($stdd==0){
    return 0;
  } else {
    return ((3*($this->mean()-$this->median()))/$stdd);
  }
}

# private methods...

sub _bin_size {
  my $this = shift;
  my $prec = 0;
  if($this->{'TYPE'} == $HASH){
    $prec = $this->_hash_precision();
  } elsif($this->{'TYPE'} == $ARRAY){
    $prec = $this->_array_precision();
  } elsif($this->{'TYPE'} == $GROUP){
    # should not occur
    return 1;
  }   

  return 1 if $prec == 0;

  my $res = ".";
  for(my $x = 0; $x < ($prec-1); $x ++){
    $res .= "0"; 
  }
  $res .= "1";
  return $res;
}

sub _bin_total() {
  my $hash = shift;
  return 0 if (scalar(keys(%{$hash})) < 1);
  my $sum  = 0;
  foreach my $key(keys(%{$hash})){
    $sum ++ if (defined $key && defined ${$hash}{$key});
  }
  return $sum;
}

sub _hash_mean() {
  my $this = shift;
  my $sum  = 0;
  foreach my $key (keys(%{$this->{'DATA'}})){
    $sum += $this->{'DATA'}{$key}; 
  }
  return ($sum/$this->_size()); 
}

sub _array_mean() {
  my $this = shift;
  my $sum  = 0;
  foreach my $thing(@{$this->{'DATA'}}){
    $sum += $thing;
  }
  return ($sum/$this->_size()); 
}

sub _grouped_mean() {
  my $this = shift;
  if($this->{'f'} == 0){
    return 0;
  } else {
    return $this->{'fX'}/$this->{'f'}; 
  }
}

sub _hash_gmean() {
  my $this = shift;
  my $prod = 1;
  my $expo = (1/$this->_size());
  foreach my $key (keys(%{$this->{'DATA'}})){
    return undef if $this->{'DATA'}{$key} < 0;
    $prod *= $this->{'DATA'}{$key}**$expo;
  }
  return $prod; 
}

sub _array_gmean() {
  my $this = shift;
  my $prod = 1;
  my $expo = (1/$this->_size());
  foreach my $thing(@{$this->{'DATA'}}){
    return undef if $thing < 0;
    $prod *= $thing ** $expo;
  }
  return $prod;
}

sub _hash_median() {
  my $this = shift;
  my @arr;
  foreach my $key (keys(%{$this->{'DATA'}})){
    push @arr, $this->{'DATA'}{$key};
  }
  my $median = (sort {$a <=> $b} @arr)[($#arr+1) / 2]; 
  return $median; 
}
 
sub _array_median() {
  my $this = shift;
  my $median = (sort {$a <=> $b} @{$this->{'DATA'}})[($this->_size()-1) / 2]; 
  return $median;
} 

sub _grouped_median() {
  my $this = shift;
  my %hash = %{$this->{'FREQ'}};
  my $cf   = 0;
  my $f    = 0;
  my $lo   = 0;
  my $hi   = 0;
  foreach my $k (sort{ $a <=> $b } keys(%hash)){ 
    $f  = $hash{$k}->{'freq'} if $hash{$k}->{'lo'} == $this->{'LOW'}; 
    next if $hash{$k}->{'lo'} >= $this->{'LOW'};
    $cf = $hash{$k}->{'cfreq'}; 
    $lo = $hash{$k}->{'lo'};
    $hi = $hash{$k}->{'hi'}; 
  }
  my     $median = ((((($this->{'f'}-1)/2)-$cf)/$f)*($hi-$lo))+($this->{'LOW'});
  return $median;
}

sub _hash_mode() {
  my $this = shift;
  my @arr;
  my %hash;        
  foreach my $key (keys(%{$this->{'DATA'}})){
    push @arr, $this->{'DATA'}{$key};
  } 
  $hash{$_}++ foreach @arr;

  my $mode = (sort {$hash{$a} <=> $hash{$b}} keys %hash)[-1]; 

  return $mode;
}
 
sub _array_mode() {
  my $this = shift;
  my %hash;        
  $hash{$_}++ foreach @{$this->{'DATA'}};

  my $mode = (sort {$hash{$a} <=> $hash{$b}} keys %hash)[-1]; 
  return $mode;
} 

sub _grouped_mode() {
  my $this = shift;
  my %hash = %{$this->{'FREQ'}};
  my ($mid, $max);
  
  foreach my $key (sort{ $a <=> $b } keys(%hash)){
    if($hash{$key}->{'freq'} > $max){
      $max = $hash{$key}->{'freq'};
      $mid = $key;
    }
    $max = $hash{$key}->{'freq'} if $hash{$key}->{'freq'} > $max; 
  }
  return $mid;
}

sub _hash_percentile() {
  my $this   = shift;
  my $n      = shift;

  $n = ($n < 1 && $n > 0) ? $n : $n * .01;

  my @arr;
  foreach my $key (keys(%{$this->{'DATA'}})){
    push @arr, $this->{'DATA'}{$key};
  } 

  my @sorted = sort {$a<=>$b} @arr;
  my $px     = int((@sorted)*$n);
  my $p      = $sorted[$px];
  return $p; 
}
 
sub _array_percentile() {
  my $this   = shift;
  my $n      = shift;
 
  $n = ($n < 1 && $n > 0) ? $n : $n * .01;
 
  my @sorted = sort {$a<=>$b} @{$this->{'DATA'}};
  my $px     = int((@sorted)*$n);
  my $p      = $sorted[$px];
  return $p; 
}

sub _hash_min() {
  my $this = shift;
  my @keys = keys %{$this->{'DATA'}};
  my $min = $this->{'DATA'}{shift @keys};

  foreach my $key (@keys){
    next if !defined($this->{'DATA'}{$key});
    $min = $this->{'DATA'}{$key} if $this->{'DATA'}{$key} < $min;
  } 
 
  return $min;
}
 
sub _array_min() {
  my $this = shift;
  my $min  = @{$this->{'DATA'}}[0];

  for(0..$this->_size()-1){
    next if !defined(@{$this->{'DATA'}}[$_]);
    $min = @{$this->{'DATA'}}[$_] if @{$this->{'DATA'}}[$_] < $min; 
  }
  return $min;
} 

sub _hash_max() {
  my $this = shift;
  my @keys = keys %{$this->{'DATA'}};
  my $max  = $this->{'DATA'}{shift @keys};
 
  foreach my $key (@keys){
    next if !defined($this->{'DATA'}{$key});
    $max = $this->{'DATA'}{$key} if $this->{'DATA'}{$key} > $max;
  }
 
  return $max;
}

sub _array_max() {
  my $this = shift;
  my $max  = @{$this->{'DATA'}}[0];
 
  for(0..$this->_size()-1){
    next if !defined(@{$this->{'DATA'}}[$_]);
    $max = @{$this->{'DATA'}}[$_] if @{$this->{'DATA'}}[$_] > $max;
  }
 
  return $max;
} 

sub _hash_variance() {
  my $this = shift;
  my $sum  = 0;
  my $sqrt = 0;
  my $var  = 0;
  my $n    = $this->_size(); 

  if(($n*($n-1))==0){
    return 0;
  }

  my @keys = keys %{$this->{'DATA'}};
  my $max = $this->{'DATA'}{shift @keys};
 
  foreach my $key (keys %{$this->{'DATA'}}){
    next if !defined($this->{'DATA'}{$key});
    $sum  += $this->{'DATA'}{$key};
    $sqrt += $this->{'DATA'}{$key}*$this->{'DATA'}{$key}; 
  } 
  return (($n * $sqrt) - $sum**2)/($n*($n-1));  
}

sub _array_variance() {
  my $this = shift;
  my $sum  = 0;
  my $sqrt = 0;
  my $var  = 0;
  my $n    = $this->_size();

  if(($n*($n-1))==0){
    return 0;
  }

  foreach my $thing (@{$this->{'DATA'}}){
    $sum  += $thing;
    $sqrt += $thing*$thing;
  }
  return (($n * $sqrt) - $sum**2)/($n*($n-1));
}

sub _grouped_variance() {
  my $this = shift;
  if(($this->{'f'}-1)==0){
    return 0;
  } else {
    return ($this->{'fXsq'}-((($this->{'fX'}*$this->{'fX'})/$this->{'f'})))/($this->{'f'}-1);
  }
}

sub _read_fdistribution() {
  my $this  = shift;
  my $file  = shift;
  my $sep   = shift;
  my $lines = "";
  my %hash;

  $sep = (!defined($sep))?"|":$sep;  # Okay, I'm 'noid

  if(open(FILE, "<" . $file)){
    flock(FILE, $LOCK_EX);
    while(<FILE>){
      next if /^$/;
      next if /^\s*#/;
      $lines .= $_;
    }
    flock(FILE, $LOCK_UN);
    close(FILE);
  }

  foreach my $thing (split(/\n/, $lines)){
    my ($left, $right, $lo, $hi, $mid);
    if($sep =~ m!\||\/|\\|\<|\>!){
      my $regex = "\\".$sep;
      ($left,$right) = split(/$regex/, $thing);
    } else {
      if($sep =~ ' '){
        ($left,$right) = split(/$sep/, $thing);
      } else {
        #($left,$right) =~ /"[^"]+"|\S+/g;
      }
    }

    $left          = trim($left);
    $right         = trim($right);
    ($lo, $hi)     = split /-/, $left; 
    $lo            = trim($lo) or die "ERROR: unknown data structure";
    $hi            = trim($hi) or die "ERROR: unknown data structure";
    $mid           = $lo + (($hi - $lo)/2); 
    $hash{$mid}    = {'lo' => $lo, 'hi' => $hi, 'freq' => $right, 'cfreq' => 0};  
    $this->{'f'}  += $right;
    $this->{'fX'} += ($mid * $right); 
  } 

  my $sum   = 0;
  my $ttl   = 0;
  my $found = 0;
  foreach my $k (sort{ $a <=> $b } keys(%hash)){
    $hash{$k}->{'cfreq'} = ($sum + $hash{$k}->{'freq'});
    for($ttl = $sum; $ttl < $hash{$k}->{'cfreq'} && !$found; $ttl++){
      if($ttl == ($this->{'f'}/2)){
        $this->{'LOW'} = $hash{$k}->{'lo'};
        $found = 1;
      }
    }
    $sum = $hash{$k}->{'cfreq'};
    $this->{'fXsq'} += ($hash{$k}->{'freq'} * $k) * $k;
  }
  $this->{'FREQ'} = \%hash;  
  return;
}

sub _array_precision() {
  my $this = shift;
  my $prec = _precision(@{$this->{'DATA'}}[0]);
 
  for(0..$this->_size()-1){
    next if !defined(@{$this->{'DATA'}}[$_]);
    my $tmp = _precision(@{$this->{'DATA'}}[$_]); 
    $prec   = $tmp if $tmp > $prec;
  }

  return $prec; 
}

sub _hash_precision() {
  my $this = shift;
  my @keys = keys %{$this->{'DATA'}};
  my $prec = _precision($this->{'DATA'}{shift @keys});
 
  foreach my $key (@keys){
    next if !defined($this->{'DATA'}{$key});
    my $tmp = _precision($this->{'DATA'}{$key}); 
    $prec   = $tmp if $tmp > $prec;
  }
 
  return $prec; 
}

sub _precision() {
  my $num = shift;
 
  $num    =~ s/^0+//; # trim leading zeros
  $num    =~ s/0+$//; # trim trailing zeros
 
  return 0 if index($num, ".") < 0;
 
  my $len = length($num) - (index($num, ".")+1);
  return $len;
} 


#
# can't trust scalar(keys(%hash)) to return the proper
# size since it counts undefined hash elements (grrr)
sub _hash_size() {
  my $this = shift;
  return 0 if (scalar(keys(%{$this->{'DATA'}})) < 1);
  my $sum  = 0;
  foreach my $key (keys(%{$this->{'DATA'}})){
    $sum++ if (defined $key && defined($this->{'DATA'}{$key})); 
  }
  return $sum; 
}

sub trim() {
  my $thing = shift;
  $thing =~ s/#.*$//; # trim trailing comments
  $thing =~ s/^\s+//; # trim leading whitespace
  $thing =~ s/\s+$//; # trim trailing whitespace
  return $thing;
} 


1;

__END__

=head1 DESCRIPTION

JoeDog::Stats 

=head1 AUTHORS

Jeffrey Fulmer, jeff@joedog.org

=head1 SEE ALSO

perl(1).

=cut
