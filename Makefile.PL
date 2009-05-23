use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'XML::SAX::DOM::LibXML',
    'VERSION_FROM'	=> 'lib/XML/SAX/DOM/LibXML.pm', # finds $VERSION
    'AUTHOR'		=> 'Chris Leishman <chris@leishman.org>',
    'ABSTRACT_FROM'	=> 'lib/XML/SAX/DOM/LibXML.pm',
    'PREREQ_PM'		=> {
    	XML::SAX		=> 0.12,
	XML::LibXML		=> 1.53,
	XML::SAX::Cacheable	=> 1.00,
	Test::More		=> 0.47,
	XML::SAX::Writer	=> 0.42,
    },
);
