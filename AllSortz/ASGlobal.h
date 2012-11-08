//
//  ASGlobal.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "UIKit/UIKit.h"

#define AS_DARK_BLUE  [UIColor colorWithRed:28.0f/255.0f green:55.0f/255.0f blue:82.0f/255.0f alpha:1.0f]



@interface NSDictionary (UrlEncoding)

-(NSString*) urlEncodedString;

@end


@interface UIImage (ImageColorationCategory)
+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;
@end