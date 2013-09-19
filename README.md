# NAME

AnyEvent::Sub::Retry - retry $n times in AnyEvent

# SYNOPSIS

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



# DESCRIPTION

AnyEvent::Sub::Retry is Sub::Retry like module in AnyEvent.
In AnyEvent::Sub::Retry, code ref that is executed MUST returrn AnyEvent::CondVar object.
Coderef MUST execute $cv->send or $cv->croak on case of error or success.

# METHODS

# FUNCTIONS

## retry($count, $interval\_second, $code\_ref) : AnyEvent::CondVar

# LICENSE

Copyright (C) maedama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

maedama <maedama85@gmail.com>
