package Hanoi;
use strict;

#
# Internally represent a node as a hash:
#   left => [which discs are on the left]
#   middle => [which discs are on the middle]
#   right => [which discs are on the right]
#   h => value of heuristic
#
# Externally represent a node by a string
# defined like this:
#   NODE := LEFT ':' MIDDLE ':' RIGHT
#   LEFT := DISC_LIST
#   MIDDLE := DISC_LIST
#   RIGHT := DISC_LIST
#   DISCLIST := DISC DISC_LIST | <empty>
#   DISC := <number>
# where <number> is a disc number, with 1 being the smallest disc, 2 being the
# second smallest, and so on. Here is an example. The initial configuration is
# represented by the string
#   1,2,3,4::
# If the smallest disc were moved to the right peg and the next smallest to the
# middle, the representation would be 3,4:2:1.
#

# default options
my $discs = 4;
my $USE_ASTAR = 0;

#
# Mapping from external node representation to internal node representation
#
my %node_info;

#
# initialize is called once to set things up. It processes the command line
# arguments, and it returns the external representation of the start node.
# 
# Args can be:
#   n               use n discs
#   -h or -h1       use heuristic #1 (the one from the final)
#   -h2             use heuristic #2 (see node_h function for details)
#
sub initialize
{
    while (@ARGV) {
        my $arg = shift @ARGV;
        if ( $arg =~ /^-h(.*)/ ) {
            $USE_ASTAR = $1 || 1;
        } else {
            $discs = $arg
        };
    }
    return get_node([1..$discs],[],[]);
}

#
# heuristic returns the heuristic for the given node, which is specified
# by its external representation.
#
sub heuristic
{
    my($n) = @_;
    return $node_info{$n}{h};
}

#
# is_goal returns 1 if the given node, given by its external representation, is the
# goal node. Otherwise, it returns 0.
#
sub is_goal
{
    my($n) = @_;
    return 1 if scalar(@{$node_info{$n}{right}}) == $discs;
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
    my $ld = $node_info{$n}{left}[0] + 0;
    my $md = $node_info{$n}{middle}[0] + 0;
    my $rd = $node_info{$n}{right}[0] + 0;
    if ( $ld && ($ld < $md || $md == 0) ) {
        my @left = @{$node_info{$n}{left}};
        my @middle = @{$node_info{$n}{middle}};
        my @right = @{$node_info{$n}{right}};
        unshift @middle, shift @left;
        push @neighbors, [get_node(\@left, \@middle, \@right), 1];
    }
    if ( $ld && ($ld < $rd || $rd == 0) ) {
        my @left = @{$node_info{$n}{left}};
        my @middle = @{$node_info{$n}{middle}};
        my @right = @{$node_info{$n}{right}};
        unshift @right, shift @left;
        push @neighbors, [get_node(\@left, \@middle, \@right), 1];
    }
    if ( $md && ($md < $ld || $ld == 0) ) {
        my @left = @{$node_info{$n}{left}};
        my @middle = @{$node_info{$n}{middle}};
        my @right = @{$node_info{$n}{right}};
        unshift @left, shift @middle;
        push @neighbors, [get_node(\@left, \@middle, \@right), 1];
    }
    if ( $md && ($md < $rd || $rd == 0) ) {
        my @left = @{$node_info{$n}{left}};
        my @middle = @{$node_info{$n}{middle}};
        my @right = @{$node_info{$n}{right}};
        unshift @right, shift @middle;
        push @neighbors, [get_node(\@left, \@middle, \@right), 1];
    }
    if ( $rd && ($rd < $ld || $ld == 0) ) {
        my @left = @{$node_info{$n}{left}};
        my @middle = @{$node_info{$n}{middle}};
        my @right = @{$node_info{$n}{right}};
        unshift @left, shift @right;
        push @neighbors, [get_node(\@left, \@middle, \@right), 1];
    }
    if ( $rd && ($rd< $md || $md == 0) ) {
        my @left = @{$node_info{$n}{left}};
        my @middle = @{$node_info{$n}{middle}};
        my @right = @{$node_info{$n}{right}};
        unshift @middle, shift @right;
        push @neighbors, [get_node(\@left, \@middle, \@right), 1];
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
    # external representation is almost human friendly as is, so all we need to
    # do is tweak it a little to make it print even nicer.
    $n =~ s/:/\t/g;
    return $n;
}

##############################################################################
# Internal functions. These are not called by search.pl.
##############################################################################

#
# Given the configuration of the three pegs, get_node returns the external
# representation of that node, and adds the internal representation to
# node_info if it is not already there.
#
sub get_node
{
    my($left, $middle, $right) = @_;
    my $ext_rep = join(':', join(',', @$left), join(',', @$middle), join(',', @$right));
    if ( ! defined $node_info{$ext_rep} ) {
        $node_info{$ext_rep} = { 'left' => [@$left],
                            'middle' => [@$middle],
                            'right' => [@$right],
                            'h' => node_h($left,$middle,$right) };
    }
    return $ext_rep;
}

#
# Given the configuration of the three pegs, node_h returns the heuristic value for
# that configuration.
#
sub node_h
{
    my($left, $middle, $right) = @_;
    return 0 unless $USE_ASTAR;
    return 0+@$left if $USE_ASTAR == 1;

    #
    # A more complex heuristic: number of discs on left plus number on middle plus
    # twice the number of discs on right for which there is a bigger disc on left
    # or middle
    my $h = @$left + @$middle;
    my $ml = $left->[@$left-1];
    my $mm = $middle->[@$middle-1];
    for (my $i = 0; $i < @$right; ++$i) {
        if ( $right->[$i] < $ml || $right->[$i] < $mm ) {
            $h += 2;
        }
    }
    return $h;
}

1;
