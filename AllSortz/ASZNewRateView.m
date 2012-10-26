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

#define MAX_RATING 4

@interface ASZNewRateView ()
@property (nonatomic, assign) CGFloat size;

@end

@implementation ASZNewRateView
@synthesize vertical;

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        self.vertical = YES;
        self.max_rating = MAX_RATING;
        self.size = frame.size
        .height;
        
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor*)_color rating:(NSInteger)_rating
{
    self = [super initWithFrame:frame];
    if (self) {
        self.vertical = NO;
        self.max_rating = MAX_RATING;
        self.frame = frame;
        [self refresh:_color rating:_rating];

        
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
    
    
    for(UIView *v in self.subviews)
    {
        [v removeFromSuperview];
    }
    
    NSLog(@"The rating is %d\n",rating);
    for(int i = 0; i < rating; i++)
    {
        ASZStarAnnotation * newView;
        if(self.vertical)
        {
            newView = [[ASZStarAnnotation alloc] initWithFrame:CGRectMake(0,self.size - SPACE_PER_BLOCK*i,VERTICAL_CELL_SIZE,VERTICAL_CELL_SIZE) withColor:color];
        }else
        {
            newView = [[ASZStarAnnotation alloc] initWithFrame:CGRectMake(14*i,0,20,20) withColor:color];

        }
        [newView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:newView];
        [self.views addObject:newView];
    }
    
    NSLog(@"the number of stars is %d\n", self.subviews.count);
    
}
@end