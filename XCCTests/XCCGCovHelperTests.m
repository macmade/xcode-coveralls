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

@interface XCCGCovHelperTests()

@property( atomic, readwrite, strong ) NSString * tempPath;
@property( atomic, readwrite, strong ) NSString * dirPath;
@property( atomic, readwrite, strong ) NSString * invalidDirPath;
@property( atomic, readwrite, strong ) NSString * emptyDirPath;
@property( atomic, readwrite, strong ) NSString * filePath;

@end

@implementation XCCGCovHelperTests

- ( void )setUp
{
    NSString * template;
    char     * buf;
    char     * result;
    NSData   * gcdaData;
    NSData   * gcnoData;
    NSData   * codeData;
    
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
    self.invalidDirPath = [ self.tempPath stringByAppendingPathComponent: @"invalid" ];
    self.emptyDirPath   = [ self.tempPath stringByAppendingPathComponent: @"empty" ];
    self.filePath       = [ self.tempPath stringByAppendingPathComponent: @"file" ];
    
    gcdaData = [ NSData dataWithContentsOfFile: [ [ NSBundle bundleForClass: self.class ] pathForResource: @"test" ofType: @"gcda" ] ];
    gcnoData = [ NSData dataWithContentsOfFile: [ [ NSBundle bundleForClass: self.class ] pathForResource: @"test" ofType: @"gcno" ] ];
    codeData = [ [ NSFileManager defaultManager ] contentsAtPath: [ [ NSBundle bundleForClass: self.class ] pathForResource: @"test" ofType: @"" ] ];
    
    [ [ NSFileManager defaultManager ] createDirectoryAtPath: self.dirPath        withIntermediateDirectories: YES attributes: nil error: NULL ];
    [ [ NSFileManager defaultManager ] createDirectoryAtPath: self.invalidDirPath withIntermediateDirectories: YES attributes: nil error: NULL ];
    [ [ NSFileManager defaultManager ] createDirectoryAtPath: self.emptyDirPath   withIntermediateDirectories: YES attributes: nil error: NULL ];
    
    [ [ NSFileManager defaultManager ] createFileAtPath: self.filePath contents: nil attributes: nil ];
    
    [ [ NSFileManager defaultManager ] createFileAtPath: @"/tmp/test.m"                                                       contents: codeData attributes: nil ];
    [ [ NSFileManager defaultManager ] createFileAtPath: [ self.dirPath        stringByAppendingPathComponent: @"test.gcda" ] contents: gcdaData attributes: nil ];
    [ [ NSFileManager defaultManager ] createFileAtPath: [ self.dirPath        stringByAppendingPathComponent: @"test.gcno" ] contents: gcnoData attributes: nil ];
    [ [ NSFileManager defaultManager ] createFileAtPath: [ self.invalidDirPath stringByAppendingPathComponent: @"test.gcda" ] contents: nil attributes: nil ];
    [ [ NSFileManager defaultManager ] createFileAtPath: [ self.invalidDirPath stringByAppendingPathComponent: @"test.gcno" ] contents: nil attributes: nil ];
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

- ( void )testSetupInvalidDirPath
{
    BOOL isDir;
    
    isDir = NO;
    
    XCTAssertNotNil( self.dirPath );
    XCTAssertTrue( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.invalidDirPath isDirectory: &isDir ] );
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
    const char    *                 argv[] = { "", "--verbose", "test" };
    NSError       * __autoreleasing error;
    
    args  = [ [ XCCArguments alloc ] initWithArguments: argv count: 3 ];
    gcov  = [ [ XCCGCovHelper alloc ] initWithArguments: args ];
    error = nil;
    
    XCTAssertFalse( [ gcov run: &error ] );
    XCTAssertNotNil( error );
}

- ( void )testInvalidFilePath
{
    XCCGCovHelper *                 gcov;
    XCCArguments  *                 args;
    const char    *                 argv[] = { "", "--verbose", self.filePath.UTF8String };
    NSError       * __autoreleasing error;
    
    args  = [ [ XCCArguments alloc ] initWithArguments: argv count: 3 ];
    gcov  = [ [ XCCGCovHelper alloc ] initWithArguments: args ];
    error = nil;
    
    XCTAssertFalse( [ gcov run: &error ] );
    XCTAssertNotNil( error );
}

- ( void )testEmptyDirectoryPath
{
    XCCGCovHelper *                 gcov;
    XCCArguments  *                 args;
    const char    *                 argv[] = { "", "--verbose", self.emptyDirPath.UTF8String };
    NSError       * __autoreleasing error;
    
    args  = [ [ XCCArguments alloc ] initWithArguments: argv count: 3 ];
    gcov  = [ [ XCCGCovHelper alloc ] initWithArguments: args ];
    error = nil;
    
    XCTAssertFalse( [ gcov run: &error ] );
    XCTAssertNotNil( error );
}

- ( void )testInvalidDirectoryPath
{
    XCCGCovHelper *                 gcov;
    XCCArguments  *                 args;
    const char    *                 argv[] = { "", "--verbose", self.invalidDirPath.UTF8String };
    NSError       * __autoreleasing error;
    
    args  = [ [ XCCArguments alloc ] initWithArguments: argv count: 3 ];
    gcov  = [ [ XCCGCovHelper alloc ] initWithArguments: args ];
    error = nil;
    
    XCTAssertFalse( [ gcov run: &error ] );
    XCTAssertNotNil( error );
}

- ( void )testInvalidGCov
{
    XCCGCovHelper *                 gcov;
    XCCArguments  *                 args;
    const char    *                 argv[] = { "", "--verbose", "--gcov", "/bin/gcov", self.dirPath.UTF8String };
    NSError       * __autoreleasing error;
    
    args  = [ [ XCCArguments alloc ] initWithArguments: argv count: 5 ];
    gcov  = [ [ XCCGCovHelper alloc ] initWithArguments: args ];
    error = nil;
    
    XCTAssertFalse( [ gcov run: &error ] );
    XCTAssertNotNil( error );
}

- ( void )testValidDirectoryPath
{
    XCCGCovHelper *                 gcov;
    XCCArguments  *                 args;
    const char    *                 argv[] = { "", "--verbose", self.dirPath.UTF8String };
    NSError       * __autoreleasing error;
    BOOL                            success;
    
    args    = [ [ XCCArguments alloc ] initWithArguments: argv count: 3 ];
    gcov    = [ [ XCCGCovHelper alloc ] initWithArguments: args ];
    error   = nil;
    success = [ gcov run: &error ];
    
    if( success == NO )
    {
        NSLog( @"%@", error );
    }
    
    XCTAssertTrue( success );
    XCTAssertNil( error );
}

@end
