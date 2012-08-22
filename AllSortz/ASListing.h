//
//  ASListing.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/10/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASRateView.h"


@interface ASListing : NSObject

@property (nonatomic) NSString *businessDistance;
@property (nonatomic) NSString *businessName;
@property (nonatomic) UIImage *businessPhoto;
@property (nonatomic) NSArray *businessTypes;
@property (nonatomic) NSString *imageURLString;
@property (nonatomic) float recommendation;
@property (nonatomic) float userRating;
@property (nonatomic) NSString * averagePrice;

@end
