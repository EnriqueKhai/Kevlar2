#!/usr/bin/env zsh
clear

file_overview_for='>> [build.sh]

----------------------------------------------------
'


# Local file names for tidiness.
log="log.txt"
tfile="temp.txt"


# Helper functions for tidiness.
function finish() {
    printf "\nPress ENTER to continue... "; read _
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


# Script start.
set_up


# Import supported languages.
source '../../settings/libraries/languages.sh'


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

file="$fname$f_ext"

[ -f "$file" ] || \
{
    printf "No test harness detected.\n"
    clean_up 1
}


# Update template compile command.
cmd="${compile[$f_ext]}"
cmd="${cmd//FILENAME/$fname}"


# If $cmd is defined for $f_ext,
[ -n "$cmd" ] && \
{
    printf "Compiling $file..."

    # compile $file
    { eval "$cmd"; } &> /dev/null; exit_code=$?

    [ $exit_code -eq 0 ] && printf " done!   \n\n"
    [ $exit_code -ne 0 ] && printf " failed. \n\n"

    # If compilation failed, recompile to print errors.
    [ $exit_code -ne 0 ] && { eval "$cmd"; clean_up 1; }
}


# Execute all tests.
cmd="${execute[$f_ext]}"
cmd="${cmd//FILENAME/$fname}"

tested=0; ignored=0 passed=0 failed=0

printf "Test Suites\n"

for test_suite in test_suites/*
do
    # If test_suite is not a directory, ignore it.
    [ -d "$test_suite" ] || continue

    (( ++tested ))

    printf "  %-23s" "$(basename "$test_suite")"

    ifile="$test_suite/input.txt"
    ofile="$test_suite/output.txt"
    rfile="$test_suite/result.txt"

    # Remove comments from input.txt.
    sed                                                 \
        -e '/^[ \t]*#/d'                                \
        -e 's/[ \t]*#.*$//g'                            \
                                                        \
    < "$ifile"                                          \
    > "$tfile"

    # Test results.
    verdict=""
    remarks=""
    exit_code=0

    # If test suite is empty, ignore it.
    [ -s "$tfile" ] || { exit_code=0; verdict="--"; remarks="No Input"; (( ++ignored )); }

    # If test suite is non-empty,
    [ -s "$tfile" ] && \
    {
        # run it.
        { ( $cmd < "$tfile" > "$rfile" ); } &> /dev/null; exit_code=$?

        [ $exit_code -eq 0 ] && \
        {
            # Compare results generated with the output expected.
            f_diff="$(
                diff                                                 \
                    --ignore-space-change                            \
                    --ignore-blank-lines                             \
                                                                     \
                "$rfile"                                             \
                "$ofile"
            )"

            [ -z "$f_diff" ] && { verdict="Ok."    ; remarks=""             ; (( ++passed )); }
            [ -n "$f_diff" ] && { verdict="Failed."; remarks="Wrong Output" ; (( ++failed )); }
        }

        [ $exit_code -ne 0 ] && { verdict="Failed."; remarks="Runtime Error"; (( ++failed )); }

    }

    case "$verdict" in
        "Ok."     ) color_='\033[1;32m' _color='\033[0m' ;;   # Green
        "Failed." ) color_='\033[1;31m' _color='\033[0m' ;;   # Red
        "--"      ) color_='\033[1;33m' _color='\033[0m' ;;   # Yellow
        *         ) color_='\033[0m'    _color='\033[0m' ;;
    esac

    # Print test results.
    printf "${color_}%-9s %-14s${_color}" "$verdict" "$remarks"

    # Print exit code for runtime errors.
    [ $exit_code -eq 0 ] && printf "${color_}     ${_color}\n"
    [ $exit_code -ne 0 ] && printf "${color_}(%3d)${_color}\n" $exit_code

done; printf "\n"


# Evaluate test results.
printf "Results                 \n"
printf "  %-7s %-3d             \n" "Total"   $tested

[ $tested -gt 0 ] && \
{
    printf "  %-7s %-3d (%3d%%) \n" "Passed"  $passed  $(( 100 * passed  / tested ))
    printf "  %-7s %-3d (%3d%%) \n" "Failed"  $failed  $(( 100 * failed  / tested ))
    printf "  %-7s %-3d (%3d%%) \n" "Ignored" $ignored $(( 100 * ignored / tested ))
}


# Script end.
clean_up 0
