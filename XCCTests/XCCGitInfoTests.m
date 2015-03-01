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

@interface XCCGitInfoTests: XCTestCase

@property( atomic, readwrite, strong ) NSString * tempPath;
@property( atomic, readwrite, strong ) NSString * reposPath;
@property( atomic, readwrite, strong ) NSString * invalidReposPath;

@end

@implementation XCCGitInfoTests

- ( void )setUp
{
    NSString * bundleReposPath;
    NSString * template;
    char     * buf;
    char     * result;
    
    [ super setUp ];
    
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
    
    bundleReposPath       = [ [ NSBundle bundleForClass: self.class ] pathForResource: @"repos" ofType: @"" ];
    self.tempPath         = [ [ NSFileManager defaultManager ] stringWithFileSystemRepresentation: result length: strlen( result ) ];
    self.reposPath        = [ self.tempPath stringByAppendingPathComponent: @"repos" ];
    self.invalidReposPath = [ self.tempPath stringByAppendingPathComponent: @"invalid" ];
    
    [ [ NSFileManager defaultManager ] createDirectoryAtPath: self.invalidReposPath withIntermediateDirectories: YES attributes: nil error: NULL ];
    [ [ NSFileManager defaultManager ] copyItemAtPath: bundleReposPath toPath: self.reposPath error: NULL ];
    [ [ NSFileManager defaultManager ] moveItemAtPath: [ self.reposPath stringByAppendingPathComponent: @"git" ]
                                       toPath:         [ self.reposPath stringByAppendingPathComponent: @".git" ]
                                       error:          NULL
    ];
    
    free( buf );
}

- ( void )tearDown
{
    [ [ NSFileManager defaultManager ] removeItemAtPath: self.tempPath error: nil ];
    
    [ super tearDown ];
}

- ( void )testSetupTempPath
{
    BOOL isDir;
    
    isDir = NO;
    
    XCTAssertNotNil( self.tempPath );
    XCTAssertTrue( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.tempPath isDirectory: &isDir ] );
    XCTAssertTrue( isDir );
}

- ( void )testSetupReposPath
{
    BOOL isDir;
    
    isDir = NO;
    
    XCTAssertNotNil( self.reposPath );
    XCTAssertTrue( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.reposPath isDirectory: &isDir ] );
    XCTAssertTrue( isDir );
    XCTAssertGreaterThan( [ [ [ NSFileManager defaultManager ] contentsOfDirectoryAtPath: self.reposPath error: NULL ] count ], ( NSUInteger )0 );
}

- ( void )testSetupInvalidReposPath
{
    BOOL isDir;
    
    isDir = NO;
    
    XCTAssertNotNil( self.invalidReposPath );
    XCTAssertTrue( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.invalidReposPath isDirectory: &isDir ] );
    XCTAssertTrue( isDir );
    XCTAssertEqual( [ [ [ NSFileManager defaultManager ] contentsOfDirectoryAtPath: self.invalidReposPath error: NULL ] count ], ( NSUInteger )0 );
}

@end
