//
//  ASGlobal.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "UIKit/UIKit.h"

#define AS_DARK_BLUE  [UIColor colorWithRed:28.0f/255.0f green:55.0f/255.0f blue:82.0f/255.0f alpha:1.0f]

#define CONSUMER_KEY @"z-5AyqiKIUREnt2YdCoQ1w"
#define CONSUMER_SECRET @"_f0lb3ZMq6Lhih53fW1-sLX2ZMk"
#define TOKEN @"_l_RyYYi5CdzCclU668qkXF_65iHDNXU"
#define TOKEN_SECRET @"GMcrzmglHenNdy-J3QhvVBn7d4E"

#define MAX_RATING 5

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

extern NSString *const ASMultipleAssignmentException;


@interface NSDictionary (UrlEncoding)

-(NSString*) urlEncodedString;

@end


@interface UIImage (ImageColorationCategory)
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;
@end