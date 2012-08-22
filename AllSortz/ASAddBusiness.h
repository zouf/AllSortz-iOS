//
//  ASAddBusiness.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface ASAddBusiness : NSObject
{
    NSString *businessName;
    NSString *businessAddress;
    NSString *businessCity;
    NSString *businessState;

    NSString *businessPhone;
    NSString *businessURL;
    NSArray *selectedTypes;


    NSArray *allTypes;

}


@property(nonatomic, retain) NSString *businessName;
@property(nonatomic, retain) NSString *businessAddress;
@property(nonatomic, retain) NSString *businessCity;
@property(nonatomic, retain) NSString *businessState;

@property(nonatomic, retain) NSString *businessPhone;
@property(nonatomic, retain) NSString *businessURL;

@property(nonatomic, retain) NSArray *selectedTypes;
@property(nonatomic, retain) NSArray *allTypes;

- (id)initWithJSONObject:(NSDictionary *)aJSONObject;
- (NSDictionary *)serializeToDictionary;



@end
