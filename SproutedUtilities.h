//
//  SproutedUtilities.h
//  SproutedUtilities
//
//  Created by Philip Dow on xx.
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

#include <SproutedUtilities/PDUtilityDefinitions.h>
#include <SproutedUtilities/PDUtilityFunctions.h>

#include <SproutedUtilities/NSObject_PDScriptingAdditions.h>
#include <SproutedUtilities/NSException_PDAdditions.h>
#include <SproutedUtilities/NSNotifications_ColloquyAdditions.h>
#include <SproutedUtilities/NSDate_PDAdditions.h>
#include <SproutedUtilities/NSText+PDAdditions.h>
#include <SproutedUtilities/NSObjectController+PDAdditions.h>
#include <SproutedUtilities/KBWordCountingTextStorage.h>
#include <SproutedUtilities/ZipUtilities.h>
#include <SproutedUtilities/PDTextClipping.h>
#include <SproutedUtilities/L0iPod.h>
#include <SproutedUtilities/AGKeychain.h>
#include <SproutedUtilities/PDWebArchive.h>
#include <SproutedUtilities/PDPowerManagement.h>

#include <SproutedUtilities/NDAlias.h>
#include <SproutedUtilities/NDAlias+AliasFile.h>
#include <SproutedUtilities/NDResourceFork.h>
#include <SproutedUtilities/NDResourceFork+OtherSorces.h>

#include <SproutedUtilities/PDFileTextContentExtractor.h>
#include <SproutedUtilities/SpotlightTextContentRetriever.h>

#include <SproutedUtilities/KFAppleScriptHandlerAdditionsCore.h>
#include <SproutedUtilities/KFASHandlerAdditions-TypeTranslation.h>

#include <SproutedUtilities/NSBezierPath_AMAdditons.h>
#include <SproutedUtilities/NSBezierPath_AMShading.h>
#include <SproutedUtilities/CTGradient.h>

#include <SproutedUtilities/MailMessageParser.h>
#include <SproutedUtilities/PDWebArchiveMiner.h>

#include <SproutedUtilities/PDWebDelegate.h>
#include <SproutedUtilities/PDWeblocFile.h>

#include <SproutedUtilities/NTResourceFork.h>
#include <SproutedUtilities/GTResourceFork.h>

#include <SproutedUtilities/NSTableView_PDCategory.h>
#include <SproutedUtilities/NSOutlineView_Extensions.h>
#include <SproutedUtilities/NSOutlineView_ProxyAdditions.h>

#include <SproutedUtilities/NSApplication+PDAdditions.h>
#include <SproutedUtilities/NSApplication_RelaunchAdditions.h>
#include <SproutedUtilities/NSString+NDCarbonUtilities.h>
#include <SproutedUtilities/NSString+PDStringAdditions.h>
#include <SproutedUtilities/NSURL+NDCarbonUtilities.h>
#include <SproutedUtilities/NSMutableAttributedString+PDAdditions.h>
#include <SproutedUtilities/NSMutableString+PDAdditions.h>
#include <SproutedUtilities/NSParagraphStyle_PDAdditions.h>
#include <SproutedUtilities/PDFDocument_PDCategory.h>
#include <SproutedUtilities/NSWorkspace_PDCategories.h>
#include <SproutedUtilities/ABRecord_PDAdditions.h>
#include <SproutedUtilities/NSColor_JournlerAdditions.h>
#include <SproutedUtilities/NSImage_PDCategories.h>
#include <SproutedUtilities/NSArray_PDAdditions.h>
#include <SproutedUtilities/NSManagedObjectContext_PDCategory.h>
#include <SproutedUtilities/NSManagedObject_PDCategory.h>
#include <SproutedUtilities/NSUserDefaults+PDDefaultsAdditions.h>

#include <SproutedUtilities/NSTBFTextBlock.h>
#include <SproutedUtilities/PDUTINameTransformer.h>
#include <SproutedUtilities/SproutedEmailer.h>
#include <SproutedUtilities/SproutedLabelConverter.h>