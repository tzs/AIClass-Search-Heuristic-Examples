OVERVIEW
========
Search.pl is a generic implementation of A* search I wrote to play around
a bit with heuristics after taking the online Stanford AI class. This code
is under a BSD license. See the LICENSE.txt file for details.

To use it, invoke it as follows:

    ./search.pl Problem [problem_arguments ...]

where "Problem" is the name of the problem you wish it to solve, and the
optional problem_arguments are any arguments specific to that problem.

This will do a search to solve your problem, and then will print out the
sequence of steps for the solution, and will tell you how many nodes were
expanded during the search.

It looks for a Perl moduled named Problem.pm, which contains the code that
actually defines the problem.

I have provided such modules for the Tower of Hanoi problem (Hanoi.pm), the
sliding block puzzle (Blocks.pm) from the AI class. I've also provided a
module for pancake sorting (Pancake.pm) and an essentially blank module
to use as a starting point if you want to define your own problems
(NewProblem.pm).

Thus, if you wanted to solve the Tower of Hanoi with 5 discs, you could
do this:

    ./search.pl Hanoi 5

The Hanoi module takes as an argument the number of discs. Hanoi by default
does not use A*. It takes an argument, -h, to indicate you want to use A*
using the heuristic from the final exam, so

    ./search.pl Hanoi -h 5

would be the command to run it using A*. Hanoi.pm also allows -h2 to try a
more sophisticated heuristic.

As a convenience, you can include a .pm at the end of the module name, e.g.,

    ./search.pl Hanoi.pm -h 5

so that if you are lazy and using tab-completion in your shell to fill
in the module name you don't have to backspace over the .pm.

REQUIRED FUNCTIONS OVERVIEW
===========================
To handle a new problem, make a perl module named after your problem. Your
module must provide five function:

    initialize
    is_goal
    heuristic
    neighbors
    to_string

Before I describe what each function must do, we need to go over how
nodes in the search space are represented. You are free to represent
them inside your module however you want. For example, for Tower of
Hanoi I represent them as a hash that looks like this for the start
node:

    {
        left => [1 2 3 4],  # what is on the left peg
        middle => [],       # what is on the middle peg
        right => [],        # what is on the right peg
        h => 4              # the heuristic value for this node
    }

For each node, you must provide a scalar representation to search.pl,
which will treat it as an opaque token that it can use, via an eq
comparison, to check if two nodes are the same and that it can pass
back to you to refer to the node.

For Hanoi, this is my scalar representation of the start node:

    1,2,3,4::
    
I chose to use a representation that would be meaningful to a human
when printed to make debugging easier, but there is no requirement
that the scalar be meaningful when printed. For the Block puzzle,
my scalar representation is simply a number, which actually represents
an index into an array of nodes that Blocks.pm generates.

I will refer to the scalar representation of a node as the "node token".

THE INITIALIZE FUNCTION
=======================
This will be called once, before any other function is called. It
will be passed an array of arguments from the command line. It should
parse these arguments and set up the problem.

It should return the node token for the start node.

THE IS_GOAL FUNCTION
====================
This is called with a node token, and should return a true value if
that is the node token for the goal. Otherwise, it should return false.

THE HEURISTIC FUNCTION
======================
This is called with a node token, and should return the heuristic value
for that node for A* search. If you do not want to do A*, return 0.

THE NEIGHBORS FUNCTION
======================
This is called with a node token, and should return a list with information
about the neighbors of that node. Each list entry is a reference to an array
that contains the node token for a neighbor and the cost of the link to that
neighbor.

For example, for Hanoi, using the node token format I gave earlier, if this
were called with start node, 1,2,3,4::, it would return a list with these
two elements:

    [ '2,3,4:1::', 1 ]
    [ '2,3,4::1', 1 ]

which means that the neighors of the start node are the nodes the result
from moving the smallest disc from the left to the middle, and from the
left to the right, respectively, and these moves each have a cost of 1.

THE TO_STRING FUNCTION
======================
Given a node token, this should return a human-friendly text representation
of the node. This is used when search.pl prints out the solution. It will
print for each step the path cost, a plus sign, the heuristic for the node
for that step, a tab, and then whatever to_string returns, followed by a
newline.

If you can represent the node in one line, return that. If your representation
takes more than one line, you should prefix it with a newline for best
results.

USING THE PROVIDED MODULES
==========================
Hanoi.pm takes as an argument the number of discs initially on the left
peg. If you want to use A* you can include one of the following:

    -h          # use the heuristic from the final exam
    -h2         # use a better heuristic

With no arguments, it defaults to NOT using A*, and 4 discs.
------------------------------------------------------------------------------
Blocks.pm takes the width, the height, and the list of tiles, with 0
marking the empty spot. For example, this scrambled 3x3 puzzle:

    1   7   0
    5   3   2
    4   8   6

would be entered by these arguments:

    3 3 1 7 0 5 3 2 4 8 6

You can preceed the puzzle specification by '-h' if you want to use A*
search.

The Blocks module also contains a function to generate scrambled puzzles
for you. To generate an W wide by H high puzzle, scrambled by making R
random moves starting from the solved state, do this:

    perl -MBlocks -e Blocks::sample W H R
------------------------------------------------------------------------------
Pancake.pm takes a list giving the sizes of the pancakes in your stack,
from top to bottom. For instance, to find out how to pancake sort a stack
of pancakes consisting of pancakes of size 5, 8, 6, 6, 4, 4, 9, 3, you
would do

    ./search.pl Pancake 5 7 8 8 4 4 9 3

Pancake.pm does not have a heuristic, as none has yet occurred to me.
