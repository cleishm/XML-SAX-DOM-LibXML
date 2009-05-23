use strict;
use warnings;
use XML::SAX::PurePerl;
use XML::SAX::Writer;

use Test::More tests => 4;

use lib 't';
require_ok('TestDOMFilter');


## Create a chained pipeline

# Create output writer
my $testout;
my $writer = XML::SAX::Writer->new(Output => \$testout);

# Create filters
my $filter = TestDOMFilter->new(Handler => $writer);
my $filter2 = TestDOMFilter->new(Handler => $filter);

# Create parser
my $parser = XML::SAX::PurePerl->new(Handler => $filter2);

# Parse string
my $testxml = "<?xml version='1.0'?><foo>bar<h1>!</h1></foo>";
$parser->parse_string($testxml, Handler => $filter2);

# Check output
SKIP: {
    eval { require XML::SemanticDiff }
        or skip 'XML::SemanticDiff is required for these tests', 2;
    my $diff = XML::SemanticDiff->new();

    is(scalar $diff->compare($testout, $testxml), 0, 'output correct');
    my $dom = $filter->result();
    is(scalar $diff->compare($dom, $testxml), 0, 'processsed DOM correct');
}

# Check data was passed as a DOM
ok($filter->passed_dom(), 'filter was passed a pre-parsed DOM');
