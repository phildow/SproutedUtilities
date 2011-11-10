//
//  PDPowerManagement.h
//	SproutedUtilities
//
//  Created by Philip Dow on 3/21/06.

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

#import <Cocoa/Cocoa.h>

//
// Be sure to include the IOKit Framework in your project

#import <mach/mach_port.h>
#import <mach/mach_interface.h>
#import <mach/mach_init.h>

#import <IOKit/pwr_mgt/IOPMLib.h>
#import <IOKit/IOMessage.h>

//
// Notifications
//
// The PDPowerManagementNotification will be sent to the default notification center
// with the shared instance of PDPowerManagement as the object. To make sure that a shared 
// instance is available, call [PDPowerManagement sharedPowerManagement] somewhere in your code.
//
// The notification's user info dictionary will contain the PDPowerManagementMessage key with an 
// NSNumber whose int value is either PDPowerManagementWillSleep or PDPowerManagementPoweredOn.

#define PDPowerManagementNotification	@"PDPowerManagementNotification"
#define PDPowerManagementMessage		@"PDPowerManagementMessage"
#define PDPowerManagementWillSleep		1
#define PDPowerManagementPoweredOn		3

//
// Disallowing Sleep
//
// There are two ways to disallow a power down. Either call setPermitSleep: with NO 
// or implement the - (BOOL) shouldAllowIdleSleep:(id)sender delegate method and return NO as needed.
// At initialization _permitSleep is set to YES. With this value, the delegate method is
// always called if the delegate implements it. If _permitSleep is set to NO, the delegate
// method is never called. setPermitSleep: is thus a lazy way of always disallowing sleep.
//
// It must however be noted that it is not possible to cancel a sleep command that the user
// initiates. _permitSleep and the delegate method can only prevent an idle sleep. For 
// more information: http://developer.apple.com/qa/qa2004/qa1340.html

@interface PDPowerManagement : NSObject {
	
	BOOL	_permitSleep;
	id		_delegate;
	
}

+ (id)sharedPowerManagement;

- (BOOL) permitSleep;
- (void) setPermitSleep:(BOOL)permitSleep;

- (id) delegate;
- (void) setDelegate:(id)delegate;

- (void) _postPMNotification:(int)message;
- (BOOL) _shouldAllowSleep;

@end

//
// Delegation
// You should implement: - (BOOL) shouldAllowIdleSleep:(id)sender
// 
// If you set a delegate, before the computer is put to idle sleep the delegate's
// shouldAllowSleep: method will be called. Return NO to disallow the power down, 
// return yes to permit it.

@interface NSObject (PDPowerManagementDelegate)

//
// return YES to permit a power down, NO to disallow it
- (BOOL) shouldAllowIdleSleep:(id)sender;

@end
