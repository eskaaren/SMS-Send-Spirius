package SMS::Send::Spirius;
use HTTP::Tiny;
use URI::Escape;
use base 'SMS::Send::Driver';
use strict;
use warnings;
use utf8;
our $VERSION = '0.02';

sub new {
	my ($class, %args) = @_;

  unless ($args{'_login'} && $args{'_password'} && $args{'_sender'}) {
	  die "$class needs hash with _login, _password and _sender.\n"
  }

	my $self = bless {%args}, $class;
	$self->{base_url}    = 'https://get.spiricom.spirius.com:55001';
	$self->{send_url}    = $self->{base_url} . '/cgi-bin/sendsms';
	$self->{_sender}     = $self->{_sender} // 'SPIRIUS'; # "From" phone number +4612345789 or alphanumeric text.
                                                        # Probably limited to 11 chars when text.
  unless ($self->{_sender} =~ /^\+\d\d[\-\d]+$/) { # We expect either phone number: +46.. or alphanumeric: SPIRI..
    $self->{_sender} .= '&FromType=A';
  }
  $self->{_test} = $self->{_test} || undef;
	return $self;
}

sub send_sms {
	my ($self, %args) = @_;
  utf8::decode($args{'text'});
  my $query = $self->{send_url}
              . '?User=' . $self->{_login}
              . '&Pass=' . $self->{_password}
              . '&To=' . $args{'to'}
              . '&From=' . $self->{_sender}
              . '&Msg=' . uri_escape($args{'text'});

  if (defined($self->{_test})) {
	  return HTTP::Tiny->new->get("$query");
  }

	my $response = HTTP::Tiny->new->get("$query");
  if ($response->{status} eq "202") {
		return 1;
	}
	return 0;
}

1;

__END__

=head1 NAME

SMS::Send::Spirius - SMS::Send driver to send messages via Spirius HTTP Get API

=head1 SYNOPSIS

  use SMS::Send;

  # Create a sender
  my $sender = SMS::Send->new('Spirius',
		_login    => 'username',
		_password => 'password',
		_sender   => 'FROM ME', # Text, max 11 chars or phone number +46123456789
  );

  # Send a message
  my $sent = $sender->send_sms(
		text => 'This is a test message',
		to   => '+4612345678',
  );

  if ( $sent ) {
		print "Message sent ok\n";
  } else {
		print "Failed to send message\n";
  }


=head1 DESCRIPTION

A driver for SMS::Send to send SMS text messages via Spirius HTTP Get API

This is not intended to be used directly, but instead called by SMS::Send
(see synopsis above for a basic illustration, and see SMS::Send's documentation
for further information).


=head1 AUTHOR

Eivin Giske Skaaren, <eivin@sysmystic.com>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015  by Eivin Giske Skaaren

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.7 or,
at your option, any later version of Perl 5 you may have available.


=cut
