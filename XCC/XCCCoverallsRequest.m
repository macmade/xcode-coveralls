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
#import "XCCGitInfo.h"

@interface XCCCoverallsRequest()

@property( atomic, readwrite, strong ) NSDictionary * dictionary;
@property( atomic, readwrite, strong ) XCCArguments * arguments;

- ( BOOL )createError: ( NSError * __autoreleasing * )error withText: ( NSString * )text;
- ( void )log: ( NSString * )message;
- ( void )setPOSTData: ( NSData * )data forRequest: ( NSMutableURLRequest * )request;

@end

@implementation XCCCoverallsRequest

- ( instancetype )init
{
    return [ self initWithFiles: nil arguments: nil ];
}

- ( instancetype )initWithFiles: ( NSArray * )files arguments: ( XCCArguments * )args
{
    NSMutableDictionary * dict;
    NSString            * service;
    NSNumber            * jobID;
    NSMutableArray      * sourceFiles;
    XCCGCovFile         * file;
    NSDictionary        * info;
    XCCGitInfo          * gitInfo;
    
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
        
        gitInfo = [ [ XCCGitInfo alloc ] initWithRepositoryPath: [ [ NSFileManager defaultManager ] currentDirectoryPath ] arguments: args ];
        info    = gitInfo.dictionaryRepresentation;
        
        if( info )
        {
            [ dict setObject: info forKey: @"git" ];
        }
        
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
    NSData              *                 data;
    
    if( *( error ) != NULL )
    {
        *( error ) = nil;
    }
    
    req            = [ [ NSMutableURLRequest alloc ] initWithURL: ( id )[ NSURL URLWithString: @"https://coveralls.io/api/v1/jobs" ] ];
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
        data = [ NSURLConnection sendSynchronousRequest: req returningResponse: &response error: error ];
    }
    else
    {
        data = [ NSData data ];
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
        
        {
            NSString * body;
            NSString * errorText;
            NSString * header;
            
            body      = [ [ NSString alloc ] initWithData: ( data ) ? data : [ NSData data ] encoding: NSUTF8StringEncoding ];
            errorText = [ NSString stringWithFormat: @"Bad response: %lu (%@)", ( unsigned long )( response.statusCode ), ( statusText ) ? statusText : @"unknown" ];
            
            if( response.allHeaderFields.count > 0 )
            {
                errorText = [ errorText stringByAppendingString: @"\n" ];
                
                for( header in response.allHeaderFields )
                {
                    errorText = [ errorText stringByAppendingFormat: @"\n%@: %@", header, [ response.allHeaderFields objectForKey: header ] ];
                }
            }
            
            if( body.length > 0 )
            {
                errorText = [ errorText stringByAppendingFormat: @"\n\n%@", body ];
            }
            
            [ self createError: error withText: errorText ];
        }
        
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
    
    [ body appendData: ( id )[ [ NSString stringWithFormat: @"\r\n--%@\r\n", boundary ] dataUsingEncoding: NSUTF8StringEncoding ] ];
    [ body appendData: ( id )[ @"Content-Disposition: form-data; name=\"json_file\"; filename=\"json_file\"\r\n" dataUsingEncoding: NSUTF8StringEncoding ] ];
    [ body appendData: ( id )[ @"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding: NSUTF8StringEncoding ] ];
    [ body appendData: data ];
    [ body appendData: ( id )[ [ NSString stringWithFormat: @"\r\n--%@--\r\n", boundary ] dataUsingEncoding: NSUTF8StringEncoding ] ];
    
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

@end
