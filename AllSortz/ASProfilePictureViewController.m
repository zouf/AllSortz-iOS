//
//  ASProfilePictureViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASProfilePictureViewController.h"

@interface ASProfilePictureViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet ASSocialDataController *socialDataController;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@end

@implementation ASProfilePictureViewController
@synthesize overlayView;
@synthesize nameBox;
@synthesize emailBox;
@synthesize passwordBox;
@synthesize image;

@synthesize imageView;
@synthesize saveImageButton;



#pragma mark - TB arguments


- (IBAction)updateTapped:(id)sender {
    NSLog(@"Update User Profile %@\n",emailBox.text);
    [self.socialDataController.userProfile setUserEmail:emailBox.text];
    [self.socialDataController.userProfile setUserName:nameBox.text];
    [self.socialDataController.userProfile setUserPassword:passwordBox.text];

    [self.socialDataController updateUserData];
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=self.overlayView.center;
    
    [activityView startAnimating];
    
    [self.overlayView addSubview:activityView];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	[textField endEditing:YES];
    
	return YES;
    
}


#pragma mark - Show camera

-(IBAction)showCameraAction:(id)sender
{
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    //You can use isSourceTypeAvailable to check
    
    imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
    imagePickController.delegate=self;
    imagePickController.allowsEditing=NO;
    //imagePickController.showsCameraControls=YES;
    //This method inherit from UIView,show imagePicker with animation
    [self presentViewController:imagePickController animated:YES completion:nil];
}

#pragma mark - When Tap Save Button
-(IBAction)saveImageAction:(id)sender
{
    //save photo to photoAlbum
    UIImageWriteToSavedPhotosAlbum(self.imageView.image,self, @selector(CheckedImage:didFinishSavingWithError:contextInfo:), nil);
    saveImageButton.enabled=NO;
}

#pragma mark - Check Save Image Error
- (void)CheckedImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
    UIAlertView *alert;
    
    if (error) {
        alert = [[UIAlertView alloc] initWithTitle:@"ERROR"
                                           message:[error description]
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    } else {
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"The image has been stored in an album"
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    }
    
    [alert show];
}

#pragma mark - When Finish Shoot

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *originalImage=[info objectForKey:UIImagePickerControllerOriginalImage];
    //Show OriginalImage size
    NSLog(@"Original Image%@",image);
    imageView.image=originalImage;
    saveImageButton.enabled=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - When Tap Cancel

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Release object


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.socialDataController = [[ASSocialDataController alloc]init];

    

    [self.socialDataController addObserver:self
                                       forKeyPath:@"userProfile"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=self.overlayView.center;
    
    [activityView startAnimating];
    
    [self.overlayView addSubview:activityView];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // For selecting cell.
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setImage:nil];
    [self setNameBox:nil];
    [self setEmailBox:nil];
    [self setPasswordBox:nil];
    [self setOverlayView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Imitate default behavior of UITableViewController
    // deselectRowAtIndexPath:animated: should be fine taking a possible nil
    
    // Download data automatically if there's no data source
    
    if (!self.socialDataController)
        self.socialDataController = [[ASSocialDataController alloc] init];
    if (!self.socialDataController.userProfile)
    {
        [self.socialDataController updateData];
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

// Key-value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"userProfile"])
    {
        

        if (!self.socialDataController.userProfile.registered)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Register"
                                                            message:@"Register with an email, username, and password"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            self.nameBox.text = self.socialDataController.userProfile.userName;
            self.emailBox.text = self.socialDataController.userProfile.userEmail;
            



        }
        

        [self.overlayView removeFromSuperview];

    }
    
}

@end
