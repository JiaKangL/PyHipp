#!/bin/bash

# Find the directories that are MISSING an expected output file, at ANY level of the tree.
# Read-only except for the list files it writes in the current directory
# (all_units.txt, missing.txt, and in --by-name mode also unit_names.txt / done_names.txt / missing_names.txt).
#
# Usage (head node; cd to the directory the search should START in first):
#   bash /data/src/PyHipp/missing.sh '<unit-dir-glob>' '<output-file-glob>'
#   bash /data/src/PyHipp/missing.sh --by-name '<unit-dir-glob>' '<output-file-glob>'
#
# A "unit" is the directory that should hold (or own) the output: 'session01', 'channel*', ...
# Default mode: unit dir is missing if NO non-empty file matching <output-file-glob> exists anywhere beneath it.
# --by-name (for spike sorting): firings.mda lives in a SEPARATE mountains/channelXXX/output/ tree, not
#   inside each channel dir, so units are compared by NAME (channel002 ...) and mapped back to their real paths.
#   Run --by-name from ONE day directory only (channel names repeat across days and would be merged).
#
# Examples:
#   cd /data/picasso            && bash missing.sh 'session01' 'unity*hkl'        # session level (2024)
#   cd /data/picasso/20181101   && bash missing.sh 'channel*'  'waveform*hkl'     # channel level
#   cd /data/picasso/20181101   && bash missing.sh 'channel*'  'freqspectrum*hkl'
#   cd /data/picasso/20181101   && bash missing.sh --by-name 'channel*' 'firings.mda'   # spike sorting (2023)
#
# Then READ missing.txt against the scope in the prompt BEFORE submitting anything, and submit with:
#   cwd=`pwd`; for i in `cat missing.txt`; do echo $i; cd $i; sbatch /data/src/PyHipp/<script>.sh; cd $cwd; done
# Narrow the scope with grep, e.g.:  grep -v array04 missing.txt > scope.txt   (then use `cat scope.txt`)
# After the jobs finish, run this again: it must report 0 missing.
# eye and mountain(s) directories are always excluded from the unit list.

mode=dir
if [ "$1" = "--by-name" ]; then mode=name; shift; fi
unit=$1
out=$2
if [ -z "$unit" ] || [ -z "$out" ]; then
    sed -n '3,30p' "$0"
    exit 1
fi

find . -type d -name "$unit" | grep -v -e eye -e mountain | sort > all_units.txt
total=$(wc -l < all_units.txt | tr -d ' ')
if [ "$total" = "0" ]; then
    echo "No directories named '$unit' under $(pwd). Wrong start directory or pattern?"
    exit 1
fi

: > missing.txt

if [ "$mode" = "dir" ]; then
    while IFS= read -r d; do
        # present = at least one NON-EMPTY file matching the pattern somewhere beneath the unit dir
        if [ -z "$(find "$d" -type f -name "$out" -size +0c 2>/dev/null | head -n 1)" ]; then
            echo "$d" >> missing.txt
        fi
    done < all_units.txt
else
    re=$(echo "$unit" | sed 's/\*/[0-9]+/g')
    grep -oE "$re" all_units.txt | sort -u > unit_names.txt
    find . -type f -name "$out" -size +0c | grep -oE "$re" | sort -u > done_names.txt
    comm -23 unit_names.txt done_names.txt > missing_names.txt
    while IFS= read -r n; do
        grep "/$n\$" all_units.txt >> missing.txt
    done < missing_names.txt
    sort -o missing.txt missing.txt
fi

missing=$(wc -l < missing.txt | tr -d ' ')
echo "start dir : $(pwd)"
echo "units     : $total   ($unit)"
echo "looking for non-empty '$out' ($mode mode)"
echo "missing   : $missing   -> missing.txt"
if [ "$missing" != "0" ]; then
    echo "--- first 10 missing ---"
    head -n 10 missing.txt
fi
echo "Read missing.txt against the scope in the prompt before submitting. Re-run this after the jobs finish: expect 'missing : 0'."
