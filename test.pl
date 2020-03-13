use strict;
use warnings;

my $bool  = 0; # 1==print, 0==no print
my $dump  = 0; # 1==fdump, 0==no fdump
my $test  = 10;
my @test;
print "1.. ";
for(my $x = 0; $x < $test; $x++){
  print "\b".($x+1);
  $test[$x] = ($bool==1)?1:0;
}
print "\n";
our $loaded;

BEGIN { $| = 1; }
END   { print "not ok $test\n" unless $loaded; }

{
  use JoeDog::Stats;
  $test   = 1;
  $loaded = 1;
  print "ok $test\n";
}

{
  use JoeDog::Stats;
  $test   = 2;
  $loaded = 0;
  my @arr = (
    132, 138, 140, 141, 142, 143, 144, 145, 146, 149,
    150, 150, 151, 151, 152, 152, 153, 153, 154, 154,
    155, 155, 156, 156, 157, 157, 158, 158, 159, 159,
    160, 161, 163, 163, 163, 164, 165, 166, 165, 166,
    168, 169, 165, 166, 162, 171, 172, 173, 174, 175,
    176, 177, 178, 179, 183, 184, 185, 186, 187, 188,
    189, 191, 195, 199, 202, 206
  );

  my $stat = new JoeDog::Stats(\@arr);
  print sprintf("array mean:            \t%6.2f\n",  $stat->mean())         if $test[1];
  print sprintf("array median:          \t%6.2f\n",  $stat->median())       if $test[1];
  print sprintf("array mode:            \t%6.2f\n",  $stat->mode())         if $test[1];
  print sprintf("array 95 percentile:   \t%6.2f\n",  $stat->percentile(95)) if $test[1];
  print sprintf("array min:             \t%6.2f\n",  $stat->min())          if $test[1];
  print sprintf("array max:             \t%6.2f\n",  $stat->max())          if $test[1];
  print sprintf("array variance:        \t%6.2f\n",  $stat->variance())     if $test[1];
  print sprintf("array std deviation:   \t%6.2f\n",  $stat->stddev())       if $test[1];
  print sprintf("array skewness:        \t%6.2f\n",  $stat->skewness())     if $test[1];
  $stat->fdistribution(8, 130);
  print sprintf("grouped mean:          \t%6.2f\n",  $stat->mean())         if $test[1];
  print sprintf("grouped median:        \t%6.2f\n",  $stat->median())       if $test[1];
  print sprintf("grouped mode:          \t%6.2f\n",  $stat->mode())         if $test[1];
  print sprintf("grouped variance:      \t%6.2f\n",  $stat->variance())     if $test[1];
  print sprintf("grouped std deviation: \t%6.2f\n",  $stat->stddev())       if $test[1];
  print sprintf("grouped skewness:      \t%6.2f\n",  $stat->skewness())     if $test[1];
  $stat->fdump() if $dump;

  $loaded = 1;
  print "ok $test\n";
}

{
  use JoeDog::Stats;
  $test    = 3;
  $loaded  = 0;
  my %hash = (
    'a1' => 30, 'a2' => 31, 'a3' => 32, 'a4' => 35, 'a5' => 35,
    'b1' => 36, 'b2' => 36, 'b3' => 35, 'b4' => 35, 'b5' => 35,
    'c1' => 40, 'c2' => 41, 'c3' => 42, 'c4' => 44, 'c5' => 44,
    'd1' => 40, 'd2' => 41, 'd3' => 42, 'd4' => 44, 'd5' => 42,
    'e1' => 40, 'e2' => 45, 'e3' => 45, 'e4' => 46, 'e5' => 46,
    'f1' => 47, 'f2' => 47, 'f3' => 47, 'f4' => 47, 'f5' => 47,
    'g1' => 46, 'g2' => 46, 'g3' => 46, 'g4' => 46, 'g5' => 46,
    'h1' => 49, 'h2' => 49, 'h3' => 49, 'h4' => 49, 'h5' => 49,
    'i1' => 48, 'i2' => 48, 'i3' => 48, 'i4' => 50, 'i5' => 50,
    'j1' => 54, 'j2' => 51, 'j3' => 52, 'j4' => 50, 'j5' => 50,
    'k1' => 53, 'k2' => 52, 'k3' => 52, 'k4' => 50, 'k5' => 53,
    'l1' => 53, 'l2' => 52, 'l3' => 52, 'l4' => 50, 'l5' => 53,
    'm1' => 53, 'm2' => 52, 'm3' => 52, 'm4' => 50, 'm5' => 53,
    'n1' => 53, 'n2' => 52, 'n3' => 52, 'n4' => 50, 'n5' => 53,
    'o1' => 53, 'o2' => 52, 'o3' => 52, 'o4' => 50, 'o5' => 53,
    'p1' => 53, 'p2' => 54, 'p3' => 52, 'p4' => 50, 'p5' => 53,
    'q1' => 53, 'q2' => 54, 'q3' => 54, 'q4' => 65, 'q5' => 65,
    'r1' => 65, 'r2' => 68, 'r3' => 60, 'r4' => 64, 'r5' => 63,
    's1' => 64, 's2' => 64, 's3' => 64, 's4' => 64, 's5' => 63,
    't1' => 64, 't2' => 55, 't3' => 55, 't4' => 55, 't5' => 55,
    'u1' => 58, 'u2' => 58, 'u3' => 59, 'u4' => 59, 'u5' => 56,
    'v1' => 58, 'v2' => 58, 'v3' => 59, 'v4' => 59, 'v5' => 56,
    'w1' => 58, 'w2' => 58, 'w3' => 59, 'w4' => 59, 'w5' => 56,
    'x1' => 58, 'x2' => 58, 'x3' => 59, 'x4' => 59, 'x5' => 56,
  );

  my $stat = new JoeDog::Stats(\%hash);
  print sprintf("hash mean:             \t%6.2f\n",  $stat->mean())         if $test[2];
  print sprintf("hash median:           \t%6.2f\n",  $stat->median())       if $test[2];
  print sprintf("hash mode:             \t%6.2f\n",  $stat->mode())         if $test[2];
  print sprintf("hash 95 percentile:    \t%6.2f\n",  $stat->percentile(95)) if $test[2];
  print sprintf("hash min:              \t%6.2f\n",  $stat->min())          if $test[2];
  print sprintf("hash max:              \t%6.2f\n",  $stat->max())          if $test[2];
  print sprintf("hash variance:         \t%6.2f\n",  $stat->variance())     if $test[2];
  print sprintf("hash std deviation:    \t%6.2f\n",  $stat->stddev())       if $test[2];
  print sprintf("hash skewness:         \t%6.2f\n",  $stat->skewness())     if $test[2];
  $stat->fdistribution(8, 30, 69);
  print sprintf("grouped mean:          \t%6.2f\n",  $stat->mean())         if $test[2];
  print sprintf("grouped median:        \t%6.2f\n",  $stat->median())       if $test[2];
  print sprintf("grouped mode:          \t%6.2f\n",  $stat->mode())         if $test[2];
  print sprintf("grouped variance:      \t%6.2f\n",  $stat->variance())     if $test[2];
  print sprintf("grouped std deviation: \t%6.2f\n",  $stat->stddev())       if $test[2];
  print sprintf("grouped skewness:      \t%6.2f\n",  $stat->skewness())     if $test[2];
  $stat->fdump("|") if $dump;

  $loaded = 1;
  print "ok $test\n";
}

{
  use JoeDog::Stats; 
  $test    = 4;
  $loaded  = 0;
  my $tmp  = "./haha.txt";
  my ($s1, $v1, $s2, $v2);
  my $stat = new JoeDog::Stats("./test.txt");
  $s1 = $stat->stddev();
  $v1 = $stat->variance();
  print sprintf("1st variance:          \t%6.2f\n",  $s1)     if $test[3];
  print sprintf("1st std deviation:     \t%6.2f\n",  $v1)     if $test[3];
  $stat->save($tmp);
  my $haha = new JoeDog::Stats($tmp);
  $s2 = $haha->stddev();
  $v2 = $haha->variance(); 
  print sprintf("2nd variance:          \t%6.2f\n",  $s2)     if $test[3];
  print sprintf("2nd std deviation:     \t%6.2f\n",  $v2)     if $test[3];
  $loaded = 1 if (($s1 == $s2) && ($v1 == $v2));
  unlink($tmp);
  print "ok $test\n" if $loaded;
}

{
  use JoeDog::Stats;
  $test    = 5;
  $loaded  = 0;
  my $stat = new JoeDog::Stats();
  $stat->add(132);
  $stat->add(138);
  $stat->add(140);
  $stat->add(141); 
  $stat->add(142); 
  $stat->add(143);
  $stat->add(144); 
  $stat->add(145); 
  $stat->add(146); 
  $stat->add(149);
  $stat->add([150, 150, 151, 151, 152, 152, 153, 153, 154, 154]);
  $stat->add([155, 155, 156, 156, 157, 157, 158, 158, 159, 159]);
  $stat->add([160, 161, 163, 163, 163, 164, 165, 166, 165, 166]);
  $stat->add([168, 169, 165, 166, 162, 171, 172, 173, 174, 175]);
  $stat->add([176, 177, 178, 179, 183, 184, 185, 186, 187, 188]);
  $stat->add([189, 191, 195, 199, 202, 206]);
  print sprintf("array mean:            \t%6.2f\n",  $stat->mean())         if $test[4];
  print sprintf("array median:          \t%6.2f\n",  $stat->median())       if $test[4];
  print sprintf("array mode:            \t%6.2f\n",  $stat->mode())         if $test[4];
  $stat->fdistribution(8, 130);
  print sprintf("grouped mean:          \t%6.2f\n",  $stat->mean())         if $test[4];
  print sprintf("grouped median:        \t%6.2f\n",  $stat->median())       if $test[4];
  print sprintf("grouped mode:          \t%6.2f\n",  $stat->mode())         if $test[4];

  $loaded  = 1;
  print "ok $test\n" if $loaded;
  
}

{
  use JoeDog::Stats;

  $test    = 6;
  $loaded  = 0;

  my $stat = new JoeDog::Stats({'a1' => 30, 'a2' => 31, 'a3' => 32, 'a4' => 35, 'a5' => 35});
  my %hash = (
    'b1' => 36, 'b2' => 36, 'b3' => 35, 'b4' => 35, 'b5' => 35,
    'c1' => 40, 'c2' => 41, 'c3' => 42, 'c4' => 44, 'c5' => 44,
    'd1' => 40, 'd2' => 41, 'd3' => 42, 'd4' => 44, 'd5' => 42,
    'e1' => 40, 'e2' => 45, 'e3' => 45, 'e4' => 46, 'e5' => 46,
    'f1' => 47, 'f2' => 47, 'f3' => 47, 'f4' => 47, 'f5' => 47,
    'g1' => 46, 'g2' => 46, 'g3' => 46, 'g4' => 46, 'g5' => 46,
    'h1' => 49, 'h2' => 49, 'h3' => 49, 'h4' => 49, 'h5' => 49,
    'i1' => 48, 'i2' => 48, 'i3' => 48, 'i4' => 50, 'i5' => 50,
    'j1' => 54, 'j2' => 51, 'j3' => 52, 'j4' => 50, 'j5' => 50,
    'k1' => 53, 'k2' => 52, 'k3' => 52, 'k4' => 50, 'k5' => 53,
    'l1' => 53, 'l2' => 52, 'l3' => 52, 'l4' => 50, 'l5' => 53,
    'm1' => 53, 'm2' => 52, 'm3' => 52, 'm4' => 50, 'm5' => 53,
    'n1' => 53, 'n2' => 52, 'n3' => 52, 'n4' => 50, 'n5' => 53,
    'o1' => 53, 'o2' => 52, 'o3' => 52, 'o4' => 50, 'o5' => 53,
    'p1' => 53, 'p2' => 54, 'p3' => 52, 'p4' => 50, 'p5' => 53,
    'q1' => 53, 'q2' => 54, 'q3' => 54, 'q4' => 65, 'q5' => 65,
    'r1' => 65, 'r2' => 68, 'r3' => 60, 'r4' => 64, 'r5' => 63,
    's1' => 64, 's2' => 64, 's3' => 64, 's4' => 64, 's5' => 63,
    't1' => 64, 't2' => 55, 't3' => 55, 't4' => 55, 't5' => 55,
    'u1' => 58, 'u2' => 58, 'u3' => 59, 'u4' => 59, 'u5' => 56,
    'v1' => 58, 'v2' => 58, 'v3' => 59, 'v4' => 59, 'v5' => 56,
    'w1' => 58, 'w2' => 58, 'w3' => 59, 'w4' => 59, 'w5' => 56,
  );
  $stat->add(\%hash);
  $stat->add({'x1' => 58, 'x2' => 58, 'x3' => 59, 'x4' => 59, 'x5' => 56});
  print sprintf("hash mean:             \t%6.2f\n",  $stat->mean())         if $test[5];
  print sprintf("hash median:           \t%6.2f\n",  $stat->median())       if $test[5];
  print sprintf("hash mode:             \t%6.2f\n",  $stat->mode())         if $test[5];
  print sprintf("hash 95 percentile:    \t%6.2f\n",  $stat->percentile(95)) if $test[5];
  print sprintf("hash min:              \t%6.2f\n",  $stat->min())          if $test[5];
  print sprintf("hash max:              \t%6.2f\n",  $stat->max())          if $test[5];
  print sprintf("hash variance:         \t%6.2f\n",  $stat->variance())     if $test[5];
  print sprintf("hash std deviation:    \t%6.2f\n",  $stat->stddev())       if $test[5];
  print sprintf("hash skewness:         \t%6.2f\n",  $stat->skewness())     if $test[5];
  $stat->fdistribution(8, 30, 69);
  print sprintf("grouped mean:          \t%6.2f\n",  $stat->mean())         if $test[5];
  print sprintf("grouped median:        \t%6.2f\n",  $stat->median())       if $test[5];
  print sprintf("grouped mode:          \t%6.2f\n",  $stat->mode())         if $test[5];
  print sprintf("grouped variance:      \t%6.2f\n",  $stat->variance())     if $test[5];
  print sprintf("grouped std deviation: \t%6.2f\n",  $stat->stddev())       if $test[5];
  print sprintf("grouped skewness:      \t%6.2f\n",  $stat->skewness())     if $test[5];
  $stat->fdump("|") if $dump;
 
  $loaded  = 1;
  print "ok $test\n" if $loaded;
}

{
  use JoeDog::Stats;
  $test    = 7;
  $loaded  = 0;

  # check for division by zero errors
  my $stat = new JoeDog::Stats([1]);
  print sprintf("array mean:            \t%6.2f\n",  $stat->mean())         if $test[6];
  print sprintf("array median:          \t%6.2f\n",  $stat->median())       if $test[6];
  print sprintf("array mode:            \t%6.2f\n",  $stat->mode())         if $test[6];
  print sprintf("array 95 percentile:   \t%6.2f\n",  $stat->percentile(95)) if $test[6];
  print sprintf("array min:             \t%6.2f\n",  $stat->min())          if $test[6];
  print sprintf("array max:             \t%6.2f\n",  $stat->max())          if $test[6];
  print sprintf("array variance:        \t%6.2f\n",  $stat->variance())     if $test[6];
  print sprintf("array std deviation:   \t%6.2f\n",  $stat->stddev())       if $test[6];
  print sprintf("array skewness:        \t%6.2f\n",  $stat->skewness())     if $test[6];
  $stat->fdistribution(1);
  print sprintf("grouped mean:          \t%6.2f\n",  $stat->mean())         if $test[6];
  print sprintf("grouped median:        \t%6.2f\n",  $stat->median())       if $test[6];
  print sprintf("grouped mode:          \t%6.2f\n",  $stat->mode())         if $test[6];
  print sprintf("grouped variance:      \t%6.2f\n",  $stat->variance())     if $test[6];
  print sprintf("grouped std deviation: \t%6.2f\n",  $stat->stddev())       if $test[6];
  print sprintf("grouped skewness:      \t%6.2f\n",  $stat->skewness())     if $test[6];

  $stat = new JoeDog::Stats({'a'=>1});
  print sprintf("hash mean:             \t%6.2f\n",  $stat->mean())         if $test[6];
  print sprintf("hash median:           \t%6.2f\n",  $stat->median())       if $test[6];
  print sprintf("hash mode:             \t%6.2f\n",  $stat->mode())         if $test[6];
  print sprintf("hash 95 percentile:    \t%6.2f\n",  $stat->percentile(95)) if $test[6];
  print sprintf("hash min:              \t%6.2f\n",  $stat->min())          if $test[6];
  print sprintf("hash max:              \t%6.2f\n",  $stat->max())          if $test[6];
  print sprintf("hash variance:         \t%6.2f\n",  $stat->variance())     if $test[6];
  print sprintf("hash std deviation:    \t%6.2f\n",  $stat->stddev())       if $test[6];
  print sprintf("hash skewness:         \t%6.2f\n",  $stat->skewness())     if $test[6];
  $stat->fdistribution(2);
  print sprintf("grouped mean:          \t%6.2f\n",  $stat->mean())         if $test[6];
  print sprintf("grouped median:        \t%6.2f\n",  $stat->median())       if $test[6];
  print sprintf("grouped mode:          \t%6.2f\n",  $stat->mode())         if $test[6];
  print sprintf("grouped variance:      \t%6.2f\n",  $stat->variance())     if $test[6];
  print sprintf("grouped std deviation: \t%6.2f\n",  $stat->stddev())       if $test[6];
  print sprintf("grouped skewness:      \t%6.2f\n",  $stat->skewness())     if $test[6];

  $loaded  = 1;
  print "ok $test\n" if $loaded;
}

{
  use JoeDog::Stats;
  $test    = 8;
  $loaded  = 0;
 
  # positively skewed data test
  my $stat = new JoeDog::Stats([.5, .74]);  
  $stat->add([.75, .80, .83, .90, .91, .98, .88]);
  $stat->add([1.0, 1.1, 1.21, 1.22, 1.23, 1.12, 1.20, 1.23, 1.01, 1.02, 1.1, 1.1, 1.2, 1.2, 1.24]);
  $stat->add([1.25, 1.26, 1.26, 1.27, 1.28, 1.29, 1.32, 1.33, 1.40, 1.41, 1.43, 1.4, 1.3, 1.4]);
  $stat->add([1.25, 1.26, 1.26, 1.27, 1.28, 1.29, 1.32, 1.33, 1.40, 1.41, 1.43, 1.4, 1.3, 1.4]);
  $stat->add([1.5, 1.56, 1.56, 1.57, 1.58, 1.59, 1.62, 1.63, 1.60, 1.71, 1.73, 1.6, 1.5, 1.6]);
  $stat->add([1.75, 1.76, 1.76, 1.77, 1.78, 1.79, 1.82, 1.83, 1.80]);
  $stat->add([2, 2, 2.2]);
  $stat->add([2.4, 2.3]);
  $stat->fdistribution({
    0.50=>0.74, 0.75=>0.99, 1.00=>1.24, 1.25=>1.49, 
    1.50=>1.74, 1.75=>1.99, 2.00=>2.24, 2.25=>2.49
  });
  $stat->fdump() if $dump;
  print sprintf("grouped mean:          \t%6.2f\n",  $stat->mean())         if $test[7];
  print sprintf("grouped median:        \t%6.2f\n",  $stat->median())       if $test[7];
  print sprintf("grouped mode:          \t%6.2f\n",  $stat->mode())         if $test[7];
  print sprintf("grouped variance:      \t%6.2f\n",  $stat->variance())     if $test[7];
  print sprintf("grouped std deviation: \t%6.2f\n",  $stat->stddev())       if $test[7];
  print sprintf("grouped skewness:      \t%6.2f\n",  $stat->skewness())     if $test[7];

  $loaded  = 1;
  print "ok $test\n" if $loaded;
}

{
  use JoeDog::Stats;
  $test    = 9;
  $loaded  = 0; 

  my $stat = new JoeDog::Stats();
  $stat->add([605, 700, 780]);
  $stat->add([805, 900, 880, 815, 817, 888, 890]);
  $stat->add([1005, 1100, 1080, 1015, 1017, 1088, 1090, 1009, 1009, 1101, 1190]);
  $stat->add([1205, 1300, 1280, 1315, 1317, 1288, 1290, 1209, 1309, 1201, 1390]);
  $stat->add([1205, 1300, 1280, 1315, 1317, 1288, 1290, 1209, 1309, 1201, 1390]);
  $stat->add([1405, 1500, 1480, 1515, 1517, 1488, 1490, 1509, 1509, 1501, 1590]);
  $stat->add([1405, 1500, 1480, 1515, 1517, 1488, 1490, 1509, 1509, 1501, 1590]);
  $stat->add([1405, 1500, 1480, 1515, 1517, 1488, 1490, 1509, 1509, 1501, 1590]);
  $stat->add([1405, 1500, 1480, 1515, 1517, 1488, 1490]);
  $stat->add([1605, 1700, 1680, 1715, 1717, 1688, 1790, 1709, 1709, 1701, 1790, 1700]);
  $stat->add([1605, 1700, 1680, 1715, 1717, 1688, 1790, 1709, 1709, 1701, 1790, 1609]);
  $stat->add([1805, 1900, 1880, 1915, 1817, 1988, 1890, 1909, 1909]);
  $stat->add([2005, 2100, 2080, 2115]);
  $stat->fdistribution({ 
     600=> 799,  800=> 999, 1000=>1199, 1200=>1399, 
    1400=>1599, 1600=>1799, 1800=>1999, 2000=>2199
  });
  $stat->fdump() if $dump;
  print sprintf("grouped mean:          \t%8.2f\n",  $stat->mean())         if $test[8];
  print sprintf("grouped median:        \t%8.2f\n",  $stat->median())       if $test[8];
  print sprintf("grouped mode:          \t%8.2f\n",  $stat->mode())         if $test[8];
  print sprintf("grouped variance:      \t%8.2f\n",  $stat->variance())     if $test[8];
  print sprintf("grouped std deviation: \t%8.2f\n",  $stat->stddev())       if $test[8];
  print sprintf("grouped skewness:      \t%8.2f\n",  $stat->skewness())     if $test[8];
  $loaded  = 1;
  print "ok $test\n" if $loaded;
}

{
  use JoeDog::Stats;
  $test  = 10;
  $loaded = 0; 
  my $csum = 3.46;
  my $s1   = new JoeDog::Stats({'a1' => 3, 'a2' => 2, 'a3' => 4, 'a4' => 6});
  my $s2   = new JoeDog::Stats([3, 2, 4, 6]);
  my $r1   = sprintf("%.2f", $s1->gmean());
  my $r2   = sprintf("%.2f", $s2->gmean());

  $loaded = 1;
  print "ok $test\n" if $loaded && ($r1==$r2) && ($r2==$csum);
}

