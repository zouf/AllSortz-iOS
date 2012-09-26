//
//  ASZViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/25/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASZRateView.h"

@interface ASZRateViewController : UIViewController <RateViewDelegate>

@property (weak, nonatomic) IBOutlet ASZRateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
