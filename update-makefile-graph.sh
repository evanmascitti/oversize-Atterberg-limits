#!/bin/bash 

make -Bnd | make2graph | dot -Tpdf -o makefile-graph.pdf 

# for svg output as well uncomment the following line and be 
# sure the whole command is on the same line, separated by
# a semicolon... 
# ; make -Bnd | make2graph | dot -Tsvg -o makefile-graph.svg

# I wanted to make this script both update the graph and then open it, but the
# start command won't work on WSL
# and makefile2graph won't work in Git Bash
# so I have to do the steps separately and therefore this command is commented out 

# start makefile-graph.pdf

