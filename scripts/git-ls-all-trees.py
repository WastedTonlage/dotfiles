#! /usr/bin/python3

import git
import os

repo = git.Repo(os.getcwd(), search_parent_directories=True)

trees = []
trees.append(repo.tree())
idx = 0
while idx < len(trees):
    tree = trees[idx]
    print(tree)
    trees = trees + tree.trees
    idx += 1

