//
//  NSObjectController+PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 7/6/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSObjectController+PDAdditions.h>

@implementation NSObjectController (PDAdditions)

- (id) boundObjectForKey:(NSString*)aKey {
	
	//
	// returns the object to which my aKey is bound
	
	NSDictionary *bindingInfo = [self infoForBinding:@"contentArray"];
	return ( bindingInfo ? [bindingInfo objectForKey:NSObservedObjectKey] : nil );
	
}

@end
