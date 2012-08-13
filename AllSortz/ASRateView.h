//
//  ASRateView.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//
// Code from http://www.raywenderlich.com/1768/how-to-make-a-custom-uiview-a-5-star-rating-view
#import <UIKit/UIKit.h>

@class ASRateView;

@protocol ASRateViewDelegate
- (void)rateView:(ASRateView *)rateView ratingDidChange:(float)rating;
@end

@interface ASRateView : UIView

@property (strong, nonatomic) UIImage *notSelectedImage;
@property (strong, nonatomic) UIImage *halfSelectedImage;
@property (strong, nonatomic) UIImage *fullSelectedImage;
@property (assign, nonatomic) float rating;
@property (assign) BOOL editable;
@property (strong) NSMutableArray * imageViews;
@property (assign, nonatomic) int maxRating;
@property (assign) int midMargin;
@property (assign) int leftMargin;
@property (assign) CGSize minImageSize;
@property (assign) id <ASRateViewDelegate> delegate;

@end
