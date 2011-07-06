//
//  PDWebLoc.m
//  SproutedUtilities
//
//  Created by Philip Dow on 10/20/06.
//  Copyright Sprouted. All rights reserved.
//  Significant portions of code originally in NTWeblocFile class, CocoaTech Open Source
//	All inquiries should be directed to developer@journler.com
//

#import "PDWeblocFile.h"
#import <SproutedUtilities/NTResourceFork.h>
#import <SproutedUtilities/GTResourceFork.h>

static OSType kDragWeblocType = 'drag';
static OSType kURLWeblocType = 'url ';
static OSType kTEXTWeblocType = 'TEXT';
static OSType kRTFWeblocType = 'RTF ';
static OSType kUnicodeWeblocType = 'utxt';

static OSType kTEXTWeblocFileType = 'clpt';
//static OSType kWeblocFileCreator = 'MACS';

// =================================================================================
// types used inside a webloc file

// type  'TEXT' - just plain text "http://www.cocoatech.com"
// type  'url' - just plain text "http://www.cocoatech.com"
// type  'drag' - WLDragMapHeaderStruct with n WLDragMapEntries

#pragma options align=mac68k

typedef struct WLDragMapHeaderStruct
{
    long mapVersion;  // always 1
    long unused1;     // always 0
    long unused2;     // always 0
    short unused;
    short numEntries;   // number of repeating WLDragMapEntries
} WLDragMapHeaderStruct;

typedef struct WLDragMapEntryStruct
{
    OSType type;
    short unused;  // always 0
    ResID resID;   // always 128 or 256?
    long unused1;   // always 0
    long unused2;   // always 0
} WLDragMapEntryStruct;


// ---------------------------------------------------------------------------
#pragma mark -

@implementation PDWeblocFile

+ (NSString*) weblocExtension {
	static NSString *kWeblocExtension = @"webloc";
	return kWeblocExtension;
}

// can be NSString or NSAttributedString
+ (id)weblocWithString:(id)string
{
    PDWeblocFile* result = [[PDWeblocFile alloc] init];
    [result setString:string];
    return [result autorelease];
}

+ (id)weblocWithURL:(NSURL*)url
{
    PDWeblocFile* result = [[PDWeblocFile alloc] init];
    [result setURL:url];
    return [result autorelease];
}

- (id) initWithContentsOfFile:(NSString*)filename
{
	if ( self = [super init] )
	{
		// parse the resource file
		
		GTResourceFork *resourceFork = [[[GTResourceFork alloc] initWithContentsOfFile:filename] autorelease];
		
		if ( resourceFork == nil )
		{
			[self release];
			return nil;
		}
		
		ResType urlType = 'url ';
		//ResType urlnType = 'urln';
		
		if ( [resourceFork countOfResourcesOfType:urlType] == 0 )
		{
			[self release];
			return nil;
		}
		else
		{
			NSData *urlData/*, *titleData*/;
			NSArray *used = [resourceFork usedResourcesOfType:urlType];
			if ( [used count] == 0 )
			{
				[self release];
				return nil;
			}
			else
			{
				ResID rID = [[used objectAtIndex:0] intValue];
				urlData = [resourceFork dataForResource:rID ofType:urlType];
			}
			
			/*
			used = [resourceFork usedResourcesOfType:urlnType];
			if ( [used count] > 0 )
			{
				ResID rID = [[used objectAtIndex:0] intValue];
				titleData = [resourceFork dataForResource:rID ofType:urlnType];
			}
			*/
			
			if ( urlData == nil )
			{
				[self release];
				return nil;
			}
			else
			{
				NSString *urlString = [[[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding] autorelease];
				if ( urlString == nil )
				{
					[self release];
					return nil;
				}
				else
				{
					_url = [[NSURL URLWithString:urlString] retain];
					_displayName = [[[filename lastPathComponent] stringByDeletingPathExtension] retain];
				}
			}
		}
	}
	
	return self;
}

#pragma mark -

- (void)dealloc
{
    [_url release];
    [_displayName release];
    [_attributedString release];
    
    [super dealloc];
}

#pragma mark -

- (void)setDisplayName:(NSString*)name
{
    [_displayName autorelease];
    _displayName = [name retain];
}

- (NSString*)displayName
{
    return _displayName;
}

- (void)setURL:(NSURL*)url
{
    [_url autorelease];
    _url = [url retain];
}

- (NSURL*) url
{
	return _url;
}

- (void)setString:(id)string
{
    [_attributedString autorelease];

    // if a string, convert to attributed string
    if ([string isKindOfClass:[NSString class]])
        string = [[[NSAttributedString alloc] initWithString:string] autorelease];
    
    _attributedString = [string retain];
}

#pragma mark -

- (BOOL)isHTTPWeblocFile
{
    NSURL *url = [self url];
    
    if ([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"])
        return YES;
    
    return NO;
}

- (BOOL)isServerWeblocFile
{
    if ([self url])
    {
        if (![self isHTTPWeblocFile])
            return YES;
    }
    return NO;
}

#pragma mark -

- (BOOL)writeToFile:(NSString*)path
{
   
	// create a new file
	
	if ( ![[PDWeblocFile weblocExtension] isEqualToString:[path pathExtension]] )
		path = [path stringByAppendingPathExtension:[PDWeblocFile weblocExtension]];
	
	BOOL success = YES;
	NSMutableDictionary *fileAttrs = [NSMutableDictionary dictionaryWithCapacity:2];
	
	NTResourceFork* resource = [NTResourceFork resourceForkForWritingAtPath:path];
	if ( resource == nil ) {
		NSLog(@"%@ %s unable to create resource fork at path %@", [self className], _cmd, path);
		return NO;
	}
   
	NSMutableArray* entryArray = [NSMutableArray array];
	NSData* data, *displayData;

	if (_url)
	{
		NSString* urlString = [_url absoluteString];
		
		// add the 'TEXT' resource
		data = [NSData dataWithBytes:[urlString UTF8String] length:strlen([urlString UTF8String])];
		success = ( [resource addData:data type:kTEXTWeblocType Id:256 name:nil] && success );
		[entryArray addObject:[WLDragMapEntry entryWithType:kTEXTWeblocType resID:256]];

		// add the 'url ' resource
		success = ( [resource addData:data type:kURLWeblocType Id:256 name:nil] && success );
		[entryArray addObject:[WLDragMapEntry entryWithType:kURLWeblocType resID:256]];
		
		// add the 'urln' resource
		if ( _displayName != nil )
			displayData = [NSData dataWithBytes:[_displayName UTF8String] length:strlen([urlString UTF8String])];
		else
			displayData = data;
		
		success = ( [resource addData:displayData type:'urln' Id:256 name:nil] && success );
		[entryArray addObject:[WLDragMapEntry entryWithType:'urln' resID:256]];

		// add the 'drag' resource
		success = ( [resource addData:[self dragDataWithEntries:entryArray] type:kDragWeblocType Id:128 name:nil] && success );

		// set the type and creator
		if ([self isHTTPWeblocFile])
			[fileAttrs setValue:[NSNumber numberWithUnsignedLong:kInternetLocationHTTP] forKey:NSFileHFSTypeCode];
		else
			[fileAttrs setValue:[NSNumber numberWithUnsignedLong:kInternetLocationGeneric] forKey:NSFileHFSTypeCode];
		
		// set the type and creator
		[fileAttrs setValue:[NSNumber numberWithUnsignedLong:kInternetLocationCreator] forKey:NSFileHFSCreatorCode];
		success = ( [[NSFileManager defaultManager] changeFileAttributes:fileAttrs atPath:path] && success );
	}
	else if (_attributedString)
	{
		// **** SNG 666 ****
		// This code doesn't work 100%, the Finder says the text clipping file is damaged.  I didn't add the 'ustl' and 'styl' resouces since I don't know the format
		//This format is bullshit anyway.  What's the purpose of creating a file in an proprietary format?

		const unsigned bufferSize = 1024*10;
		unichar buffer[bufferSize];
		int length;

		// add the 'TEXT' resource
		data = [NSData dataWithBytes:[[_attributedString string] UTF8String] length:strlen([[_attributedString string] UTF8String])];
		success = ( [resource addData:data type:kTEXTWeblocType Id:256 name:nil] && success );
		[entryArray addObject:[WLDragMapEntry entryWithType:kTEXTWeblocType resID:256]];

		// add the 'RTF ' resource
		data = [_attributedString RTFFromRange:NSMakeRange(0,[_attributedString length]) documentAttributes:nil];
		success = ( [resource addData:data type:kRTFWeblocType Id:256 name:nil] && success );
		[entryArray addObject:[WLDragMapEntry entryWithType:kRTFWeblocType resID:256]];

		// add the 'utxt' resource
		length = MIN([_attributedString length], bufferSize);
		[[_attributedString string] getCharacters:buffer range:NSMakeRange(0, length)];
		data = [NSData dataWithBytes:buffer length:length];
		success = ( [resource addData:data type:kUnicodeWeblocType Id:256 name:nil] && success );
		[entryArray addObject:[WLDragMapEntry entryWithType:kUnicodeWeblocType resID:256]];

		// add the 'drag' resource
		success = ( [resource addData:[self dragDataWithEntries:entryArray] type:kDragWeblocType Id:128 name:nil] && success );

		// set the type and creator
		[fileAttrs setValue:[NSNumber numberWithUnsignedLong:kTEXTWeblocFileType] forKey:NSFileHFSTypeCode];
		[fileAttrs setValue:[NSNumber numberWithUnsignedLong:kInternetLocationCreator] forKey:NSFileHFSCreatorCode];
		success = ( [[NSFileManager defaultManager] changeFileAttributes:fileAttrs atPath:path] && success );
	   
	}
	
	return success;
}

#pragma mark -

- (NSData*)dragDataWithEntries:(NSArray*)entries
{
    NSMutableData *result;
    WLDragMapHeaderStruct header;
    NSEnumerator *enumerator = [entries objectEnumerator];
    WLDragMapEntry *entry;
    
    // zero the structure
    memset(&header, 0, sizeof(WLDragMapHeaderStruct));

    header.mapVersion = 1;
    header.numEntries = [entries count];

    result = [NSMutableData dataWithBytes:&header length:sizeof(WLDragMapHeaderStruct)];

    while (entry = [enumerator nextObject])
        [result appendData:[entry entryData]];

    return result;
}


@end

// ---------------------------------------------------------------------------
#pragma mark -

@implementation WLDragMapEntry

- (id)initWithType:(OSType)type resID:(int)resID;
{
    self = [super init];

    _type = type;
    _resID = resID;

    return self;
}

+ (id)entryWithType:(OSType)type resID:(int)resID;
{
    WLDragMapEntry* result = [[WLDragMapEntry alloc] initWithType:type resID:resID];

    return [result autorelease];
}

- (OSType)type;
{
    return _type;
}

- (ResID)resID;
{
    return _resID;
}

- (NSData*)entryData;
{
    WLDragMapEntryStruct result;

    // zero the structure
    memset(&result, 0, sizeof(result));
    
    result.type = _type;
    result.resID = _resID;

    return [NSData dataWithBytes:&result length:sizeof(result)];
}

@end
