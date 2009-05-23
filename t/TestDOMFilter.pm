package TestDOMFilter;

use strict;
use warnings;
use XML::SAX::DOM::LibXML;

our @ISA = qw(XML::SAX::DOM::LibXML);

sub new {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	my $self = $class->SUPER::new(@_);
	bless $self, $class;

	return $self;
}

sub process {
	my $self = shift;
	my ($dom) = @_;

	$self->{TestResult} = $dom->toString(0);

	return $dom;
}

sub result {
	my $self = shift;
	return $self->{TestResult};
}

sub handle_dom_libxml {
	my $self = shift;
	$self->{TestPassedDOM} = 1;
	$self->SUPER::handle_dom_libxml(@_);
}

sub passed_dom {
	my $self = shift;
	return $self->{TestPassedDOM};
}

sub cache_validity {
	my $self = shift;
	return $self->{TestValidity};
}

sub cache_expiry {
	my $self = shift;
	return $self->{TestExpires};
}

sub test_set_validity {
	my $self = shift;
	my ($validity) = @_;
	$self->{TestValidity} = $validity;
}

sub test_set_expiry {
	my $self = shift;
	my ($expires) = @_;
	$self->{TestExpires} = $expires;
}

1;
