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

@import ObjectiveC.runtime;

#pragma clang diagnostic ignored "-Wselector"

@interface XCCCoverallsRequestTests: XCTestCase

@property( atomic, readwrite, strong ) NSString * gcovFilePath;

+ ( NSData * )sendSynchronousRequest: ( NSURLRequest * )request returningValidResponse: ( NSURLResponse * __autoreleasing * )response error: ( NSError * __autoreleasing * )error;
+ ( NSData * )sendSynchronousRequest: ( NSURLRequest * )request returningInvalidResponse: ( NSURLResponse * __autoreleasing * )response error: ( NSError * __autoreleasing * )error;
- ( void )swizzleSelector: ( SEL )s1 ofClass: ( Class )cls1 withSelector: ( SEL )s2 ofClass: ( Class )cls2;
- ( void )swizzleClassSelector: ( SEL )s1 ofClass: ( Class )cls1 withSelector: ( SEL )s2 ofClass: ( Class )cls2;

@end

@implementation XCCCoverallsRequestTests

- ( void )setUp
{
    [ super setUp ];
    
    self.gcovFilePath = [ [ NSBundle bundleForClass: self.class ] pathForResource: @"test.m" ofType: @"gcov" ];
}

- ( void )testValidPost
{
    XCCGCovFile         *                 file;
    XCCCoverallsRequest *                 request;
    XCCArguments        *                 args;
    NSError             * __autoreleasing error;
    const char          *                 argv[] = { "", "" };
    
    args    = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    file    = [ [ XCCGCovFile alloc ] initWithPath: self.gcovFilePath ];
    request = [ [ XCCCoverallsRequest alloc ] initWithFiles: @[ file ] arguments: args ];
    error   = nil;
    
    [ self swizzleClassSelector: @selector( sendSynchronousRequest:returningResponse:error: ) ofClass: [ NSURLConnection class ] withSelector: @selector( sendSynchronousRequest:returningValidResponse:error: ) ofClass: [ self class ] ];
    
    XCTAssertTrue( [ request post: &error ] );
    XCTAssertNil( error );
    
    [ self swizzleClassSelector: @selector( sendSynchronousRequest:returningResponse:error: ) ofClass: [ NSURLConnection class ] withSelector: @selector( sendSynchronousRequest:returningValidResponse:error: ) ofClass: [ self class ] ];
}

- ( void )testBadPost
{
    XCCGCovFile         *                 file;
    XCCCoverallsRequest *                 request;
    XCCArguments        *                 args;
    NSError             * __autoreleasing error;
    const char          *                 argv[] = { "", "" };
    
    args    = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    file    = [ [ XCCGCovFile alloc ] initWithPath: self.gcovFilePath ];
    request = [ [ XCCCoverallsRequest alloc ] initWithFiles: @[ file ] arguments: args ];
    error   = nil;
    
    [ self swizzleClassSelector: @selector( sendSynchronousRequest:returningResponse:error: ) ofClass: [ NSURLConnection class ] withSelector: @selector( sendSynchronousRequest:returningBadResponse:error: ) ofClass: [ self class ] ];
    
    XCTAssertFalse( [ request post: &error ] );
    XCTAssertNotNil( error );
    
    [ self swizzleClassSelector: @selector( sendSynchronousRequest:returningResponse:error: ) ofClass: [ NSURLConnection class ] withSelector: @selector( sendSynchronousRequest:returningBadResponse:error: ) ofClass: [ self class ] ];
}

- ( void )testInvalidPost
{
    XCCGCovFile         *                 file;
    XCCCoverallsRequest *                 request;
    XCCArguments        *                 args;
    NSError             * __autoreleasing error;
    const char          *                 argv[] = { "", "" };
    
    args    = [ [ XCCArguments alloc ] initWithArguments: argv count: 2 ];
    file    = [ [ XCCGCovFile alloc ] initWithPath: self.gcovFilePath ];
    request = [ [ XCCCoverallsRequest alloc ] initWithFiles: @[ file ] arguments: args ];
    error   = nil;
    
    [ self swizzleClassSelector: @selector( sendSynchronousRequest:returningResponse:error: ) ofClass: [ NSURLConnection class ] withSelector: @selector( sendSynchronousRequest:returningInvalidResponse:error: ) ofClass: [ self class ] ];
    
    XCTAssertFalse( [ request post: &error ] );
    XCTAssertNotNil( error );
    
    [ self swizzleClassSelector: @selector( sendSynchronousRequest:returningResponse:error: ) ofClass: [ NSURLConnection class ] withSelector: @selector( sendSynchronousRequest:returningInvalidResponse:error: ) ofClass: [ self class ] ];
}

+ ( NSData * )sendSynchronousRequest: ( NSURLRequest * )request returningValidResponse: ( NSURLResponse * __autoreleasing * )response error: ( NSError * __autoreleasing * )error
{
    ( void )request;
    
    if( error != NULL )
    {
        *( error ) = nil;
    }
    
    if( response != NULL )
    {
        *( response ) = [ [ NSHTTPURLResponse alloc ] initWithURL: nil statusCode: 200 HTTPVersion: nil headerFields: nil ];
    }
    
    return nil;
}

+ ( NSData * )sendSynchronousRequest: ( NSURLRequest * )request returningBadResponse: ( NSURLResponse * __autoreleasing * )response error: ( NSError * __autoreleasing * )error
{
    ( void )request;
    
    if( error != NULL )
    {
        *( error ) = [ NSError errorWithDomain: @"" code: 0 userInfo: nil ];
    }
    
    if( response != NULL )
    {
        *( response ) = [ [ NSHTTPURLResponse alloc ] initWithURL: nil statusCode: 404 HTTPVersion: nil headerFields: nil ];
    }
    
    return nil;
}

+ ( NSData * )sendSynchronousRequest: ( NSURLRequest * )request returningInvalidResponse: ( NSURLResponse * __autoreleasing * )response error: ( NSError * __autoreleasing * )error
{
    ( void )request;
    
    if( error != NULL )
    {
        *( error ) = [ NSError errorWithDomain: @"" code: 0 userInfo: nil ];
    }
    
    if( response != NULL )
    {
        *( response ) = ( NSURLResponse * )[ NSObject new ];
    }
    
    return nil;
}

- ( void )swizzleSelector: ( SEL )s1 ofClass: ( Class )cls1 withSelector: ( SEL )s2 ofClass: ( Class )cls2
{
    Method m1;
    Method m2;
    
    m1 = class_getInstanceMethod( cls1, s1 );
    m2 = class_getInstanceMethod( cls2, s2 );
    
    method_exchangeImplementations( m1, m2 );
}

- ( void )swizzleClassSelector: ( SEL )s1 ofClass: ( Class )cls1 withSelector: ( SEL )s2 ofClass: ( Class )cls2
{
    Method m1;
    Method m2;
    
    m1 = class_getClassMethod( cls1, s1 );
    m2 = class_getClassMethod( cls2, s2 );
    
    method_exchangeImplementations( m1, m2 );
}

@end
