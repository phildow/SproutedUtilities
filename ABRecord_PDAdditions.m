//
//  ABRecord_PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 9/30/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/ABRecord_PDAdditions.h>
#import <SproutedUtilities/NSImage_PDCategories.h>

#define kLargeIconSize 128
#define kLargeIconInset 16

@implementation ABRecord (PDAdditions)

- (NSString*) fullname {
	
	//
	// the title
	NSMutableString *name = [[NSMutableString alloc] init];
	
	NSString *prefix = [self valueForProperty:kABTitleProperty];
	NSString *suffix = [self valueForProperty:kABSuffixProperty];
	NSString *firstName = [self valueForProperty:kABFirstNameProperty];
	NSString *lastName = [self valueForProperty:kABLastNameProperty];
	NSString *middleName = [self valueForProperty:kABMiddleNameProperty];
	
	//
	//create the name string
	if ( !prefix && !suffix && !firstName && !lastName && !middleName ) {
		
		//
		//maybe this is a company?
		NSString *orgProperty = [self valueForProperty:kABOrganizationProperty];
		if ( orgProperty) [name appendString:orgProperty];
		
	}
	else {
		
		//
		// prepare the person's name
		if ( prefix ) {
			[name appendString:prefix];
			if ( firstName || middleName || lastName || suffix ) [name appendString:@" "];
		}
		if ( firstName ) {
			[name appendString:firstName];
			if ( middleName || lastName || suffix) [name appendString:@" "];
		}
		if ( middleName ) {
			[name appendString:middleName];
			if ( lastName || suffix) [name appendString:@" "];
		}
		if ( lastName ) {
			[name appendString:lastName];
			if ( suffix ) [name appendString:@" "];
		}
		if ( suffix ) {
			[name appendString:suffix];
		}
		
	}	
	
	return name;
	
}

- (NSImage*) image {
	
	if ( [self isKindOfClass:[ABPerson class]] ) {
		
		NSData *tiffData;
		NSImage *personImage = nil;
		
		tiffData = [(ABPerson*)self imageData];
		if ( tiffData != nil ) 
			personImage = [[NSImage alloc] initWithData:tiffData];
		
		return [personImage autorelease];
	
	}
	else {
		return nil;
	}
	
}

- (NSString*) note
{
	return [self valueForProperty:kABNoteProperty];
}

- (NSString*) emailAddress
{
	// returns the persons first email address
	ABMultiValue *emailRecords = [self valueForProperty:kABEmailProperty];
	if ( emailRecords == nil || [emailRecords count] == 0 ) 
		return nil;
	else
		return [emailRecords valueAtIndex:0];
}

- (NSString*) website
{
	// returns the persons first website
	NSString *homepage = [self valueForProperty:kABHomePageProperty];
	if ( homepage != nil )
		return homepage;
	else
	{
		ABMultiValue *siteRecords = [self valueForProperty:kABURLsProperty];
		if ( siteRecords == nil || [siteRecords count] == 0 ) 
			return nil;
		else
			return [siteRecords valueAtIndex:0];
	}
}

#pragma mark -

- (NSString*) htmlRepresentationWithCache:(NSString*)cachePath 
{
	NSImage *icon;
	NSString *fullname = [self fullname];
	NSImage *anImage = [self image];
	if ( anImage != nil )
		icon = anImage;
	else
		icon = [NSImage imageNamed:@"vCard.tiff"];
	
	static NSString *img = @"<img align=\"left\" src=\"%@\" />\n";
	static NSString *header = @"<h3>%@</h3>\n";
	
	NSMutableString *htmlBody = [NSMutableString string];
	
	NSString *largeIconFilename = [NSString stringWithFormat:@"%@-128",[self uniqueId]];
	NSString *iconPath = [[cachePath stringByAppendingPathComponent:largeIconFilename] 
			stringByAppendingPathExtension:@"tiff"];
	
	if ( ![[NSFileManager defaultManager] fileExistsAtPath:iconPath] ) {
		[[[icon imageWithWidth:kLargeIconSize height:kLargeIconSize inset:kLargeIconInset] TIFFRepresentation] writeToFile:iconPath atomically:NO];
	}
	
	// draw the header
	[htmlBody appendString:@"<div style=\"clear:both;\">"];
	
	// draw the icon
	NSURL *imgURL = [NSURL fileURLWithPath:iconPath];
	NSString *thisImg = [NSString stringWithFormat:img, [imgURL absoluteString]];
	[htmlBody appendString:thisImg];
	
	NSString *theHeader = [NSString stringWithFormat:header,fullname];
	[htmlBody appendString:theHeader];
	
	// close the div
	[htmlBody appendString:@"</div>"];
	
	return htmlBody;
}

@end
