//
//  PDTextClipping.m
//  SproutedUtilities
//
//  Created by Phil Dow on 3/17/07.
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

#import <SproutedUtilities/PDTextClipping.h>
#import <SproutedUtilities/GTResourceFork.h>

@implementation PDTextClipping

- (id) initWithContentsOfFile:(NSString*)filename
{
	if ( self = [super init] )
	{
		// parse the resource file
		
		isRichText = NO;
		GTResourceFork *resourceFork = [[[GTResourceFork alloc] initWithContentsOfFile:filename] autorelease];
		
		if ( resourceFork == nil )
		{
			[self release];
			return nil;
		}
		
		ResType rType = 0;
		
		if ( [resourceFork countOfResourcesOfType:'TEXT'] > 0 )
		{
			rType = 'TEXT';
			if ( [resourceFork countOfResourcesOfType:'styl'] > 0 )
				isRichText = YES;
		}
		else if ( [resourceFork countOfResourcesOfType:'utxt'] > 0 )
		{
			rType = 'utxt';
		}
		else if ( [resourceFork countOfResourcesOfType:'STR '] > 0 )
		{
			rType = 'STR ';
		}
		else
		{
			[self release];
			return nil;
		}
		
		if ( rType != 0 )
		{
			NSArray *used = [resourceFork usedResourcesOfType:rType];
			if ( [used count] == 0 )
			{
				[self release];
				return nil;
			}
			else
			{
				ResID rID = [[used objectAtIndex:0] intValue];
				
				if ( [self isRichText] )
					textRepresentation = [resourceFork attributedStringResource:rID];
				else if ( rType == 'TEXT' )
					textRepresentation = [[resourceFork attributedStringResource:rID] string];
				else if ( rType == 'STR ' )
					textRepresentation = [resourceFork stringResource:rID];
				else if ( rType == 'utxt' )
					textRepresentation = [[[NSString alloc] initWithData:[resourceFork dataForResource:rType ofType:rID] encoding:NSUTF8StringEncoding] autorelease];
				else
					textRepresentation = nil;
					
				if ( textRepresentation == nil )
				{
					[self release];
					return nil;
				}
			}
		}
	}
	
	return self;
}

- (BOOL) isRichText
{
	return isRichText;
}

- (NSString*) plainTextRepresentation
{
	if ( [self isRichText] )
		return [textRepresentation string];
	else
		return textRepresentation;
}

- (NSAttributedString*) richTextRepresentation
{
	if ( [self isRichText] )
		return textRepresentation;
	else
		return [[[NSAttributedString alloc] initWithString:textRepresentation attributes:nil] autorelease];
}

@end
