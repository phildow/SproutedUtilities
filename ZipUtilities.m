//
//  ZipUtilities.m
//  SproutedUtilities
//
//  Created by Philip Dow on 8/21/07.
//  Copyright Philip Dow / Sprouted. All rights reserved.
//

//  Source: cocoadev?

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
