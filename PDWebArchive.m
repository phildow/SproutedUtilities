//
//  PDWebArchive.m
//  SproutedUtilities
//
//  Created by Philip Dow on 6/1/06.
//  Copyright 2006 Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/PDWebArchive.h>
#import <SproutedUtilities/PDWebArchiveMiner.h>

@implementation PDWebArchive : WebArchive

- (NSString*) stringValue
{
	return [PDWebArchiveMiner plaintextRepresentationForWebArchive:self];
}

/*
- (NSString*) stringValue {
	
	//
	// loads an archive into a view, grabs the dom element, the element's inner text
	
	static double kMaxLoadTime = 15.0;
	
	NSString *return_string;
	WebView *web_view = [[WebView alloc] initWithFrame:NSMakeRect(0,0,100,100)];
	
	NSURLRequest *url_request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@""]];
	[[web_view mainFrame] loadRequest:url_request];
	
	[web_view setFrameLoadDelegate:self];
	[[web_view mainFrame] loadArchive:self];
	
	//
	// wait until the frame has finished loading
	double current_time = [[NSDate date] timeIntervalSinceReferenceDate];
	while ( _finished_loading == NO ) {
		if ( [[NSDate date] timeIntervalSinceReferenceDate] - current_time >= kMaxLoadTime )
			break;
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
	}
	
	NSView *doc_view = [[[web_view mainFrame] frameView] documentView];
	if ( !doc_view || ![doc_view conformsToProtocol:@protocol(WebDocumentText)] )
		return_string = [NSString string];
	else
		return_string = [doc_view string];
	
	[web_view setFrameLoadDelegate:nil];
	
	[url_request release];
	[web_view release];
	
	return return_string;
}

#pragma mark -

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	if ( [sender mainFrame] == frame ) _finished_loading = YES;
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	if ( [sender mainFrame] == frame ) _finished_loading = YES;
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	if ( [sender mainFrame] == frame ) _finished_loading = YES;
}
*/

@end
