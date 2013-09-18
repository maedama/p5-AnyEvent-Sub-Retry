package AnyEvent::Sub::Retry;
use 5.008005;
use strict;
use warnings;
use AnyEvent;
use Exporter qw(import);
our @EXPORT_OK = qw/retry/;

our $VERSION = "0.01";

sub retry {
    my ( $retry_count, $retry_interval, $code_ref ) = @_;

    my $all_cv = AE::cv;
    my $timer;
    my $try;
    $try = sub {
        my $cv = eval { $code_ref->() };
        if ($@) {
            undef $try;
            $all_cv->croak( sprintf( "code_ref died with message:%s", $@ ) );
            return;
        }

        unless ( $cv && ref($cv) eq 'AnyEvent::CondVar' ) {
            undef $try;
            $all_cv->croak(
                sprintf( "code_ref does not return condvar ref:%s", ref($cv) )
            );
            return;
        }
        $cv->cb(
            sub {
                my @vals = eval { shift->recv };
                if ($@) {
                    $retry_count--;
                    if ( $retry_count > 0 ) {
                        $timer = AnyEvent->timer(
                            cb => sub { $try->(); undef $timer; },
                            after => $retry_interval,
                        );
                    }
                    else {
                        undef $try;
                        $all_cv->croak($@);
                    }
                }
                else {
                    undef $try;
                    $all_cv->send(@vals);
                }
            }
        );
    };
    $try->();
    return $all_cv;
}

1;
__END__

=encoding utf-8

=head1 NAME

AnyEvent::Sub::Retry

=head1 SYNOPSIS

    use AnyEvent::Sub::Retry;
    my $cv = retry 3, 1, sub {
        my $cv = AE::cv;
        ### do something
        if ($error) {
            $cv->croak("error");
        } else {
            $cv->send("success!");
        }
        return $cv;
    }
    my $result = $cv->recv;


=head1 DESCRIPTION

AnyEvent::Sub::Retry is Sub::Retry like module in AnyEvent.
In AnyEvent::Sub::Retry, code ref that is execute MUST returrn AnyEvent::CondVar object,  and MUST execute $cv->send or $cv->croak on case of error or success.


=head1 LICENSE

Copyright (C) maedama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

maedama E<lt>maedama@gmail.comE<gt>

=cut

