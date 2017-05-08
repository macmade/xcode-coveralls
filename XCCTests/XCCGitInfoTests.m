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
#import <clang-warnings.h>
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

- ( void )testValidRepos
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    
    XCTAssertNotNil( git );
}

- ( void )testInvalidRepos
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.invalidReposPath arguments: nil ];
    
    XCTAssertNil( git );
}

- ( void )testSHA1
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    
    XCTAssertTrue( [ git.sha1 isEqualToString: @"d6cfda0806def20a442b7378bc1b8bdb113df65f" ] );
}

- ( void )testAuthorName
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    
    XCTAssertTrue( [ git.authorName isEqualToString: @"macmade" ] );
}

- ( void )testAuthorEmail
{
    XCCGitInfo * git;
    NSString   * email;
    
    git   = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    email = [ git.authorEmail stringByReplacingOccurrencesOfString: @"@" withString: @"." ];
    
    XCTAssertTrue( [ email isEqualToString: @"macmade.xs-labs.com" ] );
}

- ( void )testCommitterName
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    
    XCTAssertTrue( [ git.committerName isEqualToString: @"macmade" ] );
}

- ( void )testCommitterEmail
{
    XCCGitInfo * git;
    NSString   * email;
    
    git   = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    email = [ git.committerEmail stringByReplacingOccurrencesOfString: @"@" withString: @"." ];
    
    XCTAssertTrue( [ email isEqualToString: @"macmade.xs-labs.com" ] );
}

- ( void )testTime
{
    XCCGitInfo * git;
    
    git   = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    XCTAssertEqual( git.time, 1425201366 );
}

- ( void )testMessage
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    
    XCTAssertTrue( [ git.message isEqualToString: @"Initial commit...\n" ] );
}

- ( void )testBranch
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    
    XCTAssertTrue( [ git.branch isEqualToString: @"test" ] );
}

- ( void )testRemotes
{
    XCCGitInfo   * git;
    NSArray      * remotes;
    NSDictionary * remote;
    
    git     = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    remotes = git.remotes;
    remote  = git.remotes.firstObject;
    
    XCTAssertEqual( remotes.count, ( NSUInteger )1 );
    XCTAssertTrue( [ remote[ @"name" ] isEqualToString: @"origin" ] );
    XCTAssertTrue( [ remote[ @"url" ]  isEqualToString: @"https://github.com/macmade/test.git" ] );
}

- ( void )testDictionaryRepresentation
{
    XCCGitInfo   * git;
    NSDictionary * gitDict;
    NSDictionary * headDict;
    NSArray      * remotes;
    NSDictionary * remoteDict;
    NSString     * email;
    
    git         = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath arguments: nil ];
    gitDict     = git.dictionaryRepresentation;
    headDict    = gitDict[ @"head" ];
    remotes     = gitDict[ @"remotes" ];
    remoteDict  = remotes.firstObject;
    
    XCTAssertNotNil( gitDict );
    XCTAssertNotNil( headDict );
    XCTAssertNotNil( remotes );
    XCTAssertNotNil( remoteDict );
    
    email = [ @"macmade/xs-labs.com" stringByReplacingOccurrencesOfString: @"/" withString: @"@" ];
    
    XCTAssertTrue( [ headDict[ @"id" ]              isEqualToString: @"d6cfda0806def20a442b7378bc1b8bdb113df65f" ] );
    XCTAssertTrue( [ headDict[ @"author_name" ]     isEqualToString: @"macmade" ] );
    XCTAssertTrue( [ headDict[ @"author_email" ]    isEqualToString: email ] );
    XCTAssertTrue( [ headDict[ @"committer_name" ]  isEqualToString: @"macmade" ] );
    XCTAssertTrue( [ headDict[ @"committer_email" ] isEqualToString: email ] );
    XCTAssertTrue( [ headDict[ @"message" ]         isEqualToString: @"Initial commit...\n" ] );
    XCTAssertTrue( [ gitDict[ @"branch" ]           isEqualToString: @"test" ] );
    XCTAssertTrue( [ remoteDict[ @"name" ]          isEqualToString: @"origin" ] );
    XCTAssertTrue( [ remoteDict[ @"url" ]           isEqualToString: @"https://github.com/macmade/test.git" ] );
}

@end
