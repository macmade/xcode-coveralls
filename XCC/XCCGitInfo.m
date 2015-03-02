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

#import "XCCGitInfo.h"

#ifdef __clang__
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpadded"
#pragma clang diagnostic ignored "-Wdocumentation"
#endif

#include "git2.h"

#ifdef __clang__
#pragma clang diagnostic pop
#endif

@interface XCCGitInfo()

@property( atomic, readwrite, assign ) git_repository * repository;
@property( atomic, readwrite, strong ) NSString       * sha1;
@property( atomic, readwrite, strong ) NSString       * authorName;
@property( atomic, readwrite, strong ) NSString       * authorEmail;
@property( atomic, readwrite, strong ) NSString       * committerName;
@property( atomic, readwrite, strong ) NSString       * committerEmail;
@property( atomic, readwrite, assign ) NSInteger        time;
@property( atomic, readwrite, strong ) NSString       * message;
@property( atomic, readwrite, strong ) NSString       * branch;
@property( atomic, readwrite, strong ) NSArray        * remotes;

- ( BOOL )getGitInfos: ( NSString * )path;

@end

@implementation XCCGitInfo

- ( instancetype )initWithRepositoryPath: ( NSString * )path
{
    if( ( self = [ super init ] ) )
    {
        if( [ self getGitInfos: path ] == NO )
        {
            return nil;
        }
    }
    
    return self;
}

- ( void )dealloc
{
    git_repository_free( self.repository );
}

- ( BOOL )getGitInfos: ( NSString * )path
{
    int                   err;
    git_repository      * repos;
    git_reference       * head;
    git_commit          * commit;
    git_remote          * remote;
    git_strarray          remoteNames;
    const git_oid       * oid; 
    const git_signature * author;
    const git_signature * committer;
    const char          * message;
    const char          * branchName;
    char                  sha[ 256 ];
    size_t                i;
    BOOL                  ret;
    NSMutableArray      * remotes;
    
    repos       = NULL;
    head        = NULL;
    commit      = NULL;
    branchName  = NULL;
    
    memset( &remoteNames, 0, sizeof( git_strarray ) );
    
    err = git_repository_open( &repos, path.UTF8String );
    
    if( err || repos == NULL )
    {
        goto fail;
    }
    
    err = git_repository_head( &head, repos );
    
    if( err || head == NULL )
    {
        goto fail;
    }
    
    oid = git_reference_target( head );
    err = git_commit_lookup( &commit, repos, oid );
    
    if( err || commit == NULL )
    {
        goto fail;
    }
    
    memset( sha, 0, sizeof( sha ) );
    git_oid_tostr( sha, sizeof( sha ) - 1, oid );
    
    author    = git_commit_author( commit );
    committer = git_commit_committer( commit );
    message   = git_commit_message( commit );
    
    self.sha1           = [ NSString stringWithCString: sha              encoding: NSUTF8StringEncoding ];
    self.authorName     = [ NSString stringWithCString: author->name     encoding: NSUTF8StringEncoding ];
    self.authorEmail    = [ NSString stringWithCString: author->email    encoding: NSUTF8StringEncoding ];
    self.committerName  = [ NSString stringWithCString: committer->name  encoding: NSUTF8StringEncoding ];
    self.committerEmail = [ NSString stringWithCString: committer->email encoding: NSUTF8StringEncoding ];
    self.message        = [ NSString stringWithCString: message          encoding: NSUTF8StringEncoding ];
    self.time           = ( NSInteger )( committer->when.time );
    
    if( git_reference_is_branch( head ) )
    {
        err = git_branch_name( &branchName, head );
        
        if( err || branchName == NULL )
        {
            goto fail;
        }
        
        self.branch = [ NSString stringWithCString: branchName encoding: NSUTF8StringEncoding ];
    }
    
    err = git_remote_list( &remoteNames, repos );
    
    if( err )
    {
        goto fail;
    }
    
    remotes = [ [ NSMutableArray alloc ] initWithCapacity: ( NSUInteger )( remoteNames.count ) ];
    
    for( i = 0; i < remoteNames.count; i++ )
    {
        err = git_remote_load( &remote, repos, remoteNames.strings[ i ] );
        
        if( err )
        {
            goto fail;
        }
        
        {
            NSString * name;
            NSString * url;
            
            name = [ NSString stringWithCString: git_remote_name( remote ) encoding: NSUTF8StringEncoding ];
            url  = [ NSString stringWithCString: git_remote_url( remote ) encoding: NSUTF8StringEncoding ];
        
            if( name != nil && url != nil )
            {
                [ remotes addObject: @{ @"name": name, @"url": url } ];
            }
        }
        
        git_remote_free( remote );
    }
    
    self.remotes = [ NSArray arrayWithArray: remotes ];
    
    ret = YES;
    
    goto cleanup;
    
    fail:
    
    ret = NO;
    
    cleanup:
    
    if( remoteNames.count )
    {
        git_strarray_free( &remoteNames );
    }
    
    git_commit_free( commit );
    git_reference_free( head );
    git_repository_free( repos );
    
    return ret;
}

- ( NSDictionary * )dictionaryRepresentation
{
    @synchronized( self )
    {
        NSMutableDictionary * git;
        NSMutableDictionary * head;
        NSString            * sha1;
        NSString            * aName;
        NSString            * aEmail;
        NSString            * cName;
        NSString            * cEmail;
        NSString            * msg;
        NSString            * branch;
        NSArray             * remotes;
        
        git     = [ NSMutableDictionary new ];
        head    = [ NSMutableDictionary new ];
        sha1    = self.sha1;
        aName   = self.authorName;
        aEmail  = self.authorEmail;
        cName   = self.committerName;
        cEmail  = self.committerEmail;
        msg     = self.message;
        branch  = self.branch;
        remotes = self.remotes;
        
        if( sha1    ) { [ head setObject: sha1   forKey: @"id" ]; }
        if( aName   ) { [ head setObject: aName  forKey: @"author_name" ]; }
        if( aEmail  ) { [ head setObject: aEmail forKey: @"author_email" ]; }
        if( cName   ) { [ head setObject: cName  forKey: @"committer_name" ]; }
        if( cEmail  ) { [ head setObject: cEmail forKey: @"committer_email" ]; }
        if( msg     ) { [ head setObject: msg    forKey: @"message" ]; }
        
        [ git setObject: [ NSDictionary dictionaryWithDictionary: head ] forKey: @"head" ];
        
        if( branch  ) { [ git setObject: branch  forKey: @"branch" ]; }
        if( remotes ) { [ git setObject: remotes forKey: @"remotes" ]; }
        
        return @{ @"git" : [ NSDictionary dictionaryWithDictionary: git ] };
    }
}

@end
