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

@import Foundation;

#import "XCC.h"

int main( int argc, const char * argv[] )
{
    @autoreleasepool
    {
        XCCArguments        *                 args;
        XCCGCovHelper       *                 gcov;
        XCCCoverallsRequest *                 request;
        NSError             * __autoreleasing error;
        
        @try
        {
            args = [ [ XCCArguments alloc ] initWithArguments: argv count: ( NSUInteger )argc ];
            
            if( args.showHelp )
            {
                [ [ XCCHelp sharedInstance ] display ];
                
                return EXIT_SUCCESS;
            }
            
            error = nil;
            gcov  = [ [ XCCGCovHelper alloc ] initWithArguments: args ];
            
            if( [ gcov run: &error ] == NO )
            {
                [ [ XCCHelp sharedInstance ] displayWithError: error ];
                
                return EXIT_FAILURE;
            }
            
            request = [ [ XCCCoverallsRequest alloc ] initWithFiles: gcov.files arguments: args ];
            
            if( [ request post: &error ] == NO )
            {
                [ [ XCCHelp sharedInstance ] displayWithError: error ];
                
                return EXIT_FAILURE;
            }
            
            return EXIT_SUCCESS;
        }
        @catch( NSException * e )
        {
            [ [ XCCHelp sharedInstance ] displayWithErrorText: e.reason ];
        }
            
        return EXIT_FAILURE;
    }
    
}
