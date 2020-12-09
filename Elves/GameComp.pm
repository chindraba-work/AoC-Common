package Elves::GameComp;
# SPDX-License-Identifier: MIT

use 5.030000;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	boot_game
	run_game
	$clean_exit
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.20.06';

our $clean_exit = 0;
my @game_code = ();
my $register;
my $program_counter;
my $resume = 0;

my %interpreter = (
    acc => sub {
        $register += $_[0];
        $program_counter++;
    },
    jmp => sub {
        $program_counter += $_[0];
    },
    nop => sub {
        $program_counter++;
    },
);

sub boot_game {
    @game_code = @_;
    $program_counter = 0;
    $register = 0;
    $resume = 1;
    return run_game();
}
sub run_game {
    my @loop_detector = (0) x scalar (@game_code);
    while ($resume && $program_counter < scalar @game_code) {
        my @opcode = split / /, $game_code[$program_counter];
        $loop_detector[$program_counter] = 1;
        &{$interpreter{$opcode[0]}}($opcode[1]);
        $resume = (defined $loop_detector[$program_counter] && ! $loop_detector[$program_counter]);
    }
    $clean_exit = ($program_counter == scalar @game_code);
    return $register;
}


1;
__END__

=head1 NAME

Elves::GameComp - Perl extension for processing the data files in the
daily challenges of Advent of Code

=head1 SYNOPSIS

  use Elves::GameComp;

=head1 DESCRIPTION

Read the contents of the file for the day, and parse the results into
one of the forms needed for the challenge.

=head2 EXPORT

None by default.

=head1 AUTHOR

Chindraba, E<lt>aoc@chindraba.workE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright © 2019, 2020  Chindraba (Ronald Lamoreaux)
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
