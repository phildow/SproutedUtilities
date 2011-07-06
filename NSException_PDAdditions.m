//
//  NSException_PDAddition.m
//  SproutedUtilities
//
//  Created by Phil Dow on 11/21/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSException_PDAdditions.h>
#import <ExceptionHandling/NSExceptionHandler.h>

@implementation NSException (PDAddition)

- (void) printStackTrace
{
    NSString *stack = [[self userInfo] objectForKey:NSStackTraceKey];
    if ( stack != nil ) 
	{
        NSTask *ls = [[NSTask alloc] init];
        NSString *pid = [[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] stringValue];
        NSMutableArray *args = [NSMutableArray arrayWithCapacity:20];
 
        [args addObject:@"-p"];
        [args addObject:pid];
        [args addObjectsFromArray:[stack componentsSeparatedByString:@"  "]];
        // Note: function addresses are separated by double spaces, not a single space.
 
        [ls setLaunchPath:@"/usr/bin/atos"];
        [ls setArguments:args];
        [ls launch];
        [ls release];
 
    } 
	else 
	{
        NSLog(@"No stack trace available.");
    }
}

@end
