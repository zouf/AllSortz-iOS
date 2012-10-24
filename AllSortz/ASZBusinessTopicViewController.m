//
//  ASZBusinessTopicViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/16/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessTopicViewController.h"
#import <QuartzCore/QuartzCore.h>
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

-(void)selectANode:(ASZCommentNode*)node
{
    
    for (ASZCommentNode *n in node.children)
    {
        n.inclusive = node.inclusive;
        [self selectANode:n];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger flatTreeIndex = indexPath.row + 1;
    ASZCommentNode *node = [[self.dataController.commentList.treeRoot flattenElements] objectAtIndex:flatTreeIndex];
    
    BOOL nowIncluded = !node.inclusive;
    
    if(nowIncluded) // if this is true, we're appending rows
    {
        node.inclusive = !node.inclusive;
        [self selectANode:node];
        NSMutableArray *insertRows = [[NSMutableArray alloc]init];
        int row = indexPath.row;
        row++;
        for(int i = 0; i < [node descendantCount]; i++)
        {
            [insertRows addObject:[NSIndexPath indexPathForRow:row+i inSection:indexPath.section]];
        }
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:insertRows withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else //deleting rows
    {
        NSMutableArray *deleteRows = [[NSMutableArray alloc]init];
        int row = indexPath.row;
        row++;
        for(int i = 0; i < [node descendantCount]; i++)
        {
            [deleteRows addObject:[NSIndexPath indexPathForRow:row+i inSection:indexPath.section]];
        }
        [self.tableView beginUpdates];
        node.inclusive = !node.inclusive;
        [self selectANode:node];
        [self.tableView deleteRowsAtIndexPaths:deleteRows withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];

    }
    
  
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}
-(UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == COMMENTLIST_SECTION)
    {
        UIView *backView = [[UIView alloc] initWithFrame:CGRectZero] ;
        return backView;
    }
    
    // TODO REPORT AN ERROR / FLAG
    return nil;
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
            
            CGFloat height = MAX(size.height, DEFAULT_BUSTOPIC_CONTENT_HEIGHT);
            
            return height + (CELL_MARGIN * 2);
            break;

        }
        case COMMENTLIST_SECTION:
        {
            
            
            NSArray *reviews   =  [self.dataController.commentList.treeRoot flattenElements] ;
            ASZCommentNode * node = reviews[indexPath.row + 1];
            if (node.inclusive)
            {
                NSString * text = [node getNodeText];
                
                
                CGSize constraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
                
                CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
                
                CGFloat height = MAX(size.height + START_POSITION, DEFAULT_HEIGHT);
                
                //add some room if you're going to comment
                if(node.replyTo)
                {
                    height += 75;
                    if(node.proposeChange)
                    {
                    
                        
                        NSString * proposedText = self.dataController.commentList.busTopicInfo;
                        CGSize proposedConstraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
                        CGSize size = [proposedText sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:10] constrainedToSize:proposedConstraint lineBreakMode:NSLineBreakByWordWrapping];
                        CGFloat newHeight = MAX(size.height, DEFAULT_BUSTOPIC_CONTENT_HEIGHT);
                        height += newHeight;
                        height += TEXTBOX_MARGIN*2;

                    }
                    height += TEXTBOX_MARGIN*2;

                }
                return height + (CELL_MARGIN * 2) ;
 
            }
            else
            {
                return COLLAPSED_HEIGHT;
            }
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
    [self.dataController rateCommentAsynchronously:node withRating:1 withIndex:indexPath];
}


- (IBAction)commentNegRateTap:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    ASZCommentNode *node = [self.dataController.commentList.treeRoot flattenElements][indexPath.row + 1];
    [self.dataController rateCommentAsynchronously:node withRating:0 withIndex:indexPath];

}

// When the user taps reply, this opens the box
- (IBAction)replyToComment:(id)sender {   
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

    ASZCommentNode *node = [[self.dataController.commentList.treeRoot flattenElements] objectAtIndex:indexPath.row + 1];
    
    node.replyTo = !node.replyTo;
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    return;
}


- (IBAction)proposeChange:(id)sender {
    //note i added the submit and textview as subviews of the cell itself, not the subview
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ASZCommentNode *node = [[self.dataController.commentList.treeRoot flattenElements] objectAtIndex:indexPath.row + 1];
    
    node.proposeChange = !node.proposeChange;
    
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

    
    return;
}



- (IBAction)submitComment:(id)sender {
    //note i added the submit and textview as subviews of the cell itself, not the subview
    UITableViewCell *cell = (UITableViewCell *)[sender superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    UITextView *tv = (UITextView*)[cell viewWithTag:REPLYBOX_TAG];
    UITextView *proposedView = (UITextView*)[cell viewWithTag:PROPOSECHANGE_TAG];

    ASZCommentNode *node = [[self.dataController.commentList.treeRoot flattenElements] objectAtIndex:indexPath.row + 1];
    
    [self.dataController submitComment:node :tv.text proposedChange:proposedView.text] ;

    return;
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
