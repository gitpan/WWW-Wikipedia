use ExtUtils::MakeMaker;

WriteMakefile(
    NAME		=> 'WWW::Wikipedia',
    VERSION_FROM	=> 'lib/WWW/Wikipedia.pm',
    ABSTRACT_FROM	=> 'lib/WWW/Wikipedia.pm', 
    AUTHOR		=> 'Ed Summers <esummers@flr.follett.com>',
    EXE_FILES           => [ qw( bin/wikipedia ) ],
    PREREQ_PM		=> 
			    {
				'LWP::UserAgent'    => 0,
                                'CGI'               => 0,
                                'Text::Autoformat'  => 0,
			    },
);
