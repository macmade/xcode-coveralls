xcode-coveralls
===============

[![Build Status](https://img.shields.io/travis/macmade/xcode-coveralls.svg?branch=master&style=flat)](https://travis-ci.org/macmade/xcode-coveralls)
[![Coverage Status](https://img.shields.io/coveralls/macmade/xcode-coveralls.svg?branch=master&style=flat)](https://coveralls.io/r/macmade/xcode-coveralls)
[![Issues](http://img.shields.io/github/issues/macmade/xcode-coveralls.svg?style=flat)](https://github.com/macmade/xcode-coveralls/issues)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?style=flat)
![License](https://img.shields.io/badge/license-mit-brightgreen.svg?style=flat)
[![Contact](https://img.shields.io/badge/contact-@macmade-blue.svg?style=flat)](https://twitter.com/macmade)

About
-----

`code-coveralls` is a command line helper tool to upload code coverage data from Xcode projects to [coveralls.io](https://coveralls.io).

Usage
-----

The `xcode-coveralls` command needs to be invoked from your **repository/project root directory**.  
Note that if your Xcode project file is in a sub directory, you'll need to specify its path with the `--project` option.

If you don't use [Travis CI](http://travis-ci.org), you may also specify a service name and job ID with the `--service` and `--id` options. 
Builds on [Travis CI](http://travis-ci.org) will automatically detect those values.   
You may also use the `--token` option, if you're not using a service compatible with [coveralls.io](https://coveralls.io).

You may also include/exclude specific paths from your sources with the `--include` and `--exclude` options.  
Those paths may be full paths or paths relative to the repository/project root directory.

The only mandatory argument is the Xcode build directory, containing the `.gcda` and `.gcno` files to process.  
Please read the following section to learn how to generate those files with Xcode.

Project Configuration
---------------------

In order to use `xcode-coveralls`, your Xcode targets needs to be configured to produce code coverage data files.

This can be done from a target's build settings.  
Two options needs to be activated:

 - **Generate Test Coverage Files** (`GCC_GENERATE_TEST_COVERAGE_FILES`)
 - **Instrument Program Flow** (`GCC_INSTRUMENT_PROGRAM_FLOW_ARCS`)

Although the options are prefixed with `GCC`, they are completely compatible with Clang/LLVM.

Note that turning those options on will reduce the compilation time, so you might create a specific build configuration for this, and enable it for your unit tests only.

### Build Directory

The `xcode-coveralls` command needs to be invoked with the Xcode build directory, usually in `~/Library/Developer/Xcode/DerivedData/`.

The best way to get this directory is to add a **Run Script** phase in the target for which you want coverage reports:

    export | egrep '(BUILT_PRODUCTS_DIR)|(CURRENT_ARCH)|(OBJECT_FILE_DIR_normal)|(SRCROOT)|(OBJROOT)' > xcenv.sh

This will create an `xcenv.sh` file with the necessary environment variables to find the Xcode build directory.  
If using an version control system, you may ignore this specific file.

You may then use this variables in a shell script, in order to invoke `xcode-coveralls`:

    #!/bin/bash
    
    source Scripts/xcenv.sh
    declare -r DIR_BUILD="${OBJECT_FILE_DIR_normal}/${CURRENT_ARCH}/"
    xcode-coveralls $(DIR_BUILD)

Command Options
---------------

    Usage: xcode-coveralls [OPTIONS] BUILD_DIRECTORY
    
    Options:
        
        --help       Shows this help dialog
        --verbose    Turns on extra logging
        --gcov       Path or command for invoking the gcov utility
                     (defaults to /usr/bin/gcov)
        --include    Paths to include from the sources
        --exclude    Paths to exclude from the sources
        --project    Path to the Xcode project file, if not at the directory root
        --service    The service name to use
                     (defaults to 'travis-ci')
        --id         The service job ID
                     (if not specified, defaults to the 'TRAVIS_JOB_ID' environment variable, or zero)
        --token      The repository token (optional)

License
-------

xcode-coveralls is released under the terms of the MIT License.

Repository Infos
----------------

    Owner:			Jean-David Gadina - XS-Labs
    Web:			www.xs-labs.com
    Blog:			www.noxeos.com
    Twitter:		@macmade
    GitHub:			github.com/macmade
    LinkedIn:		ch.linkedin.com/in/macmade/
    StackOverflow:	stackoverflow.com/users/182676/macmade
