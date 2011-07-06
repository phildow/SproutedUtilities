//
//  SproutedLabelConverter.m
//  SproutedUtilities
//
//  Created by Philip Dow on 8/27/08.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/SproutedLabelConverter.h>

static short kFinderLabelForPickerLabel[8] = { 0, 6, 7, 5, 2, 4, 3, 1 };
static short kPickerLabelForFinderLabel[8] = { 0, 7, 4, 6, 5, 3, 1, 2 };

@implementation SproutedLabelConverter

+ (NSInteger) finderEquivalentForSproutedLabel:(NSInteger)value
{
	return kFinderLabelForPickerLabel[value];
}

+ (NSInteger) sproutedEquivalentForFinderLabel:(NSInteger)value
{
	return kPickerLabelForFinderLabel[value];
}

@end
