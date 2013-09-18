# NAME

AnyEvent::Sub::Retry

# SYNOPSIS

    use AnyEvent::Sub::Retry;
    # Try 3 times with 1 second interval
    my $cv = retry 3, 1, sub {
        my $cv = AE::cv;
        ### do something
        if ($error) {
            $cv->croak("error");
        } else {
            $cv->send("success!");
        }
    }
    my $result = eval { $cv->recv; }


# DESCRIPTION

AnyEvent::Sub::Retry is Sub::Retry like module in AnyEvent

# LICENSE

Copyright (C) maedama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

maedama <maedama@gmail.com>
