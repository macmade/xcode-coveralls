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
#import "XCCGCovFile.h"
#import "XCCArguments.h"

@interface XCCGCovHelper()

@property( atomic, readwrite, strong ) XCCArguments * arguments;
@property( atomic, readwrite, strong ) NSArray      * files;

- ( BOOL )createError: ( NSError * __autoreleasing * )error withText: ( NSString * )text;
- ( void )log: ( NSString * )message;
- ( BOOL )processFile: ( NSString * )file error: ( NSError * __autoreleasing * )error;
- ( void )filterIncludedFiles: ( NSMutableArray * )files;
- ( void )filterExcludedFiles: ( NSMutableArray * )files;

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
    BOOL             isDir;
    NSMutableArray * files;
    NSString       * file;
    NSString       * pwd;
    NSMutableArray * gcovFiles;
    XCCGCovFile    * gcovFile;
    
    if( error != NULL )
    {
        *( error ) = nil;
    }
    
    isDir = NO;
    pwd   = [ [ NSFileManager defaultManager ] currentDirectoryPath ];
    
    if( self.arguments.project != nil )
    {
        if( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.arguments.project ] == NO )
        {
            [ self createError: error withText: [ NSString stringWithFormat: @"Xcode project file does not exist: %@", self.arguments.project ] ];
            
            return NO;
        }
        
        [ [ NSFileManager defaultManager ] changeCurrentDirectoryPath: [ self.arguments.project stringByDeletingLastPathComponent ] ];
    }
    
    if( [ [ NSFileManager defaultManager ] fileExistsAtPath: self.arguments.buildDirectory isDirectory: &isDir ] == NO )
    {
        [ self createError: error withText: [ NSString stringWithFormat: @"Build directory does not exist: %@", self.arguments.buildDirectory ] ];
        
        return NO;
    }
    
    if( isDir == NO )
    {
        [ self createError: error withText: [ NSString stringWithFormat: @"Build directory is not a directory: %@", self.arguments.buildDirectory ] ];
        
        return NO;
    }
    
    files = [ NSMutableArray new ];
    
    for( file in [ [ NSFileManager defaultManager ] contentsOfDirectoryAtPath: self.arguments.buildDirectory error: NULL ] )
    {
        if( [ file.pathExtension isEqualToString: @"gcda" ] )
        {
            [ files addObject: [ self.arguments.buildDirectory stringByAppendingPathComponent: file ] ];
        }
    }
    
    if( files.count == 0 )
    {
        [ self createError: error withText: [ NSString stringWithFormat: @"No .gcda files in build directory: %@", self.arguments.buildDirectory ] ];
        
        return NO;
    }
    
    for( file in files )
    {
        if( [ self processFile: file error: error ] == NO )
        {
            return NO;
        }
    }
    
    files     = [ NSMutableArray new ];
    gcovFiles = [ NSMutableArray new ];
    
    for( file in [ [ NSFileManager defaultManager ] contentsOfDirectoryAtPath: [ [ NSFileManager defaultManager ] currentDirectoryPath ] error: NULL ] )
    {
        if( [ file.pathExtension isEqualToString: @"gcov" ] == NO )
        {
            continue;
        }
        
        [ gcovFiles addObject: [ [ [ NSFileManager defaultManager ] currentDirectoryPath ] stringByAppendingPathComponent: file ] ];
    }
    
    [ [ NSFileManager defaultManager ] changeCurrentDirectoryPath: pwd ];
    
    for( file in gcovFiles )
    {
        gcovFile = [ [ XCCGCovFile alloc ] initWithPath: file arguments: self.arguments ];
        
        [ [ NSFileManager defaultManager ] removeItemAtPath: file error: NULL ];
        
        if( gcovFile != nil )
        {
            [ files addObject: gcovFile ];
        }
    }
    
    [ self filterIncludedFiles: files ];
    [ self filterExcludedFiles: files ];
    
    self.files = [ NSArray arrayWithArray: files ];
    
    return YES;
}

- ( void )filterIncludedFiles: ( NSMutableArray * )files
{
    NSPredicate * predicate;
    
    if( self.arguments.includedPaths.count == 0 )
    {
        return;
    }
    
    predicate = [ NSPredicate predicateWithBlock: ^ BOOL( XCCGCovFile * file, NSDictionary * bindings )
        {
            NSString * path;
            
            ( void )bindings;
            
            for( path in self.arguments.includedPaths )
            {
                if( [ path hasPrefix: @"/" ] == NO )
                {
                    path = [ [ [ NSFileManager defaultManager ] currentDirectoryPath ] stringByAppendingPathComponent: path ];
                }
                
                path = [ path stringByStandardizingPath ];
                
                if( [ path hasSuffix: @"/" ] == NO )
                {
                    path = [ path stringByAppendingString: @"/" ];
                }
                
                if( [ file.sourcePath hasPrefix: path ] )
                {
                    return YES;
                }
            }
            
            return NO;
        }
    ];
    
    [ files filterUsingPredicate: predicate ];
}

- ( void )filterExcludedFiles: ( NSMutableArray * )files
{
    NSPredicate * predicate;
    
    if( self.arguments.excludedPaths.count == 0 )
    {
        return;
    }
    
    predicate = [ NSPredicate predicateWithBlock: ^ BOOL( XCCGCovFile * file, NSDictionary * bindings )
        {
            NSString * path;
            
            ( void )bindings;
            
            for( path in self.arguments.excludedPaths )
            {
                if( [ path hasPrefix: @"/" ] == NO )
                {
                    path = [ [ [ NSFileManager defaultManager ] currentDirectoryPath ] stringByAppendingPathComponent: path ];
                }
                
                path = [ path stringByStandardizingPath ];
                
                if( [ path hasSuffix: @"/" ] == NO )
                {
                    path = [ path stringByAppendingString: @"/" ];
                }
                
                if( [ file.sourcePath hasPrefix: path ] )
                {
                    return NO;
                }
            }
            
            return YES;
        }
    ];
    
    [ files filterUsingPredicate: predicate ];
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

- ( BOOL )processFile: ( NSString * )file error: ( NSError * __autoreleasing * )error
{
    NSTask       * task;
    NSPipe       * outPipe;
    NSPipe       * errPipe;
    NSFileHandle * fh;
    NSData       * errorData;
    NSString     * errorText;
    NSData       * outData;
    NSString     * outText;
    
    task    = [ NSTask new ];
    outPipe = [ NSPipe pipe ];
    errPipe = [ NSPipe pipe ];
    
    [ task setStandardOutput: outPipe ];
    [ task setStandardError: errPipe ];
    [ task setLaunchPath: ( self.arguments.gcov == nil ) ? @"/usr/bin/gcov" : self.arguments.gcov ];
    [ task setArguments: @[ file, @"-o", self.arguments.buildDirectory ] ];
    
    [ self log: [ NSString stringWithFormat: @"xcode-coveralls: Processing file: %@", file ] ];
    
    @try
    {
        [ task launch ];
        [ task waitUntilExit ];
    }
    @catch( NSException * e )
    {
        [ self createError: error withText: e.reason ];
        
        return NO;
    }
    
    fh        = [ errPipe fileHandleForReading ];
    errorData = [ fh readDataToEndOfFile ];
    errorText = [ [ NSString alloc ] initWithData: errorData encoding: NSUTF8StringEncoding ];
    
    fh      = [ outPipe fileHandleForReading ];
    outData = [ fh readDataToEndOfFile ];
    outText = [ [ NSString alloc ] initWithData: outData encoding: NSUTF8StringEncoding ];
    
    if( errorText.length > 0 )
    {
        [ self createError: error withText: [ NSString stringWithFormat: @"gcov returned an error:\n%@", errorText ] ];
        
        return NO;
    }
    
    [ self log: outText ];
    
    return YES;
}

@end
