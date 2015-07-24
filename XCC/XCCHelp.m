/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2015 Jean-David Gadina - www-xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

#import "XCCHelp.h"

static dispatch_once_t  __once;
static XCCHelp  *       __sharedInstance    = nil;
static NSString * const __version           = @"0.1.2";

@interface XCCHelp()

@end

@implementation XCCHelp

+ ( instancetype )sharedInstance
{
    dispatch_once
    (
        &__once,
        ^( void )
        {
            __sharedInstance = [ XCCHelp new ];
        }
    );
    
    return __sharedInstance;
}

- ( void )display
{
    fprintf
    (
        stdout,
        "xcode-coveralls %s\n"
        "\n"
        "Usage: xcode-coveralls [OPTIONS] BUILD_DIRECTORY [BUILD_DIRECTORY ...]\n"
        "\n"
        "Options:\n"
        "\n"
        "    --help       Shows this help dialog\n"
        "    --version    Prints the version number\n"
        "    --verbose    Turns on extra logging\n"
        "    --gcov       Path or command for invoking the gcov utility\n"
        "                 (defaults to /usr/bin/gcov)\n"
        "    --include    Paths to include from the sources\n"
        "    --exclude    Paths to exclude from the sources\n"
        "    --project    Path to the Xcode project file, if not at the directory root\n"
        "    --service    The service name to use\n"
        "                 (defaults to 'travis-ci')\n"
        "    --id         The service job ID\n"
        "                 (if not specified, defaults to the 'TRAVIS_JOB_ID' environment variable, or zero)\n"
        "    --token      The repository token (optional)\n"
        "    --dry-run    Do not actually send data to coveralls.io\n",
        __version.UTF8String
    );
}

- ( void )displayVersion
{
    fprintf
    (
        stdout,
        "xcode-coveralls %s\n",
        __version.UTF8String
    );
}

- ( void )displayWithError: ( NSError * )error
{
    [ self displayWithErrorText: error.localizedDescription ];
}

- ( void )displayWithErrorText: ( NSString * )error
{
    fprintf( stdout, "Error: %s\n\n", error.UTF8String );
    
    [ self display ];
}

@end
