//
//  ASMapPoint.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ASMapPoint : NSObject <MKAnnotation>{
	CLLocationCoordinate2D coordinate;
	NSUInteger tag;
	NSString *title;
	NSString *subtitle;
    float score;
}

@property(nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic) NSUInteger tag;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *subtitle;
@property (nonatomic) float score;

//MKAnnotation
-(id)initWithCoordinate:(CLLocationCoordinate2D)c withScore:(float)sc withTag:(NSUInteger)t withTitle:(NSString *)tl withSubtitle:	(NSString *)s;
@end