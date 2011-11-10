//
//  NSWorkspace_PDCategories.h
//  SproutedUtilities
//
//  Created by Philip Dow on 9/9/06.
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
#import <QTKit/QTKit.h>

// label code is from the osxutils project, Copyright (C) 2003-2005 Sveinbjorn Thordarson <sveinbt@hi.is>
// it has been modified to fix inconsistencies.
// use new NSWorkspace APIs

static short GetLabelNumber (short flags);
static void SetLabelInFlags (short *flags, short labelNum);
static OSErr FSpGetPBRec(const FSSpec* fileSpec, CInfoPBRec *infoRec);


@interface NSWorkspace (PDCategories)

- (NSString*) UTIForFile:(NSString*)path;
- (NSString*) allParentsForUTI:(NSString*)uti;
- (NSArray*) allParentsAsArrayForUTI:(NSString*)uti;

- (BOOL) file:(NSString*)path conformsToUTI:(NSString*)uti;
- (BOOL) file:(NSString*)path confromsToUTIInArray:(NSArray*)anArray;

- (short) finderLabelColorForFile:(NSString*)inPath;
- (BOOL) setLabel:(short)labelNum forFile:(NSString*)path;

- (BOOL) fileIsVCF:(NSString*)filePath;
- (BOOL) fileIsClipping:(NSString*)filePath;

- (BOOL) moveToTrash:(NSString*)path;
- (NSString*) resolveForAliases:(NSString*)path;
- (BOOL) createAliasForPath:(NSString*)targetPath toPath:(NSString*)destinationPath;

- (NSString*) mdTitleForFile:(NSString*)filename;
- (NSString*) mdTitleAndComposerForAudioFile:(NSString*)filename;

- (BOOL) canPlayFile:(NSString*)filename;
- (BOOL) canWatchFile:(NSString*)filename;
- (BOOL) canViewFile:(NSString*)filename;

@end
