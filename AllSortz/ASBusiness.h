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


//The personalize score for the business
@property (nonatomic) CGFloat recommendation;
//The lat lng
@property (nonatomic) CGFloat lat;
@property (nonatomic) CGFloat lng;


//the business' website
@property (nonatomic) NSURL *website;

//the businesses image which will be set by separate request
@property (nonatomic) UIImage *image;


//distance from the current user
@property (nonatomic) NSNumber *distance;

//The average rating for the business 
@property (nonatomic) NSNumber *avgRating;

//The average price for the business
@property (nonatomic) NSNumber *avgPrice;

// The location of the business image
@property (nonatomic, strong) NSString * imageURLString;


// Whether the business is starred on teh map
@property (assign) BOOL starred;


//array of types associated with business
@property (nonatomic) NSMutableArray *types;

// a list of reviews from yelp
@property (nonatomic) NSMutableArray *reviews;

// 0 => none 1 => self-report 2 => SPE
@property (assign) NSUInteger certLevel;
//cert image
@property (nonatomic,retain) UIImage *certImage;
//cert date
@property (nonatomic,retain) NSString *certDate;


//array of toipcs associated with the business
@property (nonatomic) NSMutableArray *topics;
-(id)initWithJSONYelp:(NSDictionary*)dict;
- (id)initWithID:(id)anID;
- (NSDictionary *) serializeToDictionaryWithTypes:(NSArray*)allTypes;

@end
