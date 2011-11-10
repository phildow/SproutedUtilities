//
//  NSDate_PDAdditions.m
//  SproutedUtilities
//
//  Created by Phil Dow on 1/10/07.
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
