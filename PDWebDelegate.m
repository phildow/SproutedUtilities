//
//  PDWebDelegate.m
//  SproutedUtilities
//
//  Created by Philip Dow on 6/2/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/PDWebDelegate.h>


@implementation PDWebDelegate

- (id) initWithWebView:(WebView*)webView {
	if ( self = [super init] ) {
		_master_view = [webView retain];
		[webView setFrameLoadDelegate:self];
	}
	return self;
}

- (void) dealloc {
	
	[_master_view setFrameLoadDelegate:nil];
	[_master_view release];
	_master_view = nil;
	
	[super dealloc];
	
}

#pragma mark -

- (void) waitForView:(double)maxTime {

	//
	// wait until the frame has finished loading
	double current_time = [[NSDate date] timeIntervalSinceReferenceDate];
	while ( [self finishedLoading] == NO ) {
		if ( [[NSDate date] timeIntervalSinceReferenceDate] - current_time >= maxTime )
			break;
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
	}
	
	return;
}

#pragma mark -

- (BOOL) finishedLoading { return _finished_loading; }

- (void) setFinishedLoading:(BOOL)finished {
	_finished_loading = finished;
}

#pragma mark -

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
	if ( [sender mainFrame] == frame ) [self setFinishedLoading:YES];
}

- (void)webView:(WebView *)sender didFailProvisionalLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	if ( [sender mainFrame] == frame ) [self setFinishedLoading:YES];
}

- (void)webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
	if ( [sender mainFrame] == frame ) [self setFinishedLoading:YES];
}


@end
