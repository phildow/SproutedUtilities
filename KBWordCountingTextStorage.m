//
//  KBWordCountingTextStorage.m
//  ---------------------------
//
//  Keith Blount 2005
//

#import <SproutedUtilities/KBWordCountingTextStorage.h>

NSString *KBTextStorageStatisticsDidChangeNotification = @"KBTextStorageStatisticsDidChangeNotification";

@implementation KBWordCountingTextStorage

/*************************** Word Count Specific Methods ***************************/

#pragma mark -
#pragma mark Word Count Specific Methods

/*
 *	-wordCountForRange: uses -doubleClickAtIndex: to calculate the word count.
 *	This method was recommended for this purpose by Aki Inoue at Apple.
 *	The docs mention that such methods (actually the docs are talking about -nextWordFromIndex:forward:
 *	in this context) aren't intended for linguistic analysis, but Aki Inoue explained that this was
 *	only because they do not perform linguistic analysis and therefore may not be entirely accurate
 *	for Japanese/Chinese, but should be fine for the majority of purposes.
 *	-wordRangeForCharRange: uses -nextWordAtIndex:forward: to get a rough word range to count,
 *	because using -doubleClickAtIndex: for that method too would require more checks to stop out of bounds
 *	exceptions.
 *	UPDATE 19/09/05: Now both methods use -nextWordAtIndex:, because after extensive tests, it turns out
 *	that -doubleClickAtIndex: is incredibly slow compared to -nextWordAtIndex:.
 */

- (unsigned)wordCountForRange:(NSRange)range
{
	unsigned wc = 0;
	NSCharacterSet *lettersAndNumbers = [NSCharacterSet alphanumericCharacterSet];
	
	int index = range.location;
	while (index < NSMaxRange(range))
	{
		//int newIndex = NSMaxRange([self doubleClickAtIndex:index]);
		int newIndex = [self nextWordFromIndex:index forward:YES];
		
		NSString *word = [[self string] substringWithRange:NSMakeRange(index, newIndex-index)];
		
		// Make sure it is a valid word - ie. it must contain letters or numbers,
		// otherwise don't count it
		if ([word rangeOfCharacterFromSet:lettersAndNumbers].location != NSNotFound)
			wc++;
		
		index = newIndex;
	}
	return wc;
}

- (NSRange)wordRangeForCharRange:(NSRange)charRange
{
	NSRange wordRange;
	wordRange.location = [self nextWordFromIndex:charRange.location forward:NO];
	wordRange.length = [self nextWordFromIndex:NSMaxRange(charRange) forward:YES] - wordRange.location;
	return wordRange;
}

- (unsigned)wordCount
{
	return wordCount;
}

/*************************** NSTextStorage Overrides ***************************/

#pragma mark -
#pragma mark NSTextStorage Overrides

// All of these methods are necessary to create a concrete subclass of NSTextStorage

- (id)init
{
	if (self = [super init])
	{
		text = [[NSMutableAttributedString alloc] init];
		wordCount = 0;
	}
	return self;
}

- (id)initWithAttributedString:(NSAttributedString *)aString
{
	if (self = [super init])
	{
		text = [aString mutableCopy];
		wordCount = [self wordCountForRange:NSMakeRange(0,[text length])];
	}
	return self;
}

- (id)initWithAttributedString:(NSAttributedString *)aString wordCount:(unsigned)wc
{
	if (self = [super init])
	{
		text = [aString mutableCopy];
		wordCount = wc;
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];	// According to CocoaDev, we need to do this...
	[text release];
	[super dealloc];
}

- (NSString *)string
{
	return [text string];
}

- (NSDictionary *)attributesAtIndex:(unsigned)index effectiveRange:(NSRangePointer)aRange
{
	return [text attributesAtIndex:index effectiveRange:aRange];
}

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString
{	
	int strlen = [aString length];
	
	NSRange wcRange = [self wordRangeForCharRange:aRange];
	wordCount -= [self wordCountForRange:wcRange];
	NSRange changedRange = NSMakeRange(wcRange.location,
									   (wcRange.length - aRange.length) + strlen);
	
	[text replaceCharactersInRange:aRange withString:aString];
	int lengthChange = strlen - aRange.length;
	[self edited:NSTextStorageEditedCharacters
		   range:aRange
  changeInLength:lengthChange];

	wordCount += [self wordCountForRange:changedRange];

	[[NSNotificationCenter defaultCenter] postNotificationName:KBTextStorageStatisticsDidChangeNotification
														object:self];
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange
{
	[text setAttributes:attributes range:aRange];
	[self edited:NSTextStorageEditedAttributes
		   range:aRange
  changeInLength:0];
}

- (void)addAttribute:(NSString *)name value:(id)value range:(NSRange)aRange
{
	[text addAttribute:name value:value range:aRange];
	[self edited:NSTextStorageEditedAttributes
		   range:aRange
  changeInLength:0];
}

// A bug in the current implementation means that inserting an attachment character
// always resets the typing attributes immediately after it. This is ***really*** annoying,
// so we have to roll our own version of -fixAttributesInRange: to fix this. This method
// is documented as "removing all attachment attributes assigned to characters other than
// NSAttachmentCharacter". But it also removes all other attributes, such as the font. Our
// implementation just does what is documented, nothing more.
// (Note that one of the Omni guys recommended this fix.)
/*
- (void)fixAttachmentAttributeInRange:(NSRange)aRange;
{	
	NSString *string = [self string];
	NSRange effectiveRange;
	id attributeValue;
	while (aRange.length > 0)
	{
		attributeValue = [self attribute:NSAttachmentAttributeName
								 atIndex:aRange.location
				   longestEffectiveRange:&effectiveRange
								 inRange:aRange];
		
		if (attributeValue)
		{
			unsigned int charIndex;
			for (charIndex = effectiveRange.location; charIndex < NSMaxRange(effectiveRange); charIndex++)
			{
				if ([string characterAtIndex:charIndex] != NSAttachmentCharacter)
				{
					// Might need a -beginEditing message here if it is not already...
					[self removeAttribute:NSAttachmentAttributeName 
									range:NSMakeRange(charIndex, 1)];
				}
			}
		}
		
		aRange = NSMakeRange(NSMaxRange(effectiveRange),
							 NSMaxRange(aRange) - NSMaxRange(effectiveRange));
	}
}
*/
@end
