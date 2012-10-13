//
//  ASZCustomAnnotation.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZCustomAnnotation.h"

#import "ASZConstants.h"
#import <UIKit/UIKit.h>

#define RADIUS 8
#define GRADIENT_POINT_1 5
#define GRADIENT_POINT_2 10
@implementation ASZCustomAnnotation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    UIColor* myLightBlue = [UIColor colorWithRed: 0.498 green: 0.663 blue: .827 alpha: 1];
    UIColor* myDarkBlue = [UIColor colorWithRed: 0.11 green: .216 blue: .322 alpha: 1];
    
    //UIColor* myLightRed = [UIColor colorWithRed:1 green: .922 blue: .616 alpha: 1];
    UIColor* myDarkRed = [UIColor colorWithRed: 1 green: .8 blue: 0 alpha: 1];
    
    // UIColor* myLightBlue = UIColorFromRGB(0x07fa93);
    // UIColor* myDarkBlue = UIColorFromRGB(0x1c3752);
    
    
    //// Gradient Declarations
    NSArray* gradient3Colors = nil;

    
    UIBezierPath *aPath = nil;

    
    if (self.starred)
    {

        gradient3Colors = [NSArray arrayWithObjects:
                           (id)myDarkRed.CGColor,
                           (id)myDarkRed.CGColor, nil];
        aPath = [UIBezierPath bezierPath];
        CGFloat s = 2.5;


        
        // Set the starting point of the shape.
        [aPath moveToPoint:CGPointMake(1*s, 4*s)];
        [aPath addLineToPoint:CGPointMake(4*s, 4*s)];
        [aPath addLineToPoint:CGPointMake(5*s, 1*s)];
        [aPath addLineToPoint:CGPointMake(6*s, 4*s)];
        [aPath addLineToPoint:CGPointMake(9*s, 4*s)];
        [aPath addLineToPoint:CGPointMake(6.5*s, 6*s)];
        [aPath addLineToPoint:CGPointMake(7.5*s, 9*s)];
        [aPath addLineToPoint:CGPointMake(5*s, 7*s)];
        [aPath addLineToPoint:CGPointMake(2.5*s, 9*s)];
        [aPath addLineToPoint:CGPointMake(3.5*s, 6*s)];

        
        [aPath closePath];
    }
    else
    {
        gradient3Colors = [NSArray arrayWithObjects:
                           (id)myLightBlue.CGColor,
                           (id)myDarkBlue.CGColor, nil];
        aPath = [UIBezierPath bezierPathWithOvalInRect: CGRectMake(0.5, 0.5, RADIUS*2, RADIUS*2)];
    }
    
    CGFloat gradient3Locations[] = {0, 1};
    
    
    
    
    //// Abstracted Graphic Attributes
    NSString* textContent = [NSString stringWithFormat:@"%d\n",(NSInteger)roundf(self.recommendation*100)];
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGGradientRef gradient3 = CGGradientCreateWithColors(colorSpace, (CFArrayRef)CFBridgingRetain(gradient3Colors), gradient3Locations);
    
    
    //// Oval Drawing
    CGContextSaveGState(context);
    [aPath addClip];
    CGContextDrawRadialGradient(context, gradient3,
                                CGPointMake(RADIUS, RADIUS), GRADIENT_POINT_1,
                                CGPointMake(RADIUS, RADIUS), GRADIENT_POINT_2,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    CGContextRestoreGState(context);
    
    [[UIColor blackColor] setStroke];
    aPath.lineWidth = 0.5;
    [aPath stroke];
    
    
    //// Text Drawing
    if (self.starred)
    {
        UILabel *recommendationLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, RADIUS*2, RADIUS*2)];
        [recommendationLabel setText:textContent];
        [recommendationLabel setFont:[UIFont fontWithName:@"Gill Sans"  size:7]];
        [recommendationLabel setTextAlignment:NSTextAlignmentCenter];
        [recommendationLabel setTextColor:[UIColor darkTextColor]];
        [recommendationLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:recommendationLabel];
    }
    else
    {
        UILabel *recommendationLabel = [[UILabel alloc]initWithFrame:CGRectMake(1,1, RADIUS*2, RADIUS*2)];
        [recommendationLabel setText:textContent];
        [recommendationLabel setFont:[UIFont fontWithName:@"Gill Sans"  size:8]];
        [recommendationLabel setTextAlignment:NSTextAlignmentCenter];
        [recommendationLabel setTextColor:[UIColor darkTextColor]];
        [recommendationLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:recommendationLabel];
    }

    //CGRect textFrame = CGRectMake(3, 3, RADIUS*2, 10);
    //[[UIColor darkTextColor] setFill];
    //[textContent drawInRect: textFrame withFont: [UIFont fontWithName: @"Gill Sans" size: 8]  ];
    
    
    //// Cleanup
    CGGradientRelease(gradient3);
    CGColorSpaceRelease(colorSpace);
    

}



@end
