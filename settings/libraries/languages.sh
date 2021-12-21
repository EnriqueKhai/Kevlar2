#!/usr/bin/env zsh

file_overview_for='>> [ languages.sh ]

All programming languages supported by Kevlar2 have
been and must be defined here.

As a default, Kevlar2 supports C++, Java and Python3
out of the box.

To add a new language, users need to provide Kevlar2
with four pieces of information:

    1. Language name (in English).
    2. File extension.
    3. How to compile (if applicable).
    4. How to execute.

Refer to the existing templates below for further
clarity.
'


# Supported languages and their file extensions.
declare -a language
declare -A file_ext


# Compilation and execution instructions.
declare -A compile
declare -A execute


    # C++
    language+=(C++)
    file_ext[C++]='.cpp'
    compile[.cpp]='g++ FILENAME.cpp -o FILENAME.exe'
    execute[.cpp]='./FILENAME.exe'


    # Java
    language+=(Java)
    file_ext[Java]='.java'
    compile[.java]='javac FILENAME.java'
    execute[.java]='java FILENAME'


    # Python3
    language+=(Python3)
    file_ext[Python3]='.py'
    compile[.py]=''
    execute[.py]='python3 FILENAME.py'


    # Add a new language below!
    