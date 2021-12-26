#!/usr/bin/env bash

file_overview_for='>> [ utilities.sh ]

This script contains a collection of convenience
functions related to the parsing and formatting
of data.
'


# Decodes _B, _kB and _MB formatted size.
function parse_size() {
    size="$1"

    size="${size/B/}"
    size="${size/k/000}"
    size="${size/M/000000}"
    
    printf '%d' $size
}


# Decodes _s, _m or _h formatted time.
function parse_time() {
    tme="$1"

    tme=${tme/s/*1}
    tme=${tme/m/*60}
    tme=${tme/h/*60*60}

    printf '%d' $(( $tme ))
}
