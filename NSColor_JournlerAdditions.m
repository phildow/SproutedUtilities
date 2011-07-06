//
//  NSColor_JournlerAdditions.m
//  SproutedUtilities
//
//  Created by Philip Dow on 1/9/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSColor_JournlerAdditions.h>


@implementation NSColor (JournlerAdditions)

+ (NSColor*) colorForLabel:(int)label gradientEnd:(BOOL)end
{
	NSColor *theColor = nil;
	
	switch ( label ) 
	{
	case 1:
		if ( end ) 
		theColor = [[NSColor colorWithCalibratedRed:252.0/255.0 green:105.0/255.0 blue:106.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		else
		theColor = [[NSColor colorWithCalibratedRed:253.0/255.0 green:161.0/255.0 blue:159.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		break;
	
	case 2:
		if ( end ) 
		theColor = [[NSColor colorWithCalibratedRed:245.0/255.0 green:177.0/255.0 blue:89.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		else
		theColor = [[NSColor colorWithCalibratedRed:249.0/255.0 green:206.0/255.0 blue:150.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		break;
	
	case 3:
		if ( end ) 
		theColor = [[NSColor colorWithCalibratedRed:238.0/255.0 green:229.0/255.0 blue:97.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		else
		theColor = [[NSColor colorWithCalibratedRed:247.0/255.0 green:245.0/255.0 blue:159.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		break;
	
	case 4:
		if ( end ) 
		theColor = [[NSColor colorWithCalibratedRed:183.0/255.0 green:223.0/255.0 blue:95.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		else
		theColor = [[NSColor colorWithCalibratedRed:211.0/255.0 green:237.0/255.0 blue:158.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		break;
	
	case 5:
		if ( end ) 
		theColor = [[NSColor colorWithCalibratedRed:111.0/255.0 green:174.0/255.0 blue:252.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		else
		theColor = [[NSColor colorWithCalibratedRed:172.0/255.0 green:210.0/255.0 blue:253.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		break;
	
	case 6:
		if ( end ) 
		theColor = [[NSColor colorWithCalibratedRed:200.0/255.0 green:147.0/255.0 blue:219.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		else
		theColor = [[NSColor colorWithCalibratedRed:237.0/255.0 green:180.0/255.0 blue:255.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		break;
	
	case 7:
		if ( end ) 
		theColor = [[NSColor colorWithCalibratedRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		else
		theColor = [[NSColor colorWithCalibratedRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1.0] shadowWithLevel:0.08];
		break;
		
	default:
		theColor = nil;
		break;
	}
	
	return theColor;
}

+ (NSColor*) darkColorForLabel:(int)label gradientEnd:(BOOL)end
{
	NSColor *theColor = nil;
	
	switch ( label ) 
	{
	case 1:
		if ( end ) 
		theColor = [NSColor colorWithCalibratedRed:185.0/255.0 green:9.0/255.0 blue:21.0/255.0 alpha:1.0];
		else
		theColor = [NSColor colorWithCalibratedRed:205.0/255.0 green:30.0/255.0 blue:29.0/255.0 alpha:0.0];
		break;
	
	case 2:
		if ( end ) 
		theColor = [NSColor colorWithCalibratedRed:255.0/255.0 green:139.0/255.0 blue:43.0/255.0 alpha:1.0];
		else
		theColor = [NSColor colorWithCalibratedRed:255/255.0 green:71/255.0 blue:0/255.0 alpha:0.0];
		break;
	
	case 3:
		if ( end ) 
		theColor = [NSColor colorWithCalibratedRed:238.0/255.0 green:229.0/255.0 blue:97.0/255.0 alpha:1.0];
		else
		theColor = [NSColor colorWithCalibratedRed:247.0/255.0 green:245.0/255.0 blue:159.0/255.0 alpha:0.2];
		break;
	
	case 4:
		if ( end ) 
		//theColor = [NSColor colorWithCalibratedRed:183.0/255.0 green:223.0/255.0 blue:95.0/255.0 alpha:1.0];
		theColor = [NSColor colorWithCalibratedRed:50.0/255.0 green:92.0/255.0 blue:0.0/255.0 alpha:1.0];
		else
		//theColor = [NSColor colorWithCalibratedRed:211.0/255.0 green:237.0/255.0 blue:158.0/255.0 alpha:0.2];
		theColor = [NSColor colorWithCalibratedRed:108.0/255.0 green:155.0/255.0 blue:0.0/255.0 alpha:0.0];
		break;
	
	case 5:
		if ( end ) 
		//theColor = [NSColor colorWithCalibratedRed:111.0/255.0 green:174.0/255.0 blue:252.0/255.0 alpha:1.0];
		theColor = [NSColor colorWithCalibratedRed:0.0/255.0 green:68.0/255.0 blue:255.0/255.0 alpha:1.0];
		else
		//theColor = [NSColor colorWithCalibratedRed:172.0/255.0 green:210.0/255.0 blue:253.0/255.0 alpha:0.2];
		theColor = [NSColor colorWithCalibratedRed:0/255.0 green:139.0/255.0 blue:255.0/255.0 alpha:0.0];
		break;
	
	case 6:
		if ( end ) 
		theColor = [NSColor colorWithCalibratedRed:200.0/255.0 green:147.0/255.0 blue:219.0/255.0 alpha:1.0];
		else
		theColor = [NSColor colorWithCalibratedRed:237.0/255.0 green:180.0/255.0 blue:255.0/255.0 alpha:0.2];
		break;
	
	case 7:
		if ( end ) 
		theColor = [NSColor colorWithCalibratedRed:177.0/255.0 green:177.0/255.0 blue:177.0/255.0 alpha:1.0];
		else
		theColor = [NSColor colorWithCalibratedRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:0.2];
		break;
	
	default:
		theColor = nil;
		break;
	}
	
	return theColor;
}


@end
