/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2014 Jean-David Gadina - www-xs-labs.com
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

#import "XCCGCovFileTests.h"

@interface XCCGCovFileTests()

@property( atomic, readwrite, strong ) NSString * path;

@end

@implementation XCCGCovFileTests

- ( void )setUp
{
    self.path = [ [ NSBundle bundleForClass: self.class ] pathForResource: @"test" ofType: @"gcov" ];
}

- ( void )testInvalidFile
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: @"" ];
    
    XCTAssertNil( file );
}

- ( void )testValidFile
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertNotNil( file );
}

- ( void )testSourcePath
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertTrue( [ file.sourcePath isEqualToString: @"/XCC/XCCArguments.m" ] );
}

- ( void )testGraphPath
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertTrue( [ file.graphPath containsString: @"/dir/test.gcno" ] );
}

- ( void )testDataPath
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertTrue( [ file.dataPath containsString: @"/dir/test.gcda" ] );
}

- ( void )testRuns
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertEqual( file.runs, ( NSUInteger )53 );
}

- ( void )testPrograms
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertEqual( file.programs, ( NSUInteger )1 );
}

- ( void )testLineCount
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertEqual( file.lines.count, ( NSUInteger )148 );
}

- ( void )testLine1
{
    XCCGCovFile     * file;
    XCCGCovFileLine * line;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    line = file.lines[ 0 ];
    
    XCTAssertEqual( line.hits,       ( NSUInteger )0 );
    XCTAssertEqual( line.lineNumber, ( NSUInteger )1 );
    XCTAssertFalse( line.relevant );
}

- ( void )testLine29
{
    XCCGCovFile     * file;
    XCCGCovFileLine * line;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    line = file.lines[ 28 ];
    
    XCTAssertEqual( line.hits,       ( NSUInteger )565 );
    XCTAssertEqual( line.lineNumber, ( NSUInteger )29 );
    XCTAssertTrue( line.relevant );
}

- ( void )testJSONRepresentation
{
    XCCGCovFile     * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertNotNil( file.jsonRepresentation );
    XCTAssertGreaterThan( file.jsonRepresentation.length, ( NSUInteger )0 );
}

@end
