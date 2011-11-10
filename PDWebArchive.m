//
//  PDWebArchive.m
//  SproutedUtilities
//
//  Created by Philip Dow on 6/1/06.
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
