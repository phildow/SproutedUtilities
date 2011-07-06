//
//  NSDate_PDAdditions.m
//  SproutedUtilities
//
//  Created by Phil Dow on 1/10/07.
//  Copyright Sprouted. All rights reserved.
//	All inquiries should be directed to developer@journler.com
//

#import <SproutedUtilities/NSDate_PDAdditions.h>

@implementation NSDate (PDAdditions)

- (BOOL) fallsOnSameDay:(NSDate*)aDate
{
	NSCalendarDate *selfAsCalDate = ( [self isKindOfClass:[NSCalendarDate class]] ? 
			(NSCalendarDate*)self : [self dateWithCalendarFormat:nil timeZone:nil] );
	NSCalendarDate *targetAsCalDate = ( [aDate isKindOfClass:[NSCalendarDate class]] ? 
			(NSCalendarDate*)aDate : [aDate dateWithCalendarFormat:nil timeZone:nil] );
	
	return ( [selfAsCalDate dayOfMonth] == [targetAsCalDate dayOfMonth] 
		&& [selfAsCalDate monthOfYear] == [targetAsCalDate monthOfYear]
		&& [selfAsCalDate yearOfCommonEra] == [targetAsCalDate yearOfCommonEra] );
}

- (NSString*) descriptionAsDifferenceBetweenDate:(NSDate*)aDate
{
	BOOL past;
	NSString *suffix;
	NSMutableString *description = [NSMutableString stringWithString:@"~ "];
	NSTimeInterval interval;
	
	if ( [self laterDate:aDate] == aDate )
	{
		past = YES;
		suffix = @"ago";
		interval = floor([aDate timeIntervalSinceDate:self]);
	}
	else
	{
		past = NO;
		suffix = @"in the future";
		interval = floor([self timeIntervalSinceDate:aDate]);
	}
	
	double rem;
	double years, months, weeks, days;
	
	years = floor( interval / 31536000 );
	rem = fmod( interval , 31536000 );
	
	months = floor( rem / 2629743 );
	rem = fmod( rem , 2629743 );
	
	weeks = floor( rem / 604800 );
	rem = fmod ( rem, 604800 );
	
	days = ceil( rem / 86400 );
	
	int intYears = (int)years, intMonths = (int)months, intWeeks = (int)weeks, intDays = (int)days;
	
	if ( intYears == 1 )
		[description appendString:[NSString stringWithFormat:@"%i %@ ", intYears, @"year"]];
	else if ( intYears > 1 )
		[description appendString:[NSString stringWithFormat:@"%i %@ ", intYears, @"years"]];
	
	if ( intYears != 0 && intMonths != 0 && intWeeks == 0 && intDays == 0 )
		[description appendString:@"and "];
	
	if ( intMonths == 1 )
		[description appendString:[NSString stringWithFormat:@"%i %@ ", intMonths, @"month"]];
	else if ( intMonths > 1 )
		[description appendString:[NSString stringWithFormat:@"%i %@ ", intMonths, @"months"]];
	
	if ( (intYears != 0 || intMonths != 0) && intWeeks != 0 && intDays == 0 )
		[description appendString:@"and "];
	
	if ( intWeeks == 1 )
		[description appendString:[NSString stringWithFormat:@"%i %@ ", intWeeks, @"week"]];
	else if ( intWeeks > 1 )
		[description appendString:[NSString stringWithFormat:@"%i %@ ", intWeeks, @"weeks"]];
		
	if ( (intYears != 0 || intMonths != 0 || intWeeks != 0 ) && intDays != 0 )
		[description appendString:@"and "];	
	
	if ( intDays == 1 )
		[description appendString:[NSString stringWithFormat:@"%i %@ ", intDays, @"day"]];
	else if ( intDays > 1 )
		[description appendString:[NSString stringWithFormat:@"%i %@ ", intDays, @"days"]];
		
	// special cases
	if ( intDays == 0 || intDays == 1 )
		[description setString:( past ? @"in the past 24 hours" : @"in the next 24 hours" )];
	
	else
		[description appendString:suffix];
	
	return description;
}

@end
