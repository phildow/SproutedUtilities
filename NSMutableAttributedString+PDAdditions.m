//
//  NSMutableAttributedString+PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 6/26/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSMutableAttributedString+PDAdditions.h>


@implementation NSMutableAttributedString (PDAdditions)

- (void)removeAttribute:(NSString *)name ranges:(NSArray*)theRanges {
	int i;
	for ( i = 0; i < [theRanges count]; i++ )
		[self removeAttribute:name range:[[theRanges objectAtIndex:i] rangeValue]];
}

- (void)addAttribute:(NSString *)name value:(id)value ranges:(NSArray*)theRanges {
	int i;
	for ( i = 0; i < [theRanges count]; i++ )
		[self addAttribute:name value:value range:[[theRanges objectAtIndex:i] rangeValue]];
}

#pragma mark -

- (void)replaceCharactersInRanges:(NSArray*)ranges withStrings:(NSArray*)strings {
	if ( [ranges count] != [strings count] )
		[NSException raise:NSInternalInconsistencyException format:@""];
	
	int i;
	for ( i = [ranges count] - 1; i >= 0; i-- ) {
		NSRange aRange = [[ranges objectAtIndex:i] rangeValue];
		NSString *aString = [strings objectAtIndex:i];
		
		[self replaceCharactersInRange:aRange withString:aString];
	}
}

#pragma mark -
#pragma mark belong in NSAttributedString

- (NSString*) substringWithRange:(NSRange)aRange {
	
	return [[self attributedSubstringFromRange:aRange] string];
	
}

- (NSArray*)substringsWithRanges:(NSArray*)ranges {
	
	int i;
	NSMutableArray *strings = [[NSMutableArray alloc] initWithCapacity:[ranges count]];
	
	for ( i = 0; i < [ranges count]; i++ ) {
		NSRange aRange = [[ranges objectAtIndex:i] rangeValue];
		NSString *aString = [self substringWithRange:aRange];
		
		[strings addObject:aString];
	}
	
	return [strings autorelease];
}

@end
