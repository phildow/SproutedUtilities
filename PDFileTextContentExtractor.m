//
//  PDTextContentExtractor.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/10/07.
//  Copyright Philip Dow / Sprouted. All rights reserved.
//

/*
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

Neither the name of the organization nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

#import <SproutedUtilities/PDFileTextContentExtractor.h>


@implementation PDFileTextContentExtractor

- (id) initWithURL:(NSURL*)aURL
{
	if ( self = [super init] ) 
	{
		url = [aURL retain];
	}
	return self;
}

- (id) initWithFile:(NSString*)aPath
{
	self = [self initWithURL:[NSURL fileURLWithPath:aPath]];
	return self;
}

- (void) dealloc
{
	[url release];
	[super dealloc];
}

- (NSString*) content
{
	// perform the extraction, return nil on error
	NSString *taskResults = nil;
	NSData *inData = nil;
	
	// ends writing to this process
	NSPipe *newPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [newPipe fileHandleForReading];	
	
	NSMutableData *allData = [NSMutableData dataWithCapacity:128];
	
	NSTask *task = [[[NSTask alloc] init] autorelease];
	NSString *targetPath = [url path]; // url must be file url
	
	[task setLaunchPath:@"/usr/bin/mdimport"];
	[task setArguments:[NSArray arrayWithObjects:@"-d2", targetPath, nil]];
	[task setStandardError:newPipe];
		
	[task launch];
	
	while ( ( inData = [readHandle availableData] ) && [inData length] != 0 ) {
		[allData appendData:inData];
    }
	
	taskResults = [[[NSString alloc] initWithData:allData encoding:NSUTF8StringEncoding] autorelease];
	
	NSRange startRange = [taskResults rangeOfString:@"Attributes: '"];
	int start = startRange.location + startRange.length + 1;
	NSString *mdPropertyList = [taskResults substringWithRange:NSMakeRange( start , [taskResults length] - start - 3)];
	
	NSString *itemTextContent = nil;
	NSScanner *scanner = [NSScanner scannerWithString:mdPropertyList];
	if ( [scanner scanUpToString:@"kMDItemTextContent = \"" intoString:nil] && ![scanner isAtEnd] )
	{
		[scanner scanString:@"kMDItemTextContent = " intoString:nil];
		[scanner scanUpToString:@"; \n" intoString:&itemTextContent];
		// if the content itself has this string then this returns prematurely
		// may not be the case since the string is encoded in the propertly list format, \n is really \\n
	}
	else
	{
		//NSLog(@"%@ %s - no kMDItemTextContent for file %@", [self className], _cmd, targetPath);
		itemTextContent = nil;
	}
	
	NSString *parsedItemTextContent = [itemTextContent propertyList];
	return parsedItemTextContent;
}

@end
