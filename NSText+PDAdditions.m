//
//  NSText+PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 6/26/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSText+PDAdditions.h>

@implementation NSText (PDAdditions)

- (void)setFont:(NSFont *)aFont ranges:(NSArray*)theRanges {
	int i;
	for ( i = 0; i < [theRanges count]; i++ )
		[self setFont:aFont range:[[theRanges objectAtIndex:i] rangeValue]];
}

- (void)setTextColor:(NSColor *)aColor ranges:(NSArray*)theRanges {
	int i;
	for ( i = 0; i < [theRanges count]; i++ )
		[self setTextColor:aColor range:[[theRanges objectAtIndex:i] rangeValue]];
}

@end
