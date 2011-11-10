//
//  NSMutableAttributedString+PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 6/26/06.
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
