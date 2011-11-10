//
//  PDDocument_PDCategory.m
//  SproutedUtilities
//
//  Created by Philip Dow on 1/19/07.
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
