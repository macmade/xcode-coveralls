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

- ( void )testValidRepos
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    
    XCTAssertNotNil( git );
}

- ( void )testInvalidRepos
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.invalidReposPath ];
    
    XCTAssertNil( git );
}

- ( void )testSHA1
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    
    XCTAssertTrue( [ git.sha1 isEqualToString: @"d6cfda0806def20a442b7378bc1b8bdb113df65f" ] );
}

- ( void )testAuthorName
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    
    XCTAssertTrue( [ git.authorName isEqualToString: @"macmade" ] );
}

- ( void )testAuthorEmail
{
    XCCGitInfo * git;
    NSString   * email;
    
    git   = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    email = [ git.authorEmail stringByReplacingOccurrencesOfString: @"@" withString: @"." ];
    
    XCTAssertTrue( [ email isEqualToString: @"macmade.xs-labs.com" ] );
}

- ( void )testCommitterName
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    
    XCTAssertTrue( [ git.committerName isEqualToString: @"macmade" ] );
}

- ( void )testCommitterEmail
{
    XCCGitInfo * git;
    NSString   * email;
    
    git   = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    email = [ git.committerEmail stringByReplacingOccurrencesOfString: @"@" withString: @"." ];
    
    XCTAssertTrue( [ email isEqualToString: @"macmade.xs-labs.com" ] );
}

- ( void )testTime
{
    XCCGitInfo * git;
    
    git   = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    XCTAssertEqual( git.time, 1425201366 );
}

- ( void )testMessage
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    
    XCTAssertTrue( [ git.message isEqualToString: @"Initial commit...\n" ] );
}

- ( void )testBranch
{
    XCCGitInfo * git;
    
    git = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    
    XCTAssertTrue( [ git.branch isEqualToString: @"master" ] );
}

- ( void )testRemotes
{
    XCCGitInfo   * git;
    NSArray      * remotes;
    NSDictionary * remote;
    
    git     = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    remotes = git.remotes;
    remote  = git.remotes.firstObject;
    
    XCTAssertEqual( remotes.count, ( NSUInteger )1 );
    XCTAssertTrue( [ remote[ @"name" ] isEqualToString: @"origin" ] );
    XCTAssertTrue( [ remote[ @"url" ]  isEqualToString: @"https://github.com/macmade/test.git" ] );
}

- ( void )testDictionaryRepresentation
{
    XCCGitInfo   * git;
    NSDictionary * dict;
    NSDictionary * gitDict;
    NSDictionary * headDict;
    NSArray      * remotes;
    NSDictionary * remoteDict;
    NSString     * email;
    
    git         = [ [ XCCGitInfo alloc ] initWithRepositoryPath: self.reposPath ];
    dict        = git.dictionaryRepresentation;
    gitDict     = dict[ @"git" ];
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
    XCTAssertTrue( [ gitDict[ @"branch" ]           isEqualToString: @"master" ] );
    XCTAssertTrue( [ remoteDict[ @"name" ]          isEqualToString: @"origin" ] );
    XCTAssertTrue( [ remoteDict[ @"url" ]           isEqualToString: @"https://github.com/macmade/test.git" ] );
}

@end
