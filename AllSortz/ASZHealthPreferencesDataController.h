//
//  ASZHealthPreferencesDataController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/8/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASZHealthPreferencesDataController : NSObject <UITableViewDataSource>

//categories such as Allergen, Nutrition, etc. For now, each category is just going to be an array of dictionaries (eventually map to a proper object)
@property (nonatomic) NSMutableArray *categories;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *email;

//0 => female, 1=>male
@property (nonatomic, retain) NSNumber *gender;

//0 - 0     1 -> 1-3      2-> 4-6       3 -> 7+
@property (nonatomic, retain) NSNumber *workoutDays;

@property (nonatomic, retain) NSNumber *age;



@end
