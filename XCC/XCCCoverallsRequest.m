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

#import "XCCCoverallsRequest.h"
#import "XCCArguments.h"
#import "XCCGCovFile.h"

@interface XCCCoverallsRequest()

@property( atomic, readwrite, strong ) NSDictionary * dictionary;
@property( atomic, readwrite, strong ) XCCArguments * arguments;

- ( BOOL )createError: ( NSError * __autoreleasing * )error withText: ( NSString * )text;
- ( void )log: ( NSString * )message;
- ( void )setPOSTData: ( NSData * )data forRequest: ( NSMutableURLRequest * )request;

@end

@implementation XCCCoverallsRequest

- ( instancetype )initWithFiles: ( NSArray * )files arguments: ( XCCArguments * )args
{
    NSMutableDictionary * dict;
    NSString            * service;
    NSNumber            * jobID;
    NSMutableArray      * sourceFiles;
    XCCGCovFile         * file;
    
    if( ( self = [ super init ] ) )
    {
        dict        = [ NSMutableDictionary new ];
        service     = ( args.service == nil ) ? @"" : args.service;
        jobID       = [ NSNumber numberWithUnsignedInteger: args.jobID ];
        sourceFiles = [ NSMutableArray new ];
        
        for( file in files )
        {
            [ sourceFiles addObject: file.dictionaryRepresentation ];
        }
        
        if( args.token != nil )
        {
            [ dict setObject: args.token forKey: @"repo_token" ];
        }
        else
        {
            [ dict setObject: service forKey: @"service_name" ];
            [ dict setObject: jobID   forKey: @"service_job_id" ];
        }
        
        [ dict setObject: sourceFiles forKey: @"source_files" ];
        
        NSDictionary* gitInfo = [self generateGitInformation];
        [ dict setObject: gitInfo forKey: @"git" ];
        
        self.dictionary = dict;
        self.arguments  = args;
    }
    
    return self;
}

- ( BOOL )post: ( NSError * __autoreleasing * )error
{
    NSMutableURLRequest *                 req;
    NSData              *                 jsonData;
    NSString            *                 jsonTextPretty;
    NSData              *                 jsonDataPretty;
    NSHTTPURLResponse   * __autoreleasing response;
    NSString            *                 statusText;
    
    if( *( error ) != NULL )
    {
        *( error ) = nil;
    }
    
    req            = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: @"https://coveralls.io/api/v1/jobs" ] ];
    jsonData       = [ NSJSONSerialization dataWithJSONObject: self.dictionary options: ( NSJSONWritingOptions )0 error: error ];
    jsonDataPretty = [ NSJSONSerialization dataWithJSONObject: self.dictionary options: NSJSONWritingPrettyPrinted error: error ];
    jsonTextPretty = [ [ NSString alloc ] initWithData: jsonDataPretty encoding: NSUTF8StringEncoding ];
    
    if( *( error ) != NULL && *( error ) != nil )
    {
        return NO;
    }
    
    [ self log: jsonTextPretty ];
    [ self setPOSTData: jsonData forRequest: req ];
    
    [ req setTimeoutInterval: 0 ];
    
    if( self.arguments.dryRun == NO )
    {
        [ NSURLConnection sendSynchronousRequest: req returningResponse: &response error: error ];
    }
    
    if( *( error ) != NULL && *( error ) != nil )
    {
        return NO;
    }
    
    if( self.arguments.dryRun == NO && [ response isKindOfClass: [ NSHTTPURLResponse class ] ] == NO )
    {
        [ self createError: error withText: @"Bad response" ];
        
        return NO;
    }
    
    if( self.arguments.dryRun == NO && response.statusCode != 200 )
    {
        statusText = [ [ response allHeaderFields ] objectForKey: @"Status" ];
        
        [ self createError: error withText: [ NSString stringWithFormat: @"Bad response: %lu (%@)", ( unsigned long )( response.statusCode ), ( statusText ) ? statusText : @"unknown" ] ];
        
        return NO;
    }
    
    return YES;
}

- ( void )setPOSTData: ( NSData * )data forRequest: ( NSMutableURLRequest * )request
{
    NSString      * boundary;
    NSString      * contentType;
    NSMutableData * body;
    
    [ request setHTTPMethod: @"POST" ];
    
    boundary    = [ @"XCODE-COVERALLS-" stringByAppendingString: [ [ NSUUID UUID ] UUIDString ] ];
    contentType = [ NSString stringWithFormat: @"multipart/form-data; boundary=%@", boundary ];
    
    [ request addValue: contentType forHTTPHeaderField: @"Content-Type" ];
    
    body = [ NSMutableData new ];
    
    [ body appendData: [ [ NSString stringWithFormat: @"\r\n--%@\r\n", boundary ] dataUsingEncoding: NSUTF8StringEncoding ] ];
    [ body appendData: [ @"Content-Disposition: form-data; name=\"json_file\"; filename=\"json_file\"\r\n" dataUsingEncoding: NSUTF8StringEncoding ] ];
    [ body appendData: [ @"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding: NSUTF8StringEncoding ] ];
    [ body appendData: data ];
    [ body appendData: [ [ NSString stringWithFormat: @"\r\n--%@--\r\n", boundary ] dataUsingEncoding: NSUTF8StringEncoding ] ];
    
    [ request setHTTPBody: body ];
}

- ( BOOL )createError: ( NSError * __autoreleasing * )error withText: ( NSString * )text
{
    if( error == NULL || text.length == 0 )
    {
        return NO;
    }
    
    *( error ) = [ NSError errorWithDomain: @"com.xs-labs.xcode-coveralls" code: 0 userInfo: @{ NSLocalizedDescriptionKey: text } ];
    
    return YES;
}

- ( void )log: ( NSString * )message
{
    if( self.arguments.verbose )
    {
        fprintf( stdout, "%s\n", message.UTF8String );
    }
}



-(NSDictionary*)generateGitInformation {
    //Taken from some python coveralls repo
    //    "git": {
    //        "head": {
    //            "id": "5e837ce92220be64821128a70f6093f836dd2c05",
    //            "author_name": "Wil Gieseler",
    //            "author_email": "wil@example.com",
    //            "committer_name": "Wil Gieseler",
    //            "committer_email": "wil@example.com",
    //            "message": "depend on simplecov >= 0.7"
    //        },
    //        "branch": "master",
    //        "remotes": [{
    //            "name": "origin",
    //            "url": "https://github.com/lemurheavy/coveralls-ruby.git"
    //        }]
    //    }
    
    NSString* gitLocation = @"/usr/bin/git";
    
    //Query remote list
    NSString* remoteList = [self launch:@"/usr/bin/git"
                                    cwd:@"."
                              arguments:@[@"remote", @"-v"]];
    
    NSArray* remotesQuery = [remoteList componentsSeparatedByString:@"\n"];
    
    //Package into Dictionary for unique-ness.
    NSMutableDictionary* uniqueRemotes = [NSMutableDictionary new];
    for (NSString* remote in remotesQuery) {
        NSArray* components = [remote componentsSeparatedByString:@"\t"];
        if (components.count > 1){
            NSString* url  = [[components[1] componentsSeparatedByString:@" "] firstObject];
            [uniqueRemotes setObject:url forKey:components[0]];
        }
    }
    
    //Construct into the gitinfo format
    NSMutableArray* remotes = [NSMutableArray new];
    for (NSString* key in uniqueRemotes) {
        NSString* value = [uniqueRemotes objectForKey:key];
        [remotes addObject:@{
                             @"name" : key,
                             @"url" : value
                             }];
    }
    
    NSString* branch = [self launch: gitLocation
                                cwd:@"."
                          arguments:@[@"name-rev", @"--name-only", @"HEAD"]];
    
    //Sanitize branch. Git has a ton of corner cases round this.
    branch = [branch stringByReplacingOccurrencesOfString:@"*" withString:@""]; //Dumb git stuff
    branch = [branch stringByReplacingOccurrencesOfString:@" " withString:@""]; //Dumb git stuff
    branch = [[branch componentsSeparatedByString:@"~"] firstObject]; //master~2 means 2 commits behind master. Reflect "master"
    branch = [[branch componentsSeparatedByString:@"/"] lastObject]; // refs/origin/master. Reflect "master"
    
    
    NSDictionary* gitInfo =
    @{
      @"head" : @{
              @"id" : [self launch:gitLocation cwd:@"." arguments:@[@"--no-pager", @"log", @"-1", @"--pretty=%H"]],
              @"author_name" : [self launch:gitLocation cwd:@"." arguments:@[@"--no-pager", @"log", @"-1", @"--pretty=%aN"]],
              @"author_email" : [self launch:gitLocation cwd:@"." arguments:@[@"--no-pager", @"log", @"-1", @"--pretty=%ae"]],
              @"committer_name" : [self launch:gitLocation cwd:@"." arguments:@[@"--no-pager", @"log", @"-1", @"--pretty=%cN"]],
              @"committer_email" : [self launch:gitLocation cwd:@"." arguments:@[@"--no-pager", @"log", @"-1", @"--pretty=%ce"]],
              @"message" : [self launch:gitLocation cwd:@"." arguments:@[@"--no-pager", @"log", @"-1", @"--pretty=%s"]]
              },
      @"branch" : branch,
      @"remotes" : remotes
      
      };
    return gitInfo;
}

-(NSString*)launch:(NSString*)app
               cwd: (NSString*)cwd
         arguments: (NSArray*)arguments{
    NSTask * list = [[NSTask alloc] init];
    [list setLaunchPath:app];
    [list setArguments:arguments];
    [list setCurrentDirectoryPath:cwd];
    
    NSPipe * out = [NSPipe pipe];
    [list setStandardOutput:out];
    
    [list launch];
    [list waitUntilExit];
    
    NSFileHandle * read = [out fileHandleForReading];
    NSData * dataRead = [read readDataToEndOfFile];
    NSString * stringRead = [[NSString alloc] initWithData:dataRead encoding:NSUTF8StringEncoding];
    return [stringRead stringByReplacingCharactersInRange:NSMakeRange(stringRead.length-1, 1) withString:@""]; //Replace final character (\n) with empty string.
}

@end
