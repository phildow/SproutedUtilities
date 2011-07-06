//
//  PDUtilityFunctions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 5/15/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/PDUtilityFunctions.h>

NSString *GetUUID(void) 
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}