//
//  ASZTriangleAnnotation.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASZTriangleAnnotation : UIView
@property  (assign) CGFloat size;
@property  (assign) CGFloat scale;
@property  (strong,nonatomic) UIColor* color;

- (id)initWithFrame:(CGRect)frame withColor:(UIColor *)color;


@end
