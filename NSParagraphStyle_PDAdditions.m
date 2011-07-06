//
//  NSParagraphStyle_PDAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 2/3/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSParagraphStyle_PDAdditions.h>


@implementation NSParagraphStyle (PDAdditions)

+ (NSParagraphStyle*) defaultParagraphStyleWithLineBreakMode:(NSLineBreakMode)lineBreak
{
	NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopyWithZone:[self zone]] autorelease];
	[paragraphStyle setLineBreakMode:lineBreak];
	return paragraphStyle;
}

+ (NSParagraphStyle*) defaultParagraphStyleWithAlignment:(NSTextAlignment)textAlignment
{
	NSMutableParagraphStyle *paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopyWithZone:[self zone]] autorelease];
	[paragraphStyle setAlignment:textAlignment];
	return paragraphStyle;
}

@end
