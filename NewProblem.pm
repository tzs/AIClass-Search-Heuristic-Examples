package NewProblem;
use strict;

#
# initialize is called once to set things up. It processes the command line
# arguments, and it returns the external representation of the start node.
#
sub initialize
{
    return "start_node";
}

#
# heuristic returns the heuristic for the given node, which is specified
# by its external representation.
#
sub heuristic
{
    my($n) = @_;
    return 0;
}

#
# is_goal returns 1 if the given node, given by its external representation, is the
# goal node. Otherwise, it returns 0.
#
sub is_goal
{
    my($n) = @_;
    return 1 if $n eq "goal_node";
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
    push @neighbors, ["goal_node", 1] if $n eq "start_node";
    push @neighbors, ["start_node", 1] if $n eq "goal_node";
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

1;
