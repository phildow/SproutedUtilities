//
//  NSTableView_PDCategory.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/18/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSTableView_PDCategory.h>


@implementation NSTableView (PDCategory)

- (int) indexOfColumnWithIdentifier:(NSString*)anIdentifier
{
	int i, theIndex = -1;
	NSArray *myColumns = [self tableColumns];
	
	for ( i = 0; i < [myColumns count]; i++ )
	{
		NSTableColumn *aColumn = [myColumns objectAtIndex:i];
		
		if ( [[aColumn identifier] isEqual:anIdentifier] )
		{
			theIndex = i;
			break;
		}
	}
	
	return theIndex;
}

@end
