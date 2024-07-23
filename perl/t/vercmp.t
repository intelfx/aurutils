#!/usr/bin/env perl
use strict;
use warnings;
use v5.20;
use Test::More;

# Check if module can be imported
require_ok "AUR::Vercmp";

use AUR::Vercmp qw(vercmp);

ok(vercmp("1.0", "1.0", '='));
ok(vercmp("1.0a", "1.0b", '<'));
ok(vercmp("1", "1.0", '<='));
ok(vercmp("1:1", "1", '>'));
ok(vercmp("2.0", "1.0", '>='));
ok(vercmp("abc", undef, '<'));

done_testing();
