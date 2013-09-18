package AnyEvent::Sub::Retry;
use 5.008005;
use strict;
use warnings;
use AnyEvent;
use Exporter qw(import);
our @EXPORT_OK = qw/retry/;

our $VERSION = "0.01";

sub retry {
    my ($retry_count, $retry_interval, $code_ref) = @_;

    my $all_cv = AE::cv;
    my $timer;
    my $try ; $try = sub {
        my $cv = $code_ref->();
        unless ($cv && ref($cv) eq 'AnyEvent::CondVar') {
            $all_cv->croak(sprintf("code_ref does not return condvar ref:%s", ref($cv)));
            return;
        } 
        $cv->cb(sub {
            my @vals = eval { shift->recv };
            if ($@) {
                $retry_count--;
                if ($retry_count > 0) {
                    $timer = AnyEvent->timer(
                        cb    => sub { $try->(); undef $timer;},
                        after => $retry_interval,
                    );
                } else {
                    $all_cv->croak($@);
                }
            } else {
                $all_cv->send(@vals);
            }
        });
    };
    $try->();
    return $all_cv;
}



1;
__END__

=encoding utf-8

=head1 NAME

AnyEvent::Sub::Retry - It's new Sub::Retry like module

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
    }
    my $result = $cv->recv;


=head1 DESCRIPTION

AnyEvent::Sub::Retry is ...

=head1 LICENSE

Copyright (C) maedama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

maedama E<lt>maedama@gmail.comE<gt>

=cut

