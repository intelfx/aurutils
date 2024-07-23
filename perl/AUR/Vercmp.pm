package AUR::Vercmp;
use strict;
use warnings;
use v5.20;

use Carp;
use Exporter qw(import);
our @EXPORT_OK = qw(vercmp);
our $VERSION = 'unstable';

sub vercmp_run {
    if (defined $ENV{'AUR_DEBUG'}) {
        say STDERR __PACKAGE__ . ': vercmp ' . join(" ", @_);
    }
    my @command = ('vercmp', @_);
    my $child_pid = open(my $fh, "-|", @command) or die $!;
    my $num;

    if ($child_pid) {
        $num = <$fh>;
        waitpid($child_pid, 0);
    }
    die __PACKAGE__ . ": vercmp failure" if $?;
    return $num;
}

sub vercmp_ops {
    my %ops = (
        '<'  => sub { $_[0] <  $_[1] },
        '>'  => sub { $_[0] >  $_[1] },
        '<=' => sub { $_[0] <= $_[1] },
        '>=' => sub { $_[0] >= $_[1] },
    );
    return %ops;
}

=head2 vercmp()

This function provides a simple way to call C<vercmp(8)> from perl code.
Instead of ordering versions on the command-line, this function takes
an explicit comparison operator (<, >, =, <= or >=) as argument.

Under the hood, this function calls the C<vercmp> binary explicitly.
This avoids any rebuilds for C<libalpm.so> soname bumps. To keep the approach
performant, C<vercmp> is only called when input versions differ.

=cut

sub vercmp {
    my ($ver1, $ver2, $op) = @_;
    my %cmp = vercmp_ops();

    if (not defined $ver2 or not defined $op) {
        return "true";  # unversioned dependency
    }
    elsif ($op eq '=') {
        return $ver1 eq $ver2;
    }
    elsif (defined $cmp{$op}) {
        # check if cmp(ver1, ver2) holds        
        return $cmp{$op}->(vercmp_run($ver1, $ver2), 0);
    }
    else {
        croak "invalid vercmp operation";
    }
}
