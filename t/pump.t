#!/usr/bin/perl -w

=head1 NAME

run.t - Test suite for IPC::Run::run, etc.

=cut

use strict ;

use Test ;

use IPC::Run qw( start pump finish ) ;
use UNIVERSAL qw( isa ) ;

##
## $^X is the path to the perl binary.  This is used run all the subprocesses.
##
my @echoer = ( $^X, '-pe', 'BEGIN { $| = 1 }' ) ;

my $in ;
my $out ;

my $h ;

my $fd_map ;

sub map_fds() { &IPC::Run::_map_fds }

# $IPC::Run::debug = 2 ;

my @tests = (
##
## harness, pump, run
##
sub {
   $in  = 'SHOULD BE UNCHANGED' ;
   $out = 'REPLACE ME' ;
   $? = 99 ;
   $fd_map = map_fds ;
   $h = start( \@echoer, \$in, \$out ) ;
   ok( isa( $h, 'IPC::Run' ) ) ;
},
sub { ok( $?, 99 ) },

sub { ok( $in,  'SHOULD BE UNCHANGED' ) },
sub { ok( $out, '' ) },
sub { ok( $h->pumpable ) },

sub {
   $in  = '' ;
   $? = 0 ;
   pump_nb $h for ( 1..100 ) ;
   ok( 1 ) ;
},
sub { ok( $in, '' ) },
sub { ok( $out, '' ) },
sub { ok( $h->pumpable ) },

sub {
   $in  = "hello\n" ;
   $? = 0 ;
   pump $h until $out =~ /hello/ ;
   ok( 1 ) ;
},
sub { ok( ! $? ) },
sub { ok( $in, '' ) },
sub { ok( $out, "hello\n" ) },
sub { ok( $h->pumpable ) },

sub {
   $in  = "world\n" ;
   $? = 0 ;
   pump $h until $out =~ /world/ ;
   ok( 1 ) ;
},
sub { ok( ! $? ) },
sub { ok( $in, '' ) },
sub { ok( $out, "hello\nworld\n" ) },
sub { ok( $h->pumpable ) },

sub { ok( $h->finish ) },
sub { ok( ! $? ) },
sub { ok( map_fds, $fd_map ) },
sub { ok( $out, "hello\nworld\n" ) },
sub { ok( ! $h->pumpable ) },
) ;

plan tests => scalar @tests ;

$_->() for ( @tests ) ;
