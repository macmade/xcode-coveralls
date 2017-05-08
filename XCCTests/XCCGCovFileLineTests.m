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

@interface XCCGCovFileLineTests: XCTestCase

@end

@implementation XCCGCovFileLineTests

- ( void )testInit
{
    XCCGCovFileLine * l1;
    XCCGCovFileLine * l2;
    
    l1 = [ [ XCCGCovFileLine alloc ] init ];
    l2 = [ [ XCCGCovFileLine alloc ] initWithCode: @"hello" hits: 42 lineNumber: 1 relevant: YES ];
    
    XCTAssertNotNil( l1 );
    XCTAssertNotNil( l2 );
    
    XCTAssertEqualObjects( l1.code,        @"" );
    XCTAssertEqual(        l1.hits,        ( NSUInteger )0 );
    XCTAssertEqual(        l1.lineNumber,  ( NSUInteger )0 );
    XCTAssertEqual(        l1.relevant,    NO );
    
    XCTAssertEqualObjects( l2.code,        @"hello" );
    XCTAssertEqual(        l2.hits,        ( NSUInteger )42 );
    XCTAssertEqual(        l2.lineNumber,  ( NSUInteger )1 );
    XCTAssertEqual(        l2.relevant,    YES );
}

@end
