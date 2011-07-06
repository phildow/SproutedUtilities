//
//  NSTBFAttributedString.m
//  SproutedUtilities
//
//  Created by Philip Dow on 7/12/06.
//  Copyright 2006 Philip Dow. All rights reserved.
//

#import <SproutedUtilities/NSTBFTextBlock.h>

@implementation NSTBFTextBlock

static NSLock *unarchivingTextBlockLock = nil;
static CFMutableSetRef unarchivingTextBlockSet = NULL;

/*
+ (void)load {
	[self poseAsClass:[NSTextBlock class]];
}
*/

- (id)initWithCoder:(NSCoder *)coder {
    
	if (!unarchivingTextBlockLock) unarchivingTextBlockLock = [[NSLock alloc] init];
		[unarchivingTextBlockLock lock];
		
    if (!unarchivingTextBlockSet) unarchivingTextBlockSet = CFSetCreateMutable(NULL, 0, NULL);
		CFSetAddValue(unarchivingTextBlockSet, (const void *)self);
		
    [unarchivingTextBlockLock unlock];
    self = [super initWithCoder:coder];
    [unarchivingTextBlockLock lock];
	
    CFSetRemoveValue(unarchivingTextBlockSet, (const void *)self);
    [unarchivingTextBlockLock unlock];
	
    return self;
}

- (void)_createFloatStorage {
    BOOL create = YES;
    if (_propVals) {
        [unarchivingTextBlockLock lock];
        if (unarchivingTextBlockSet && CFSetContainsValue (unarchivingTextBlockSet, (const void *)self))
			create = NO;
        [unarchivingTextBlockLock unlock];
    }
    if (create) [super _createFloatStorage];
}

@end
