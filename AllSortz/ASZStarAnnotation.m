//
//  ASZStarAnnotation.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/18/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZStarAnnotation.h"


#define GRAD_POINT_1 5
#define GRAD_POINT_2 10
@implementation ASZStarAnnotation

- (id)initWithFrame:(CGRect)frame withColor:(UIColor *)color 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.size = 4;
        self.scale = 1.5;
        self.color = color;
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    //UIColor* myLightRed = [UIColor colorWithRed:1 green: .922 blue: .616 alpha: 1];
    
    
    
    //// Gradient Declarations
    NSArray* gradient3Colors = nil;
    
    
    UIBezierPath *aPath = nil;
    
    
    
    gradient3Colors = [NSArray arrayWithObjects:
                       (id)self.color.CGColor,
                       (id)self.color.CGColor, nil];
    aPath = [UIBezierPath bezierPath];
    CGFloat s = self.scale;
    
    
    
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
    
    CGFloat gradient3Locations[] = {0, 1};
    
    //// General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    CGGradientRef gradient3 = CGGradientCreateWithColors(colorSpace, (CFArrayRef)CFBridgingRetain(gradient3Colors), gradient3Locations);
    
    
    //// Oval Drawing
    CGContextSaveGState(context);
    [aPath addClip];

        
    CGContextDrawRadialGradient(context, gradient3,
                                CGPointMake(self.size, self.size), GRAD_POINT_1,
                                CGPointMake(self.size, self.size), GRAD_POINT_2,
                                kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
  
    CGContextRestoreGState(context);
    CFBridgingRelease((__bridge CFTypeRef)(gradient3Colors));
    
    CGGradientRelease(gradient3);
    CGColorSpaceRelease(colorSpace);
    
    
    [[UIColor blackColor] setStroke];
    aPath.lineWidth = 0.5;
    [aPath stroke];
    
    
    
    //CGRect textFrame = CGRectMake(3, 3, RADIUS*2, 10);
    //[[UIColor darkTextColor] setFill];
    //[textContent drawInRect: textFrame withFont: [UIFont fontWithName: @"Gill Sans" size: 8]  ];
    
    
    //// Cleanup
    
    
    
}


@end
