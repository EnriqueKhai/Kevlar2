#!/usr/bin/env zsh
clear


# Create new test suites.
settings="../../../settings"

printf "Added:\n"

num_tests_to_add=5

for (( i=1; num_tests_to_add>0; i++)); do
    [ -d "test_suite_$i" ] || {
        cp -r "$settings/templates/test_suite" "test_suite_$i"
        (( --num_tests_to_add ));

        printf "  test_suite_$i\n"
    }
done

printf "\n"


# Script end.
printf "Press ENTER to continue... "; read user_input
