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
@property (weak, nonatomic) IBOutlet UITableView *thisView;
@property (strong, nonatomic) IBOutlet ASSocialDataController *socialDataController;

@end

@implementation ASProfilePictureViewController
@synthesize nameBox;
@synthesize emailBox;
@synthesize passwordBox;
@synthesize image;

@synthesize imageView;
@synthesize saveImageBotton;



#pragma mark - TB arguments


- (IBAction)updateTapped:(id)sender {
    NSLog(@"Update User Profile %@\n",emailBox.text);
    [self.socialDataController updateUserData];
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
    imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.delegate=self;
    imagePickController.allowsEditing=NO;
    //imagePickController.showsCameraControls=YES;
    //This method inherit from UIView,show imagePicker with animation
    [self presentModalViewController:imagePickController animated:YES];
}

#pragma mark - When Tap Save Button
-(IBAction)saveImageAction:(id)sender
{
    UIImage *image=imageView.image;
    //save photo to photoAlbum
    UIImageWriteToSavedPhotosAlbum(image,self, @selector(CheckedImage:didFinishSavingWithError:contextInfo:), nil);
    saveImageBotton.enabled=NO;
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
    NSLog(@"OriginalImage%@",image);
    imageView.image=originalImage;
    saveImageBotton.enabled=YES;
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - When Tap Cancel

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
}

#pragma mark - Release object


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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


@end
