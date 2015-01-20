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
        service     = ( args.service == nil ) ? @""               : args.service;
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
        
        self.dictionary = dict;
        self.arguments  = args;
    }
    
    return self;
}

- ( BOOL )post: ( NSError * __autoreleasing * )error
{
    NSMutableURLRequest *                 req;
    NSString            *                 jsonText;
    NSData              *                 jsonData;
    NSHTTPURLResponse   * __autoreleasing response;
    NSString            *                 statusText;
    
    if( *( error ) != NULL )
    {
        *( error ) = nil;
    }
    
    req      = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: @"https://coveralls.io/api/v1/jobs" ] ];
    jsonData = [ NSJSONSerialization dataWithJSONObject: self.dictionary options: ( NSJSONWritingOptions )0 error: error ];
    jsonText = [ [ NSString alloc ] initWithData: jsonData encoding: NSUTF8StringEncoding ];
    
    if( *( error ) != NULL && *( error ) != nil )
    {
        return NO;
    }
    
    [ self log: jsonText ];
    [ self setPOSTData: jsonData forRequest: req ]; 
    
    [ req setTimeoutInterval: 0 ];
    [ NSURLConnection sendSynchronousRequest: req returningResponse: &response error: error ];
    
    if( *( error ) != NULL && *( error ) != nil )
    {
        return NO;
    }
    
    if( [ response isKindOfClass: [ NSHTTPURLResponse class ] ] == NO )
    {
        [ self createError: error withText: @"Bad response" ];
        
        return NO;
    }
    
    if( response.statusCode != 200 )
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

@end
