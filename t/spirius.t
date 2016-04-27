use strict;
use warnings;
use lib '../lib';
use SMS::Send::Spirius;
use SMS::Send;
use Data::Dumper;
use Test::Simple tests => 2;

# Enter credentials and receiving phone number here
my $username = '';
my $password = '';
my $number   = '+46';
my $text     = 'TEst 123 äöåÄÖÅ';
#my $text     = '%E5%E4%F6%C5%C4%D6'; # javascript escaped  äöåÄÖÅ

# Tests under here
ok(via_sms_send($username, $password, $number, $text, 1) eq '202', 'Send sms via SMS::Send');
ok(via_sms_send_spirius('fake', 'fake', $number, $text, 1) eq '403', 'Invalid credentials');
#ok(via_sms_send_spirius($username, $password, $number, $text, 1) eq '400', 'Bad request');

sub via_sms_send {
  my ($login, $pass, $to, $text, $test) = @_;
  my $sender = SMS::Send->new('Spirius',
                 _login    => "$login",
                 _password => "$pass",
                 _sender   => 'sysmystic',
                 _test     => $test
               );

  return $sender->send_sms(
    text => "$text",
    to   => "$to",
  )->{status};
}

sub via_sms_send_spirius {
  my ($login, $pass, $to, $text, $test) = @_;
  my $sender = SMS::Send::Spirius->new(
                 _login    => "$login",
                 _password => "$pass",
                 _sender   => 'sysmystic',
                 _test     => $test
               );

  return $sender->send_sms(
    text => "$text",
    to   => "$to",
  )->{status};
}
