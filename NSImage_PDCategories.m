//
//  NSImage_PDCategories.m
//  SproutedUtilities
//
//  Created by Philip Dow on 9/9/06.
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


#import <SproutedUtilities/NSImage_PDCategories.h>
#import <SproutedUtilities/CTGradient.h>
#import <QuickLook/QuickLook.h>

@implementation NSImage (PDCategories)

+ (NSImage*) imageByReferencingImageNamed:(NSString*)imageName
{
	return [[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] 
	pathForResource:[imageName stringByDeletingPathExtension] ofType:[imageName pathExtension]]] autorelease];

}

+ (BOOL) canInitWithFile:(NSString*)path
{
	NSString *app = nil;
	NSString *fileType = nil;
	NSArray *allImageFileTypes = [NSImage imageFileTypes];
	
	[[NSWorkspace sharedWorkspace] getInfoForFile:path application:&app type:&fileType];
	if ( !fileType || [fileType length] == 0 || [fileType isEqualToString:@"pdf"] ) 
		return NO; //pdf documents are a special case
	
	/*
	BOOL canInit = [allImageFileTypes containsObject:fileType];
	if ( canInit ) return YES;
	else
	{
		// try a lazy initialization
		if ( [[[NSImage alloc] initByReferencingFile:path] autorelease] != nil )
			return YES;
		else
			return NO;
	}
	*/
	
	return ( [allImageFileTypes containsObject:fileType] );
}

+ (NSImage*) iconWithContentsOfFile:(NSString*)path edgeSize:(float)size inset:(float)padding
{
	//#warning not completely implemented - inset
	NSImage *original = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
	if ( original == nil )
		return nil;
	
	NSRect targetFrame;
	NSImage *product = [[[NSImage alloc] initWithSize:NSMakeSize(size,size)] autorelease];
	NSSize mySize = [original size];
	
	if ( mySize.width > mySize.height )
	{
		int targetWidth = ( mySize.width < size ? mySize.width : size );
		int targetHeight = targetWidth*mySize.height/mySize.width;
		targetFrame = NSMakeRect(size/2 - targetWidth/2, size/2 - targetHeight/2, targetWidth, targetHeight);
	}
	else
	{
		int targetHeight = ( mySize.height < size ? mySize.height : size );
		int targetWidth = targetHeight*mySize.width/mySize.height;
		targetFrame = NSMakeRect(size/2 - targetWidth/2, size/2 - targetHeight/2, targetWidth, targetHeight);
	}
	
	[product lockFocus];
	[original drawInRect:targetFrame fromRect:NSMakeRect(0,0,mySize.width,mySize.height) 
			operation:NSCompositeSourceOver fraction:1.0];
	[product unlockFocus];
	
	return product;
	
}

+ (NSImage *)imageWithPreviewOfFileAtPath:(NSString *)path ofSize:(NSSize)size asIcon:(BOOL)icon
{
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (!path || !fileURL) {
        return nil;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:icon] 
                                                     forKey:(NSString *)kQLThumbnailOptionIconModeKey];
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault, 
                                            (CFURLRef)fileURL, 
                                            CGSizeMake(size.width, size.height),
                                            (CFDictionaryRef)dict);
    
    if (ref != NULL) {
        // Take advantage of NSBitmapImageRep's -initWithCGImage: initializer, new in Leopard,
        // which is a lot more efficient than copying pixel data into a brand new NSImage.
        // Thanks to Troy Stephens @ Apple for pointing this new method out to me.
        NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithCGImage:ref];
        NSImage *newImage = nil;
        if (bitmapImageRep) {
            newImage = [[NSImage alloc] initWithSize:[bitmapImageRep size]];
            [newImage addRepresentation:bitmapImageRep];
            [bitmapImageRep release];
            
            if (newImage) {
                return [newImage autorelease];
            }
        }
        CFRelease(ref);
    } else {
        // If we couldn't get a Quick Look preview, fall back on the file's Finder icon.
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:path];
        if (icon) {
            [icon setSize:size];
        }
        return icon;
    }
    
    return nil;
}


#pragma mark -

- (NSImage *)reflectedImage:(float)fraction
{
	// based on NSImage+BHReflectedImage.m by Jeff Ganyard
	
	NSImage *reflection = [[NSImage alloc] initWithSize:[self size]];
	[reflection setFlipped:YES];

	[reflection lockFocus];
	CTGradient *fade = [CTGradient gradientWithBeginningColor:[NSColor colorWithCalibratedWhite:1.0 alpha:0.5] endingColor:[NSColor clearColor]];
	[fade fillRect:NSMakeRect(0, 0, [self size].width, [self size].height*fraction) angle:90.0];	
	[self drawAtPoint:NSMakePoint(0,0) fromRect:NSZeroRect operation:NSCompositeSourceIn fraction:1.0];
	[reflection unlockFocus];

	return [reflection autorelease];
}

- (NSImage*) imageWithWidth:(float)width height:(float)height {
	
	// returns a WxH version of the image
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
	
	[image lockFocus];
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	[self drawInRect:NSMakeRect(0,0,width,height) fromRect:NSMakeRect(0,0,[self size].width,[self size].height) 
			operation:NSCompositeSourceOver fraction:1.0];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	[image unlockFocus];

	return [image autorelease];
	
}

- (NSImage*) imageWithWidth:(float)width height:(float)height inset:(float)inset {
	
	// returns a WxH version of the image but with the image inset on all sides
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(width,height)];
	NSRect dRect = NSMakeRect(inset,inset,width-inset*2,height-inset*2);
	
	[image lockFocus];
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	[self drawInRect:dRect fromRect:NSMakeRect(0,0,[self size].width,[self size].height) 
			operation:NSCompositeSourceOver fraction:1.0];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	[image unlockFocus];

	return [image autorelease];

}

#pragma mark -

- (NSData*) pngData
{
	NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
	return [rep representationUsingType:NSPNGFileType properties:nil];
}

- (NSAttributedString*) attributedString:(int)qual maxWidth:(int)mWidth 
{
		
	NSFileWrapper		*pngFileWrapper;
	NSBitmapImageRep	*bitmapRep;
	NSTextAttachment	*attachment;
	NSAttributedString	*picAsAttrStr;
	
	int quality = ( qual ? qual : 5 );
	
	if ( mWidth != 0 && [self size].width > mWidth ) {
		
		int newWidth = mWidth;
		int newHeight = mWidth * [self size].height / [self size].width;
		
		//draw the image into our resized image
		NSImage *resizedImage = [[NSImage alloc] initWithSize:NSMakeSize(newWidth,newHeight)];
		
		[resizedImage lockFocus];
		[NSGraphicsContext saveGraphicsState];
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		[self drawInRect:NSMakeRect(0.0,0.0,newWidth, newHeight) 
			fromRect:NSMakeRect(0.0,0.0,[self size].width, [self size].height) 
			operation:NSCompositeCopy fraction:1.0];
		[NSGraphicsContext restoreGraphicsState];
		[resizedImage unlockFocus];
		
		//
		//and grab our data
		bitmapRep = [[NSBitmapImageRep alloc] initWithData:[resizedImage TIFFRepresentation]];
		
		//
		//clean up
		[resizedImage release];
		
	}
	else {
		
		//just need the bitmap rep
		bitmapRep = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
		
	}
	
	//
	// encountered an error, return nil without worrry about releasing anything
	if ( !bitmapRep )
		return nil;
	
	//
	// depending on the quality, create a file wrapper with the appropriate representation
	if ( quality == 10 ) {
		
		pngFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[bitmapRep representationUsingType:NSPNGFileType properties:nil]];
		if ( !pngFileWrapper )
			return nil;
		
		[pngFileWrapper setPreferredFilename:@"journaled pic.png"];
		
	}
	else {
		
		NSDictionary *imageProps = [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithFloat:0.85], NSImageCompressionFactor, NULL];
		pngFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:
				[bitmapRep representationUsingType:NSJPEGFileType properties:imageProps]];
		if ( !pngFileWrapper )
			return nil;
		
		[pngFileWrapper setPreferredFilename:@"journaled pic.jpg"];
		
	}
	
	//
	// create the attachment
	attachment = [[NSTextAttachment alloc] initWithFileWrapper:pngFileWrapper];
	if ( !attachment )
		return nil;
	
	//
	// create the attributed string
	picAsAttrStr = [NSAttributedString attributedStringWithAttachment:attachment];
	
	//
	// clean up
	[attachment release];
	
	// return whatever value the attributed string is, nil okay
	return picAsAttrStr;
	
}

#pragma mark -

+ (NSImage *) imageFromCIImage:(CIImage *)ciImage
{
	NSImage *image = [[[NSImage alloc] initWithSize:NSMakeSize([ciImage extent].size.width, [ciImage extent].size.height)] autorelease];
	[image addRepresentation:[NSCIImageRep imageRepWithCIImage:ciImage]];
	return image;
}

+ (CIImage *) CIImageFromImage:(NSImage*)anImage
{
	/*
	NSBitmapImageRep *bitmapRep = [anImage bestRepresentationForDevice:nil];
	CIImage *ciImage = [[[CIImage alloc] initWithBitmapImageRep:bitmapRep] autorelease];
	return ciImage;
	*/
	
	NSData *imageData = [anImage TIFFRepresentation];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:imageData];
	CIImage *ciImage = [[[CIImage alloc] initWithBitmapImageRep:imageRep] autorelease];
	return ciImage;
}

@end
