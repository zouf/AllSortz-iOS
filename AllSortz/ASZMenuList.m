//
//  ASZMenuList.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/9/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZMenuList.h"
#import "ASZMenuItem.h"

@interface  ASZMenuList ()

@property(nonatomic,retain) NSMutableArray* meals;
@property(nonatomic,retain) NSMutableArray* mealNames;

@end


@implementation ASZMenuList


-(id)init
{
    if (!(self = [super init]))
        return nil;
    
    NSError *jsonParsingError = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"simplemenu" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray * JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
    self.mealNames = [[NSMutableArray alloc]init];
    self.meals = [[NSMutableArray alloc]init];
    for (NSDictionary* dict in JSONresponse)
    {

        NSString * mealName = [dict objectForKey:@"meal"];
        [self.mealNames addObject:mealName];
        NSMutableArray *dishes = [[NSMutableArray alloc]init];
        for(NSDictionary* d in [dict objectForKey:@"dishes"])
        {
            ASZMenuItem *mi = [[ASZMenuItem alloc]initWithJSON:d];
            [dishes addObject:mi];
        }
        [self.meals addObject:dishes];
    }
    
    
    return self;
}


- (NSUInteger)numberOfMeals
{
    return [self.meals count];
}

- (NSString*)mealNameAtIndex:(NSUInteger)index;
{
    return [self.mealNames objectAtIndex:index];
}

- (NSUInteger)numberOfMenuItemsFor:(NSUInteger)index
{
    return [[self.meals objectAtIndex:index] count];
}

- (ASZMenuItem *)menuItemsForIndex:(NSIndexPath*)indexPath;
{
    return [[self.meals objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

@end
