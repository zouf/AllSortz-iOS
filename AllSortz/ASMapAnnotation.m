//
//  ASMapAnnotation.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/29/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASMapAnnotation.h"

@implementation ASMapAnnotation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initWithAnnotation:(ASMapPoint*)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self != nil)
    {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(60.0, 85.0);
        self.frame = frame;
        self.backgroundColor = [UIColor  clearColor];
        self.centerOffset = CGPointMake(30.0, 42.0);
        
   //     NSString *temperature = [NSString stringWithFormat:@"%0.2f", annotation.score];
  //      [temperature drawInRect:CGRectMake(0.0, 0.0, 15.0, 10.0) withFont:[UIFont fontWithName:@"Gill Sans" size:5.0]];
        

  

    }
    return self;
}

- (void)setAnnotation:(id <MKAnnotation>)annotation
{
    [super setAnnotation:annotation];
    
    // this annotation view has custom drawing code.  So when we reuse an annotation view
    // (through MapView's delegate "dequeueReusableAnnoationViewWithIdentifier" which returns non-nil)
    // we need to have it redraw the new annotation data.
    //
    // for any other custom annotation view which has just contains a simple image, this won't be needed
    //
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
     {
     ASMapPoint *mp = (ASMapPoint *)self.annotation;

     if (mp != nil)
     {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, 1);
        
        // draw the gray pointed shape:
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 14.0, 0.0);
        CGPathAddLineToPoint(path, NULL, 0.0, 0.0);
        CGPathAddLineToPoint(path, NULL, 55.0, 50.0);
        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGPathRelease(path);
        
        // draw the cyan rounded box
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 15.0, 0.5);
        
         CGFloat maxx = 10;
         CGFloat maxx_corner_pt = maxx - 10;
        
         CGFloat maxy = 10;
         CGFloat maxy_corner_pt = maxy-5;
         
         CGFloat corner_radius = 5;
         CGPathRelease(path);
        
         path = CGPathCreateMutable();
         CGPathMoveToPoint(path, NULL, 15.0, 0.5);
         CGPathAddArcToPoint(path, NULL, maxx, 00.5, 59.5, 5.0, corner_radius);
         CGPathAddArcToPoint(path, NULL, maxx, maxy, maxx_corner_pt, 69.5, corner_radius);
         CGPathAddArcToPoint(path, NULL, 10.5, maxy, 10.5, maxy_corner_pt, corner_radius);
         CGPathAddArcToPoint(path, NULL, 10.5, 0, 15.0, 0, corner_radius);
         CGContextAddPath(context, path);
        
        

        CGContextAddPath(context, path);
        CGContextSetFillColorWithColor(context, [UIColor grayColor].CGColor);
        CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGPathRelease(path);
             
               
        // draw the temperature string and weather graphic
        NSString *temperature = [NSString stringWithFormat:@"%0.2f", mp.score];
        [[UIColor blackColor] set];
        [temperature drawInRect:CGRectMake(15.0, 5.0, 50.0, 40.0) withFont:[UIFont fontWithName:@"Gill Sans" size:5]];
       /* NSString *imageName = nil;
        if (mp.score > 0.5)
            imageName = @"test-smaller.png";
        else
            imageName = @"Placeholder.png";*/
        //[[UIImage imageNamed:imageName] drawInRect:CGRectMake(12.5, 28.0, 45.0, 45.0)];
    }
}




@end
