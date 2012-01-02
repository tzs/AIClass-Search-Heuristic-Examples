#!/usr/bin/env perl
use strict;
use Data::Dumper;

my $problem = shift @ARGV;
$problem =~ s/\.pm$//;
require "$problem.pm";

my $initialize = \&{$problem.'::initialize'};
my $heuristic = \&{$problem.'::heuristic'};
my $to_string = \&{$problem.'::to_string'};
my $is_goal = \&{$problem.'::is_goal'};
my $neighbors = \&{$problem.'::neighbors'};

my %frontier;
my %from;
my %cost;
my $expand_count = 0;
my $MAX_COST = 1000000;

my $start_node = &$initialize(@ARGV);
$frontier{$start_node} = 1;
$cost{$start_node} = 0;

my $goal_n = undef;
while ( ! defined($goal_n = expand_one())) {
    ;
}
for ( my $n = $goal_n; $n ne $start_node; $n = $from{$n}) {
    my $c = $cost{$n};
    my $h = &$heuristic($n);
    print "$c+$h\t", &$to_string($n), "\n";
}
print "0+", &$heuristic($start_node), "\t", &$to_string($start_node), "\n";
print "Expanded $expand_count\n";

sub expand_one
{
    ++$expand_count;
    if ( $expand_count % 100 == 0 ) {
        print "expanded $expand_count...\n";
    }
    # find the node on the frontier with the lowest score
    my $best_n = undef;
    my $best_cost = $MAX_COST;
    foreach my $n (keys %frontier) {
        my $n_cost = defined($cost{$n}) ? $cost{$n} : $MAX_COST;
        if ( $n_cost + &$heuristic($n) < $best_cost ) {
            $best_n = $n;
            $best_cost = $n_cost + &$heuristic($n);
        }
    }
    
    delete $frontier{$best_n};
    
    if ( &$is_goal($best_n) ) {
        return $best_n;
    }
    
    # get neighbors
    my @neighbors = &$neighbors($best_n);
    foreach my $ninf (@neighbors) {
        my($nn, $link_cost) = @$ninf;
        my $nn_cost = defined($cost{$nn}) ? $cost{$nn} : $MAX_COST;
        if ( $cost{$best_n} + $link_cost < $nn_cost ) {
            $cost{$nn} = $cost{$best_n} + $link_cost;
            $from{$nn} = $best_n;
            $frontier{$nn} = 1;
        }
    }
    return undef;
}
