//
//  ASZMenuItem.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/9/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASZMenuItem : NSObject

@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *description;
@property(nonatomic,retain) NSNumber *price;
@property(assign) NSUInteger certLevel;
@property(nonatomic, retain) UIImage*certImage;
@property(nonatomic,retain) NSString* certDate;


@property(nonatomic,retain) NSArray* restrictions;


- (id)initWithJSON:(NSDictionary*)aJSONobject;



@end
