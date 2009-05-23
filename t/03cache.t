use strict;
use warnings;
use XML::LibXML::SAX::Parser;
use XML::SAX::Writer;

use Test::More;

eval { require Cache::Memory }
	or plan skip_all => 'Cache::Memory is required for this test.';

plan tests => 8;

my $diff;
eval { require XML::SemanticDiff; $diff = XML::SemanticDiff->new() };

use lib 't';
require_ok('TestDOMFilter');


## Create a simple pipeline

# Create output writer
my $testout;
my $writer = XML::SAX::Writer->new(Output => \$testout);

# Create filter
my $filter = TestDOMFilter->new(Handler => $writer);

# Create parser
my $parser = XML::LibXML::SAX::Parser->new(Handler => $filter);


## Setup caching

# Set a validity string
my $validity = 'A test validity string';
$filter->test_set_validity($validity);

# Set an expiry
my $expiry = time + 600;
$filter->test_set_expiry($expiry);

# Create cache entry
my $cache = Cache::Memory->new();
my $cache_entry = $cache->entry('testentry');

# Enable caching
$filter->cache_enable($cache_entry);


## Run pipeline

my $testxml = "<?xml version='1.0' encoding='UTF-8'?><foo>bar<h1>!</h1></foo>";
$parser->parse_string($testxml, Handler => $filter);

# Check output
SKIP: {
    $diff or skip 'XML::SemanticDiff required for these tests', 2;
    is(scalar $diff->compare($testout, $testxml), 0, 'output correct');
    my $dom = $filter->result();
    is(scalar $diff->compare($dom, $testxml), 0, 'processed DOM correct');
}


# Disable caching
$filter->cache_disable();

# Check cache
ok($cache_entry->exists(), 'Entry created');

SKIP: {
    $diff or skip 'XML::SemanticDiff required for these tests', 1;
    my $content = $cache_entry->get();
    is(scalar $diff->compare($content, $testxml), 0, 'cached DOM correct');
}

# Validity should have been set
is($cache_entry->validity(), $validity, 'Validity correctly set');

# The expiry should have been set
is($cache_entry->expiry(), $expiry, 'Expiry correctly set');


## Playback cache

# Set new output
my $testout2;
my $writer2 = XML::SAX::Writer->new(Output => \$testout2);
$filter->set_handler($writer2);

# Playback
$filter->cache_playback($cache_entry);

# Output should be the same as original
is($testout2, $testout, 'Cached output is correct');
