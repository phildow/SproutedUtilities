//
//  NSManagedObjectContext_PDCategory.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/14/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSManagedObjectContext_PDCategory.h>


@implementation NSManagedObjectContext (PDCategory)

- (NSManagedObject *)managedObjectForURIRepresentation:(NSURL *)aURL
{
	NSManagedObject *theObject = nil;
	NSManagedObjectID *objectID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:aURL];
	
	if ( objectID == nil )
		NSLog(@"%@ %s - no object with uri represenation %@", [self className], _cmd, aURL);
	else
		theObject = [self objectWithID:objectID];
	
	return theObject;
}

- (NSManagedObject*) managedObjectRegisteredForURIRepresentation:(NSURL*)aURL
{
	NSManagedObject *theObject = nil;
	NSManagedObjectID *objectID = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:aURL];
	
	if ( objectID == nil )
		NSLog(@"%@ %s - no object with uri represenation %@", [self className], _cmd, aURL);
	else
		theObject = [self objectRegisteredForID:objectID];
	
	return theObject;
}

#pragma mark -

- (NSManagedObject*) managedObjectForUUIDRepresentation:(NSURL*)aURL
{
	// the URL should be in the form of scheme://entityName/uuid
	
	NSString *entityName = [aURL host];
	NSString *uuid = [aURL path];
	
	if ( [uuid characterAtIndex:0] == '/' )
		uuid = [uuid substringFromIndex:1];
	
	return [self managedObjectForUUID:uuid entity:entityName];
}

- (NSManagedObject*) managedObjectForUUID:(NSString*)uuid entity:(NSString*)entityName
{
	// the managed objects of entity name must include a string "uuid" attribute
	
	NSManagedObject *theObject = nil;
	
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"uuid == %@", uuid];
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	NSError *error = nil;
	NSArray *results;
	
	[request setEntity:entityDescription];
	[request setPredicate:predicate];
	
	results = [self executeFetchRequest:request error:&error];
	if ( results == nil )
	{
		NSLog(@"%@ %s - error executing fetch request, error: %@, request: %@", [self className], _cmd, error, request);
		theObject = nil;
	}
	else
	{
		if ( [results count] == 1 )
			theObject = [results objectAtIndex:0];
		else
		{
			NSLog(@"%@ %s - the fetch did not return a single object but %i objects, %@", [self className], _cmd, [results count], request);
			theObject = nil;
		}
	}
	
	return theObject;
}

@end
