//
//  NSOutlineView_ProxyAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 9/11/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSOutlineView_ProxyAdditions.h>

@implementation NSOutlineView (ProxyAdditions)

- (id)originalItemAtRow:(int)row
{
	id originalItem = nil;
	id item = [self itemAtRow:row];
	
	if ( [[item className] isEqual:@"NSTreeControllerTreeNode"] || [[item className] isEqual:@"NSTreeNode"] )
		originalItem = [item representedObject];
	else if ( [[item className] isEqual:@"_NSArrayControllerTreeNode"] )
		originalItem = [item observedObject];
	else
		originalItem = item;
	
	return originalItem;
}

- (NSArray*)originalItemsAtRows:(NSIndexSet*)indexSet
{
	int i, count = [indexSet count];
	unsigned int * allIndexes = calloc(count,sizeof(unsigned int));
	NSMutableArray *anArray = [NSMutableArray array];
	
	count = [indexSet getIndexes:allIndexes maxCount:count inIndexRange:nil];
	
	for ( i = 0; i < count; i++ )
	{
		id anObject = [self originalItemAtRow:allIndexes[i]];
		if ( anObject != nil ) [anArray addObject:anObject];
	}
	
	free(allIndexes);
	return anArray;
}

- (int)rowForOriginalItem:(id)originalItem
{
	int numberOfRows = [self numberOfRows];
	int row;
	for(row=0; row<numberOfRows; row++)
		if([self originalItemAtRow:row] == originalItem)
			return row;
	return -1;
}

@end
