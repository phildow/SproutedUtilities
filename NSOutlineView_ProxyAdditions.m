//
//  NSOutlineView_ProxyAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 9/11/06.
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
