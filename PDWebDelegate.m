//
//  PDWebDelegate.m
//  SproutedUtilities
//
//  Created by Philip Dow on 6/2/06.
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
