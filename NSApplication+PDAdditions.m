//
//  NSApplication+PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 9/10/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSApplication+PDAdditions.h>


@implementation NSApplication (PDAdditions)

- (NSWindowController*) singletonControllerWithClass:(Class)aClass
{
	// returns the window controller for the given class considering the on-screen windows
	// returns nil if there is no instance of the window controller in play
	
	NSWindowController *aController, *theController = nil;
	NSEnumerator *windowControllers = [[self valueForKeyPath:@"windows.windowController"] objectEnumerator];
	
	while ( aController = [windowControllers nextObject] )
	{
		if ( [aController isKindOfClass:aClass] )
		{
			theController = aController;
			break;
		}
	}
	
	return theController;
}

@end
