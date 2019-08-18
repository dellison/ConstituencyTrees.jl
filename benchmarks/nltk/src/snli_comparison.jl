# First, set up the Julia package environment.
using Pkg
pkg"activate ."
pkg"develop ../../.."
pkg"instantiate"

# Now, download the SNLI dataset.
using NLIDatasets.SNLI
corpus = SNLI.train_tsv()

@assert isfile(corpus) "Error downloading data!"

# For comparison, call nltk through PyCall.
using PyCall
nltk = pyimport_conda("nltk", "nltk")
nltk_totree(s) = pycall(nltk.tree.Tree.fromstring, PyObject, s)

@show nltk_totree("(S (NP (DT the) (N cat)) (VP (V ate)))")

# Python baseline
py"""
import csv
import time

t0 = time.time()
print('reading dataset...')
with open('/home/david/.julia/datadeps/SNLI/snli_1.0/snli_1.0_train.txt') as f:
    trees = [row['sentence1_binary_parse'] for row in csv.DictReader(f, delimiter='\t')]
t1 = time.time()
print('done reading dataset! elapsed time: {}'.format(t1 - t0))
"""

py"""
import nltk

print('reading parse trees...')
t0 = time.time()
trees = [nltk.Tree.fromstring(t) for t in trees]
t1 = time.time()
print('done building trees! elapsed time: {}'.format(t1 - t0))

print('there are {} trees'.format(len(trees)))
"""

# Now, let's see if Julia is faster!

# Loading the dataset:
using CSV

println("loading dataset...")
t0 = time()
trees = [row.sentence1_binary_parse for row in CSV.File(corpus)]
t1 = time()

println("done! elapsed: $(t1 - t0) seconds")

# Parsing the tree structures:
using ConstituencyTrees: read_bracketed_tree

totree(str) = read_bracketed_tree(str)

totree("(S (NP (DT the) (N cat)) (VP (V ate)))") # compile it first

println("reading trees...")
t0 = time()
trees = totree.(trees)
t1 = time()
println("elapsed: $(t1 - t0) seconds")

println("there are $(length(trees)) trees")
