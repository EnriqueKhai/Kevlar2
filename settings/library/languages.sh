#!/usr/bin/env zsh

: '
This section of text functions as a comment and is
used to document the purpose of this script.

`languages.sh` is a modular component of the Kevlar2
system that was build with extensibility in mind.

The idea is to keep all supported languages in one
place so that users can easily add new (or remove
existing) programming languages from support.

To add a new language, users need to provide Kevlar2
with four pieces of information:

    1. Language name (in English).
    2. File extension.
    3. How to compile (for compiled languages).
    4. How to execute.

Refer to the existing templates below for further
clarity.
'


# Supported languages and their file extensions.
declare -a language
declare -A file_ext


# Compilation and execution methods.
declare -A compile
declare -A execute


    # C++
    language+=("C++")
        file_ext["C++"]=".cpp"
        compile[".cpp"]="g++ FILENAME.cpp -o FILENAME.exe"
        execute[".cpp"]="./FILENAME.exe"

    # Java
    language+=("Java")
        file_ext["Java"]=".java"
        compile[".java"]="javac FILENAME.java"
        execute[".java"]="java FILENAME"

    # Python3
    language+=("Python3")
        file_ext["Python3"]=".py"
        compile[".py"]=""
        execute[".py"]="python3 FILENAME.py"

    # Add a new language below!
