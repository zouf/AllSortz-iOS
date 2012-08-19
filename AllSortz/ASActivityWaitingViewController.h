//
//  ASActivityWaitingViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@interface ASActivityWaitingViewController : UIViewController
{
    UILabel *activityLabel;
    UIActivityIndicatorView *activityIndicator;
    UIView *container;
    CGRect frame;
}
-(id)initWithFrame:(CGRect) theFrame;
@end
