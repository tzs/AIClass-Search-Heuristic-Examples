package Pancake;
use strict;

# external representation example:
#  1,3,2,5,4
# internal representation of that:
#  [1 3 2 5 4]
my %node;   # external rep => internal rep
my $ext_goal;   # ext rep of goal

#
# initialize is called once to set things up. It processes the command line
# arguments, and it returns the external representation of the start node.
#
sub initialize
{
    my @start;
    while (@ARGV) {
        push @start, shift @ARGV;
    }
    my $ext = int_to_ext(\@start);
    my @goal = sort {$a<=>$b} @start;
    $ext_goal = int_to_ext(\@goal);
    return $ext;
}

#
# heuristic returns the heuristic for the given node, which is specified
# by its external representation.
#
sub heuristic
{
    my($n) = @_;
    return 0;   # I have no idea for a good heuristic for pancake sorting
}

#
# is_goal returns 1 if the given node, given by its external representation, is the
# goal node. Otherwise, it returns 0.
#
sub is_goal
{
    my($n) = @_;
    return 1 if $n eq $ext_goal;
    return 0;
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
    my @pancakes = @{$node{$n}};
    my @prefix;
    while (@pancakes) {
        push @prefix, shift @pancakes;
        push @neighbors, [int_to_ext([reverse(@prefix), @pancakes]), 1];
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
    return $n;
}

##############################################################################
# Internal functions. These are not called by search.pl.
##############################################################################

sub int_to_ext
{
    my($pancakes) = @_;
    my @pancakes = @$pancakes;
    my $ext = join(",", @$pancakes);
    if ( ! defined $node{$ext} ) {
        $node{$ext} = \@pancakes;
    }
    return $ext;
}

1;
