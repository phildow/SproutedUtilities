//
//  NSManagedObjectContext_PDCategory.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/14/07.
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
