//
//  PDPowerManagement.m
//  SproutedUtilities
//
//  Created by Philip Dow on 3/21/06.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/PDPowerManagement.h>

@implementation PDPowerManagement

PDPowerManagement	*_self;
io_connect_t		root_port;

void callback(void * x,io_service_t y,natural_t messageType,void * messageArgument);
void callback(void * x,io_service_t y,natural_t messageType,void * messageArgument)
{
   
	switch ( messageType ) {
		case kIOMessageSystemWillSleep:
			if ( [_self _shouldAllowSleep] ) {
				[_self _postPMNotification:PDPowerManagementWillSleep];
				IOAllowPowerChange(root_port,(long)messageArgument);
			}
			else
				IOCancelPowerChange(root_port,(long)messageArgument);
			break;
		case kIOMessageCanSystemSleep:
			IOAllowPowerChange(root_port,(long)messageArgument);
			break;
		case kIOMessageSystemHasPoweredOn:
			[_self _postPMNotification:PDPowerManagementPoweredOn];
			break;
    }
    
}

#pragma mark -

+ (id)sharedPowerManagement {
    static PDPowerManagement *sharedPowerManagement = nil;

    if (!sharedPowerManagement)
		sharedPowerManagement = [[PDPowerManagement allocWithZone:NULL] init];

    return sharedPowerManagement;
}


- (id) init {
	
	if ( self = [super init] ) {
		
		IONotificationPortRef	notify;
		io_object_t				anIterator;

		root_port = IORegisterForSystemPower (0,&notify,callback,&anIterator);
		if ( root_port == IO_OBJECT_NULL ) {
			NSLog(@"IORegisterForSystemPower failed");
			return nil;
		}
		
		CFRunLoopAddSource(CFRunLoopGetCurrent(), IONotificationPortGetRunLoopSource(notify), kCFRunLoopDefaultMode);
		
		_permitSleep = YES;
		_self = self;
		
	}
	
	return self;
	
}

#pragma mark -

- (BOOL) permitSleep { return _permitSleep; }

- (void) setPermitSleep:(BOOL)permitSleep {
	_permitSleep = permitSleep;
}

- (id) delegate { return _delegate; }

- (void) setDelegate:(id)delegate {
	_delegate = delegate;
}

#pragma mark -

- (void) _postPMNotification:(int)message {
	
	NSNumber *dictionaryMessage;
	NSDictionary *userInfo;
	NSNotification *notification;
	
	
	// Useful for debugging
	/*
	switch ( message ) {
		
		case PDPowerManagementWillSleep:
			NSLog(@"Going to sleep now");
			break;
		case PDPowerManagementPoweredOn:
			NSLog(@"Just had a nice snooze");
			break;
		
	}
	*/
	
	dictionaryMessage = [NSNumber numberWithInt:message];
	userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			dictionaryMessage, PDPowerManagementMessage, nil];
	notification = [NSNotification notificationWithName:PDPowerManagementNotification 
			object:self userInfo:userInfo];
	
	[[NSNotificationCenter defaultCenter] postNotification:notification];
	
}

- (BOOL) _shouldAllowSleep {
	
	if ( !_permitSleep )
		return NO;
	else {
		if ( _delegate && [_delegate respondsToSelector:@selector(shouldAllowIdleSleep:)] )
			return [_delegate shouldAllowIdleSleep:self];
		else
			return YES;
	}
}

@end
