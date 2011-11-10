//
//  NSUserDefaults+PDDefaultsAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/26/06.
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
