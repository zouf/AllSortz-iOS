//
//  ASListing.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/10/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASRateView.h"

@interface ASListing : NSObject
{
    NSString *businessName;
    UIImage *businessPhoto;
    NSArray *businessTypes;
    NSString *businessDistance;
    NSString *imageURLString;
    float recommendation;
    float userRating;

}

@property (nonatomic, retain) NSString *businessName;
@property (nonatomic, retain) UIImage *businessPhoto;
@property (nonatomic, retain) NSArray *businessTypes;
@property (nonatomic, retain) NSString *imageURLString;

@property (nonatomic, retain) NSString *businessDistance;
@property (assign, nonatomic) float recommendation;
@property (assign, nonatomic) float userRating;


@end