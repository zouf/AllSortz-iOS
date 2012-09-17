//
//  ASZBusinessTopicViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/16/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessTopicViewController.h"

#import "ASZReviewViewController.h"
@interface ASZBusinessTopicViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButton;
- (IBAction)barButtonTapped:(id)sender;

@end

@implementation ASZBusinessTopicViewController
@synthesize barButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.dataController addObserver:self
                          forKeyPath:@"commentList"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    
    
    [self.dataController getCommentList:self.businessTopicID];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    [self setBarButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.dataController removeObserver:self forKeyPath:@"commentList"];

}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"commentList"]) {
        /*if ([self.dataController valueForKeyPath:@"review"] != nil) {
         dispatch_async(dispatch_get_main_queue(), ^{
         UIImageView *imageView = (UIImageView*)[self.tableView viewWithTag:1000];
         imageView.image = [self.dataController valueForKeyPath:@"business.image"];
         });
         } else {*/
        // Table view has to be refreshed on main thread
        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:NO];
        //}
        
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case 0:
        {
            return 135;
            break;
        }
        case 1:
            return 75;
            break;
        default:
            return 22;
            break;
    }
}

#pragma mark - Storyboard segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"WriteComment"]) {
        
        //create a view for editing. Has almost all of the same features as this view, but will allow for editing
        ASZReviewViewController *reviewViewController = destinationViewController;
        reviewViewController.dataController.username = self.dataController.username;
        reviewViewController.dataController.password = self.dataController.password;
        
        reviewViewController.dataController.UUID = self.dataController.UUID;
        reviewViewController.dataController.currentLatitude = self.dataController.currentLatitude;
        reviewViewController.dataController.currentLongitude = self.dataController.currentLongitude;
        reviewViewController.bustopicID  = self.businessTopicID;//.currentLongitude;
        
        
        
        
    }
   }

#pragma mark - uitextview

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.barButton.title = @"Submit Changes";
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.barButton.title = @"Comment";
}
- (IBAction)barButtonTapped:(id)sender {
    UITextView *tv = (UITextView*)[self.tableView viewWithTag:200];

    self.dataController.commentList.busTopicInfo = tv.text;
    NSLog(@"%@\n",self.dataController.commentList.busTopicInfo);
    [self.dataController submitModifiedBusTopicContent:self.businessTopicID];
    [self hideKeyboard];

}
@end