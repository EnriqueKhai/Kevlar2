#!/usr/bin/env zsh
clear

file_overview_for='>> [build.sh]

This script compiles (if applicable) the test harness
and executes each test suite defined, one at a time.

Several outcomes are possible for each test:

    1. Ok.
    2. Failed, Wrong Output.
    3. Failed, Runtime Error.
    4. Failed, Time Limit Exceeded.
    5. Failed, Output Limit Exceeded.
    6. --, No Input.


The algorithm:

For each test suite defined, Kevlar2 redirects all
inputs to the test harness.

Then, it checks to see if the results generated are
equal to the output expected (user defined).

Here, equality is determined via the `diff` command.
Importantly, blank lines and trailing white spaces
are ignored.
'


# Local filenames for tidiness.
log='log.txt'
tfile='temp.txt'


# Helper functions for tidiness.
function finish() {
    printf '\nPress ENTER to continue... '; read _
    exit $1
}

function set_up() {
    touch "$log"
    touch "$tfile"
}

function clean_up() {
    rm "$log"
    rm "$tfile"

    finish $1
}


# Options.
set -o nounset
set -o pipefail


# Script start.
set_up


# Import supported languages.
source '../../settings/libraries/languages.sh'


# Import utilities.
source '../../settings/libraries/utilities.sh'


# Locate test harness.
fname='test_harness'
f_ext='--'


# Determine file extension.
for ext in "${file_ext[@]}"
do
    [ -f "$fname$ext" ] && \
    {
        f_ext="$ext"
    }
done


# In case none of the supported extensions match.
test_harness="$fname$f_ext"

[ -f "$test_harness" ] || \
{
    printf 'No test harness detected.\n'
    clean_up 1
}


# Get compile command for $f_ext files.
cmd="${compile[$f_ext]}"


# Replace 'FILENAME' in $cmd with the actual filename.
cmd="${cmd//FILENAME/$fname}"


# If $cmd is defined for $f_ext,
[ -n "$cmd" ] && \
{
    printf "Compiling $test_harness..."

    # compile $test_harness.
    { eval "$cmd"; } &> /dev/null; exit_code=$?

    [ $exit_code -eq 0 ] && printf ' done!   \n\n'
    [ $exit_code -ne 0 ] && printf ' failed. \n\n'

    # If compilation failed, recompile to print errors.
    [ $exit_code -ne 0 ] && { eval "$cmd"; clean_up 1; }
}


# Get execute command for $f_ext files.
cmd="${execute[$f_ext]}"


# Replace 'FILENAME' in $cmd with actual filename.
cmd="${cmd//FILENAME/$fname}"


# Execute all tests.
source '../../settings/config/limits.sh'

OUTPUT_LIMIT=$( parse_size $MAX_OUTPUT_SIZE )
RUNTIME_LIMIT=$( parse_time $MAX_TEST_DURATION )

tested=0; ignored=0 passed=0 failed=0

printf 'Test Suites\n'

for test_suite in test_suites/*
do
    # If test_suite is not a directory, ignore it.
    [ -d "$test_suite" ] || continue

    (( ++tested ))

    printf '  %-23s' "$(basename "$test_suite")"

    # Test inputs.
    ifile="$test_suite/input.txt"

    # Output expected.
    ofile="$test_suite/output.txt"

    # Results generated.
    rfile="$test_suite/result.txt"

    # Remove comments from input.txt, unless otherwise specified.
    flag="${1:-none}"

    [ "$flag" = '--no-parse' ] && \
    {
        cp "$ifile" "$tfile"
    }

    [ "$flag" = '--no-parse' ] || \
    {
        sed                                             \
            -e '/^[ \t]*#/d'                            \
            -e 's/[ \t]*#.*$//g'                        \
                                                        \
        < "$ifile"                                      \
        > "$tfile"
    }

    # Test results.
    verdict=''
    remarks=''
    exit_code=0

    # If test suite is empty, ignore it.
    [ -s "$tfile" ] || { exit_code=0; verdict='--'; remarks='No Input'; (( ++ignored )); }

    # If test suite is non-empty,
    [ -s "$tfile" ] && \
    {
        # run it.
        {
            tm_cmd="$cmd < "$tfile" | head --bytes=$(( $OUTPUT_LIMIT + 1)) > "$rfile""

            eval "
                timeout --foreground $RUNTIME_LIMIT $tm_cmd
            ";
        } &> /dev/null; exit_code=$?

        # Check if output limit was exceeded.
        [ $(wc --bytes < "$rfile") -gt $OUTPUT_LIMIT ] && exit_code=141

        [ $exit_code -eq 0 ] && \
        {
            # Compare results generated with the output expected.
            f_diff="$(
                diff                                                 \
                    --ignore-space-change                            \
                    --ignore-blank-lines                             \
                                                                     \
                "$rfile"                                             \
                "$ofile" |                                           \
                                                                     \
                head --bytes=10
            )"

            [ -z "$f_diff" ] && { verdict='Ok.'    ; remarks=''             ; (( ++passed )); }
            [ -n "$f_diff" ] && { verdict='Failed.'; remarks="Wrong Output" ; (( ++failed )); }
        }

        [ $exit_code -ne 0 ] && { verdict='Failed.'; remarks='Runtime Error'; (( ++failed )); }

        # Failure Mode: Time Limit Exceeded.
        [ $exit_code -eq 124 ] && remarks='Time Limit Exceeded'

        # Failure Mode: Output Limit Exceeded.
        [ $exit_code -eq 141 ] && remarks='Output Limit Exceeded'
    }

    case "$verdict" in
        'Ok.'     ) color_='\033[1;32m' _color='\033[0m' ;;   # Green
        'Failed.' ) color_='\033[1;31m' _color='\033[0m' ;;   # Red
        '  '      ) color_='\033[1;33m' _color='\033[0m' ;;   # Yellow
        *         ) color_='\033[0m'    _color='\033[0m' ;;
    esac

    # Print test results.
    printf "${color_}%-9s %s ${_color}" "$verdict" "$remarks"

    # Print exit code for runtime errors.
    case $exit_code in
        0   ) printf '\n'                                               ;;
        124 ) printf "${color_}(%s) ${_color}\n" "${MAX_TEST_DURATION}" ;;
        141 ) printf "${color_}(%s) ${_color}\n" "${MAX_OUTPUT_SIZE}"   ;;
        *   ) printf "${color_}(%3d)${_color}\n"  $exit_code            ;;
    esac

done; printf '\n'


# Evaluate test results.
printf 'Results                 \n'
printf '  %-7s %-3d             \n' 'Total'   $tested

[ $tested -gt 0 ] && \
{
    printf '  %-7s %-3d (%3d%%) \n' 'Passed'  $passed  $(( 100 * passed  / tested ))
    printf '  %-7s %-3d (%3d%%) \n' 'Failed'  $failed  $(( 100 * failed  / tested ))
    printf '  %-7s %-3d (%3d%%) \n' 'Ignored' $ignored $(( 100 * ignored / tested ))
}


# Script end.
clean_up 0
