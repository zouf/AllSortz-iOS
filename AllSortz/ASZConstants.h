//
//  ASZConstants.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#ifndef AllSortz_ASZConstants_h
#define AllSortz_ASZConstants_h

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif
