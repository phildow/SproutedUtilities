//
//  ZipUtilities.m
//  SproutedUtilities
//
//  Created by Philip Dow on 8/21/07.
//  Copyright 2007 Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/ZipUtilities.h>

@implementation ZipUtilities

+ (BOOL) zip:(NSString*)targetPath toFile:(NSString*)targetZip {
	
	//
	// backs up the journal to path, or if no path is specified,
	// backs up the journal to the application support directory.
	// blocks if flag is true
	// if flag is not true, calls xxx of the target to let the caller know the process is finsihed ?
	
	int status;
	static int ZIP_TASK_SUCCESS = 0;
	NSTask *zipTask = [[NSTask alloc] init];
	
	NSString *workingDirectory = [[NSFileManager defaultManager] currentDirectoryPath];
	if ( [[NSFileManager defaultManager] changeCurrentDirectoryPath:[targetPath stringByDeletingLastPathComponent]] )
		targetPath = [targetPath lastPathComponent];
	
	[zipTask setLaunchPath:@"/usr/bin/zip"];
	[zipTask setArguments:[NSArray arrayWithObjects:@"-q", @"-r", targetZip, targetPath, nil]];
	
	[zipTask launch];
	[zipTask waitUntilExit];
	
	status = [zipTask terminationStatus];
	
	[[NSFileManager defaultManager] changeCurrentDirectoryPath:workingDirectory];
	[zipTask release];
	
	return ( status == ZIP_TASK_SUCCESS );
	
}

+ (BOOL) unzipPath:(NSString*)sourcePath toPath:(NSString*)destinationPath
{
	// ditto will overwrite the original file
	
	int status;
	static int UNZIP_TASK_SUCCESS = 0;
	
	NSTask *cmnd=[[NSTask alloc] init];
	
	[cmnd setLaunchPath:@"/usr/bin/ditto"];
	[cmnd setArguments:[NSArray arrayWithObjects:@"-v",@"-x",@"-k",@"--rsrc", sourcePath, destinationPath, nil]];
	
	[cmnd launch];
	[cmnd waitUntilExit];
	
	status = [cmnd terminationStatus];

	[cmnd release];
	
	return ( status == UNZIP_TASK_SUCCESS );
}


@end
