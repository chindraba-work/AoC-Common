package Elves::Reports;
# SPDX-License-Identifier: MIT

use 5.026001;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	report_loaded
	report_number
	report_string
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.21.15';

sub report_loaded {
    printf "Advent of Code %u, Day %u initialization complete (Taking %f ms.)\n",
        $main::aoc_year,
        $main::challenge_day,
        Time::HiRes::tv_interval($main::start_time[0]) * 1_000;
    $main::start_time[0] = [Time::HiRes::gettimeofday()];
}

sub report_number {
    $main::start_time[$_[0]] = [Time::HiRes::gettimeofday()];
    printf "Advent of Code %u, Day %u Part %u : the answer is %u (Taking %f ms.)\n",
        $main::aoc_year,
        $main::challenge_day,
        $_[0],
        $_[1],
        Time::HiRes::tv_interval($main::start_time[$_[0] - 1]) * 1_000;
}

sub report_string {
    $main::start_time[$_[0]] = [Time::HiRes::gettimeofday()];
    printf "Advent of Code %u, Day %u Part %u : the answer is «%s» (Taking %f ms.)\n",
        $main::aoc_year,
        $main::challenge_day,
        $_[0],
        $_[1],
        Time::HiRes::tv_interval($main::start_time[$_[0] - 1]) * 1_000;
}

1;
__END__

=head1 NAME

Elves::Reports - Perl extension for reporting the answers to the
daily challenges of Advent of Code

=head1 SYNOPSIS

  use Elves::Reports qw( :all );

=head1 DESCRIPTION

Report, in a common format, the answers to daily challenges for the
Advent of Code

=head2 EXPORT

None by default.

=head1 AUTHOR

Chindraba, E<lt>aoc@chindraba.workE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright © 2020, 2021  Chindraba (Ronald Lamoreaux)
                  <aoc@chindraba.work>
- All Rights Reserved

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

=cut
