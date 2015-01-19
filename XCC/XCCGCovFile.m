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

#import "XCCGCovFile.h"
#import "XCCGCovFileLine.h"

@interface XCCGCovFile()

@property( atomic, readwrite, strong ) NSString * path;
@property( atomic, readwrite, strong ) NSString * sourcePath;
@property( atomic, readwrite, strong ) NSString * graphPath;
@property( atomic, readwrite, strong ) NSString * dataPath;
@property( atomic, readwrite, assign ) NSUInteger runs;
@property( atomic, readwrite, assign ) NSUInteger programs;
@property( atomic, readwrite, strong ) NSArray  * lines;

- ( BOOL )parse;
- ( BOOL )parseLine: ( NSString * )line array: ( NSMutableArray * )array;

@end

@implementation XCCGCovFile

- ( instancetype )initWithPath: ( NSString * )path
{
    BOOL isDir;
    
    if( [ [ NSFileManager defaultManager ] fileExistsAtPath: path isDirectory: &isDir ] == NO || isDir == YES )
    {
        return nil;
    }
    
    if( ( self = [ super init ] ) )
    {
        self.path = path;
        
        if( [ self parse ] == NO )
        {
            return nil;
        }
    }
    
    return self;
}

- ( BOOL )parse
{
    NSData         * data;
    NSString       * text;
    NSString       * line;
    NSArray        * lines;
    NSMutableArray * array;
    
    data  = [ [ NSFileManager defaultManager ] contentsAtPath: self.path ];
    text  = [ [ NSString alloc ] initWithData: data encoding: NSUTF8StringEncoding ];
    lines = [ text componentsSeparatedByString: @"\n" ];
    array = [ NSMutableArray array ];
    
    for( line in lines )
    {
        if( line.length == 0 )
        {
            continue;
        }
        
        if( [ self parseLine: line array: array ] == NO )
        {
            return NO;
        }
    }
    
    self.lines = [ NSArray arrayWithArray: array ];
    
    return YES;
}

- ( BOOL )parseLine: ( NSString * )line array: ( NSMutableArray * )array
{
    NSRegularExpression  *                 expr;
    NSError              * __autoreleasing error;
    NSArray              *                 matches;
    NSTextCheckingResult *                 result;
    NSString             *                 match1;
    NSString             *                 match2;
    NSString             *                 match3;
    NSString             *                 pwd;
    XCCGCovFileLine      *                 gcovLine;
    NSUInteger                             coverage;
    NSUInteger                             lineNumber;
    BOOL                                   relevant;
    
    error = nil;
    expr  = [ NSRegularExpression regularExpressionWithPattern: @"^([^:]+):([^:]+):(.*)" options: ( NSRegularExpressionOptions )0 error: &error ];
    
    if( error != nil )
    {
        return NO;
    }
    
    matches = [ expr matchesInString: line options: ( NSMatchingOptions )0 range: NSMakeRange( 0, line.length ) ];
    
    if( matches.count != 1 )
    {
        return NO;
    }
    
    result = matches[ 0 ];
    
    if( [ result numberOfRanges ] != 4 )
    {
        return NO;
    }
    
    pwd = [ [ NSFileManager defaultManager ] currentDirectoryPath ];
    
    match1 = [ line substringWithRange: [ result rangeAtIndex: 1 ] ];
    match2 = [ line substringWithRange: [ result rangeAtIndex: 2 ] ];
    match3 = [ line substringWithRange: [ result rangeAtIndex: 3 ] ];
    match1 = [ match1 stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceCharacterSet ] ];
    match2 = [ match2 stringByTrimmingCharactersInSet: [ NSCharacterSet whitespaceCharacterSet ] ];
    
    coverage   = ( NSUInteger )[ match1 integerValue ];
    lineNumber = ( NSUInteger )[ match2 integerValue ];
    
    if( lineNumber == 0 )
    {
        if( [ match3 hasPrefix: @"Source:" ] )
        {
            self.sourcePath = [ [ match3 substringFromIndex: 7 ] stringByReplacingOccurrencesOfString: pwd withString: @"" ];
        }
        else if( [ match3 hasPrefix: @"Graph:" ] )
        {
            self.graphPath = [ match3 substringFromIndex: 6 ];
        }
        else if( [ match3 hasPrefix: @"Data:" ] )
        {
            self.dataPath = [ match3 substringFromIndex: 5 ];
        }
        else if( [ match3 hasPrefix: @"Runs:" ] )
        {
            self.runs = ( NSUInteger )[ [ match3 substringFromIndex: 5 ] integerValue ];
        }
        else if( [ match3 hasPrefix: @"Programs:" ] )
        {
            self.programs = ( NSUInteger )[ [ match3 substringFromIndex: 9 ] integerValue ];
        }
        
        return YES;
    }
    
    if( [ match1 isEqualToString: @"-" ] )
    {
        relevant = NO;
    }
    else
    {
        relevant = YES;
    }
    
    gcovLine = [ [ XCCGCovFileLine alloc ] initWithCode: match3 hits: coverage lineNumber: lineNumber relevant: relevant ];
    
    if( gcovLine == nil )
    {
        return NO;
    }
    
    [ array addObject: gcovLine ];
    
    return YES;
}

- ( NSString * )jsonRepresentation
{
    @synchronized( self )
    {
        NSMutableDictionary * dict;
        XCCGCovFileLine     * line;
        NSMutableString     * source;
        NSMutableArray      * coverage;
        NSData              * data;
        
        dict     = [ NSMutableDictionary new ];
        source   = [ NSMutableString     new ];
        coverage = [ NSMutableArray      new ];
        
        [ dict setObject: self.sourcePath forKey: @"name" ];
        
        for( line in self.lines )
        {
            [ source appendFormat: @"%@\n", line.code ];
            
            if( line.relevant )
            {
                [ coverage addObject: [ NSNumber numberWithUnsignedInteger: line.hits ] ];
            }
            else
            {
                [ coverage addObject: [ NSNull null ] ];
            }
        }
        
        [ dict setObject: source   forKey: @"source" ];
        [ dict setObject: coverage forKey: @"coverage" ];
        
        data = [ NSJSONSerialization dataWithJSONObject: dict options: NSJSONWritingPrettyPrinted error: nil ];
        
        return [ [ NSString alloc ] initWithData: data encoding: NSUTF8StringEncoding ];
    }
}

@end
