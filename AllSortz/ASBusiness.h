//
//  ASBusiness.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@interface ASBusiness : NSObject

@property (readonly) id ID;

// TODO: Use more structured repr for location, hours, and phone

@property (nonatomic) NSString *address;
@property (nonatomic) NSString *city;
@property (nonatomic) NSString *state;
@property (nonatomic) NSString *zipcode;


@property (nonatomic) NSArray *hours;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *phone;

// the health violation text
@property (nonatomic) NSString *healthViolationText;

// The actual grade for the business (letter encoded)
@property (nonatomic) NSString *healthGrade;

//The personalize score for the business
@property (nonatomic) CGFloat recommendation;
//The lat lng
@property (nonatomic) CGFloat lat;
@property (nonatomic) CGFloat lng;


//the business' website
@property (nonatomic) NSURL *website;

//the businesses image which will be set by separate request
@property (nonatomic) UIImage *image;

//ID of the image
@property (nonatomic) NSUInteger imageID;

//distance from the current user
@property (nonatomic) NSNumber *distance;

//The average rating for the business 
@property (nonatomic) NSNumber *avgRating;

//The average price for the business
@property (nonatomic) NSNumber *avgPrice;

//The average price for the business
@property (nonatomic, strong) NSString * imageURLString;


// Whether the business is starred on teh map
@property (assign) BOOL starred;


//array of types associated with business
@property (nonatomic) NSArray *types;

//array of toipcs associated with the business
@property (nonatomic) NSMutableArray *topics;

- (id)initWithID:(id)anID;
- (NSDictionary *) serializeToDictionaryWithTypes:(NSArray*)allTypes;

@end
