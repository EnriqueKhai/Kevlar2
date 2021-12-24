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

# Runtime limit (in secs) for each test.
MAX_TEST_TIME_IN_SECONDS=5


# File size limit (in bytes) for output.txt.
MAX_FILE_SIZE_IN_BYTES=10