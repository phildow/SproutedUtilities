//
//  NSWorkspace_PDCategories.m
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


#import <SproutedUtilities/NSWorkspace_PDCategories.h>

#import <SproutedUtilities/NDAlias.h>
#import <SproutedUtilities/NDAlias+AliasFile.h>

// UTType Conformity (parents)
static NSString *kConformsToKey = @"UTTypeConformsTo";

// Finder label colors
/*
static BOOL	sFinderColorsInited = NO;
static NSColor* sFinderColors[8] = { nil, nil, nil, nil, nil, nil, nil, nil }; 
static void initFinderColors(void)
{
	sFinderColors[0] = [NSColor clearColor]	;
	sFinderColors[1] = [NSColor colorWithCalibratedRed:(168.0/255.0) green:(168.0/255.0) blue:(168.0/255.0) alpha:1.0]	;	// gray
	sFinderColors[2] = [NSColor colorWithCalibratedRed:(174.0/255.0) green:(216.0/255.0) blue:( 65.0/255.0) alpha:1.0]	;	// green
	sFinderColors[3] = [NSColor colorWithCalibratedRed:(194.0/255.0) green:(138.0/255.0) blue:(217.0/255.0) alpha:1.0]	;	// purple
	sFinderColors[4] = [NSColor colorWithCalibratedRed:( 92.0/255.0) green:(160.0/255.0) blue:(255.0/255.0) alpha:1.0]	;	// blue
	sFinderColors[5] = [NSColor colorWithCalibratedRed:(235.0/255.0) green:(219.0/255.0) blue:( 65.0/255.0) alpha:1.0]	;	// yellow
	sFinderColors[6] = [NSColor colorWithCalibratedRed:(252.0/255.0) green:( 99.0/255.0) blue:( 89.0/255.0) alpha:1.0]	;	// red
	sFinderColors[7] = [NSColor colorWithCalibratedRed:(246.0/255.0) green:(170.0/255.0) blue:( 62.0/255.0) alpha:1.0]	;	// orange
	
	sFinderColorsInited = YES	;
}
*/

// label code is from the osxutils project, Copyright (C) 2003-2005 Sveinbjorn Thordarson <sveinbt@hi.is>
// it has been modified to fix inconsistencies.
// use new NSWorkspace APIs

static OSErr FSpGetPBRec(const FSSpec* fileSpec, CInfoPBRec *infoRec)
{
	CInfoPBRec                  myInfoRec = {0};
	OSErr                       err = noErr;

	myInfoRec.hFileInfo.ioNamePtr = (unsigned char *)fileSpec->name;
	myInfoRec.hFileInfo.ioVRefNum = fileSpec->vRefNum;
	myInfoRec.hFileInfo.ioDirID = fileSpec->parID;
	
	err = PBGetCatInfoSync(&myInfoRec);
    if (err == noErr)
		*infoRec = myInfoRec;
		
	return err;
}

static void SetLabelInFlags (short *flags, short labelNum)
{
    short myFlags = *flags;

    //nullify former label
        /* Is Orange */
	if (myFlags & 2 && myFlags & 8 && myFlags & 4)
	{
		myFlags -= 2;
		myFlags -= 8;
		myFlags -= 4;
	}
        /* Is Red */
	if (myFlags & 8 && myFlags & 4)
	{
		myFlags -= 8;
		myFlags -= 4;
	}
        /* Is Yellow */
	if (myFlags & 8 && myFlags & 2)
	{
		myFlags -= 8;
		myFlags -= 2;
	}
        
        /* Is Blue */
	if (myFlags & 8)
	{
		myFlags -= 8;
	}
        
        /* Is Purple */
	if (myFlags & 2 && myFlags & 4)
	{
		myFlags -= 2;
		myFlags -= 4;
	}
        
        /* Is Green */
	if (myFlags & 4)
	{
		myFlags -= 4;
	}
        
        /* Is Gray */
	if (myFlags & 2)
	{
		myFlags -= 2;
	}
        
	//OK, now all the labels should be at off
	//create flags with the desired label
	switch(labelNum)
	{
		case 0://None
			break;
		//case 1:
		case 6:
			myFlags += 8;
			myFlags += 4;
			break;
		//case 2:
		case 7:
			myFlags += 2;
			myFlags += 8;
			myFlags += 4;
			break;
		//case 3:
		case 5:
			myFlags += 2;
			myFlags += 8;
			break;
		//case 4:
		case 2:
			myFlags += 4;
			break;
		//case 5:
		case 4:
			myFlags += 8;
			break;
		//case 6:
		case 3:
			myFlags += 2;
			myFlags += 4;
			break;
		//case 7:
		case 1:
			myFlags += 2;
			break;
	}
        
    //now, to set the desired label
	*flags = myFlags;
}

static short GetLabelNumber (short flags)
{
        /* Is Orange */		// GREEN
	if (flags & 2 && flags & 8 && flags & 4)
            return 2;

        /* Is Red */		// GREY
	if (flags & 8 && flags & 4)
            return 1;

        /* Is Yellow */		// PURPLE
	if (flags & 8 && flags & 2)
            return 3;
        
        /* Is Blue */		// YELLOW
	if (flags & 8)
            return 5;
        
        /* Is Purple */		// RED
	if (flags & 2 && flags & 4)
            return 6;
        
        /* Is Green */		// BLUE
	if (flags & 4)
            return 4;
			
        /* Is Gray */		// ORANGE
	if (flags & 2)
            return 7;

    return 0;
}

@implementation NSWorkspace (PDCategories)

- (NSString*) UTIForFile:(NSString*)path
{
	FSRef		fsRefToItem;
	FSPathMakeRef( (const UInt8 *)[path fileSystemRepresentation], &fsRefToItem, NULL );

	CFStringRef itemUTI = NULL;
	LSCopyItemAttribute( &fsRefToItem, kLSRolesAll, kLSItemContentType, (CFTypeRef *)&itemUTI );
	
	if ( itemUTI == NULL )
	{
		NSAppleEventDescriptor *ed;
		NSAppleScript *script = [[NSAppleScript alloc] 
				initWithSource:[NSString stringWithFormat:@"do shell script \"/usr/bin/file -b '%@'\"", path]];
		
		ed = [script executeAndReturnError:nil];
		if ( ed )
		{
			// grab the location of the file according to iTunes import
			NSString *scriptReturn = [ed stringValue];
			
			if ( [scriptReturn rangeOfString:@"text" options:NSCaseInsensitiveSearch].location != NSNotFound )
				itemUTI = CFStringCreateCopy(NULL,kUTTypePlainText);
		}
	}
	
	if ( itemUTI == NULL )
		return nil;
	else
		return [(NSString*)itemUTI autorelease];
}

- (NSArray*) allParentsAsArrayForUTI:(NSString*)uti
{
	if ( uti == nil )
		return nil;
	
	// the type declaration
	NSDictionary *utiDeclaration = [(NSDictionary*)UTTypeCopyDeclaration((CFStringRef)uti) autorelease];
	if ( utiDeclaration == nil )
		return nil;
	
	// the parents
	id conformsTo = [utiDeclaration objectForKey:kConformsToKey];
	if ( conformsTo == nil )
		return nil;
	
	// if the parent is singular, it's a string, recast as array
	if ( ![conformsTo isKindOfClass:[NSArray class]] )
		conformsTo = [NSArray arrayWithObject:conformsTo];
	
	NSString *aParentUTI;
	NSEnumerator *enumerator = [conformsTo objectEnumerator];
	NSMutableArray *myUTIs = [NSMutableArray array];
	
	// recursively iterate through each parent, deriving the grandparents
	while ( aParentUTI = [enumerator nextObject] )
	{
		// add the current parent to the array
		[myUTIs addObject:aParentUTI];
		
		// get the grandparents and append that
		NSArray *parentsUp = [self allParentsAsArrayForUTI:aParentUTI];
		if ( parentsUp != nil ) [myUTIs addObjectsFromArray:parentsUp];
	}
	
	return myUTIs;
}

- (NSString*) allParentsForUTI:(NSString*)uti
{
	if ( uti == nil )
		return nil;
	
	// the type declaration
	NSDictionary *utiDeclaration = [(NSDictionary*)UTTypeCopyDeclaration((CFStringRef)uti) autorelease];
	if ( utiDeclaration == nil )
		return nil;
	
	// the parents
	id conformsTo = [utiDeclaration objectForKey:kConformsToKey];
	if ( conformsTo == nil )
		return nil;
	
	// if the parent is singular, it's a string, recast as array
	if ( ![conformsTo isKindOfClass:[NSArray class]] )
		conformsTo = [NSArray arrayWithObject:conformsTo];
	
	NSString *aParentUTI;
	NSEnumerator *enumerator = [conformsTo objectEnumerator];
	NSMutableString *myUTIs = [NSMutableString string];
	
	// recursively iterate through each parent, deriving the grandparents
	while ( aParentUTI = [enumerator nextObject] )
	{
		// add the current parent to the string
		[myUTIs appendString:[NSString stringWithFormat:@"%@,",aParentUTI]];
		
		// get the grandparents and append that
		NSString *parentsUp = [self allParentsForUTI:aParentUTI];
		if ( parentsUp != nil )
			[myUTIs appendString:[NSString stringWithFormat:@"%@,",parentsUp]];
	}
	
	// remove the trailing comma
	if ( [myUTIs characterAtIndex:[myUTIs length]-1] == ',' )
		[myUTIs deleteCharactersInRange:NSMakeRange([myUTIs length]-1,1)];
	
	return myUTIs;
}

#pragma mark -

- (BOOL) file:(NSString*)path conformsToUTI:(NSString*)uti
{
	if ( path == nil )
		return NO;
	
	NSString *utiAtPath = [self UTIForFile:path];
	if ( utiAtPath == nil )
		return NO;
	
	return ( UTTypeConformsTo( (CFStringRef)utiAtPath, (CFStringRef)uti ) );
}

- (BOOL) file:(NSString*)path confromsToUTIInArray:(NSArray*)anArray
{
	if ( path == nil )
		return NO;
	
	NSString *utiAtPath = [self UTIForFile:path];
	if ( utiAtPath == nil )
		return NO;
	
	BOOL conforms = NO;
	NSString *aUTI;
	NSEnumerator *enumerator = [anArray objectEnumerator];
	
	while ( aUTI = [enumerator nextObject] )
	{
		if ( UTTypeConformsTo( (CFStringRef)utiAtPath, (CFStringRef)aUTI ) )
		{
			conforms = YES;
			break;
		}
	}
	
	return conforms;
}

#pragma mark -

- (NSString*) mdTitleForFile:(NSString*)filename
{
	// have a look at the metadata for the file, returning the provided title if one exists
	
	NSString *title = nil;
	
	MDItemRef metaData = MDItemCreate(NULL,(CFStringRef)filename);
	if ( metaData != NULL ) 
	{
		// grab the title
		title = [(NSString*)MDItemCopyAttribute(metaData,kMDItemTitle) autorelease];
		
		// use the md display name
		if ( title == nil )
			title = [(NSString*)MDItemCopyAttribute(metaData,kMDItemDisplayName) autorelease];
			
		// use the display name at path
		if ( title == nil )
			title = [[filename lastPathComponent] stringByDeletingPathExtension];
			
		// clean up
		CFRelease(metaData);
	}
	else 
	{
		// use the display name at path
		title = [[filename lastPathComponent] stringByDeletingPathExtension];
	}
	
	return title;
}

- (NSString*) mdTitleAndComposerForAudioFile:(NSString*)filename 
{
	// have a look at the metadata for the file, 
	// author and name, or use display name
	
	NSMutableString *returnString = [[NSMutableString allocWithZone:[self zone]] init];
	
	MDItemRef metaData = MDItemCreate(NULL,(CFStringRef)filename);
	if ( metaData != NULL ) {
		
		NSString *title = (NSString*)MDItemCopyAttribute(metaData,kMDItemTitle);
		NSArray *authors = (NSArray*)MDItemCopyAttribute(metaData,kMDItemAuthors);
		NSString *composer = (NSString*)MDItemCopyAttribute(metaData,kMDItemComposer);
		
		if ( title != nil ) {
			
			if ( authors != nil )
				[returnString appendFormat:@"%@ - ", [authors componentsJoinedByString:@", "]];
			else if ( composer != nil )
				[returnString appendFormat:@"%@ - ", composer];
			
			[returnString appendString:title];
		}
		else {
			// use the display name no path
			[returnString appendString:[[filename lastPathComponent] stringByDeletingPathExtension]];
		}
		
		// clean up
		CFRelease(metaData);
	}
	else {
		// use the display name no path
		[returnString appendString:[[filename lastPathComponent] stringByDeletingPathExtension]];
	}
	
	return [returnString autorelease];
}


#pragma mark -

- (BOOL) fileIsVCF:(NSString*)filePath 
{
	NSString *app, *fileType;
	[[NSWorkspace sharedWorkspace] getInfoForFile:filePath application:&app type:&fileType];
	
	return ( [fileType isEqual:@"vcf"] );
}

- (BOOL) fileIsClipping:(NSString*)filePath 
{	
	NSString *app, *fileType;
	[[NSWorkspace sharedWorkspace] getInfoForFile:filePath application:&app type:&fileType];
	
	return ( [fileType isEqual:@"textClipping"] );
}

#pragma mark -

- (short)finderLabelColorForFile:(NSString*)inPath 
{
	// 0 = no color, 1 = gray, 2 = green, 3 = purple, 4 = blue, 5 = yellow, 6 = red, 7 = orange
	
	CFURLRef       url;
	FSRef          fsRef;
	BOOL           ret;
	FSCatalogInfo  cinfo;
	
	//if (!sFinderColorsInited)
	//	initFinderColors();

	url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)inPath, kCFURLPOSIXPathStyle, FALSE);
	if (!url)
	    return 0;
		
	ret = CFURLGetFSRef(url, &fsRef);
	CFRelease(url);
	
	if (ret && (FSGetCatalogInfo(&fsRef, kFSCatInfoFinderInfo, &cinfo, NULL, NULL, NULL) == noErr))	
		return (((FileInfo*)&cinfo.finderInfo)->finderFlags & kColor) >> kIsOnDesk;
		//return sFinderColors[ (((FileInfo*)&cinfo.finderInfo)->finderFlags & kColor) >> kIsOnDesk ] ;
	else
		return 0;
}

- (BOOL) setLabel:(short)labelNum forFile:(NSString*)path
{
    OSErr		err = noErr;
    FSRef		fileRef;
    FSSpec		fileSpec;
    BOOL		isFldr;
    //short       currentLabel;
    FInfo       finderInfo;
    CInfoPBRec  infoRec;

	// make sure a file exists at the specified path
	if ( path == nil || ![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isFldr] )
		return NO;
	
	//get file reference from path
	err = FSPathMakeRef((const UInt8 *)[path fileSystemRepresentation], &fileRef, NULL);
	if (err != noErr)
	{
		NSLog(@"%@ %s - unable to get file reference for path %@", [self className], _cmd, path );
		return NO;
	}

	//retrieve filespec from file ref
	err = FSGetCatalogInfo (&fileRef, 0, NULL, NULL, &fileSpec, NULL);
	if (err != noErr)
	{
		NSLog(@"%@ %s - unable to get file spec for path %@", [self className], _cmd, path );
		return NO;
	}
	
    ///////////////////////// IF SPECIFIED FILE IS A FOLDER /////////////////////////
	
    if ( isFldr )
    {
        //Get HFS record
        FSpGetPBRec(&fileSpec, &infoRec);
        
        //get current label
		//currentLabel = GetLabelNumber(infoRec.dirInfo.ioDrUsrWds.frFlags);
        
        //set new label into record
        SetLabelInFlags((short *)&infoRec.dirInfo.ioDrUsrWds.frFlags, labelNum);
        
        //fill in the requisite fields
        infoRec.hFileInfo.ioNamePtr = (unsigned char *)fileSpec.name;
		infoRec.hFileInfo.ioVRefNum = fileSpec.vRefNum;
		infoRec.hFileInfo.ioDirID = fileSpec.parID;
        
        //set the record
        PBSetCatInfoSync(&infoRec);
    }
    
    ///////////////////////// IF SPECIFIED FILE IS A REGULAR FILE /////////////////////////
	
    else
    {
        /* get the finder info */
        err = FSpGetFInfo (&fileSpec, &finderInfo);
        if (err != noErr) 
        {
			NSLog(@"%@ %s - unable to get finder info for path %@", [self className], _cmd, path );
			return NO;
        }
        
        //retrieve the label number of the file
        //currentLabel = GetLabelNumber(finderInfo.fdFlags);
        
        //if it's already set with the desired label we return
        //if (currentLabel == labelNum)
          //  return YES;
        
        //set the appropriate value in the flags field
        SetLabelInFlags((short*)&finderInfo.fdFlags, labelNum);
        
        //apply the settings to the file
        err = FSpSetFInfo (&fileSpec, &finderInfo);
        if (err != noErr)
        {
			NSLog(@"%@ %s - unable to set finder info for path %@", [self className], _cmd, path );
			return NO;
		}
    }
    
    return YES;
}

#pragma mark -

- (BOOL) moveToTrash:(NSString*)path
{
   int tag;
   return ( [[NSWorkspace sharedWorkspace] 
		performFileOperation:NSWorkspaceRecycleOperation
		source:[path stringByDeletingLastPathComponent] destination:@""
		files:[NSArray arrayWithObject:[path lastPathComponent]] tag:&tag] && tag == 0 );
}

- (NSString*) resolveForAliases:(NSString*)path {
	
	NSString *resolvedPath = nil;
	CFURLRef url;
	
	// return a nil string if there is no path
	if ( path == nil )
		return nil;
	
	url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)path, kCFURLPOSIXPathStyle, NO );
	if (url != NULL)
	{
		FSRef fsRef;
		if (CFURLGetFSRef(url, &fsRef))
		{
			Boolean targetIsFolder, wasAliased;
			if (FSResolveAliasFile (&fsRef, true /*resolveAliasChains*/, 
				&targetIsFolder, &wasAliased) == noErr )
			{
				if ( wasAliased )
				{
					CFURLRef resolvedUrl = CFURLCreateFromFSRef(NULL, &fsRef);
					if (resolvedUrl != NULL)
					{
						resolvedPath = (NSString*)
										CFURLCopyFileSystemPath(resolvedUrl,
										kCFURLPOSIXPathStyle);
						CFRelease(resolvedUrl);
					}
				}
				else
				{
					resolvedPath = [[NSString alloc] initWithString:path];
				}
			}
		}
		CFRelease(url);
	}
	 
	//if (resolvedPath==nil)
	//	resolvedPath = [[NSString alloc] initWithString:path];
	
	return [resolvedPath autorelease];
	
}

- (BOOL) createAliasForPath:(NSString*)targetPath toPath:(NSString*)destinationPath
{
	// actually create the link
	NDAlias *alias = [[NDAlias alloc] initWithPath:targetPath];
	if ( ![alias writeToFile:destinationPath] ) 
	{
		NSLog(@"%@ %s - unable to alias %@ to %@", [self className], _cmd, targetPath, destinationPath);
		return NO;
	}
	else
		return YES;
}

#pragma mark -

- (BOOL) canPlayFile:(NSString*)filename 
{
	NSString *extension = [filename pathExtension];
	NSArray *allFileTypes = [NSSound soundUnfilteredFileTypes];
	
	NSString *app = nil, *fileType = nil;
	
	[[NSWorkspace sharedWorkspace] getInfoForFile:filename application:&app type:&fileType];
	if ( [[fileType lowercaseString] isEqualToString:@"pdf"] 
			|| [[extension lowercaseString] isEqualToString:@"pdf"] ) 
		return NO; //pdf documents are a special case
	
	if ( [allFileTypes containsObject:extension] )
		return YES;
	else
		return NO;
}

- (BOOL) canWatchFile:(NSString*)filename 
{
	long quickTimeVersion = 0;
	NSString *extension = [filename pathExtension];
	NSArray *allFileTypes;
	NSString *app = nil, *fileType = nil;
	
	[[NSWorkspace sharedWorkspace] getInfoForFile:filename application:&app type:&fileType];
	if ( [[fileType lowercaseString] isEqualToString:@"pdf"] 
			|| [[extension lowercaseString] isEqualToString:@"pdf"] ) 
		return NO; //pdf documents are a special case
	
	if (Gestalt(gestaltQuickTime, &quickTimeVersion) || ((quickTimeVersion & 0xFFFFFF00) < 0x07008000))
	{
		allFileTypes = [NSMovie movieUnfilteredFileTypes];
		if ( [allFileTypes containsObject:extension] || [allFileTypes containsObject:fileType] )
			return YES;
		else
			return NO;
	}
	else
	{
		allFileTypes = [QTMovie movieFileTypes:QTIncludeCommonTypes];
		if ( [allFileTypes containsObject:extension] || [allFileTypes containsObject:fileType] )
			return YES;
		else
			return NO;
		//return [QTMovie canInitWithFile:filename];
	}
}

- (BOOL) canViewFile:(NSString*)filename
{
	NSString *app = nil, *fileType = nil;
	NSString *extension = [filename pathExtension];
	NSArray *allImageFileTypes = [NSImage imageFileTypes];
	
	[[NSWorkspace sharedWorkspace] getInfoForFile:filename application:&app type:&fileType];
	if ( !fileType || [fileType length] == 0 
			|| [[fileType lowercaseString] isEqualToString:@"pdf"] 
			|| [[extension lowercaseString] isEqualToString:@"pdf"] ) 
		return NO; //pdf documents are a special case
	
	return ( [allImageFileTypes containsObject:fileType] || [allImageFileTypes containsObject:extension] );
}

@end
