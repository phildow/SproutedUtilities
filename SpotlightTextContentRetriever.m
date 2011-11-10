//
//  SpotlightTextContentRetriever.m
//  SpotInside
//
//  Created by Masatoshi Nishikata on 06/11/22.
//  Copyright 2006 www.oneriver.jp. All rights reserved.
//


#import <Carbon/Carbon.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreFoundation/CFPlugInCOM.h>

#import <SproutedUtilities/NSWorkspace_PDCategories.h>
#import <SproutedUtilities/SpotlightTextContentRetriever.h>

//#import "TEC.h"
//#import "JapaneseString.h"


typedef struct PlugInInterfaceStruct {
    IUNKNOWN_C_GUTS;
	Boolean (*GetMetadataForFile)(void* myInstance, 
								  CFMutableDictionaryRef attributes, 
								  CFStringRef contentTypeUTI,
								  CFStringRef pathToFile);
	
} MDImporterInterfaceStruct;


static MDImporterInterfaceStruct **mdimporterInterface = nil;

@implementation SpotlightTextContentRetriever

static NSArray* mdimporterArray = nil;
static NSArray* unloadedMDImporterArray = nil;

static NSDictionary* contentTypesForMDImporter = nil;

static NSMutableDictionary* converters_ = nil;
static int osversion = 0;

+ (void)initialize
{
    if ( self == [SpotlightTextContentRetriever class] ) {
	
		converters_ = [[NSMutableDictionary alloc] init];
		osversion = [self OSVersion];
		
		if( mdimporterArray == nil )
			[self loadPlugIns];
    }
}

+(BOOL)loadPlugIns
{
	
	// Get and store MDImporter list	
	NSTask *task = [[NSTask alloc] init];
	NSPipe *messagePipe = [NSPipe pipe];
	
	[task setLaunchPath:@"/usr/bin/mdimport"];
	[task setArguments:[NSArray arrayWithObjects: @"-L" ,nil]];
	
	
	[task setStandardError : messagePipe];				
	[task launch];
	[task waitUntilExit];
	
	
	
	NSData *messageData = [[messagePipe fileHandleForReading] availableData]; 
	
	
	NSString* message;
	message = [[[NSString alloc] initWithData:messageData
									 encoding:NSUTF8StringEncoding] autorelease];
	
	[task release];
	
	
	
	// Cut unwanted string
	
	NSRange firstReturn = [message rangeOfString:@"(\n"];
	if( firstReturn.location == NSNotFound )
	{
		mdimporterArray = [[NSArray array] retain];
	}else
	{
		
		NSString* arrayStr = [message substringFromIndex:  firstReturn.location ];
		
		
		// Convert string to array
		
		NSData* data = [arrayStr dataUsingEncoding:NSASCIIStringEncoding];
		NSMutableArray *array = [NSPropertyListSerialization propertyListFromData:data 
																 mutabilityOption:NSPropertyListMutableContainers
																		   format:nil errorDescription:nil];
		
		
		if( array == nil ){
			NSLog(@"Parse Error");
			return NO;
		}
		
		
		
		//sortMDImporterArray
		NSMutableArray* sortedArray = [NSMutableArray array];
		int hoge;
		
		//(1) ~/Library/Spotlight/
		NSString* userFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Spotlight"];
		
		for( hoge = 0; hoge < [array count]; hoge++ )
		{
			NSString* aStr = [array objectAtIndex:hoge];
			if( [aStr hasPrefix: userFolder] )
			{
				[sortedArray addObject: aStr];
			}
		}
		
		
		//(2) /Library/Spotlight/
		NSString* pluginFolder = @"/Library/Spotlight/";
		for( hoge = 0; hoge < [array count]; hoge++ )
		{
			NSString* aStr = [array objectAtIndex:hoge];
			if( [aStr hasPrefix: pluginFolder] )
			{				
				[sortedArray addObject: aStr];
			}
		}
		
		//(3) /System/Library/Spotlight/
		NSString* sysPluginFolder = @"/System/Library/Spotlight";
		for( hoge = 0; hoge < [array count]; hoge++ )
		{
			NSString* aStr = [array objectAtIndex:hoge];
			if( [aStr hasPrefix: sysPluginFolder] )
			{				
				[sortedArray addObject: aStr];
			}
		}
		
		
		//(4) others
		[array removeObjectsInArray: sortedArray];
		[sortedArray addObjectsFromArray: array];
		
		
		
		// exclude dynamic plugins ... check CFPlugInDynamicRegistration
		NSMutableArray* unloadedArray = [NSMutableArray array];
		
		for( hoge = 0; hoge < [sortedArray count]; hoge++ )
		{
			NSString* aStr = [sortedArray objectAtIndex:hoge];
			
			CFTypeRef dynamicValue = [[NSBundle bundleWithPath:aStr] objectForInfoDictionaryKey: @"CFPlugInDynamicRegistration"];
			
			
			BOOL removeFlag = NO;
			
			
			if( CFGetTypeID(dynamicValue) == CFBooleanGetTypeID()  )
			{
				
				removeFlag = CFBooleanGetValue(dynamicValue);
				
				
			}else if( CFGetTypeID(dynamicValue) == CFStringGetTypeID()  )
			{
				
				removeFlag = ( [[(NSString*)dynamicValue lowercaseString] isEqualToString:@"yes"] ? YES:NO);
			}
			
			
			if( removeFlag )
			{		
				[unloadedArray addObject:aStr];
				[sortedArray removeObjectAtIndex:hoge];
			}
			
			
		}
		
		mdimporterArray = [[NSArray alloc] initWithArray:sortedArray];
		unloadedMDImporterArray = [[NSArray alloc] initWithArray:unloadedArray];
		
		
		// Read value for key:CFBundleDocumentTypes in Info.plist
		// Get one item and check if it has key:CFBundleTypeRole value:MDImporter  
		// Read the value for key:LSItemContentTypes
		// set the value to contentTypesForMDImporter 
		
		NSMutableDictionary* contentTypesForMDImporterMutableDictionary = [[NSMutableDictionary alloc] init];
		
		for( hoge = 0; hoge < [mdimporterArray count]; hoge++ )
		{
			NSString* aStr = [mdimporterArray objectAtIndex:hoge];
			
			id value = [[NSBundle bundleWithPath:aStr] objectForInfoDictionaryKey: @"CFBundleDocumentTypes"];
			if( value != nil )
			{
				if( [value isKindOfClass:[NSArray class]] && [value count] >0 )
				{
					int piyo=0;
					for( piyo = 0; piyo < [value count] ; piyo++ )
					{
						id typeDictionary = [value objectAtIndex:piyo];
						if( [typeDictionary isKindOfClass:[NSDictionary class]] && 
							[[typeDictionary valueForKey:@"CFBundleTypeRole"] isEqualToString: @"MDImporter"]   )
						{
							id array = [typeDictionary objectForKey: @"LSItemContentTypes"];
							if( array != nil && [array isKindOfClass:[NSArray class]] )
							{
								if( [contentTypesForMDImporterMutableDictionary objectForKey: aStr] == nil )
									[contentTypesForMDImporterMutableDictionary setObject:[NSMutableArray array] forKey:aStr];
								
								[[contentTypesForMDImporterMutableDictionary objectForKey: aStr] addObjectsFromArray: array ];
							}
						
						}
					
					}
				
				}
			
			}
			
		}

		contentTypesForMDImporter = [[NSDictionary alloc] initWithDictionary:contentTypesForMDImporterMutableDictionary];
		
	}	
	
	return YES;
}

+(NSArray* )loadedPlugIns
{
	return mdimporterArray;
}
+(NSArray* )unloadedPlugIns
{
	return unloadedMDImporterArray;
}

+(NSDictionary*)contentTypesForMDImporter
{
	return contentTypesForMDImporter;
}

+(NSMutableDictionary* )metaDataOfFileAtPath:(NSString*)targetFilePath
{
	//Check plugIn list
	if( mdimporterArray == nil )
	{
		if( ![SpotlightTextContentRetriever loadPlugIns] ) 
			return [NSMutableArray array];
	}

	
	// Get UTI of the given file
	NSString *uti = [[NSWorkspace sharedWorkspace] UTIForFile:targetFilePath];
	
	/*
	//NSString* targetFilePath_converted = [targetFilePath stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	NSURL* anUrl = [NSURL fileURLWithPath:targetFilePath];
	FSRef ref;
	CFURLGetFSRef((CFURLRef)anUrl,&ref);
	//CFTypeRef outValue;
	CFStringRef outValue;
	LSCopyItemAttribute (
						 &ref,
						 kLSRolesAll,
						 kLSItemContentType,
						 (CFTypeRef*)&outValue
						 );
	
	if( outValue == nil ) return nil;
	
	NSString* uti = [NSString stringWithString:(NSString*)outValue];
	CFRelease(outValue);
	*/
	
	//mdimporterArray
	//contentTypesForMDImporter

	
	
	int hoge;
	for (hoge = 0; hoge < [mdimporterArray count]; hoge++) {
		NSString* mdimporterPath = [mdimporterArray objectAtIndex:hoge];
		
		NSArray* contentUTITypes = [contentTypesForMDImporter objectForKey:mdimporterPath ];
		
		if( [contentUTITypes containsObject:uti ] )
		{

			// found one mdimporter
			NSMutableDictionary* attributes = 
			[SpotlightTextContentRetriever executeMDImporterAtPath:mdimporterPath 
														   forPath:targetFilePath
															   uti:uti];
			
				
			//In 10.5, text content created by SourceCode.mdimporter contains only minimum keywords.
			// Overwrite full text here.
			if( osversion >= 1050 && UTTypeConformsTo ( (CFStringRef)uti, kUTTypeSourceCode  )) 
			{
			   
			   NSString* contents = [SpotlightTextContentRetriever readTextAtPath: targetFilePath];
			   if ( contents) {
				   [attributes setObject:contents forKey:(NSString*)kMDItemTextContent];
								
			   }			   
			}

		   return attributes;
		}
	}
	
	

		
	
	/* Original idea and code.  Did not work on Leopard for source code.
	
	
	//----------------
	
	
	//Get handlers that can handle the file
	CFArrayRef ha = LSCopyAllRoleHandlersForContentType (
														 uti,
														 kLSRolesAll
														 );	
	NSArray* handlerArray;
	
	if( ha == nil )
	{
		return nil;
	}else
	{
		handlerArray = [NSArray arrayWithArray: ha];
		CFRelease(ha);
	}
	
	//----------------
	
	//Evaluate
	
	int hoge;
	for( hoge = 0; hoge < [mdimporterArray count]; hoge++ )
	{
		NSString* mdimporterPath = [mdimporterArray objectAtIndex:hoge];			
		NSBundle* bndl = [NSBundle bundleWithPath: mdimporterPath ];
		
		if( bndl != nil )
		{
			
			int piyo;
			for( piyo = 0; piyo < [handlerArray count]; piyo++ )
			{
				NSString* aHandler = [handlerArray objectAtIndex:piyo];
				
	
				if( [aHandler isEqualToString:[bndl bundleIdentifier] ] )
				{

					//NSLog(@"Reading using %@",mdimporterPath);
					// found one mdimporter
					NSMutableDictionary* attributes = 
					[SpotlightTextContentRetriever executeMDImporterAtPath:mdimporterPath 
																   forPath:targetFilePath
																	   uti:uti];
					
					
					if( [attributes objectForKey:kMDItemTextContent] != nil )
						return attributes;

				}
			}
			
		}else
		{
			//NSLog(@"bndl is null");
			
		}
		
	}	
	*/
	
	return nil;
	
}

+(NSString*)readTextAtPath:(NSString*)path
{
	// When handling only ascii text, the source can be much more simple.
	
	NSError *error;
	NSStringEncoding encoding;
	NSString *contents = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
	return contents;
	
	/*
	NSData* data = [NSData dataWithContentsOfFile: path ];
	if ( data) {
		
		// Detect Encoding
		NSStringEncoding encoding;
		encoding = [JapaneseString detectEncoding: data];
		
		// Convert Encoding
		NSString* contents = nil;
		if (encoding == NSUnicodeStringEncoding ||
			encoding == CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF16BE) ||
			encoding == CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF16LE)) {
			contents = [[[NSString alloc] initWithData: data
											  encoding: encoding] autorelease];
		} else {
			TECConverter* converter = [SpotlightTextContentRetriever createConverter:encoding];
			contents = [converter convertToString: data];
		}
		return contents;
	}

	return nil;
	*/
}

+(int)OSVersion
{
	long SystemVersionInHexDigits;
	long MajorVersion, MinorVersion, MinorMinorVersion;
	
	Gestalt(gestaltSystemVersion, &SystemVersionInHexDigits);
	
	
	MinorMinorVersion = SystemVersionInHexDigits & 0xF;
	
	MinorVersion = (SystemVersionInHexDigits & 0xF0)/0xF;
	
	MajorVersion = ((SystemVersionInHexDigits & 0xF000)/0xF00) * 10 +
	(SystemVersionInHexDigits & 0xF00)/0xF0;
	
	
	////NSLog(@"ver %ld", SystemVersionInHexDigits);
	////NSLog(@"%ld.%ld.%ld", MajorVersion, MinorVersion, MinorMinorVersion);	
	
	
	return (int)MajorVersion*100 + MinorVersion*10 + MinorMinorVersion ;
}





+(NSString* )textContentOfFileAtPath:(NSString*)targetFilePath
{
	NSMutableDictionary* attributes = 
	[SpotlightTextContentRetriever metaDataOfFileAtPath:targetFilePath];
	
	id textContent = [attributes objectForKey:(NSString*)kMDItemTextContent];
	if( [textContent isKindOfClass:[NSString class]]  )
	{
		return textContent;
	}
	
	return nil;
}


+(NSMutableDictionary*)executeMDImporterAtPath:(NSString*)mdimportPath forPath:(NSString*)path uti:(NSString*)uti
{
	
	NSMutableDictionary* attributes = nil;
	//CFBundleRef		bundle;
	
	/*
	mdimportPath = [mdimportPath stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	CFURLRef url = CFURLCreateWithString ( nil, (CFStringRef)mdimportPath, nil );
	if( url == nil )	return nil;
	*/
	
	NSURL *url = [NSURL fileURLWithPath:mdimportPath];
	if ( url == nil ) return nil;

	// Create CFPlugInRef
		
	CFPlugInRef plugin = CFPlugInCreate(NULL, (CFURLRef)url);
	//CFRelease(url);
	
	if (!plugin)
	{
		//NSLog(@"Could not create CFPluginRef.\n");
		return nil;
	}

	
	//  The plug-in was located. Now locate the interface.

	BOOL foundInterface = NO;
	CFArrayRef	factories;
	
	//  See if this plug-in implements the Test type.
	factories	= CFPlugInFindFactoriesForPlugInTypeInPlugIn( kMDImporterTypeID, plugin );
	
	
	
	//  If there are factories for the Test type, attempt to get the IUnknown interface.
	if ( factories != NULL )
	{
		CFIndex	factoryCount;
		CFIndex	index;
		
		factoryCount	= CFArrayGetCount( factories );
		

		
		if ( factoryCount > 0 )
		{
			for ( index = 0 ; (index < factoryCount) && (foundInterface == false) ; index++ )
			{
				CFUUIDRef	factoryID;
				
				//  Get the factory ID for the first location in the array of IDs.
				factoryID = (CFUUIDRef) CFArrayGetValueAtIndex( factories, index );
				if ( factoryID )
				{
					
					IUnknownVTbl **iunknown;
					
					//  Use the factory ID to get an IUnknown interface. Here the plug-in code is loaded.
					iunknown	= (IUnknownVTbl **) CFPlugInInstanceCreate( NULL, factoryID, kMDImporterTypeID );
					
					if ( iunknown )
					{
						//  If this is an IUnknown interface, query for the test interface.
						(*iunknown)->QueryInterface( iunknown, CFUUIDGetUUIDBytes( kMDImporterInterfaceID ), (LPVOID *)( &mdimporterInterface ) );
						
						// Now we are done with IUnknown
						(*iunknown)->Release( iunknown );
						
						if ( mdimporterInterface )
						{
							//	We found the interface we need
							foundInterface	= true;
						}
					}
				}
			}
		}
		
		
		CFRelease( factories );

	}

	

		
	if ( foundInterface == false )
	{
	}
	else
	{
		attributes = [NSMutableDictionary dictionary];	


		/* This sometimes fails and causes crash. */
			
		@try {
			//path = [path stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];

			
			//NSLog(@"GetMetadataForFile" );

			(*mdimporterInterface)->GetMetadataForFile( mdimporterInterface, 
														(CFMutableDictionaryRef)attributes, 
														(CFStringRef)uti,
														(CFStringRef)path);	
		
			//void* ptr = (*mdimporterInterface)->GetMetadataForFile;
			//NSLog(@"%x",ptr);
			//(*mdimporterInterface)->Release( mdimporterInterface );
			
			
			
		}
		@catch (NSException *exception) {
			attributes = nil;
			//NSLog(@"exception" );

		}
		
		


	}
	
	// Finished

	CFRelease( plugin );
	plugin	= NULL;
	
	return attributes;
}

/*
#pragma mark Japanese Converter
+(TECConverter*)createConverter:(NSStringEncoding) encoding
{
	TECConverter* converter;

	converter = [converters_ objectForKey: [NSNumber numberWithInt: encoding]];

	if (! converter) {
		converter = [[TECConverter alloc] initWithEncoding: encoding];
		[converters_ setObject: converter
					   forKey: [NSNumber numberWithInt: encoding]];
		[converter release];
	}

	return converter;
}
*/
@end