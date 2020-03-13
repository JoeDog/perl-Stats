#
# Makefile.PL for JoeDog::Stats
#
# Filename:     Makefile.PL
# Author:       Jeffrey Fulmer
# Created:      04 January 2006
#
 
use ExtUtils::MakeMaker;
 
&WriteMakefile(
  ABSTRACT      => 'JoeDog::Stats module',
  VERSION_FROM  => 'Stats.pm',
  PM            => {
     'Stats.pm' => '$(INST_LIBDIR)/Stats.pm',
  }, 
  dist          => {
    'COMPRESS'  => 'gzip -9f', 'SUFFIX'      => 'gz',
    'ZIP'       => '/usr/bin/zip','ZIPFLAGS' => '-rl'
  },
  AUTHOR        => 'Jeff Fulmer <jeff@joedog.org>',
  NAME          => 'JoeDog::Stats'
); 


