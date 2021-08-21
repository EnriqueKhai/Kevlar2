#!/usr/bin/env zsh
clear


# Path variables.
settings="../settings"

    # First time setup: mark all scripts as executable.
    [ -d "$settings/config" ] || {
        chmod +x "$settings/library/languages.sh"
        chmod +x "$settings/templates/project/build.sh"
        chmod +x "$settings/templates/project/add_test_suites.sh"
        chmod +x "$settings/templates/project/test_suites/add_test_suites.sh"

        mkdir "$settings/config"
    }


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

num_opt=${#language[@]}


# Read project name.
printf "Class/ Function Name: "; read user_input
printf "\n"


# Clean user input.
[ -z "$user_input" ] && {

    # If empty, treat input as "new_project".
    project_name="new_project"
} || {

    # Else, replace non-alphanumerics with underscores.
    project_name="${user_input//[^a-zA-Z0-9]/_}"
}


# Query class implementation.
printf "Implementation:\n"

PS3="Select an option (1-$num_opt): "
select lang in "${language[@]}"; do

    # Integer check.
    [ "$REPLY" = "${REPLY//[^0-9]/}" ] || continue

    # Boundary check.
    [ $REPLY -lt 1        ]            && continue
    [ $REPLY -gt $num_opt ]            && continue

    # If input is valid, define f_ext.
    f_ext="${file_ext[$lang]}"         ;  break
done

printf "\n"


# If directory $project_name already exists,   x----------------------+
[ -d "$project_name" ] && {                                    #      |
    for (( i=1 ;; ++i )); do                                   #      |
                                                               #      |
        # try adding suffixes "_1", "_2", and so on.   <<-------------+
        [ -d "${project_name}_$i" ] || {
            project_name="${project_name}_$i"
            break
        }
    done
}


# Create directory for class.
printf "Creating directory for $project_name..."

cp -r "$settings/templates/project" "$project_name"

printf " done!\n"


# Change directory and update paths.
cd "$project_name"
settings="../$settings"


# Create test harness for class/ function.
templates="$settings/templates/test_harness"
test_harness="test_harness$f_ext"

printf "Creating test harness for $project_name..."

[ -f "$templates/$test_harness" ] && cp "$templates/$test_harness" "$test_harness"
[ -f "$templates/$test_harness" ] || touch "$test_harness"

printf " done!\n\n"


# End script.
printf "\nPress ENTER to continue..."; read user_input
