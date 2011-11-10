//
//  PDWebArchiveMiner.m
//  SproutedUtilities
//
//  Created by Philip Dow on 3/30/07.
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

#import <SproutedUtilities/PDWebArchiveMiner.h>


@implementation PDWebArchiveMiner

- (id) initWithWebArchive:(WebArchive*)aWebArchive
{
	if ( self = [super init] )
	{
		webArchive = [aWebArchive retain];
	}
	return self;
}

- (void) dealloc
{
	[webArchive release];
	[resources release];
	[plaintextRepresentation release];
	
	[super dealloc];
}

#pragma mark -

+ (NSString*) plaintextRepresentationForWebArchive:(WebArchive*)aWebArchive
{
	PDWebArchiveMiner *miner = [[[PDWebArchiveMiner alloc] initWithWebArchive:aWebArchive] autorelease];
	return [miner plaintextRepresentation];
}

+ (NSString*) plaintextRepresentationForResource:(WebResource*)aResource
{
	NSString *content = nil;
	NSString *mimeType = [[aResource MIMEType] lowercaseString];
		
	if ( [mimeType isEqualTo:@"text/html"] || [mimeType isEqualToString:@"text/plain"] )
	{
		NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
		 [aResource textEncodingName], NSTextEncodingNameDocumentOption,
		 self, NSWebResourceLoadDelegateDocumentOption, nil];
		
		NSAttributedString *attrString = [[[NSAttributedString alloc] initWithHTML:[aResource data] 
		 options:options documentAttributes:nil] autorelease];
		
		if ( attrString != nil )
			content = [attrString string];
	}
	
	return content;
}

+ (NSArray*) resourcesForWebArchive:(WebArchive*)aWebArchive
{
	PDWebArchiveMiner *miner = [[[PDWebArchiveMiner alloc] initWithWebArchive:aWebArchive] autorelease];
	return [miner resources];
}

#pragma mark -

- (WebArchive*) webArchive
{
	return webArchive;
}

- (void) setWebArchive:(WebArchive*)aWebArchiv
{
	if ( webArchive != aWebArchiv )
	{
		[webArchive release];
		webArchive = [aWebArchiv copyWithZone:[self zone]];
		
		[resources release];
		resources = nil;
	}
}

- (NSArray*) resources
{
	if ( resources == nil )
		resources = [[self _resourcesForWebArchive:[self webArchive]] retain];
	
	return resources;
}

#pragma mark -

- (NSString*) plaintextRepresentation
{
	WebResource *aResource;
	NSEnumerator *enumerator = [[self resources] objectEnumerator];
	
	NSMutableString *content = [NSMutableString string];
	
	while ( aResource = [enumerator nextObject] )
	{
		NSString *mimeType = [[aResource MIMEType] lowercaseString];
		
		if ( [mimeType isEqualTo:@"text/html"] || [mimeType isEqualToString:@"text/plain"] )
		{
			NSString *someContent = nil;
			
			NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
			 [aResource textEncodingName], NSTextEncodingNameDocumentOption,
			 self, NSWebResourceLoadDelegateDocumentOption, nil];
			
			NSAttributedString *attrString = [[[NSAttributedString alloc] initWithHTML:[aResource data] 
			 options:options documentAttributes:nil] autorelease];
			
			if ( attrString != nil && ( someContent = [attrString string] ) != nil )
			{
				[content appendString:someContent];
				[content appendString:@" "];
			}
		}
	}
	
	return content;
}

#pragma mark -

- (NSArray*) _resourcesForWebArchive:(WebArchive*)aWebArchive
{
	NSMutableArray *allResources = [NSMutableArray array];
	
	WebResource *mainResource = [aWebArchive mainResource];
	NSArray *subResources = [aWebArchive subresources];
	NSArray *subArchives = [aWebArchive subframeArchives];
	
	if ( mainResource != nil ) [allResources addObject:mainResource];
	if ( subResources != nil ) [allResources addObjectsFromArray:subResources];
	
	if ( subArchives != nil )
	{
		WebArchive *aSubArchive;
		NSEnumerator *enumerator = [subArchives objectEnumerator];
		
		while ( aSubArchive = [enumerator nextObject] )
		{
			NSArray *subArchiveResources = [self _resourcesForWebArchive:aSubArchive];
			if ( subArchiveResources != nil ) [allResources addObjectsFromArray:subArchiveResources];
		}
	}
	
	return allResources;
}

#pragma mark -

- (id)webView:(WebView *)sender identifierForInitialRequest:(NSURLRequest *)request fromDataSource:(WebDataSource *)dataSource
{
	return [[request URL] absoluteString];
}

-(NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request 
 redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
	if ( [[[request URL] absoluteString] rangeOfString:@"http" options:NSCaseInsensitiveSearch].location == 0 )
		return nil;
	
	//NSLog([[request URL] absoluteString]);
	return request;
}

@end
