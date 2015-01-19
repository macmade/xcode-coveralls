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

@interface XCCCoverallsRequest()

@property( atomic, readwrite, strong ) NSDictionary * dictionary;

- ( BOOL )createError: ( NSError * __autoreleasing * )error withText: ( NSString * )text;

@end

@implementation XCCCoverallsRequest

- ( instancetype )initWithFiles: ( NSArray * )files arguments: ( XCCArguments * )args
{
    NSMutableDictionary * dict;
    NSString            * service;
    NSNumber            * jobID;
    NSArray             * sourceFiles;
    
    if( ( self = [ super init ] ) )
    {
        dict        = [ NSMutableDictionary new ];
        service     = ( args.service == nil ) ? @""               : args.service;
        sourceFiles = ( files        == nil ) ? [ NSArray array ] : files;
        jobID       = [ NSNumber numberWithUnsignedInteger: args.jobID ];
        
        [ dict setObject: service     forKey: @"service_name" ];
        [ dict setObject: jobID       forKey: @"service_job_id" ];
        [ dict setObject: sourceFiles forKey: @"source_files" ];
    }
    
    return self;
}

- ( BOOL )post: ( NSError * __autoreleasing * )error
{
    NSMutableURLRequest *                 req;
    NSString            *                 jsonText;
    NSData              *                 jsonData;
    NSString            *                 postText;
    NSData              *                 postData;
    NSHTTPURLResponse   * __autoreleasing response;
    
    if( *( error ) != NULL )
    {
        *( error ) = nil;
    }
    
    req      = [ [ NSMutableURLRequest alloc ] initWithURL: [ NSURL URLWithString: @"https://coveralls.io/api/v1/jobs" ] ];
    jsonData = nil;//[ NSJSONSerialization dataWithJSONObject: self.dictionary options: ( NSJSONWritingOptions )0 error: error ];
    jsonText = [ [ NSString alloc ] initWithData: jsonData encoding: NSUTF8StringEncoding ];
    
    if( *( error ) != NULL && *( error ) != nil )
    {
        return NO;
    }
    
    postText = [ @"json_file=" stringByAppendingString: [ jsonText stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding ] ];
    postData = [ postText dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion: YES ];
    
    [ req setValue:      @"application/x-www-form-urlencoded"                                        forHTTPHeaderField: @"Content-Type" ];
    [ req setValue:      [ NSString stringWithFormat: @"%lu", ( unsigned long )( postData.length ) ] forHTTPHeaderField: @"Content-Length" ];
    [ req setHTTPMethod: @"POST" ];
    [ req setHTTPBody: postData ];    
    
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
        [ self createError: error withText: [ NSString stringWithFormat: @"Bad response: %@", [ [ response allHeaderFields ] objectForKey: @"Status" ] ] ];
        
        return NO;
    }
    
    return YES;
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

@end
