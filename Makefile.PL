use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		=> 'WWW::Wikipedia',
    VERSION_FROM	=> 'lib/WWW/Wikipedia.pm',
    ABSTRACT_FROM	=> 'lib/WWW/Wikipedia.pm', 
    AUTHOR		=> 'Ed Summers <esummers@flr.follett.com>',
    EXE_FILES           => [ qw( bin/wikipedia ) ],
    PREREQ_PM		=> 
			    {
				'HTML::Parser'	    => 1,
				'LWP::UserAgent'    => 1
			    },
);
