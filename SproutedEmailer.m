//
//  SproutedEmailer.m
//  SproutedUtilities
//
//  Created by Philip Dow on 4/17/08.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/SproutedEmailer.h>

@implementation SproutedEmailer

- (BOOL)sendRichMail:(NSAttributedString *)richBody 
		to:(NSString *)to 
		subject:(NSString *)subject 
		isMIME:(BOOL)isMIME 
		withNSMail:(BOOL)wM
{
	NSMutableDictionary *toFromDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
			to,@"to",
			subject,@"subject",
			NSFullUserName(),@"from",NULL];

	NSString *from = [[NSUserDefaults standardUserDefaults] objectForKey:@"IDEmail"];
	if (from) [toFromDict setObject:from forKey:@"from"];
	
	BOOL success = YES;

	// 1. Attempt to send a mail using the delivery framework ----------------

	// Can we even use the mail framework?
	
	if ( wM && [NSMailDelivery hasDeliveryClassBeenConfigured]) {
		
		// we use error handling in case there is trouble in the NSMailDelivery framework

		@try 
		{
			// first we try SMPT, then if that fails, we try sendmail:
			if ( ![NSMailDelivery deliverMessage:richBody 
						headers:toFromDict 
						format:isMIME?NSMIMEMailFormat:NSASCIIMailFormat 
						protocol:NSSMTPDeliveryProtocol] )
						
				[NSMailDelivery deliverMessage:richBody 
						headers:toFromDict 
						format:isMIME?NSMIMEMailFormat:NSASCIIMailFormat 
						protocol:NSSendmailDeliveryProtocol];
		}

		@catch (NSException *localException) 
		{
			NSLog(@"NSMailDelivery: an exception was raised: %@",[localException reason]);
			success = NO;
		}
		@finally
		{
		
		}
	
	}
	else {
		success = NO;
	}
	
	// 2. Check the result here, if failure, attempt to send using nsurl ------------
	
	if ( !success ) {
		
		int result = NSAlertFirstButtonReturn;
		
		if ( wM ) {
			
			//only display the alert panel if we originally tried to send with nsmail
			
			NSAlert *mailAlert = [NSAlert alertWithMessageText:@"Unable to send entry to Blogger.com" 
				defaultButton:@"Send" 
				alternateButton:@"Cancel" 
				otherButton:nil 
				informativeTextWithFormat:@"Journler was unable to send an email using your system settings. Would you like send this entry with your default mail client?"];
				
			[mailAlert setShowsHelp:YES];
			[mailAlert setHelpAnchor:@"Journler Blog Help"];
				
			result = [mailAlert runModal];
			
		}
		
		if ( result == NSAlertFirstButtonReturn || result == 1 ) {
			
			//construct the nsurl using our dictionary
			
			//prepre the body text
			NSMutableString *parsed = [[NSMutableString alloc] initWithString:[richBody string]];
			//get rid of attachment plus new line
			[parsed replaceOccurrencesOfString:[NSString stringWithCharacters:(const unichar[]) {NSAttachmentCharacter, '\n'} length:2] 
					withString:@"" 
					options:NSLiteralSearch 
					range:NSMakeRange(0, [parsed length])];
					
			[parsed replaceOccurrencesOfString:[NSString stringWithCharacters:(const unichar[]) {NSAttachmentCharacter, '\r'} length:2] 
					withString:@"" 
					options:NSLiteralSearch 
					range:NSMakeRange(0, [parsed length])];
					
			//get rid of attachment alone
			[parsed replaceOccurrencesOfString:[NSString stringWithCharacters:(const unichar[]) {NSAttachmentCharacter} length:1] 
					withString:@"" 
					options:NSLiteralSearch 
					range:NSMakeRange(0, [parsed length])];
			
			//
			// MEMORY LEAK HERE WITH CFURLCREATESTRINGBYADDINGPERCENTESCAPES
			
			//encode the url
			NSMutableString *encodedBody = [[NSMutableString alloc] initWithFormat:@"BODY=%@", 
					(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)parsed, NULL,NULL, kCFStringEncodingUTF8)];
			
			[encodedBody replaceOccurrencesOfString:@"&" 
					withString:@"%26" 
					options:NSLiteralSearch 
					range:NSMakeRange(0, [parsed length])];
			
			NSMutableString *encodedSubject = [[NSMutableString alloc] initWithFormat:@"SUBJECT=%@", 
					(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)subject, NULL,NULL, kCFStringEncodingUTF8)];
			
			[encodedSubject replaceOccurrencesOfString:@"&" 
					withString:@"%26" 
					options:NSLiteralSearch 
					range:NSMakeRange(0, [encodedSubject length])];
			
			NSString *encodedURLString = [[NSString alloc] initWithFormat:@"mailto:%@?%@&%@", to, encodedSubject, encodedBody]; 
			NSURL *mailtoURL = [[NSURL alloc] initWithString:encodedURLString]; 
			if ( !mailtoURL )
			{
				success = NO;
				NSLog(@"%@ %s - unable to create URL from encoded string %@", [self className], _cmd, encodedURLString);
			}
			
			//send it off to default mail client
			if ( ![[NSWorkspace sharedWorkspace] openURL:mailtoURL] )
			{
				success = NO;
				NSLog(@"%@ %s - unable to launch URL %@", [self className], _cmd, mailtoURL);
			}
			
			//clean up
			[mailtoURL release];
			[encodedURLString release];
			[parsed release];
			[encodedBody release];
			[encodedSubject release];
			
			success = YES;
		}
		else {
			success = NO;
		}
	}
	
	return success;
}


@end
