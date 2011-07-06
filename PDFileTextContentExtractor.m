//
//  PDTextContentExtractor.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/10/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

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
