//
//  ASMapPoint.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASMapPoint.h"

@implementation ASMapPoint

@synthesize coordinate;
@synthesize tag;
@synthesize title;
@synthesize subtitle;

@synthesize score;



-(id)initWithCoordinate:(CLLocationCoordinate2D)c withScore:(float)sc withTag:(id)t withTitle:(NSString *)tl withSubtitle:	(NSString *)s
{
	if(self = [super init])
	{
		coordinate = c;
		score = sc;
		title = tl;
		subtitle = s;
        tag = t;
        
        
	}
	return self;
    
}

@end