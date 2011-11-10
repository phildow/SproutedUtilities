//
//  MailMessageParser.m
//  SproutedUtilities
//
//  Created by Philip Dow on 1/12/07.
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

#import <SproutedUtilities/MailMessageParser.h>
#import <SproutedUtilities/PDUtilityDefinitions.h>
#import <SproutedUtilities/NSWorkspace_PDCategories.h>

//#define __DEBUG__

static NSString *kTextHTML = @"text/html";
static NSString *kTextXHTML = @"text/xhtml";
static NSString *kTextPlain = @"text/plain";

static NSString *kMultipartContent = @"multipart";
// options include multipart/alternative


// to prevent some of those annoying warnings
@interface NSObject (CWWarningsCategory)

- (NSString *) contentType;
- (id) partAtIndex: (unsigned int) theIndex;

@end


@implementation MailMessageParser

- (id) initWithFile:(NSString*)path
{
	if ( self = [super init] )
	{
		_filepath = [path retain];
		_htmlBody = [[NSMutableString alloc] init];
		_plaintextBody = [[NSMutableString alloc] init];
		_fileType = [[[NSWorkspace sharedWorkspace] UTIForFile:path] retain];
		
		if ( ![self _initializeMessage] )
		{
			[_filepath release];
			[self release];
			return nil;
		}
	}
	return self;
}

- (void) dealloc
{
	[_filepath release];
	[_message release];
	[_htmlBody release];
	[_plaintextBody release];
	[_multipartContent release];
	[_fileType release];
	
	[super dealloc];
}

#pragma mark -

- (BOOL) _initializeMessage
{
	BOOL success = YES;
	NSStringEncoding theEncoding = NSMacOSRomanStringEncoding;
	
	NSError *error = nil;
	NSString *emailContent = nil;
	NSString *fileContents = [NSString stringWithContentsOfFile:_filepath usedEncoding:&theEncoding error:&error];
	
	if ( fileContents == nil )
	{
		// force the encoding
		int i;
		NSStringEncoding encodings[2] = { NSMacOSRomanStringEncoding, NSUnicodeStringEncoding };
		
		for ( i = 0; i < 2; i++ )
		{
			fileContents = [NSString stringWithContentsOfFile:_filepath encoding:encodings[i] error:&error];
			if ( fileContents != nil )
			{
				theEncoding = encodings[i];
				break;
			}
		}
		
		// if it's still nill
		if ( fileContents == nil )
		{
			NSLog(@"%@ %s - unable to initialize string with contents of file %@, error: %@", [self className], _cmd,
			_filepath, error);
			success = NO;
			goto bail;
		}
	}
	
	if ( [_fileType isEqualToString:kPDUTTypeMailStandardEmail] )
	{
		emailContent = fileContents;
	}
	else if ( [_fileType isEqualToString:kPDUTTypeMailEmail] )
	{
		int loc;
		int dataLength;
		NSScanner *scanner = [NSScanner scannerWithString:fileContents];
		
		[scanner scanInt:&dataLength];
		#ifdef __DEBUG__
		NSLog(@"Data length is %i",dataLength);
		#endif
		
		loc = [scanner scanLocation] + 1;
		emailContent = [fileContents substringWithRange:NSMakeRange(loc,dataLength)];
	}
	else
	{
		NSLog(@"%@ %s - unknown file type: %@", [self className], _cmd, _fileType);
		success = NO;
		goto bail;
	}
		
	NSData *contentData = [emailContent dataUsingEncoding:theEncoding];
	if ( contentData == nil )
	{
		NSLog(@"%@ %s - unable to initialize data with contents of file %@, using encoding %i, contents: %@", [self className], _cmd, 
		_filepath, theEncoding, emailContent);
		success = NO;
		goto bail;
	}
	
	Class cwmessage = NSClassFromString(@"CWMessage");
	if ( !cwmessage )
	{
		NSLog(@"%@ %s - unable to get class for class name CWMessage", [self className], _cmd);
		success = NO;
		goto bail;
	}
	
	//_message = [[CWMessage alloc] initWithData:contentData];
	_message = [[cwmessage alloc] initWithData:contentData];
	if ( _message == nil )
	{
		NSLog(@"%@ %s - unable to initialize message with contents of file %@", [self className], _cmd, _filepath);
		success = NO;
		goto bail;
	}
	
	// extract some information that will be of use
	
	NSString *contentType = [_message contentType];
	id content = [_message content];
	
	#ifdef __DEBUG__
	NSLog(contentType);
	NSLog([content className]);
	#endif

	Class cwmimemultipart = NSClassFromString(@"CWMIMEMultipart");
	if ( !cwmimemultipart )
	{
		NSLog(@"%@ %s - unable to get class from class name CWMIMEMultipart", [self className], _cmd);
		success = NO;
		goto bail;
	}

	if ( [content isKindOfClass:[NSString class]] )
	{
		if ( [contentType isEqualToString:kTextHTML] || [contentType isEqualToString:kTextXHTML] )
			//_htmlBody = [(NSString*)content retain];
			[_htmlBody appendString:(NSString*)content];
		else
			//_plaintextBody = [content retain];
			[_plaintextBody appendString:(NSString*)content];
	}
	//else if ( [content isKindOfClass:[CWMIMEMultipart class]] )
	else if ( [content isKindOfClass:[cwmimemultipart class]] )
	{
		_multipartContent = [content retain];
		
		int i, count = [_multipartContent count];
		for ( i = 0; i < count; i++ )
		{
			//CWPart *aPart = [_multipartContent partAtIndex:i];
			id aPart = [_multipartContent partAtIndex:i];
			NSString *contentType = [aPart contentType];
			
			//NSLog(contentType);
			
			if ( [contentType isEqualToString:kTextPlain] )
				//_plaintextBody = [(NSString*)[aPart content] retain];
				[_plaintextBody appendString:(NSString*)[aPart content]];
				
			else if ( [contentType isEqualToString:kTextHTML] || [contentType isEqualToString:kTextXHTML] )
				//_htmlBody = [(NSString*)[aPart content] retain];
				[_htmlBody appendString:(NSString*)[aPart content]];
			
			else if ( [contentType rangeOfString:kMultipartContent options:NSCaseInsensitiveSearch].location != NSNotFound )
			{
				// we must go inside this cwpart
				
				id subContent = [aPart content];
				if ( [subContent isKindOfClass:[cwmimemultipart class]] )
				{
					int subI, subCount = [subContent count];
					for ( subI = 0; subI < subCount; subI++ )
					{
						//CWPart *aPart = [_multipartContent partAtIndex:i];
						id aSubPart = [subContent partAtIndex:subI];
						NSString *subContentType = [aSubPart contentType];
						
						//NSLog(subContentType);
						
						if ( [subContentType isEqualToString:kTextPlain] )
							//_plaintextBody = [(NSString*)[aSubPart content] retain];
							[_plaintextBody appendString:(NSString*)[aSubPart content]];
							
						else if ( [subContentType isEqualToString:kTextHTML] || [subContentType isEqualToString:kTextXHTML]  )
							//_htmlBody = [(NSString*)[aSubPart content] retain];
							[_htmlBody appendString:(NSString*)[aSubPart content]];
					}
				}
			}
		}
	}
	
bail:
	
	if ( [_htmlBody length] == 0 )
	{
		[_htmlBody release];
		_htmlBody = nil;
	}
	if ( [_plaintextBody length] == 0 )
	{
		[_plaintextBody release];
		_plaintextBody = nil;
	}
	
	return YES;

}

#pragma mark -

//- (CWMessage*) message
- (id) message
{
	return _message;
}

#pragma mark -

- (BOOL) hasHTMLBody
{
	return ( _htmlBody != nil );
}

- (BOOL) hasPlainTextBody
{
	return ( _plaintextBody != nil );
}

- (NSString*) body:(BOOL)preferHTML;
{
	if ( preferHTML && _htmlBody != nil )
		return _htmlBody;
	else
		return _plaintextBody;
}

@end
