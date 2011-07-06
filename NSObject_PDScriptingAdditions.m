//
//  NSObject_JSAdditions.m
//  SproutedUtilities
//
//  Created by Phil Dow on 11/18/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSObject_PDScriptingAdditions.h>

@implementation NSObject (PDScriptingAdditions)

- (void) returnError:(int)n string:(NSString*)s 
{
	NSScriptCommand* c = [NSScriptCommand currentCommand];
	[c setScriptErrorNumber:n];
	if (s) [c setScriptErrorString:( s != nil ? s : [NSString string] )]; 
}

@end

@implementation NSScriptCommand (PDScriptingAdditions)

- (id) subjectsSpecifier
{
    NSAppleEventDescriptor *subjDesc = [[self appleEvent] attributeDescriptorForKeyword: 'subj'];
    NSScriptObjectSpecifier *subjSpec = [NSScriptObjectSpecifier _objectSpecifierFromDescriptor: subjDesc
        inCommandConstructionContext: nil];
    return [subjSpec objectsByEvaluatingSpecifier];
}

- (id) evaluatedDirectParameters
{
    id param = [self directParameter];
    if ([param isKindOfClass: [NSScriptObjectSpecifier class]])
    {
        NSScriptObjectSpecifier *spec = (NSScriptObjectSpecifier *)param;
        id container = [[spec containerSpecifier] objectsByEvaluatingSpecifier];
        param = [spec objectsByEvaluatingWithContainers: container];
    }
    return param;
}

@end
