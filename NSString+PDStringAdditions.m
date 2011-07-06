//
//  NSString+PDStringAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/30/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSString+PDStringAdditions.h>
#import <SproutedUtilities/NSMutableString+PDAdditions.h>
#include <openssl/md5.h>

static NSString *htmlFrame = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\">\n<head>\n\t<title>%@</title>\n\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF-8\" />\n\t<meta name=\"Generator\" content=\"Cocoa HTML Writer\" />\n\t<meta name=\"CocoaVersion\" content=\"824.42\" />\n</head>\n<body>\n%@</body>\n</html>\n";

enum {
    kNumberType,
    kStringType,
    kPeriodType
};

int SUGetCharType(NSString *character);
NSArray *SUSplitVersionString(NSString *version);

#pragma mark -

int SUGetCharType(NSString *character)
{
    if ([character isEqualToString:@"."]) {
        return kPeriodType;
    } else if ([character isEqualToString:@"0"] || [character intValue] != 0) {
        return kNumberType;
    } else {
        return kStringType;
    }	
}

NSArray *SUSplitVersionString(NSString *version)
{
    NSString *character;
    NSMutableString *s;
    int i, n, oldType, newType;
    NSMutableArray *parts = [NSMutableArray array];
    if ([version length] == 0) {
        // Nothing to do here
        return parts;
    }
    s = [[[version substringToIndex:1] mutableCopy] autorelease];
    oldType = SUGetCharType(s);
    n = [version length] - 1;
    for (i = 1; i <= n; ++i) {
        character = [version substringWithRange:NSMakeRange(i, 1)];
        newType = SUGetCharType(character);
        if (oldType != newType || oldType == kPeriodType) {
            // We've reached a new segment
			NSString *aPart = [[NSString alloc] initWithString:s];
            [parts addObject:aPart];
			[aPart release];
            [s setString:character];
        } else {
            // Add character to string and continue
            [s appendString:character];
        }
        oldType = newType;
    }
    
    // Add the last part onto the array
    [parts addObject:[NSString stringWithString:s]];
    return parts;
}

#pragma mark -

@implementation NSString (PDStringAdditions)

- (BOOL) matchesRegex:(NSString*)regex
{
	NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
	return [regexPredicate evaluateWithObject:self];
}

- (BOOL) regexMatches:(NSString*)aString
{
	NSPredicate *regexPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self];
	return [regexPredicate evaluateWithObject:aString];
}

#pragma mark -

- (BOOL) isWellformedURL
{
	// right now the method only checks for http:// links with any text after the http:// 
	// that can be initialized by nsurl
	
	static NSString *httpScheme = @"http://";
	
	if ( [self rangeOfString:httpScheme options:NSCaseInsensitiveSearch].location == 0 )
		return ( [self length] > [httpScheme length] && ( [NSURL URLWithString:self] != nil ) );
	else return NO;
}

- (BOOL) isOnlyWhitespace
{
	int i;
	BOOL isOnlyWhitespace = YES;
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	for ( i = 0; i < [self length]; i++ )
	{
		if ( ![whitespace characterIsMember:[self characterAtIndex:i]] )
		{
			isOnlyWhitespace = NO;
			break;
		}
	}
	
	return isOnlyWhitespace;
}

#pragma mark -

- (NSString*) stringAsHTMLDocument:(NSString*)title
{
	if ( title == nil ) title = [NSString string];
	NSString *htmlDocument = [NSString stringWithFormat:htmlFrame,title,self];
	return htmlDocument;
}

- (NSArray*) substringsWithRanges:(NSArray*)ranges
{
	if ( ranges == nil ) return nil;
	
	NSValue *rangeValue;
	NSEnumerator *enumerator = [ranges objectEnumerator];
	
	NSMutableArray *substrings = [NSMutableArray arrayWithCapacity:[ranges count]];
	
	while ( rangeValue = [enumerator nextObject] )
	{
		NSRange aRange = [rangeValue rangeValue];
		NSString *aSubstring = [self substringWithRange:aRange];
		
		[substrings addObject:aSubstring];
	}
	
	return substrings;
}

- (NSArray*) rangesOfString:(NSString*)aString options:(unsigned)mask range:(NSRange)aRange
{
	if ( aString == nil ) return nil;
	
	int endPoint = aRange.length - aRange.location;
	NSMutableArray *ranges = [NSMutableArray array];
	
	while ( aRange.location != NSNotFound )
	{
		aRange = [self rangeOfString:aString options:mask range:aRange];
		if ( aRange.location == NSNotFound )
			break;
		
		[ranges addObject:[NSValue valueWithRange:aRange]];
		
		aRange.location = aRange.location + aRange.length;
		aRange.length = endPoint - ( aRange.location + aRange.length );
	}
	
	return ranges;
}

#pragma mark -

- (NSString*) pathSafeString 
{	
	NSMutableString *path = [self mutableCopyWithZone:[self zone]];
	
	[path replaceOccurrencesOfString:@"/" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0,[path length])];
	[path replaceOccurrencesOfString:@":" withString:@"-" options:NSLiteralSearch range:NSMakeRange(0,[path length])];
	
	return [path autorelease];
}

- (BOOL) isFilePackage 
{	
	BOOL package = NO;
	
	MDItemRef meta_data = MDItemCreate(NULL,(CFStringRef)self);
	if ( meta_data == NULL ) return NO;
	
	NSString *file_uti = (NSString*)MDItemCopyAttribute(meta_data,kMDItemContentType);
	if ( file_uti == NULL ) return NO;
	
	package = ( UTTypeConformsTo((CFStringRef)file_uti,kUTTypePackage) );

	[file_uti release];
	return package;
}

- (NSString*) stringByStrippingAttachmentCharacters 
{	
	NSMutableString *textString = [self mutableCopyWithZone:[self zone]];
	[textString replaceOccurrencesOfString:[NSString stringWithCharacters:(const unichar[]) {NSAttachmentCharacter} length:1] 
			withString:[NSString string] options:NSLiteralSearch range:NSMakeRange(0, [textString length])];
	
	return [textString autorelease];
}

#pragma mark -

- (NSString*) MD5Digest 
{	
	#warning this doesn't seem to work for Journler, I have to include the method locally!
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	if ( data ) 
	{
		NSMutableData *digest = [NSMutableData dataWithLength:MD5_DIGEST_LENGTH];
		if ( digest && MD5([data bytes], [data length], [digest mutableBytes])) {
			NSString *digestAsString = [digest description];
			return digestAsString;
		}
	}
	return nil;
}


#pragma mark -

- (NSString*) pathWithoutOverwritingSelf
{
	int i = 0;
	NSMutableString *newPath = [NSMutableString stringWithString:self];
	
	while ( [[NSFileManager defaultManager] fileExistsAtPath:newPath] && ++i < INT_MAX ) 
	{
		// find a valid filename
		NSString *extension = [self pathExtension];
		NSString *filename = [[[self lastPathComponent] stringByDeletingPathExtension] pathSafeString];
		NSString *directory = [self stringByDeletingLastPathComponent];
		
		//NSString *pathWithoutExtension = [[self stringByDeletingPathExtension] pathSafeString];
		//NSString *pathWithoutExtension = [self stringByDeletingPathExtension];
		
		if ( extension != nil && [extension length] != 0 ) 
			//[newPath setString:[[pathWithoutExtension stringByAppendingFormat:@" %i",i] stringByAppendingPathExtension:extension]];
			[newPath setString:[[[directory stringByAppendingPathComponent:filename] stringByAppendingFormat:@" %i",i] stringByAppendingPathExtension:extension]];
		else
			//[newPath setString:[pathWithoutExtension stringByAppendingFormat:@" %i",i]];
			[newPath setString:[[directory stringByAppendingPathComponent:filename] stringByAppendingFormat:@" %i",i]];
	}
	
	return newPath;
}

- (NSString*) capitalizedStringWithoutAffectingOtherLetters
{
	int i;
	NSMutableString *convertedString = [NSMutableString string];
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	
	for ( i = 0; i < [self length]; i++ )
	{
		NSString *thisConverted = nil;
		NSString *substring = [self substringWithRange:NSMakeRange(i,1)];
		if ( i == 0 )
			thisConverted = [substring uppercaseString];
		else if ( [whitespace characterIsMember:[self characterAtIndex:i-1]] )
			thisConverted = [substring uppercaseString];
		else
			thisConverted = substring;
	
		[convertedString appendString:thisConverted];
	}
	
	return convertedString;
}


#pragma mark -

- (NSAttributedString*) attributedStringSyntaxHighlightedForHTML
{
	static NSString *doubleQuote = @"\"";
	static NSString *beginHTML = @"<";
	static NSString *endHTML = @">";
	
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor blackColor], NSForegroundColorAttributeName, nil];
		
	NSMutableAttributedString *attributedString = [[[NSMutableAttributedString alloc] initWithString:self attributes:attributes] autorelease];
	
	//NSLog(@"html");
	
	// convert the html marking
	NSScanner *scanner = [NSScanner scannerWithString:self];
	
	while ( ![scanner isAtEnd] )
	{
		int htmlStart = 0, htmlEnd = 0;
		
		if ( [scanner scanLocation] == 0 && [self characterAtIndex:0] == '<' )
			[scanner scanString:@"<" intoString:nil];
		else
		{
			if ( [scanner scanString:beginHTML intoString:nil] )
			{
				htmlStart = [scanner scanLocation] - 1;
			}
			else
			{
				if ( ![scanner scanUpToString:beginHTML intoString:nil] )
					break;
					
				htmlStart = [scanner scanLocation];
				
				if ( ![scanner scanString:beginHTML intoString:nil] )
					break;
				}
		}
		
		if ( [scanner scanString:endHTML intoString:nil] )
		{
			htmlStart = [scanner scanLocation];
		}
		else
		{
			if ( ![scanner scanUpToString:endHTML intoString:nil] )
				break;
				
			htmlEnd = [scanner scanLocation];
			
			if ( ![scanner scanString:endHTML intoString:nil] ) 
				break;
		
		}
		
		//NSLog(@"%i %i",htmlStart,htmlEnd);
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor blueColor] range:NSMakeRange(htmlStart, htmlEnd-htmlStart+1)];
		
		// while we're inside the html, scan for properties (any items after first space)
		
		[scanner setScanLocation:htmlStart];
		
		{
			int propStart, propEnd;
			[scanner setCharactersToBeSkipped:nil];
			
			if ( [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil] && [scanner scanLocation] < htmlEnd )
			{
				propStart = [scanner scanLocation] + 1;
				propEnd = htmlEnd - 1;
				
				//NSLog(@"%i %i",propStart,propEnd);
				[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor purpleColor] range:NSMakeRange(propStart, propEnd-propStart+1)];
			}
			
			[scanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		}
		
		[scanner setScanLocation:htmlEnd];
		
		// while we're inside the html, scan for quotes
		
		[scanner setScanLocation:htmlStart];
		
		while ( [scanner scanLocation] < htmlEnd )
		{
			int quoteStart, quoteEnd;
			
			if ( ![scanner scanUpToString:doubleQuote intoString:nil] )
				break;
				
			quoteStart = [scanner scanLocation];
			
			if ( ![scanner scanString:doubleQuote intoString:nil] )
				break;
			
			if ( ![scanner scanUpToString:doubleQuote intoString:nil] )
				break;
				
			quoteEnd = [scanner scanLocation];
			
			if ( ![scanner scanString:doubleQuote intoString:nil] ) 
				break;
				
			//NSLog(@"%i %i",quoteStart,quoteEnd);
			[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor orangeColor] range:NSMakeRange(quoteStart, quoteEnd-quoteStart+1)];
		}

		
		[scanner setScanLocation:htmlEnd];
			
	}

	//NSLog(@"quotes");

	// convert the quotes
	/*
	scanner = [NSScanner scannerWithString:self];
	while ( ![scanner isAtEnd] )
	{
		int quoteStart, quoteEnd;
		
		if ( ![scanner scanUpToString:doubleQuote intoString:nil] )
			break;
			
		quoteStart = [scanner scanLocation];
		
		if ( ![scanner scanString:doubleQuote intoString:nil] )
			break;
		
		if ( ![scanner scanUpToString:doubleQuote intoString:nil] )
			break;
			
		quoteEnd = [scanner scanLocation];
		
		if ( ![scanner scanString:doubleQuote intoString:nil] ) 
			break;
			
		NSLog(@"%i %i",quoteStart,quoteEnd);
		[attributedString addAttribute:NSForegroundColorAttributeName value:[NSColor orangeColor] range:NSMakeRange(quoteStart, quoteEnd-quoteStart+1)];
	}
	*/
	
	return attributedString;
}

#pragma mark -

- (NSComparisonResult) compareVersion:(NSString*)versionB
{	
	NSArray *partsA = SUSplitVersionString(versionB);
    NSArray *partsB = SUSplitVersionString(self);
    
    NSString *partA, *partB;
    int i, n, typeA, typeB, intA, intB;
    
    n = MIN([partsA count], [partsB count]);
    for (i = 0; i < n; ++i) {
        partA = [partsA objectAtIndex:i];
        partB = [partsB objectAtIndex:i];
        
        typeA = SUGetCharType(partA);
        typeB = SUGetCharType(partB);
        
        // Compare types
        if (typeA == typeB) {
            // Same type; we can compare
            if (typeA == kNumberType) {
                intA = [partA intValue];
                intB = [partB intValue];
                if (intA > intB) {
                    return NSOrderedAscending;
                } else if (intA < intB) {
                    return NSOrderedDescending;
                }
            } else if (typeA == kStringType) {
                NSComparisonResult result = [partB compare:partA];
                if (result != NSOrderedSame) {
                    return result;
                }
            }
        } else {
            // Not the same type? Now we have to do some validity checking
            if (typeA != kStringType && typeB == kStringType) {
                // typeA wins
                return NSOrderedAscending;
            } else if (typeA == kStringType && typeB != kStringType) {
                // typeB wins
                return NSOrderedDescending;
            } else {
                // One is a number and the other is a period. The period is invalid
                if (typeA == kNumberType) {
                    return NSOrderedAscending;
                } else {
                    return NSOrderedDescending;
                }
            }
        }
    }
    // The versions are equal up to the point where they both still have parts
    // Lets check to see if one is larger than the other
    if ([partsA count] != [partsB count]) {
        // Yep. Lets get the next part of the larger
        // n holds the value we want
        NSString *missingPart;
        int missingType, shorterResult, largerResult;
        
        if ([partsA count] > [partsB count]) {
            missingPart = [partsA objectAtIndex:n];
            shorterResult = NSOrderedDescending;
            largerResult = NSOrderedAscending;
        } else {
            missingPart = [partsB objectAtIndex:n];
            shorterResult = NSOrderedAscending;
            largerResult = NSOrderedDescending;
        }
        
        missingType = SUGetCharType(missingPart);
        // Check the type
        if (missingType == kStringType) {
            // It's a string. Shorter version wins
            return shorterResult;
        } else {
            // It's a number/period. Larger version wins
            return largerResult;
        }
    }
    
    // The 2 strings are identical
    return NSOrderedSame;
}

@end
