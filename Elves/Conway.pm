package Elves::Conway;
# SPDX-License-Identifier: MIT

use 5.030000;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
	run_game
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

our $VERSION = '0.20.17';

my %settings = (
    dimensions => 2,
    turn_on    => [],
    stay_on    => [],
    toggle     => [],
    plane_maps => [],
);

my $main_map = {};

sub init {
    $main_map = {};
    my %config = (@_);
    if (! exists($config{'dimensions'})) {
        return undef;
    }
    $settings{'dimensions'} = $config{'dimensions'};
    if (exists($config{'active_mark'})) {
        $settings{'active_mark'} = $config{'active_mark'};
    } else {
        $settings{'active_mark'} = '#';
    }
    if (exists($config{'stay_on'})) {
        $settings{'stay_on'} = {map { $_ => undef } @{$config{'stay_on'}}};
    } else {
        $settings{'stay_on'} = {};
    }
    if (exists($config{'turn_on'})) {
        $settings{'turn_on'} = {map { $_ => undef } @{$config{'turn_on'}}};
    } else {
        $settings{'turn_on'} = {};
    }
    if (exists($config{'toggle'})) {
        $settings{'toggle'} = {map { $_ => undef } @{$config{'toggle'}}};
    } else {
        $settings{'toggle'} = {};
    } 
    if (! exists($config{'plane_maps'})) {
        return undef;
    }
    foreach my $plane_settings (@{$config{'plane_maps'}}) {
        my %plane_setup = (
            char_dim    => $plane_settings->{'char_dim'},
            char_start  => $plane_settings->{'char_start'},
            line_dim    => $plane_settings->{'line_dim'},
            line_start  => $plane_settings->{'line_start'},
            base_coords => [(0) x $settings{'dimensions'}],
            datum_list  => [@{$plane_settings->{'datum'}}],
        );
        $plane_setup{'base_coords'}->[$plane_setup{'line_dim'}] = $plane_setup{'line_start'};
        $plane_setup{'base_coords'}->[$plane_setup{'char_dim'}] = $plane_setup{'char_start'};
        $plane_setup{'base_node'} = join(':', @{$plane_setup{'base_coords'}});
        load_plane(
            $main_map,
            $plane_setup{'char_dim'},
            $plane_setup{'line_dim'},
            $plane_setup{'base_node'},
            @{$plane_setup{'datum_list'}}
        );
        push @{$settings{'plane_maps'}}, \%plane_setup;
    }
    $settings{'init'} = undef;
}

sub list_neighbors { # ($target [, $dimension = 0 [, @scan_coords = coords of $target]]) => @node_ids
    my $target = shift; # The node id for which the neighbor list will be built
    my @target_coords = split ':', $target; # $target split into coordinates
    my $dimension; # The current dimension, ranges from 0 to max dimension
    my @list; # List of neighbor node id's of the target node
    if (defined $_[0]) {
        $dimension = shift;
    } else {
        $dimension = 0;
    }
    my @scan_coords; # The reference point, in this dimension to work around
    if (defined $_[0]) {
        @scan_coords = @_;
    }else {
        @scan_coords = split ':', $target;
    }
    my @test_coords; # The coordinates to inspect
    my $test_id; # The node id of a potential neighbor
    for ($target_coords[$dimension] - 1 .. $target_coords[$dimension] + 1) {
        @test_coords = (@scan_coords);
        $test_coords[$dimension] = $_;
        $test_id = sprintf(join(':', (('%d') x scalar(@test_coords))),(@test_coords));
        if ($dimension == $#target_coords) {
            unless ($target eq $test_id) {
                push @list, $test_id;
            }
        } else {
            push @list, (list_neighbors($target, $dimension + 1, @test_coords));
        }
    }
    return @list;
}

sub count_neighbors { # ($ref_map hashref, $target) => count of active neighbors
    my $ref_map = shift; # The map of nodes
    my $target = shift;  # The node to count active neighbors of
    my $count = 0; # Running count of active neighbors
    my @neighbor_list = (list_neighbors($target)); # The list of neighbors to check for activity
    foreach (@neighbor_list) {
        $count++ if (exists($ref_map->{$_}));
    }
    return $count;
}

sub point_switch { # ($ref_map hashref) => $new_map hashref
    my $ref_map = shift; # The current node map
    my @neighbor_list = (); # List of neighbors to check (constantly rebuilt)
    my $neighbor_map = {}; # A record of nodes already checked
    my $new_map = {}; # The new node map bding built
    foreach my $node (sort keys %{$ref_map}) {
        push @neighbor_list, (list_neighbors($node));
    }
    foreach my $target (@neighbor_list) {
        unless (exists($neighbor_map->{$target})) {
            $neighbor_map->{$target} = count_neighbors($ref_map, $target);
            if (exists($ref_map->{$target})) {
                $new_map->{$target} = 1 if (exists($settings{'stay_on'}->{$neighbor_map->{$target}}));
            } else {
                $new_map->{$target} = 1 if (exists($settings{'toggle'}->{$neighbor_map->{$target}}));
                $new_map->{$target} = 1 if (exists($settings{'turn_on'}->{$neighbor_map->{$target}}));
            }
        }
    }
    return $new_map;
}

sub load_plane { # ($world_map, $char_dim, $line_dim, $ref_point, @inputs)
    my $world_map = shift; # The map of nodes to add this plane to
    my $char_dim = shift; # The dimension represented by each character of each array element
    my $line_dim = shift; # The dimension represented by each element in the input array
    my $ref_point = shift; # The node id anchor-point of input map (data fills in positive direction)
    my @coords = (split ':', $ref_point); # The coordinates of the anchor-point
    my @new_coords = (@coords); # The rolling set of coordinates for placing the data
    my @inputs = @_; # The data to place into the world_map
    foreach my $row (0..$#inputs) {
        $new_coords[$line_dim] = $row;
        my @datum = split //, $inputs[$row];
        foreach my $col (0..$#datum) {
            $new_coords[$char_dim] = $col;
            $world_map->{sprintf(join(':', (('%d') x scalar(@new_coords))),(@new_coords))} = 1
                if ($settings{'active_mark'} eq $datum[$col]);
        }
    }
}

sub run_game {
    if (! exists($settings{'init'})) {
        return undef;
    }
    my $node_map = $main_map;
    my $dimensions = $settings{'dimensions'};
    my @base_coords = (0) x $dimensions;
    foreach (1 .. $_[0]) {
        $node_map = point_switch($node_map);
    }
    return $node_map;
}
        
1;
__END__

=head1 NAME

Elves::Conway - Perl extension for processing the data files in the
daily challenges of Advent of Code

=head1 SYNOPSIS

  use Elves::Conway;

=head1 DESCRIPTION

Read the contents of the file for the day, and parse the results into
one of the forms needed for the challenge.

=head2 EXPORT

    init: load the parameters for the Game of Life
    run_game: run the game for given number of iterations.
        Returns a hashref of currently active nodes.

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
