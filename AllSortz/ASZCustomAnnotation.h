//
//  ASZCustomAnnotation.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASZCustomAnnotation : UIView

@property(retain,nonatomic) NSString * text;

@property(assign,nonatomic) CGFloat recommendation;
@property(assign,nonatomic) Boolean starred;
- (id)initWithFrame:(CGRect)frame rec:(CGFloat)_recommendation;
@end
