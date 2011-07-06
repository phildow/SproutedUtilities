//
//  NSArray_PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 11/9/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

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
