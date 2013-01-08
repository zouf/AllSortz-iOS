//
//  ASMapPoint.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "ASBusinessList.h"

@interface ASMapPoint : NSObject <MKAnnotation>{
	CLLocationCoordinate2D coordinate;
	id tag;
	NSString *title;
	NSString *subtitle;
    
    

    
    
}

@property(nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic) id tag;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *subtitle;

// a reference to the businesss this mappoint refers to
@property(nonatomic,strong) ASBusiness *business;

@property (nonatomic) float score;

//MKAnnotation
-(id)initWithCoordinate:(CLLocationCoordinate2D)c withScore:(float)sc withTag:(id)t withTitle:(NSString *)tl withSubtitle:	(NSString *)s;
@end