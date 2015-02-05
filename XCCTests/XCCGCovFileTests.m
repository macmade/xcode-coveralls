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

@interface XCCGCovFileTests: XCTestCase

@property( atomic, readwrite, strong ) NSString * path;

@end

@implementation XCCGCovFileTests

- ( void )setUp
{
    [ super setUp ];
    
    self.path = [ [ NSBundle bundleForClass: self.class ] pathForResource: @"test.m" ofType: @"gcov" ];
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
    
    XCTAssertTrue( [ file.sourcePath isEqualToString: @"/tmp/test.m" ] );
}

- ( void )testGraphPath
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertTrue( [ file.graphPath hasSuffix: @"test.gcno" ] );
}

- ( void )testDataPath
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertTrue( [ file.dataPath hasSuffix: @"test.gcda" ] );
}

- ( void )testRuns
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertEqual( file.runs, ( NSUInteger )1 );
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
    
    XCTAssertEqual( file.lines.count, ( NSUInteger )14 );
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

- ( void )testLine8
{
    XCCGCovFile     * file;
    XCCGCovFileLine * line;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    line = file.lines[ 7 ];
    
    XCTAssertEqual( line.hits,       ( NSUInteger )1 );
    XCTAssertEqual( line.lineNumber, ( NSUInteger )8 );
    XCTAssertTrue( line.relevant );
}

- ( void )testLine12
{
    XCCGCovFile     * file;
    XCCGCovFileLine * line;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    line = file.lines[ 11 ];
    
    XCTAssertEqual( line.hits,       ( NSUInteger )0 );
    XCTAssertEqual( line.lineNumber, ( NSUInteger )12 );
    XCTAssertTrue( line.relevant );
}

- ( void )testJSONRepresentation
{
    XCCGCovFile * file;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    
    XCTAssertNotNil( file.jsonRepresentation );
    XCTAssertGreaterThan( file.jsonRepresentation.length, ( NSUInteger )0 );
}

- ( void )testDictionaryRepresentation
{
    XCCGCovFile  * file;
    NSDictionary * dict;
    
    file = [ [ XCCGCovFile alloc ] initWithPath: self.path ];
    dict = file.dictionaryRepresentation;
    
    XCTAssertNotNil( dict );
    XCTAssertNotNil( [ dict objectForKey: @"name" ] );
    XCTAssertNotNil( [ dict objectForKey: @"source" ] );
    XCTAssertNotNil( [ dict objectForKey: @"coverage" ] );
    XCTAssertTrue( [ [ dict objectForKey: @"coverage" ] isKindOfClass: [ NSArray class ] ] );
    XCTAssertEqual( [ [ dict objectForKey: @"coverage" ] count ], ( NSUInteger )14 );
}

@end
