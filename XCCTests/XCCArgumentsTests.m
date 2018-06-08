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

#import <Foundation/Foundation.h>
#import "XCC.h"

#ifdef __clang__

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvariadic-macros"
#pragma clang diagnostic ignored "-Wgnu-statement-expression"
#pragma clang diagnostic ignored "-Wgnu-zero-variadic-macro-arguments"
#pragma clang diagnostic ignored "-Wdocumentation-unknown-command"

#if __clang_major__ >= 7
#pragma clang diagnostic ignored "-Wreserved-id-macro"
#endif

#endif

#import <XCTest/XCTest.h>

@interface XCCArgumentsTests: XCTestCase

@end

@implementation XCCArgumentsTests

- ( void )testEmptyArguments
{
    {
        XCCArguments * args;
        const char   * argv[] = { "" };
        
        args = [ [ XCCArguments alloc ] initWithArguments: argv count: 1 ];
        
        XCTAssertTrue( args.showHelp );
    }
}

- ( void )testInvalidArguments
{
    {
        XCCArguments * args;
        const char   * argv[] = { "" };
        
        args = [ [ XCCArguments alloc ] initWithArguments: argv count: 1 ];
        
        XCTAssertTrue( args.showHelp );
    }
}

- ( void )testShowHelp
{
    XCCArguments * args;
    const char   * argv[] = { "", "--help" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    
    XCTAssertTrue( args.showHelp );
}

- ( void )testShowVersion
{
    XCCArguments * args;
    const char   * argv[] = { "", "--version" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    
    XCTAssertTrue( args.showVersion );
}

- ( void )testVerbose
{
    XCCArguments * args;
    const char   * argv[] = { "", "--verbose" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    
    XCTAssertTrue( args.verbose );
}

- ( void )testDryRun
{
    XCCArguments * args;
    const char   * argv[] = { "", "--dry-run" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    
    XCTAssertTrue( args.dryRun );
}

- ( void )testBuildDirectory
{
    XCCArguments * args;
    const char   * argv[] = { "", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    
    XCTAssertFalse( args.showHelp );
    XCTAssertEqual( args.buildDirectories.count, ( NSUInteger )1 );
}

- ( void )testMultipleBuildDirectories
{
    XCCArguments * args;
    const char   * argv[] = { "", "", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 3 ];
    
    XCTAssertFalse( args.showHelp );
    XCTAssertEqual( args.buildDirectories.count, ( NSUInteger )2 );
}

- ( void )testMultipleBuildDirectoriesWithInvalidOption
{
    XCCArguments * args;
    const char   * argv[] = { "", "", "--verbose", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( args.showHelp );
    XCTAssertEqual( args.buildDirectories.count, ( NSUInteger )0 );
}

- ( void )testInvalidGCov
{
    XCCArguments * args;
    const char   * argv[] = { "", "--gcov", "--verbose", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( args.showHelp );
    XCTAssertNil( args.gcov );
}

- ( void )testValidGCov
{
    XCCArguments * args;
    const char   * argv[] = { "", "--gcov", "", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertFalse( args.showHelp );
    XCTAssertNotNil( args.gcov );
}

- ( void )testInvalidIncludeDir
{
    XCCArguments * args;
    const char   * argv[] = { "", "--include", "--verbose", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( args.showHelp );
    XCTAssertEqual( ( NSUInteger )0, args.includedPaths.count );
}

- ( void )testValidIncludeDir
{
    XCCArguments * args;
    const char   * argv[] = { "", "--include", "", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertFalse( args.showHelp );
    XCTAssertGreaterThan( args.includedPaths.count, ( NSUInteger )0 );
}

- ( void )testInvalidExcludeDir
{
    XCCArguments * args;
    const char   * argv[] = { "", "--exclude", "--verbose", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( args.showHelp );
    XCTAssertEqual( ( NSUInteger )0, args.excludedPaths.count );
}

- ( void )testValidExcludeDir
{
    XCCArguments * args;
    const char   * argv[] = { "", "--exclude", "", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertFalse( args.showHelp );
    XCTAssertGreaterThan( args.excludedPaths.count, ( NSUInteger )0 );
}

- ( void )testInvalidID
{
    XCCArguments * args;
    const char   * argv[] = { "", "--id", "--verbose", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( args.showHelp );
    XCTAssertEqual( args.jobID, ( NSUInteger )0 );
}

- ( void )testValidID
{
    XCCArguments * args;
    const char   * argv[] = { "", "--id", "1234", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertFalse( args.showHelp );
    XCTAssertEqual( args.jobID, ( NSUInteger )1234 );
}

- ( void )testDefaultService
{
    XCCArguments * args;
    const char   * argv[] = { "", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    
    XCTAssertTrue( [ args.service isEqualToString: @"travis-ci" ] );
}

- ( void )testInvalidService
{
    XCCArguments * args;
    const char   * argv[] = { "", "--service", "--verbose", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( args.showHelp );
    XCTAssertNil( args.service );
}

- ( void )testCustomService
{
    XCCArguments * args;
    const char   * argv[] = { "", "--service", "xyz", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( [ args.service isEqualToString: @"xyz" ] );
}

- ( void )testInvalidToken
{
    XCCArguments * args;
    const char   * argv[] = { "", "--token", "--verbose", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( args.showHelp );
    XCTAssertNil( args.token );
}

- ( void )testValidToken
{
    XCCArguments * args;
    const char   * argv[] = { "", "--token", "1234", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertFalse( args.showHelp );
    XCTAssertTrue( [ args.token isEqualToString: @"1234" ] );
}

- ( void )testInvalidProject
{
    XCCArguments * args;
    const char   * argv[] = { "", "--project", "--verbose", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertTrue( args.showHelp );
    XCTAssertNil( args.project );
}

- ( void )testValidProject
{
    XCCArguments * args;
    const char   * argv[] = { "", "--project", "test", "" };
    
    args = [ [ XCCArguments alloc ] initWithArguments: argv count: 4 ];
    
    XCTAssertFalse( args.showHelp );
    XCTAssertTrue( [ args.project isEqualToString: @"test" ] );
}

@end
