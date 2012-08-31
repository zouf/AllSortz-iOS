//
//  ASProfilePictureViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASSocialDataController.h"

@interface ASProfilePictureViewController :  UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property(nonatomic,retain)IBOutlet UIImageView *imageView;
@property(nonatomic,retain)IBOutlet UIBarButtonItem *saveImageBotton;
- (IBAction)passwordDone:(id)sender;
- (IBAction)touchOutside:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *nameBox;
@property (weak, nonatomic) IBOutlet UITextField *emailBox;
@property (weak, nonatomic) IBOutlet UITextField *passwordBox;

- (IBAction)updateTapped:(id)sender;

-(IBAction)showCameraAction:(id)sender;
-(IBAction)saveImageAction:(id)sender;

@end
