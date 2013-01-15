//
//  ASZMenuList.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/9/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASZMenuItem.h"
@interface ASZMenuList : NSObject
{
}




- (NSUInteger)numberOfMeals;
- (NSString*)mealNameAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfMenuItemsFor:(NSUInteger)index;
- (ASZMenuItem *)menuItemsForIndex:(NSIndexPath*)indexPath;
@end