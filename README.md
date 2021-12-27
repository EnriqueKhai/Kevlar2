# Kevlar2

Kevlar2 is a language-agnostic framework built to 
automate black-box and regression testing workflows.

# Table of Contents

  - [Overview](#overview)
  - [Installation](#installation)
  - [Getting Started](#getting-started)
    - [Errors](#errors)
      - [Time Limit Exceeded](#time-limit-exceeded)
      - [Output Limit Exceeded](#output-limit-exceeded)
  - [Adding a new Language](#adding-a-new-language)
    - [Step 1: Define it](#step-1-define-it)
    - [Step 2: Add a Template](#step-2-add-a-template)
  - [Comments](#comments)

# Overview

Before we begin, let's address the elephant in the room:
why "Kevlar2"? The hope is that we can help you *bulletproof*
your code by helping you automate regressiont tests!

Also, Kevlar2 is the next iteration of the original [Kevlar](https://github.com/EnriqueKhai/Kevlar)
project, a system I had developed for the purpose of
Competitive Programming.

## The Problem Today

Programming languages come and go: what is fashionable
today might be extinct tomorrow. For that reason,
developers often have to learn a number of languages
over their careers (and a testing framework for each).

## One Tool to Rule Them All

What if we had one framework to test all code? A tool
such that, no matter what new language we pick up
tomorrow, we will not need to learn yet *another*
testing framework from scratch?

## Universal Testing with Black-box(ing)

Kevlar2 achieves language-agnosticism by leveraging an
underlying shell (we support both `bash` and `zsh`) and
an idea from [black-box testing](https://en.wikipedia.org/wiki/Black-box_testing).

By leveraging an underlying shell to coordinate file
redirects, we can drive any piece of code with inputs
and check its output at the other end: is it what we
were expecting? Put another way, Kevlar2 can test any
code that the user's own shell supports.

That is why we say we can "add any language" because
which *xyz* developer doesn't have *xyz* installed on
his or her machine?

# Installation

Free of any dependencies, Kevlar2 is lightweight and easy
to install.

```
git clone https://github.com/EnriqueKhai/Kevlar2.git
```

# Getting Started

...

## Errors

...

### Time Limit Exceeded

...

### Output Limit Exceeded

...

# Adding a New Language

Out of the box, Kevlar2 supports C++, Java and Python3.

That said, the magic of it is that *any* language can be
added with just four lines of code.

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

First, we are tell Kevlar2 that our new language is
called "TypeScript", and that its files end with ".ts".
Next, we specify that TypeScript files require compilation
by giving it a compile command: `tsc <FILENAME>.ts`.
Note that this compile command creates a JavaScript file.
Lastly, we tell Kevlar2 that our source file can be run
using the `node <FILENAME>.js` command.

Here, the "FILENAME" string literal is just a token that
will be dynamically replaced with the actual filename
during runtime.

## Step 2: Add a Template

For completeness, we can choose to create a template test
harness for our new language.

If present, this template test harness will be be copied
over whenever we create a new project using this language.

# Comments

...
