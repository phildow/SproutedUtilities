//
//  NSUserDefaults+PDDefaultsAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/26/06.
//  CopyrightSprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSUserDefaults+PDDefaultsAdditions.h>

@implementation NSUserDefaults (PDDefaultsAdditions)

- (NSDictionary*) defaultEntryAttributes {
	
	//
	// the default font - archive this!
	NSFont *defaultFont = [NSFont systemFontOfSize:15.0];
	NSData *defaultFontData = [[NSUserDefaults standardUserDefaults] dataForKey:@"DefaultEntryFont"];
	if ( defaultFontData != nil )
		defaultFont = [NSUnarchiver unarchiveObjectWithData:defaultFontData];
		
	if ( defaultFont == nil || ![defaultFont isKindOfClass:[NSFont class]] ) {
	
		NSString *fontFamName = [[NSUserDefaults standardUserDefaults] objectForKey:@"Journler Default Font"];
		NSString *fontSize = [[NSUserDefaults standardUserDefaults] objectForKey:@"Text Font Size"];
		
		if ( fontFamName && fontSize ) {
			defaultFont = [[NSFontManager sharedFontManager] convertFont:defaultFont toFace:fontFamName];
			defaultFont = [[NSFontManager sharedFontManager] convertFont:defaultFont toSize:[fontSize floatValue]];
		}
	
	}
	
	//
	// the default color
	NSColor *defaultColor = nil;
	NSData *defaultColorData = [[NSUserDefaults standardUserDefaults] dataForKey:@"Entry Text Color"];
	if ( defaultColorData != nil )
		defaultColor = [NSUnarchiver unarchiveObjectWithData:defaultColorData];
	else
		defaultColor = [NSColor blackColor];
	
	//
	// the default paragraph style
	NSParagraphStyle *defaultParagraph;
	NSData *paragraphData = [[NSUserDefaults standardUserDefaults] dataForKey:@"DefaultEntryParagraphStyle"];
	if ( paragraphData != nil )
		defaultParagraph = [NSUnarchiver unarchiveObjectWithData:paragraphData];
	else
		defaultParagraph = [NSParagraphStyle defaultParagraphStyle]; 
	
	//
	// put it all together
	NSDictionary *attr = [[NSDictionary alloc] initWithObjectsAndKeys:
		defaultFont, NSFontAttributeName, 
		defaultColor, NSForegroundColorAttributeName, 
		defaultParagraph, NSParagraphStyleAttributeName, nil];
		
	return [attr autorelease];
	
}

#pragma mark -

- (NSFont*) fontForKey:(NSString*)aKey {
	
	if ( aKey == nil ) [NSException raise:NSInvalidArgumentException format:@""];
	
	NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:aKey];
	if ( data == nil ) return nil;
	
	id font = [NSUnarchiver unarchiveObjectWithData:data];
	if ( font == nil || ![font isKindOfClass:[NSFont class]] ) return nil;
	else return font;
	
}

- (void) setFont:(NSFont*)aFont forKey:(NSString*)aKey {
	
	if (aFont == nil || aKey == nil) [NSException raise:NSInvalidArgumentException format:@""];
	
	NSData *data = [NSArchiver archivedDataWithRootObject:aFont];
	if ( data ) [[NSUserDefaults standardUserDefaults] setObject:data forKey:aKey];
	
}

- (NSColor*) colorForKey:(NSString*)aKey {
	
	if ( aKey == nil ) [NSException raise:NSInvalidArgumentException format:@""];
	
	NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:aKey];
	if ( data == nil ) return nil;
	
	id color = [NSUnarchiver unarchiveObjectWithData:data];
	if ( color == nil || ![color isKindOfClass:[NSColor class]] ) return nil;
	else return color;
	
}

- (void) setColor:(NSColor*)aColor forKey:(NSString*)aKey {
	
	if (aColor == nil || aColor == nil) [NSException raise:NSInvalidArgumentException format:@""];
	
	NSData *data = [NSArchiver archivedDataWithRootObject:aColor];
	if ( data ) [[NSUserDefaults standardUserDefaults] setObject:data forKey:aKey];
	
}

@end
