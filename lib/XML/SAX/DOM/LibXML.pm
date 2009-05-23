# $Id: LibXML.pm,v 1.10 2006/02/06 02:54:55 caleishm Exp $
package XML::SAX::DOM::LibXML;

require 5.005;
use strict;
use warnings;
use XML::LibXML::SAX::Builder;
use XML::LibXML::SAX::Parser;
use XML::SAX::Cacheable;
use Carp;

our @ISA = qw(XML::LibXML::SAX::Builder XML::SAX::Cacheable);

our $VERSION = '1.00';

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	my $self = $class->SUPER::new(@_);
	bless $self, $class;

	# create DOM parser now so that set_handler/get_handler has a target
	$self->{DOMParser} = XML::LibXML::SAX::Parser->new(@_);

	return $self;
}

sub end_document {
	my $self = shift;
	my $dom = $self->SUPER::end_document(@_);
	return $self->handle_dom_libxml($dom);
}

sub set_handler {
	my $self = shift;
	$self->{DOMParser}->set_handler( @_ );
}

sub get_handler {
	my $self = shift;
	$self->{DOMParser}->get_handler( @_ );
}

sub handle_dom_libxml {
	my $self = shift;
	my ($dom) = @_;

	# allow subclass to process the DOM
	$dom = $self->process($dom);

	# cache result
	if ($self->{DOMCache}) {
		my $fh = $self->{DOMCacheEntry}->handle('>');
		$dom->toFH($fh);

		# retrieve and store expiry & validity
		my $validity = $self->cache_validity();
		$self->{DOMCacheEntry}->set_validity($validity)
			if defined $validity;
		my $expiry = $self->cache_expiry();
		$self->{DOMCacheEntry}->set_expiry($expiry)
			if defined $expiry;
	}

	return $self->_output_dom($dom);
}

# subclasses should override this method
sub process {
	my $self = shift;
	my ($dom) = @_;
	return $dom;
}

sub _output_dom {
	my $self = shift;
	my ($dom) = @_;

	# Check if the next handler implements handle_dom_libxml
	my $handler = $self->get_handler();
	if ($handler and $handler->can('handle_dom_libxml')) {
		return $handler->handle_dom_libxml($dom);
	}
	else {
		return $self->{DOMParser}->generate($dom);
	}
}


# override default caching methods as we can just store an XML doc
sub cache_enable {
	my $self = shift;
	my ($cache_entry, $validity_only) = @_;

	$self->{DOMCache} = 1;
	$self->{DOMCacheEntry} = $cache_entry;
}

sub cache_disable {
	my $self = shift;
	$self->{DOMCache} = undef;
	$self->{DOMCacheEntry} = undef;
}

sub cache_playback {
	my $self = shift;
	my ($cache_entry) = @_;

	$self->{DOMCache}
		and croak "Can't playback when cache has been enabled";

	my $fh = $cache_entry->handle('<');

	# return if stream is empty
	return undef if not $fh or eof($fh);

	require XML::LibXML;
	my $parser = XML::LibXML->new();

	my $dom = $parser->parse_fh($fh);

	my $result = $self->_output_dom($dom);

	return wantarray? (1, $result) : 1;
}


sub cache_enabled {
	my $self = shift;
	return $self->{DOMCache};
}


1;
__END__

=head1 NAME

XML::SAX::DOM::LibXML - Wrapper class for using a LibXML DOM in SAX pipelines

=head1 SYNOPSIS

  use XML::SAX::DOM::LibXML;
  
  our @ISA = qw(XML::SAX::DOM::LibXML);

  sub new {
  	my $class = shift;
	my $self = $class->SUPER::new(@_);
	bless $self, $class;
	return $self;
  }

  sub process {
  	my $self = shift;
	my ($dom) = @_;
	...
	return $dom;
  }

=head1 DESCRIPTION

This module provides a wrapper that uses a SAX stream to create a LibXML DOM
that can be processed by the filter that inherits from this module.  Once the
DOM tree is built, the process method is invoked and passed the DOM as an
argument.  When the process method completes, the DOM is serialised back to
SAX events (with the exception below).

=head1 METHODS

The subclass of this module should overwrite the 'process' method.  It
receives a DOM tree as a single argument and should return a modified tree
that will be sent on down the SAX chain.

=head1 CHAINED LibXML DOM FILTERS

If this filter has a default handler registered as the next filter in the SAX
chain, that handler is checked to see if it implements a method called
'handle_dom_libxml'.  If so, this is invoked with the complete DOM tree (after
the process method completes) rather than sending SAX events.

This module also includes a handle_dom_libxml method which allows it to avoid
building the DOM when used after other modules derived from this module.

=head1 CACHING

This module inherits from XML::SAX::Cacheable, which provides an interface for
caching SAX filter output.  The default implementation of the Cacheable
interface allows the output of the module to be cached indefinitely and with
no dependencies.  Developers of DOM based filters may wish to override
interface methods to provide for output expiry and/or dependancy checking,
however developers should NOT need to override the 'cache_enable',
'cache_disable' or 'cache_playback' methods as these have already been 
optimized for caching DOM objects rather than SAX events.

To assist developers of derived modules, this interface contains a
'cached_enabled()' method, that returns a boolean indicating whether caching
has been enabled or not.

=head1 SEE ALSO

XML::SAX, XML::SAX::Cacheable

=head1 AUTHOR

Chris Leishman <chris@leishman.org>

=head1 COPYRIGHT

Copyright (C) 2006 Chris Leishman.  All Rights Reserved.

This module is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,
either expressed or implied. See the License for the specific language
governing rights and limitations under the License.

$Id: LibXML.pm,v 1.10 2006/02/06 02:54:55 caleishm Exp $

=cut
