//
//  PDTextClipping.m
//  SproutedUtilities
//
//  Created by Phil Dow on 3/17/07.
//  Copyright 2007 Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

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
