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

...

Usage
-----

    Usage: xcode-coveralls [OPTIONS] BUILD_DIRECTORY
    
    Options:
        
        --help       Shows this help dialog
        --verbose    Turns on extra logging
        --gcov       Path or command for invoking the gcov utility
                     (defaults to /usr/bin/gcov)
        --include    Paths to include from the sources
        --exclude    Paths to exclude from the sources
        --service    The service name to use
                     (defaults to 'travis-ci')
        --id         The service job ID
                     (if not specified, defaults to the 'TRAVIS_JOB_ID' environment variable, or zero)

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
