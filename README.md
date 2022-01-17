# Kevlar2

![david-troeger-M8xxVih_V_U-unsplash](https://user-images.githubusercontent.com/42400406/149685905-a343cf05-c31f-4e18-9290-a981af71e76c.jpg)

Kevlar2 is a language-agnostic, shell-based framework
built to automate regression testing workflows.

# Table of Contents

  - [Overview](#overview)
    - [The Problem Today](#the-problem-today)
    - [One Tool to Rule Them All](#one-tool-to-rule-them-all)
    - [Universal Testing with Black-box(ing)](#universal-testing-with-black-boxing)
  - [Installation](#installation)
  - [Getting Started](#getting-started)
    - [Runtime Errors](#runtime-errors)
      - [Time Limit Exceeded](#time-limit-exceeded)
      - [Output Limit Exceeded](#output-limit-exceeded)
  - [Adding a New Language](#adding-a-new-language)
    - [Step 1: Define it](#step-1-define-it)
    - [Step 2: Add a Template](#step-2-add-a-template)
  - [Comments](#comments)
  - [License and Copyright](#license-and-copyright)

# Overview

Before we begin, let's address the elephant in the room:
why "Kevlar2"? We test code to make it robust, and it is
my greatest hope that Kevlar2 can help you **bulletproof**
yours!

## The Problem Today

Programming languages come and go: what is fashionable
today might be extinct tomorrow. For that reason,
developers often have to learn a number of languages
over their careers (and one testing framework for each).

## One Tool to Rule Them All

What if we had one framework that could test any code?
A tool such that, no matter what new language we pick
up tomorrow, we will not need to learn yet *another*
testing framework from scratch?

## Universal Testing with Black-box(ing)

Kevlar2 achieves language-agnostic testing by leveraging
the user's native shell (we support both `bash` and `zsh`)
and an idea from [black-box testing](https://en.wikipedia.org/wiki/Black-box_testing).

By coordinating file redirects, we can **test** any piece
of code by driving it with inputs and checking its output,
so long as the user's shell can compile and execute the
source language (almost always a given).

That is why we say we can "support any language" - because
which *xyz* developer doesn't have *xyz* installed on
his or her machine?

# Installation

Free of any dependencies, Kevlar2 is lightweight and easy
to install.

```
git clone https://github.com/EnriqueKhai/Kevlar2.git
```

# Getting Started

To learn about Kevlar2 and how to use it, check out the
[Kevlar2 Tutorial](https://youtube.com/playlist?list=PLsEw_qS-mPbZHY9hmQ9TAAwu4sqoHgn-u)
playlist on YouTube!

## Runtime Errors

Kevlar2 was designed with multiple safeguards to ensure
that tests could finish gracefully when met with errors.
These errors include runtime errors such as
*Time Limit Exceeded* and *Output Limit Exceeded*.

For a video walkthrough, click [here](https://youtu.be/VOFFMCoHcW4).

### Time Limit Exceeded

This error indicates that a certain test took too long
and was terminated prematurely. Time limits across all
tests conducted by Kevlar2 are defined (and can be set)
in `settings/config/limits.sh`.

```Bash
17
18    # Runtime limit for each test. Units = s, m or h.
19    MAX_TEST_DURATION='5s'
20
```

By default, the time limit is 5 seconds.

Getting a *Time Limit Exceeded* error often means that the
program entered an infinite loop somewhere. Of course,
users can also set specific time limits to ensure that
their code meets certain performance benchmarks.

The latter is not recommended as execution performance
varies widely from machine to machine, all else being
constant. Mostly, this feature was implemented as a
safeguard for testing, not to judge absolute performance.

### Output Limit Exceeded

This error indicates that a test produced more output
than the maximum limit defined. Output limits across all
tests conducted by Kevlar2 are defined (and can be set)
in `settings/config/limits.sh`.

```Bash
21
22    # File size limit for output.txt. Units = B, kB or MB.
23    MAX_OUTPUT_SIZE='10kB'
24
```

By default, the output limit is 10kB.

Getting an *Output Limit Exceeded* error often means that
the program entered an infinite loop somewhere and keeps
printing to standard output. Implemented as a safeguard
for program-OS write safety, it is advisable to keep the
output limit small.

# Adding a New Language

Out of the box, Kevlar2 supports C++, Java and Python3.

That said, the magic of it is that *any* language can be
added with just four lines of code.

For a video walkthrough, click [here](https://youtu.be/xk8EpCfwF1o).

## Step 1: Define it

Simply define four pieces of information in `settings/libraries/languages.sh`:

  1. Language name (in English)
  2. File extension
  3. How to compile (if applicable)
  4. How to execute

As an example, here is how we would add TypeScript:

```Bash
48    # Python3
49    language+=(Python3)
40    file_ext[Python3]='.py'
51    compile[.py]=''
52    execute[.py]='python3 FILENAME.py'
53
54
55    # TypeScript             <-- Adding a new language!
56    language+=(TypeScript)
57    file_ext[TypeScript]='.ts'
58    compile[.ts]='tsc FILENAME.ts'
59    execute[.ts]='node FILENAME.js'
50  
```

First, we tell Kevlar2 that our new language is called
`TypeScript`, and that its files end with `.ts`. Next,
we specify that TypeScript files require compilation by
giving it a compile command: `tsc <FILENAME>.ts`. Note
that this compile command creates a JavaScript file.
Lastly, we tell Kevlar2 that our source code can be run
(or tested) using the `node <FILENAME>.js` command.

Here, the `FILENAME` string literal is just a token that
will be dynamically replaced with the actual filename
during runtime.

## Step 2: Add a Template

For completeness, we can choose to create a template test
harness for our new language.

If present, this template test harness will be be copied
over whenever we create a new project using this language.

# Comments

Kevlar2 supports shell-styled comments, or parts beginning
with a `#` character, in all input files. Consider the
following `input.txt` file:

```
# Number of test cases, n.      <-- This is a comment!
5

# Arguments: a, b               <-- This is also a comment!
3 5
6 1
3 6
7 6  # Note: edge case.         <-- This is also a (trailing) comment!
3 7
```

Comments serve as a way to document test inputs, and are
ignored during testing. To disable comments, possibly
because the `#` character is used in tests, run the
`build.sh` script with the `--no-parse` flag:

```
build.sh --no-parse
```

For a video walkthrough, click [here](https://youtu.be/W1Q1TcRZsYc).

# License and Copyright

Copyright (c) 2021, Nigel Tan.

All rights reserved.

This source code is licensed under the BSD-style license
found [here](LICENSE).
