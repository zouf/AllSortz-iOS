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
- (IBAction)replyToComment:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *pageName;

@end

@implementation ASZBusinessTopicViewController
@synthesize pageName;
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
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (void)viewDidUnload
{
    [self setBarButton:nil];
    [self setPageName:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    
    [self.dataController addObserver:self
                          forKeyPath:@"commentList"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    [self.dataController getCommentList:self.businessTopicID];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.pageName setText:self.businessTopicName];
    
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // For selecting cell.
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];

}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.dataController removeObserver:self forKeyPath:@"commentList"];

    [super viewDidDisappear:animated];

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

        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:NO];

        
    }
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASZCommentNode *node = [[self.dataController.commentList.treeRoot flattenElements] objectAtIndex:indexPath.row + 1];
    if (node.children.count == 0) return;
    
    node.inclusive = !node.inclusive;
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch(indexPath.section)
    {
        case BUSTOPICCONTENT_SECTION:
        {
            NSString * text = self.dataController.commentList.busTopicInfo;
                        
            CGSize constraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
            CGFloat height = MAX(size.height, 145);
            
            return height + (CELL_MARGIN * 2);
            break;

        }
        case COMMENTLIST_SECTION:
        {
            
            
            NSArray *reviews   =  [self.dataController.commentList.treeRoot flattenElements] ;
            ASZCommentNode * node = reviews[indexPath.row + 1];
            
            NSString * text = node.content;
            
            CGSize constraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
            CGFloat height = MAX(size.height + START_POSITION, DEFAULT_HEIGHT);
            
            return height + (CELL_MARGIN * 2) ;
            break;
        }
        default:
            return tableView.rowHeight;
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
#pragma mark - Handle comment ratings
- (IBAction)commentPosRateTap:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    ASZCommentNode *node = [self.dataController.commentList.treeRoot flattenElements][indexPath.row + 1];
    NSInteger cID = node.commentID;
    
    [self.dataController rateCommentAsynchronously:cID withRating:1];
}


- (IBAction)commentNegRateTap:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    ASZCommentNode *node = [self.dataController.commentList.treeRoot flattenElements][indexPath.row + 1];
    NSInteger cID = node.commentID;
    
    [self.dataController rateCommentAsynchronously:cID withRating:0];
}


- (IBAction)replyToComment:(id)sender {

    NSString * targetViewControllerIdentifier = @"ReviewBusinessControllerID";
    
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ASZCommentNode *node = [[self.dataController.commentList.treeRoot flattenElements] objectAtIndex:indexPath.row + 1];

    
    
    ASZReviewViewController *detailsViewController =     (ASZReviewViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:detailsViewController];
    
    
    
    detailsViewController.dataController.username = self.dataController.username;
    detailsViewController.dataController.password = self.dataController.password;
    
    detailsViewController.dataController.UUID = self.dataController.UUID;
    detailsViewController.dataController.currentLatitude = self.dataController.currentLatitude;
    detailsViewController.dataController.currentLongitude = self.dataController.currentLongitude;
    detailsViewController.bustopicID  = self.businessTopicID;
    detailsViewController.replyToID  =  node.commentID; //;

    
    //[self.view addSubview:navBar.view];
    [self.navigationController presentViewController:navBar animated:YES completion:nil];



    
}


- (IBAction)barButtonTapped:(id)sender {
    UITextView *tv = (UITextView*)[self.tableView viewWithTag:200];

    self.dataController.commentList.busTopicInfo = tv.text;
    if(![self.barButton.title isEqualToString:@"Comment"])
    {
        [self.dataController submitModifiedBusTopicContent:self.businessTopicID];
        [self hideKeyboard];
    }
    else
    {
        NSString * targetViewControllerIdentifier = @"ReviewBusinessControllerID";
        
        ASZReviewViewController *detailsViewController =     (ASZReviewViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
        UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:detailsViewController];
        
        
        detailsViewController.dataController.username = self.dataController.username;
        detailsViewController.dataController.password = self.dataController.password;
        
        detailsViewController.dataController.UUID = self.dataController.UUID;
        detailsViewController.dataController.currentLatitude = self.dataController.currentLatitude;
        detailsViewController.dataController.currentLongitude = self.dataController.currentLongitude;
        detailsViewController.bustopicID  = self.businessTopicID;
        detailsViewController.replyToID = -1;
        
        //[self.view addSubview:navBar.view];
        [self.navigationController presentViewController:navBar animated:YES completion:nil];
    }



}
@end
