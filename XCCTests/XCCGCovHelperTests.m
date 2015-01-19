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

#import "XCCGCovHelperTests.h"
#import "XCC.h"

@interface XCCGCovHelperTests()

@property( atomic, readwrite, retain ) NSString * tempPath;
@property( atomic, readwrite, retain ) NSString * dirPath;
@property( atomic, readwrite, retain ) NSString * emptyDirPath;
@property( atomic, readwrite, retain ) NSString * filePath;

@end

@implementation XCCGCovHelperTests

- ( void )setUp
{
    NSString * template;
    char     * buf;
    char     * result;
    
    template = [ NSTemporaryDirectory() stringByAppendingPathComponent: @"xcode-coveralls.XXXXXX" ];
    buf      = malloc( strlen( template.fileSystemRepresentation ) + 1 );
    
    if( buf == NULL )
    {
        return;
    }
    
    strlcpy( buf, template.fileSystemRepresentation, strlen( template.fileSystemRepresentation ) );
    
    result = mkdtemp( buf );
    
    if( result == NULL )
    {
        free( buf );
        
        return;
    }
    
    free( buf );
    
    self.tempPath       = [ [ NSFileManager defaultManager ] stringWithFileSystemRepresentation: result length: strlen( result ) ];
    self.dirPath        = [ self.tempPath stringByAppendingPathComponent: @"dir" ];
    self.emptyDirPath   = [ self.tempPath stringByAppendingPathComponent: @"empty" ];
    self.filePath       = [ self.tempPath stringByAppendingPathComponent: @"file" ];
    
    [ [ NSFileManager defaultManager ] createDirectoryAtPath: self.dirPath withIntermediateDirectories: YES attributes: nil error: NULL ];
    [ [ NSFileManager defaultManager ] createDirectoryAtPath: self.emptyDirPath withIntermediateDirectories: YES attributes: nil error: NULL ];
    [ [ NSFileManager defaultManager ] createFileAtPath: self.filePath contents: nil attributes: nil ];
    [ [ NSFileManager defaultManager ] createFileAtPath: [ self.dirPath stringByAppendingPathComponent: @"test.gcda" ] contents: nil attributes: nil ];
}

- ( void )tearDown
{
    [ [ NSFileManager defaultManager ] removeItemAtPath: self.tempPath error: nil ];
}

- ( void )testSetupTempPath
{
    BOOL isDir;
    
    isDir = NO;
    
    XCTAssertNotNil( self.tempPath );
    XCTAssertTrue( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.tempPath isDirectory: &isDir ] );
    XCTAssertTrue( isDir );
}

- ( void )testSetupDirPath
{
    BOOL isDir;
    
    isDir = NO;
    
    XCTAssertNotNil( self.dirPath );
    XCTAssertTrue( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.dirPath isDirectory: &isDir ] );
    XCTAssertTrue( isDir );
    XCTAssertGreaterThan( [ [ [ NSFileManager defaultManager ] contentsOfDirectoryAtPath: self.dirPath error: NULL ] count ], ( NSUInteger )0 );
}

- ( void )testSetupEmptyDirPath
{
    BOOL isDir;
    
    isDir = NO;
    
    XCTAssertNotNil( self.emptyDirPath );
    XCTAssertTrue( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.emptyDirPath isDirectory: &isDir ] );
    XCTAssertTrue( isDir );
    XCTAssertEqual( [ [ [ NSFileManager defaultManager ] contentsOfDirectoryAtPath: self.emptyDirPath error: NULL ] count ], ( NSUInteger )0 );
}

- ( void )testSetupFilePath
{
    BOOL isDir;
    
    isDir = NO;
    
    XCTAssertNotNil( self.filePath );
    XCTAssertTrue( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.filePath isDirectory: &isDir ] );
    XCTAssertFalse( isDir );
}

- ( void )testInvalidPath
{
    XCCGCovHelper *                 gcov;
    XCCArguments  *                 args;
    const char    *                 argv[] = { "--verbose", "test" };
    NSError       * __autoreleasing error;
    
    args  = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    gcov  = [ [ XCCGCovHelper alloc ] initWithArguments: args ];
    error = nil;
    
    XCTAssertFalse( [ gcov run: &error ] );
    XCTAssertNotNil( error );
}

@end
