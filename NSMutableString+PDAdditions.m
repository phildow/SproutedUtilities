//
//  NSMutableString (PDAdditions).m
//  SproutedUtilities
//
//  Created by Philip Dow on 7/22/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSMutableString+PDAdditions.h>


@implementation NSMutableString (PDAdditions)

- (void) replaceOccurrencesOfCharacterFromSet:(NSCharacterSet*)aSet 
		withString:(NSString*)aString options:(unsigned int)mask range:(NSRange)searchRange {
	
	NSRange aRange;
	while ( YES ) {
		aRange = [self rangeOfCharacterFromSet:aSet options:mask range:searchRange];
		if ( aRange.location == NSNotFound ) break;
		else { 
			[self replaceCharactersInRange:aRange withString:aString];
			searchRange.length -= aRange.length;
			if ( searchRange.length <= 0 ) break;
		}
	}
	
	/*
	int i;
	//for ( i = searchRange.location+searchRange.length - 1; i >= searchRange.location; i-- ) { -- this doesn't stop the loop!
	for ( i = searchRange.location+searchRange.length - 1; i >= 0; i-- ) {
		if ( [aSet characterIsMember:[self characterAtIndex:i]] )
			[self replaceCharactersInRange:NSMakeRange(i,1) withString:aString];
	}
	*/
}

@end
