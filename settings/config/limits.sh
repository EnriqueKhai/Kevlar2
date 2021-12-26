#!/usr/bin/env zsh

file_overview_for='>> [ limits.sh ]

This script contains a collection of configuration
options pertaining to test limits.

Importantly, users can control the maximum allowable
runtime for each test suite, in cases of infinite
loops due to bugs.

Users can also specify the maximum allowable output
size for each test, in cases of infinite loops and
unfettered printing to standard output.
'


# Runtime limit for each test. Units = s, m or h.
MAX_TEST_DURATION='5s'


# File size limit for output.txt. Units = B, kB or MB.
MAX_OUTPUT_SIZE='10kB'
