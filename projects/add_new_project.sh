#!/usr/bin/env zsh
clear


# Import supported languages.
source '../settings/libraries/languages.sh'
num_lang=${#language[@]}


# Enter project name.
printf 'Project Name: '; read project_name
printf '\n'


# Enter implementation.
printf 'Implementation:\n'


# List supported languages.
for (( i = 0; i <= $num_lang; i++ ))
do
    # Bash is 0-indexed, but zsh is 1-indexed.
    [ -n "${language[$i]}" ] && \
    {
        printf '  %2d) %s\n' $i "${language[$i]}"
    }
done; printf '\n'


# Get choice.
printf 'Select an option: '; read idx


# Retrieve corresponding language name and extension.
lang="${language[$idx]}"
f_ext="${file_ext[$lang]}"


# Update UI with choice.
printf '\033[1A'
printf 'Select an option: %d (%s)\n\n' $idx $lang


# If a directory with $project_name already exists,
[ -d "$project_name" ] && \
{
    for (( i=1 ;; ++i ))
    do
        # try adding suffixes "_1", "_2", and so on.
        [ -d "${project_name}_$i" ] || \
        {
            project_name="${project_name}_$i"
            break
        }
    done
}


# Create directory for class.
printf "> Creating directory for $project_name..."

cp -r '../settings/templates/project' "$project_name"

printf " done!\n"


# Create test harness for project.
templates='../settings/templates/test_harness'
test_harness="test_harness$f_ext"

printf "> Creating test harness for $project_name..."


# If a template harness exists, copy it over.
[ -f "$templates/$test_harness" ] && \
{
    cp "$templates/$test_harness" "$project_name/$test_harness"
    printf " done!\n\n"
}


# If no template harness is found, create an empty one.
[ -f "$templates/$test_harness" ] || \
{
    printf "none found.\n\n"
    touch "$project_name/$test_harness"
}


# End script.
printf '\nPress ENTER to continue...'; read _

