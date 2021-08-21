#!/usr/bin/env zsh
clear


# Paths & Functions.
settings="../../settings"

function set_up() {
    log="log.txt"
    tfile="temp.txt"

    touch "$log"
    touch "$tfile"
}

function clean_up() {
    rm "$log"
    rm "$tfile"

    printf "\nPress ENTER to continue... "; read user_input
    exit $1
}


# Script start.
set_up


# Import supported languages.
source "$settings/library/languages.sh"

: '
This section of text functions as a comment and is
used to document the effects of sourcing languages.sh
above.

Supported programming languages and their metadata
are defined in another script called languages.sh.
This script is located in kevlar2/settings/library/.
By sourcing it, developers can gain access to said
metadata.

Specifically, the following arrays are imported:

    declare -a language   -- supported languages, i.e.
                               - language[0]="C++"
                               - language[1]="Java"
                               - language[2]="Python3"
                               - ( ... )

    declare -A file_ext   -- corresponding file extensions, i.e.
                               - file_ext["C++"]=".cpp"
                               - file_ext["Java"]=".java"
                               - file_ext["Python3"]=".py"
                               - ( ... )

    declare -A compile    -- compilation methods, i.e.
                               - compile[".cpp"]="g++ FILENAME.cpp ..."
                               - compile[".java"]="javac FILENAME.java"
                               - compile[".py"]=""
                               - ( ... )

    declare -A execute    -- execution methods, i.e.
                               - execute[".cpp"]="./FILENAME.exe"
                               - execute[".java"]="java FILENAME"
                               - execute[".py"]="python3 FILENAME.py"
                               - ( ... )

By default, only C++, Java and Python3 are supported.
That said, Kevlar2 was designed with extensibility in
mind; users can easily add new programming languages
with just four lines of code (per language).
'


# Locate test harness.
fname="test_harness"
f_ext=

    # Determine file extension.
    for ext in "${file_ext[@]}"; do
        [ -f "$fname$ext" ] && f_ext="$ext"
    done

file="$fname$f_ext"

[ -f "$file" ] && {
    printf "No test harness detected.\n"
    clean_up 1
}


# Compile, if needed.
cmd="${compile[$f_ext]}"
cmd="${cmd//FILENAME/$fname}"

    # If $cmd is defined for $f_ext,  x-------------------------------+
    [ -n "$cmd" ] && {                                        #       |
        printf "Compiling $file..."                           #       |
                                                              #       |
        # compile $file.  <<------------------------------------------+
        { ( $cmd ); } &> /dev/null; exit_code=$?

        [ $exit_code -eq 0 ] && printf " done!   \n\n"
        [ $exit_code -ne 0 ] && printf " failed. \n\n"

        # If compilation failed, recompile to print errors.
        [ $exit_code -ne 0 ] && { ( $cmd ); clean_up 1; }
    }


# Execute all tests.
cmd="${execute[$f_ext]}"
cmd="${cmd//FILENAME/$fname}"

tested=0; ignored=0 passed=0 failed=0

printf "Test Suites\n"
for test_suite in test_suites/*; do

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

    # If test suite is non-empty,   x--------------------------------+
    [ -s "$tfile" ] && {                                #            |
                                                        #            |
        # Run test suite.   <<---------------------------------------+
        { ( $cmd < "$tfile" > "$rfile" ); } &> /dev/null; exit_code=$?

        [ $exit_code -eq 0 ] && {

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

done

printf "\n"


# Evaluate test results.
printf "Results                 \n"
printf "  %-7s %-3d             \n" "Total"   $tested

[ $tested -gt 0 ] && {
    printf "  %-7s %-3d (%3d%%) \n" "Passed"  $passed  $(( 100 * passed  / tested ))
    printf "  %-7s %-3d (%3d%%) \n" "Failed"  $failed  $(( 100 * failed  / tested ))
    printf "  %-7s %-3d (%3d%%) \n" "Ignored" $ignored $(( 100 * ignored / tested ))
}


# Script end.
clean_up 0
