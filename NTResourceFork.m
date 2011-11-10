
#import <SproutedUtilities/NTResourceFork.h>
#import <SproutedUtilities/NSString+NDCarbonUtilities.h>

// Source: ?  CocoaTech Open Source I think.
// needed for the PDWeblocFile class, a derivative of CocoaTech open source.

@implementation NTResourceFork

+ (id)resourceForkForReadingAtURL:(NSURL *)aURL
{
    return [[[self alloc] initForReadingAtURL:aURL] autorelease];
}

+ (id)resourceForkForWritingAtURL:(NSURL *)aURL
{
    return [[[self alloc] initForWritingAtURL:aURL] autorelease];
}

+ (id)resourceForkForReadingAtPath:(NSString *)aPath
{
    return [[[self alloc] initForReadingAtPath:aPath] autorelease];
}

+ (id)resourceForkForWritingAtPath:(NSString *)aPath
{
    return [[[self alloc] initForWritingAtPath:aPath] autorelease];
}

- (id)initForReadingAtURL:(NSURL *)aURL
{
    return [self initForPermission:fsRdPerm AtURL:aURL];
}

- (id)initForWritingAtURL:(NSURL *)aURL
{
    return [self initForPermission:fsWrPerm AtURL:aURL];
}

- (id)initForPermission:(char)aPermission AtURL:(NSURL *)aURL
{
    return [self initForPermission:aPermission AtPath:[aURL path]];
}

- (id)initForPermission:(char)aPermission AtPath:(NSString *)aPath
{
    OSErr theError = !noErr;
    FSRef theFsRef, theParentFsRef;

    if( self = [self init] )
    {
        /*
         * if write permission then create resource fork
         */
        if ((aPermission & 0x06) != 0)		// if write permission
        {
            if ( [[aPath stringByDeletingLastPathComponent] getFSRef:&theParentFsRef] )
            {
                unsigned int theNameLength;
                unichar theUnicodeName[PATH_MAX];
                NSString *theName;

                theName = [aPath lastPathComponent];
                theNameLength = [theName length];

                if( theNameLength <= PATH_MAX )
                {
                    [theName getCharacters:theUnicodeName range:NSMakeRange(0, theNameLength)];

                    FSCreateResFile(&theParentFsRef, theNameLength, theUnicodeName, 0, NULL, NULL, NULL);		// doesn't replace if already exists

                    theError = ResError();

                    if (theError == noErr || theError == dupFNErr)
                    {
                        [aPath getFSRef:&theFsRef];
                        fileReference = FSOpenResFile(&theFsRef, aPermission);
                        theError = fileReference > 0 ? ResError() : !noErr;
                    }
                }
                else
                    theError = !noErr;
            }
        }
        else		// dont have write permission
        {
            [aPath getFSRef:&theFsRef];
            fileReference = FSOpenResFile ( &theFsRef, aPermission );
            theError = fileReference > 0 ? ResError( ) : !noErr;
        }
    }

    if( noErr != theError && theError != dupFNErr )
    {
        [self release];
        self = nil;
    }

    return self;
}

- (id)initForReadingAtPath:(NSString *)aPath
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:aPath])
        return [self initForPermission:fsRdPerm AtURL:[NSURL fileURLWithPath:aPath]];

    return nil;
}

- (id)initForWritingAtPath:(NSString *)aPath
{
    return [self initForPermission:fsWrPerm AtURL:[NSURL fileURLWithPath:aPath]];
}

- (void)dealloc
{
    CloseResFile(fileReference);
    [super dealloc];
}

- (BOOL)addData:(NSData *)aData type:(ResType)aType Id:(short)anID name:(NSString *)aName
{
    Handle theResHandle;
    BOOL result = NO;

    if ([self removeType:aType Id:anID])
    {
        // copy NSData's bytes to a handle
        if (noErr == PtrToHand([aData bytes], &theResHandle, [aData length]))
        {
            Str255 thePName = "\p";
            short thePreviousRefNum;

            // set the current res file
            thePreviousRefNum = CurResFile();
            UseResFile(fileReference);

            if (aName)
                CopyCStringToPascal([aName lossyCString], thePName);

            HLock(theResHandle);
            AddResource(theResHandle, aType, anID, thePName);
            HUnlock( theResHandle );

            // handle is now owned by the resource manager
            // DisposeHandle( theResHandle );
            
            result = ( ResError( ) == noErr );

            // restore resFile
            UseResFile(thePreviousRefNum);
        }
    }

    return result;
}

- (NSData *)dataForType:(ResType)aType Id:(short)anID
{
    NSData* theData = nil;
    short thePreviousRefNum;

    // set the current res file
    thePreviousRefNum = CurResFile();
    UseResFile(fileReference);
    
    if (noErr == ResError())
    {
        Handle theResHandle = Get1Resource(aType, anID);

        if (theResHandle && (noErr == ResError()))
        {
            HLock(theResHandle);
            theData = [NSData dataWithBytes:*theResHandle length:GetHandleSize(theResHandle)];
            HUnlock(theResHandle);
        }

        if (theResHandle)
            ReleaseResource(theResHandle);
    }

    // restore resFile
    UseResFile(thePreviousRefNum);

    return theData;
}

- (BOOL)addString:(NSString *)aString type:(ResType)aType Id:(short)anID name:(NSString *)aName
{
    unsigned int theLength;

    theLength = [aString length];

    if (theLength < 256)
    {
        NSMutableData* theData;

        theData = [NSMutableData dataWithLength:1];
        *((char*)[theData mutableBytes]) = (char)theLength;
        [theData appendData:[aString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
        
        return [self addData:theData type:aType Id:anID name:aName];
    }
    else
        return NO;
}

- (NSString *)stringForType:(ResType)aType Id:(short)anID
{
    NSData* theData;

    theData = [self dataForType:aType Id:anID];

    return theData ? [NSString stringWithCString:([theData bytes] + 1) length:[theData length] - 1] : nil;
}

- (BOOL)removeType:(ResType)aType Id:(short)anID
{
    Handle theResHandle;
    OSErr theErr;
    short thePreviousRefNum;

    // set the current res file
    thePreviousRefNum = CurResFile();
    UseResFile(fileReference);
    
    theResHandle = Get1Resource(aType, anID);
    theErr = ResError();
    if (theResHandle && theErr == noErr)
    {
        RemoveResource(theResHandle);		// Disposed of in current resource file
        theErr = ResError();
    }

    // restore resFile
    UseResFile(thePreviousRefNum);
    
    return (theErr == noErr);
}

@end
