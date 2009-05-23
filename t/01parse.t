use strict;
use warnings;
use XML::SAX::PurePerl;
use XML::SAX::Writer;

use Test::More;

eval { require XML::SemanticDiff }
	or plan skip_all => 'XML::SemanticDiff required for this test';

plan tests => 3;

use lib 't';
require_ok('TestDOMFilter');


## Create a simple pipeline

# Create output writer
my $testout;
my $writer = XML::SAX::Writer->new(Output => \$testout);

# Create filter
my $filter = TestDOMFilter->new(Handler => $writer);

# Create parser
my $parser = XML::SAX::PurePerl->new(Handler => $filter);

# Parse string
my $testxml = "<?xml version='1.0'?><foo>bar<h1>!</h1></foo>";
$parser->parse_string($testxml, Handler => $filter);

# Check output
my $diff = XML::SemanticDiff->new();
is(scalar $diff->compare($testout, $testxml), 0, 'output correct');

my $dom = $filter->result();
is(scalar $diff->compare($dom, $testxml), 0, 'processed DOM correct');
