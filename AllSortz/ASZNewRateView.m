//
//  ASZNewRateView.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/18/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZNewRateView.h"
#import "ASZStarAnnotation.h"


#define HORIZONTAL_CELL_SIZE 15
#define VERTICAL_CELL_SIZE 15
#define SPACE_PER_BLOCK 14
#define SIZE 50

#define MAX_RATING 4

@implementation ASZNewRateView
@synthesize vertical;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.views = [[NSMutableArray alloc]init];
        self.vertical = YES;
        self.max_rating = MAX_RATING;
        
    }
    return self;
}


-(void)refresh:(UIColor*)color rating:(NSInteger)rating
{
    if(rating < 1)
    {
        rating = 1;
    }
    else if(rating > MAX_RATING)
    {
        rating = MAX_RATING;
    }
    
    
    for(UIView *v in self.views)
    {
        [v removeFromSuperview];
    }
    
    
    for(int i = 0; i < rating; i++)
    {
        ASZStarAnnotation * newView;
        if(self.vertical)
        {
            newView = [[ASZStarAnnotation alloc] initWithFrame:CGRectMake(0,SIZE - SPACE_PER_BLOCK*i,VERTICAL_CELL_SIZE,VERTICAL_CELL_SIZE) withColor:color];
        }else
        {
            newView = [[ASZStarAnnotation alloc] initWithFrame:CGRectMake(SPACE_PER_BLOCK*i,0,HORIZONTAL_CELL_SIZE,HORIZONTAL_CELL_SIZE) withColor:color];

        }
        [newView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:newView];
        [self.views addObject:newView];
    }
    
}
@end