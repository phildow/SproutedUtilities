//
//  NSManagedObject_PDCategory.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/14/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSManagedObject_PDCategory.h>


@implementation NSManagedObject (PDCategory)

- (NSURL *)URIRepresentation
{
	return [[self objectID] URIRepresentation];
}

- (NSURL*) UUIDURIRepresentation
{
	// the managed object must include a string "uuid" attribute
	
	NSString *entityName = [[self entity] name];
	NSString *uuid = [self valueForKey:@"uuid"];
	
	NSString *uuidString = [NSString stringWithFormat:@"managedobject://%@/%@",entityName,uuid];
	return [NSURL URLWithString:uuidString];
}

@end
