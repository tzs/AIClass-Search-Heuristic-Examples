package Blocks;
use strict;

# Internal representation:
#   [ list of tiles from left to right, top to bottom, with 0 for the blank ]
# External representation:
#   Index into array of known nodes
my @node;   # known nodes
my @h;      # heuristic
my %node_map;   # map node key to node number
my $width;
my $height;
my $goal;
my $USE_ASTAR = 0;

#
# initialize is called once to set things up. It processes the command line
# arguments, and it returns the external representation of the start node.
#
sub initialize
{
    my @tiles;
    while (@ARGV) {
        my $arg = shift @ARGV;
        if ( $arg eq '-h' ) {
            $USE_ASTAR = 1;
            next;
        }
        push @tiles, $arg;
    }
    $width = shift @tiles;
    $height = shift @tiles;
    my $start = node_for(\@tiles);
    
    my @goal = sort {$a <=> $b} @tiles;
    push @goal, 0;
    shift @goal;
    $goal = node_for(\@goal);
    
    return $start;
}

#
# heuristic returns the heuristic for the given node, which is specified
# by its external representation.
#
sub heuristic
{
    my($n) = @_;
    return $h[$n];
}

#
# is_goal returns 1 if the given node, given by its external representation, is the
# goal node. Otherwise, it returns 0.
#
sub is_goal
{
    my($n) = @_;
    return $n == $goal;
}

#
# Given a node, named by its external representation, neighbors returns a list of
# neighboring nodes. Each neighbor is represented by a reference to an array of
# two items: the external representation of the neighbor, and the cost of the link
# to that neighbor.
#
sub neighbors
{
    my($n) = @_;
    my @neighbors;
    my @tiles = @{$node[$n]};
    for (my $z = 0; $z < @tiles; ++$z) {
        if ( $tiles[$z] == 0 ) {
            my $row = int($z/$width);
            my $col = $z % $width;
            if ( $col > 0 ) {   # can move blank to left
                my @new = @tiles;
                ($new[$z], $new[$z-1]) = ($new[$z-1], $new[$z]);
                push @neighbors, [node_for(\@new), 1];
            }
            if ( $col < $width-1 ) {   # can move blank to right
                my @new = @tiles;
                ($new[$z], $new[$z+1]) = ($new[$z+1], $new[$z]);
                push @neighbors, [node_for(\@new), 1];
            }
            if ( $row > 0 ) {   # can move blank up
                my @new = @tiles;
                ($new[$z], $new[$z-$width]) = ($new[$z-$width], $new[$z]);
                push @neighbors, [node_for(\@new), 1];
               
            }
            if ( $row < $height-1 ) {   # can move blank down
                my @new = @tiles;
                ($new[$z], $new[$z+$width]) = ($new[$z+$width], $new[$z]);
                push @neighbors, [node_for(\@new), 1];
            }
            last;
        }
    }
    return @neighbors;
}

#
# to_string returns a human-friendly string representation of the given
# node, which is given by its external representation. This is used when
# printing the solution.
#
sub to_string
{
    my($n) = @_;
    my @tiles = @{$node[$n]};
    my $out = "\n-------------\n";
    for (my $r = 0; $r < $height; ++$r) {
        my @row;
        for (my $c = 0; $c < $width; ++$c) {
            push @row, shift @tiles;
        }
        $out .= join("\t", @row) . "\n";
    }
    return $out;
}

##############################################################################
# Internal functions. These are not called by search.pl.
##############################################################################

sub node_for
{
    my($tiles) = @_;
    my $key = join(",", @$tiles);
    if ( ! defined $node_map{$key} ) {      # first time seeing this node
        my @tiles = @$tiles;
        $node_map{$key} = @node;
        push @node, \@tiles;
        push @h, node_h(\@tiles);
    }
    return $node_map{$key};
}

sub node_h
{
    my($tiles) = @_;
    return 0 unless $USE_ASTAR;
    my $hval = 0;
    for (my $i = 0; $i < @$tiles; ++$i) {
        my $t = $tiles->[$i];
        next if $t == 0;
        my $row = int($i/$width);
        my $col = $i % $width;
        my $desired_row = int(($t-1)/$width);
        my $desired_col = ($t-1) % $width;
        $hval += abs($row - $desired_row) + abs($col - $desired_col);
    }
    return $hval;
}

#
# Generate a sample problem. Invoke from the command line:
#
#   perl -MBlocks -e Blocks::sample width height moves
#
# This will generate a sample problem with the given width and height
# by setting up a solved puzzle of that size and then scrambling it by
# making random moves. The last parameter gives the number of random
# moves. Example:
#
#   perl -MBlocks -e Blocks::sample 4 4 50
#
# generates a 4x4 puzzle (e.g., 15 blocks) that is scrambled by making
# 50 random moves.
#
# The output is a space separated list giving the width, the height,
# and then the tiles in left to right, top to bottom order with 0
# representing the blank tile.
# 
sub sample
{
    my $width = shift @ARGV || 4;
    my $height = shift @ARGV || 4;
    my $moves = shift @ARGV || 8;

    my $tiles = $width * $height - 1;
    my @tiles = (1..$tiles);
    push @tiles, 0;
    while ($moves-- > 0) {
        for (my $z = 0; $z < @tiles; ++$z) {
            if ( $tiles[$z] == 0 ) {
                my $row = int($z/$width);
                my $col = $z % $width;
                my @allowed;
                push @allowed, -1 if $col > 0;
                push @allowed, 1 if $col < $width-1;
                push @allowed, -$width if $row > 0;
                push @allowed, $width  if $row < $height-1;
                my $move = $allowed[int(rand(@allowed))];
                ($tiles[$z], $tiles[$z+$move]) = ($tiles[$z+$move], $tiles[$z]);
                last;
            }
        }
    }

    print join(" ", $width, $height, @tiles), "\n";
}


1;
