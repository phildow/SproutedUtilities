//
//  PDWebArchiveMiner.m
//  SproutedUtilities
//
//  Created by Philip Dow on 3/30/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

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
