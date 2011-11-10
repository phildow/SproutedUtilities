//
//  NSArray_PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 11/9/06.
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


#import <SproutedUtilities/NSArray_PDAdditions.h>


@implementation NSArray (PDAdditions)

- (BOOL) allObjectsAreEqual
{
	if ( [self count] <= 1 )
		return YES;
	
	BOOL areEqual = YES;
	NSEnumerator *enumerator = [self objectEnumerator];
	id previousEnumeratorObject = [enumerator nextObject];
	id nextEnumeratorObject;
	
	while ( nextEnumeratorObject = [enumerator nextObject] )
	{
		if ( ![previousEnumeratorObject isEqual:nextEnumeratorObject] )
		{
			areEqual = NO;
			break;
		}
		previousEnumeratorObject = nextEnumeratorObject;
	}
	return areEqual;
}

- (BOOL) containsObjects:(NSArray*)anArray
{
	id anObject;
	BOOL contains = YES;
	NSEnumerator *enumerator = [anArray objectEnumerator];
	
	while ( anObject = [enumerator nextObject] )
	{
		if ( ![self containsObject:anObject] )
		{
			contains = NO;
			break;
		}
	}
	
	return contains;
}

- (BOOL) containsAnObjectInArray:(NSArray*)anArray
{
	id anObject;
	BOOL contains = NO;
	NSEnumerator *enumerator = [anArray objectEnumerator];
	
	while ( anObject = [enumerator nextObject] )
	{
		if ( [self containsObject:anObject] )
		{
			contains = YES;
			break;
		}
	}
	
	return contains;
}

#pragma mark -

- (int) stateForInteger:(int)aValue
{
	#warning doesn't work when called from Journler
	
	id anObject;
	int i, state = NSOffState;
	
	for ( i = 0; i < [self count]; i++ )
	{
		anObject = [self objectAtIndex:i];
		if ( ![anObject isKindOfClass:[NSNumber class]] )
			continue;
		
		if ( [anObject intValue] == aValue )
		{
			if ( state == NSOffState && i == 0 ) 
				state = NSOnState;
			else if ( state == NSOffState )
				state = NSMixedState;
		}
		else
		{
			if ( state == NSOnState )
				state = NSMixedState;
		}
	}
	
	return state;
}

// returns an array of objects whose value for aKey match aValue using the isEqual method
// every object in the array must respond to aKey or an exception will be raised
// returns an empty array if no objects are found

- (NSArray*) objectsWithValue:(id)aValue forKey:(NSString*)aKey
{
	if ( aValue == nil || aKey == nil )
		return nil;
	
	id anObject;
	NSEnumerator *enumerator = [self objectEnumerator];
	NSMutableArray *returnArray = [NSMutableArray array];
	
	while ( anObject = [enumerator nextObject] )
	{
		if ( [aValue isEqual:[anObject valueForKey:aKey]] )
			[returnArray addObject:anObject];
	}
	
	return returnArray;
}

@end
