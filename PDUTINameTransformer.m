//
//  PDUTINameTransformer.m
//  SproutedUtilities
//
//  Created by Philip Dow on 6/18/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/PDUTINameTransformer.h>


@implementation PDUTINameTransformer

+ (Class)transformedValueClass
{
    return [NSString self];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)beforeObject
{
	
	//
	// takes before object as a number and creates a rank image from it
	// - assumes that the beforeObject value is on a scale from 0 to 100
	//
	
	if ( beforeObject == nil )
		return nil;
	
	NSString *title = (NSString*)UTTypeCopyDescription((CFStringRef)beforeObject);
	return [title autorelease];
}


@end
