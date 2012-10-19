//
//  ASZNewRateView.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/18/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASZNewRateView : UIView

@property (nonatomic,assign) BOOL  vertical;
@property (nonatomic,assign) NSInteger  max_rating;
@property (nonatomic,retain) NSMutableArray * views;
-(void)refresh:(UIColor*)color rating:(NSInteger)rating;
@end
