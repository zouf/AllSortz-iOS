//
//  ASBusiness.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@interface ASBusiness : NSObject

@property (readonly) NSUInteger ID;

// TODO: Use more structured repr for location, hours, and phone

@property (nonatomic) NSString *address;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *zipcode;


@property (nonatomic) NSArray *hours;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *phone;
@property (nonatomic) NSString *healthGrade;
@property (nonatomic) CGFloat recommendation;

@property (nonatomic) NSURL *website;

@property (nonatomic) UIImage *image;
@property (nonatomic) NSUInteger imageID;

@property (nonatomic) NSNumber *distance;

@property (nonatomic) NSNumber *score;

@property (nonatomic) NSArray *types;

@property (nonatomic) NSArray *topics;

- (id)initWithID:(NSUInteger)anID;

@end
