//
//  PDDocument_PDCategory.m
//  SproutedUtilities
//
//  Created by Philip Dow on 1/19/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/PDFDocument_PDCategory.h>

@implementation PDFDocument (PDCategory )

- (NSImage*) thumbnailForPage:(unsigned int)index size:(float)edge
{
	if ( index > [self pageCount] )
		return nil;
	
	//NSPDFImageRep *imageRep = [NSPDFImageRep imageRepWithData:[[self pageAtIndex:0] dataRepresentation]];
	//if ( imageRep == nil )
	//	return nil;
	
	//NSSize repSize = [imageRep size];
	
	NSPDFImageRep *imageRep = [NSPDFImageRep imageRepWithData:[self dataRepresentation]];
	if ( imageRep == nil )
		return nil;
		
	[imageRep setCurrentPage:index];
	NSSize repSize = [imageRep size];
	
	NSImage *renderedPage = [[[NSImage alloc] initWithSize:NSMakeSize(edge,edge)] autorelease];
	
	[renderedPage lockFocus];
	
	NSRect targetRect;
	
	if ( repSize.width > repSize.height )
	{
		int newHeight = edge*repSize.height/repSize.width;
		targetRect = NSMakeRect(0, edge/2 - newHeight/2 ,edge, newHeight);
	}
	else 
	{
		int newWidth = edge*repSize.width/repSize.height;
		targetRect = NSMakeRect(edge/2 - newWidth/2,0,newWidth,edge);
	}
	
	[[NSColor whiteColor] set];
	NSRectFillUsingOperation(targetRect, NSCompositeSourceOver);
	
	[imageRep drawInRect:targetRect];
	
	[[NSColor lightGrayColor] set];
	[[NSBezierPath bezierPathWithRect:targetRect] stroke];
	
	[renderedPage unlockFocus];
	
	return renderedPage;
}

- (NSImage*) efficientThumbnailForPage:(unsigned int)index size:(float)edge
{
	NSImage *theImage = nil;
	
	// I had this commented out, why? another option might be drawWithBox
	NSPDFImageRep *imageRep = [NSPDFImageRep imageRepWithData:[[self pageAtIndex:index] dataRepresentation]];
	if ( imageRep == nil )
		return nil;
	
	[imageRep setCurrentPage:0];
	NSSize repSize = [imageRep size];
	
	theImage = [[[NSImage alloc] initWithSize:NSMakeSize(edge,edge)] autorelease];
	//[theImage addRepresentation:imageRep];
	
	[theImage lockFocus];
	
	NSRect targetRect;
	
	if ( repSize.width > repSize.height )
	{
		int newHeight = edge*repSize.height/repSize.width;
		targetRect = NSMakeRect(0, edge/2 - newHeight/2 ,edge, newHeight);
	}
	else 
	{
		int newWidth = edge*repSize.width/repSize.height;
		targetRect = NSMakeRect(edge/2 - newWidth/2,0,newWidth,edge);
	}
	
	[[NSColor whiteColor] set];
	NSRectFillUsingOperation(targetRect, NSCompositeSourceOver);
	
	[imageRep drawInRect:targetRect];
	
	[[NSColor lightGrayColor] set];
	[[NSBezierPath bezierPathWithRect:targetRect] stroke];
	
	[theImage unlockFocus];
	
	return theImage;
}


@end
