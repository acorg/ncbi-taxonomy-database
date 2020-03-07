#!/usr/bin/env python

from __future__ import print_function

import sys
import sqlite3
import argparse
from collections import Counter


parser = argparse.ArgumentParser(
    formatter_class=argparse.ArgumentDefaultsHelpFormatter,
    description='Describe the full virus taxonomy.')

parser.add_argument(
    '--maxDepth', type=int,
    help='The maximum depth to descend.')

args = parser.parse_args()

maxDepth = args.maxDepth
width = 40

conn = sqlite3.connect('taxonomy.db')
conn.row_factory = sqlite3.Row


class LevelRecorder():
    def __init__(self):
        self.levels = {}

    def add(self, rank, level, parentRank):
        try:
            currentLevel, currentParentRank, count = self.levels[rank]
        except KeyError:
            self.levels[rank] = (level, parentRank, 1)
            # assert self.levels[parentRank][0] < level, parentRank
        else:
            if level > currentLevel:
                print(
                    'Adjusting %s from (level: %d, parent: %s) to '
                    '(level: %d parent: %s).' %
                    (rank, currentLevel, currentParentRank, level, parentRank),
                    file=sys.stderr)
                self.levels[rank] = (level, parentRank, count + 1)
            else:
                self.levels[rank] = (currentLevel, currentParentRank,
                                     count + 1)


levels = LevelRecorder()


def name(taxid, conn):
    cur = conn.execute('SELECT name FROM names WHERE taxid = ?', (taxid,))
    return cur.fetchone()['name']


def rank(taxid, conn):
    cur = conn.execute('SELECT rank FROM nodes WHERE taxid = ?', (taxid,))
    return cur.fetchone()['rank']


def descendants(parentTaxid, parentRank, depth, conn):
    if maxDepth is not None and depth > maxDepth:
        return

    indent = '  ' * depth
    print('%-*s %s' % (
        width, '%s%d. %s' % (indent, depth, parentRank),
        name(parentTaxid, conn)))
    cur = conn.execute(
        'SELECT taxid, rank FROM nodes WHERE parent_taxid = ?',
        (parentTaxid,))
    for row in cur.fetchall():
        childRank = row['rank']
        if childRank == 'no rank':
            childRank = '-' + parentRank
        descendants(row['taxid'], childRank, depth + 1, conn)
        levels.add(childRank, depth + 1, parentRank)


levels.add(rank(10239, conn), 0, None)

descendants(10239, rank(10239, conn), 0, conn)


print('\nLevel summary\n')

thisLevel = 0

while True:
    ranks = Counter()
    for rank, (level, parentRank, count) in levels.levels.items():
        if level == thisLevel:
            if rank is not None:
                ranks[rank] += count

    if ranks:
        for rank, count in ranks.items():
            print('%s%d: %s (%d)' % ('  ' * thisLevel, thisLevel, rank, count))
        thisLevel += 1
    else:
        break
