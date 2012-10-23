//
//  ASProfilePictureViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/30/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASUserProfileViewController.h"

@interface ASUserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet ASUserProfileDataController *userProfileDataController;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

@end

@implementation ASUserProfileViewController
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
    [self.userProfileDataController.userProfile setUserEmail:emailBox.text];
    [self.userProfileDataController.userProfile setUserName:nameBox.text];
    [self.userProfileDataController.userProfile setUserPassword:passwordBox.text];
    [self.userProfileDataController uploadProfilePic:self.imageView.image];
    [self.userProfileDataController updateUserData];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
        imagePickController.delegate=self;
        imagePickController.allowsEditing=NO;
    }
    else
    {
        imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickController.delegate=self;
        imagePickController.allowsEditing=NO;
    }
    
    

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
    self.userProfileDataController = [[ASUserProfileDataController alloc]init];

    

    [self.userProfileDataController addObserver:self
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
    
    if (!self.userProfileDataController)
        self.userProfileDataController = [[ASUserProfileDataController alloc] init];
    if (!self.userProfileDataController.userProfile)
    {
        [self.userProfileDataController updateData];
        
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
        

        if (!self.userProfileDataController.userProfile.registered)
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
            self.nameBox.text = self.userProfileDataController.userProfile.userName;
            self.emailBox.text = self.userProfileDataController.userProfile.userEmail;
            self.imageView.image = self.userProfileDataController.userProfile.profilePicture;
        }
        

        [self.overlayView removeFromSuperview];

    }

    
}

-(void)imageDidLoad:(ASUser *)user
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = self.userProfileDataController.userProfile.profilePicture;
    });
}

@end
