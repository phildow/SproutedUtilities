//
//  PDWebLoc.h
//  SproutedUtilities
//
//  Created by Philip Dow on 10/20/06.
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

//  Significant portions of code originally in NTWeblocFile class, CocoaTech Open Source


#import <Cocoa/Cocoa.h>

@interface PDWeblocFile : NSObject {
	
	NSAttributedString* _attributedString;
    
    NSString* _displayName;
    NSURL* _url;
	
}

+ (NSString*) weblocExtension;

// can be NSString or NSAttributedString
+ (id)weblocWithString:(id)string;
+ (id)weblocWithURL:(NSURL*)url;

- (id) initWithContentsOfFile:(NSString*)filename;

- (void)setDisplayName:(NSString*)name;
- (NSString*)displayName;

- (void)setURL:(NSURL*)url;
- (NSURL*) url;

- (void)setString:(id)string;

- (BOOL)isHTTPWeblocFile;
- (BOOL)isServerWeblocFile;

- (BOOL)writeToFile:(NSString*)path;

- (NSData*)dragDataWithEntries:(NSArray*)entries;

@end

#pragma mark -

@interface WLDragMapEntry : NSObject
{
    OSType _type;
    ResID _resID;
}

+ (id)entryWithType:(OSType)type resID:(int)resID;

- (OSType)type;
- (ResID)resID;
- (NSData*)entryData;

@end
