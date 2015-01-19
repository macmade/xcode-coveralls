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

#import "XCCGCovHelper.h"
#import "XCCArguments.h"

@interface XCCGCovHelper()

@property( atomic, readwrite, retain ) XCCArguments * arguments;

- ( BOOL )createError: ( NSError * __autoreleasing * )error withText: ( NSString * )text;

@end

@implementation XCCGCovHelper

- ( instancetype )initWithArguments: ( XCCArguments * )args
{
    if( ( self = [ super init ] ) )
    {
        self.arguments = args;
    }
    
    return self;
}

- ( BOOL )run: ( NSError * __autoreleasing * )error
{
    BOOL isDir;
    
    if( error != NULL )
    {
        *( error ) = nil;
    }
    
    isDir = NO;
    
    if( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.arguments.buildDirectory isDirectory: &isDir ] )
    {
        [ self createError: error withText: [ NSString stringWithFormat: @"Build directory does not exist: %@", self.arguments.buildDirectory ] ];
        
        return NO;
    }
    
    if( isDir == NO )
    {
        [ self createError: error withText: [ NSString stringWithFormat: @"Build directory is not a directory: %@", self.arguments.buildDirectory ] ];
        
        return NO;
    }
    
    return NO;
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
