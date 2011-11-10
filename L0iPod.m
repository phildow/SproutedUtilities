//
//  L0iPod.m
//  Source: Cocoadev

#import <SproutedUtilities/L0iPod.h>

@implementation L0iPod

+ (NSString*) deviceRootForPath:(NSString*) path {
    NSArray* arr = [[NSWorkspace sharedWorkspace] mountedRemovableMedia];
    NSEnumerator* enu = [arr objectEnumerator];
    NSString* root;
    
    while (root = [enu nextObject]) {
        if ([path hasPrefix:root] && [self hasControlFolder:root])
            return root;
    }
    
    return nil;
}

+ (BOOL) hasControlFolder:(NSString*) path {
    BOOL isDir;
    return [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:@"iPod_Control"] isDirectory:&isDir] && isDir;
}

+ (NSArray*) allMountedDevices {
    NSArray* arr = [[NSWorkspace sharedWorkspace] mountedRemovableMedia];
    NSEnumerator* enu = [arr objectEnumerator];
    NSMutableArray* ipods = [NSMutableArray arrayWithCapacity:[arr count]];
    
    NSString* path;
    while (path = [enu nextObject]) {
        if ([self hasControlFolder:path])
            [ipods addObject:[[self alloc] initWithPath:path]];
    }
    
    return [NSArray arrayWithArray:ipods];
}

- (id) initWithPath:(NSString*) path {
    if (self = [super init]) {
        NSString* ipodRoot = [[self class] deviceRootForPath:path];
        if (!ipodRoot) {
            [self release];
            return nil;
        }
        
        CFURLGetFSRef((CFURLRef)[NSURL fileURLWithPath:ipodRoot], &iPodRef);
        
        family = kL0iPodUnchecked;
    }
    
    return self;
}

- (NSURL*) fileURL {
    NSURL* url = (NSURL*) CFURLCreateFromFSRef(NULL, &iPodRef);
    return [url autorelease];
}

- (NSString*) path {
    return [[self fileURL] path];
}

- (NSImage*) icon {
    NSString* path = [self path];
    return path == nil? nil : [[NSWorkspace sharedWorkspace] iconForFile:path];    
}

- (NSDictionary*) deviceInformation {
    NSString* ipod = [self path];
    if (!ipod)
        return nil;
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    NSString* sysInfo = [NSString stringWithContentsOfFile:[ipod stringByAppendingPathComponent:@"iPod_Control/Device/SysInfo"]];
    NSScanner* scanner = [NSScanner scannerWithString:sysInfo];
        
    [scanner setCharactersToBeSkipped:[NSCharacterSet whitespaceCharacterSet]];
    
    while (![scanner isAtEnd]) {
        NSString* key = nil, * value = nil;
        [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@":\n"] intoString:&key];
        
        if ([scanner scanString:@":" intoString:nil]) {
            [scanner scanUpToString:@"\n" intoString:&value];
            [dict setObject:value forKey:key];
        }
        
        [scanner scanString:@"\n" intoString:nil];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (L0iPodFamily)family
{
	//L0iPodFamily family;
	
	if (family != kL0iPodUnchecked)
        return family;
	
	NSDictionary* info = [self deviceInformation];
	if (info == nil || [info count] == 0)
	{
		// it's most likely a shuffle...
		family = kL0iPodShuffle;
	}
	else
	{
		NSString *boardHwSwInterfaceRev = [info objectForKey:@"boardHwSwInterfaceRev"];
		if ([boardHwSwInterfaceRev hasPrefix:@"0x00010000"] || [boardHwSwInterfaceRev hasPrefix:@"0x00020000"])
		{
			// mechanical/touch wheel (first & second generation)
			family = kL0iPodMechanicalOrTouchWheel;
		}
		else if ([boardHwSwInterfaceRev hasPrefix:@"0x00030001"])
		{
			// touch wheel & buttons (third generation)
			family = kL0iPodTouchWheelAndButtons;
		}
		else if ([boardHwSwInterfaceRev hasPrefix:@"0x00040013"] || [boardHwSwInterfaceRev hasPrefix:@"0x00070002"])
		{
			// iPod mini (1st and 2nd generations)
			family = kL0iPodMini;
		}
		else if ([boardHwSwInterfaceRev hasPrefix:@"0x00050013"] || [boardHwSwInterfaceRev hasPrefix:@"0x00050014"])
		{
			// click wheel (fourth generation)
			family = kL0iPodClickWheel;
		}
		else if ([boardHwSwInterfaceRev hasPrefix:@"0x00060000"] || [boardHwSwInterfaceRev hasPrefix:@"0x00060004"])
		{
			// iPod with color display (includes iPod photo)
			family = kL0iPodColorDisplay;
		}
		else if ([boardHwSwInterfaceRev hasPrefix:@"0x000C0005"])
		{
			// iPod nano
			family = kL0iPodNano;
		}
		else if ([boardHwSwInterfaceRev hasPrefix:@"0x000B0005"])
		{
			// iPod (with video playback)
			family = kL0iPodVideo;
		}
		else
		{
			// Unrecognized iPod
			family = kL0iPodGeneric;
		}
	}
			   
	return family;
}

- (BOOL) hasDisplay {
    return [self family] != kL0iPodShuffle;
}

- (BOOL) hasColorDisplay {
    L0iPodFamily fam = [self family];
    return fam == kL0iPodColorDisplay || fam == kL0iPodNano || fam == kL0iPodVideo;
}

- (BOOL) hasNotes {
    L0iPodFamily fam = [self family];
    return fam != kL0iPodMechanicalOrTouchWheel && fam != kL0iPodShuffle;
}

- (BOOL) hasTVOut {
    L0iPodFamily fam = [self family];
    return fam == kL0iPodColorDisplay || fam == kL0iPodVideo;
}

- (BOOL) hasVideoPlayback {
    return [self family] == kL0iPodVideo;
}

- (BOOL) hasPhotoAlbum {
    return [self hasColorDisplay];
}

- (NSString*) displayName {
    NSString* path = [self path];
    return path? [[NSFileManager defaultManager] displayNameAtPath:path] : nil;
}

@end