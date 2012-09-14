//
//  ASZBusinessDetailsViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 8/9/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessDetailsViewController.h"

#import "ASZBusinessDetailsDataController.h"

#import "ASZTopicDetailViewController.h"


#import "ASZEditBusinessDetailsViewController.h"

#import "ASBusiness.h"

#define CELL_WIDTH 224
#define CELL_MARGIN 8
#define DEFAULT_HEIGHT 52

@implementation ASZBusinessDetailsViewController

- (IBAction)editTapped:(id)sender {
    [self performSegueWithIdentifier:@"EditBusinessSegue" sender:self];
}
- (IBAction)busTopicRateTap:(id)sender forEvent:(UIEvent *)event {
    UISegmentedControl*rateControl = (UISegmentedControl*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    NSDictionary *topic = self.dataController.business.topics[indexPath.row];
    NSLog(@"User gave %@ a %d\n",[topic valueForKey:@"name"], rateControl.selectedSegmentIndex);
    NSInteger btID = [[topic valueForKey:@"bustopicID"] intValue];
    
    [self.dataController rateBusinessTopicAsynchronously:btID withRating:rateControl.selectedSegmentIndex];
    
    
}

#pragma mark - Storyboard segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"EditBusinessSegue"]) {
        
        //create a view for editing. Has almost all of the same features as this view, but will allow for editing
        UINavigationController *nv = destinationViewController;
        ASZEditBusinessDetailsViewController *detailsViewController = (ASZEditBusinessDetailsViewController *)nv.topViewController;
        detailsViewController.dataController.business = self.dataController.business;
        detailsViewController.dataController.username = self.dataController.username;
        detailsViewController.dataController.password = self.dataController.password;

        detailsViewController.dataController.UUID = self.dataController.UUID;
        detailsViewController.dataController.currentLatitude = self.dataController.currentLatitude;
        detailsViewController.dataController.currentLongitude = self.dataController.currentLongitude;
        detailsViewController.businessID  = self.businessID;//.currentLongitude;

        

        
    }
    else if ([segue.identifier isEqualToString:@"HealthDetailSegueID"])
    {
        UIViewController *dvc = (UIViewController*)segue.destinationViewController;
        UIImageView * healthImage = (UIImageView*)[dvc.view viewWithTag:2];
        UITextView * detailText = (UITextView*)[dvc.view viewWithTag:1];
        

        [healthImage setImage:[self.dataController getImageForGrade:self.dataController.business.healthGrade]];
        
        [detailText setText:self.dataController.business.healthViolationText];

    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self.dataController addObserver:self
                          forKeyPath:@"business"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    [self.dataController addObserver:self
                          forKeyPath:@"business.image"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    
    [self.dataController refreshBusinessAsynchronouslyWithID:self.businessID];
}

- (void)viewDidUnload {
    [self.dataController removeObserver:self forKeyPath:@"business"];
    [self.dataController removeObserver:self forKeyPath:@"business.image"];
    self.dataController = nil;

    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.dataController removeObserver:self forKeyPath:@"business"];
    [self.dataController removeObserver:self forKeyPath:@"business.image"];
    [super viewDidDisappear:animated];
}


#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"business"] || [keyPath isEqual:@"business.image"]) {
        if ([self.dataController valueForKeyPath:@"business.image"] != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = (UIImageView*)[self.tableView viewWithTag:1000];
                imageView.image = [self.dataController valueForKeyPath:@"business.image"];
            });
        } else {
            // Table view has to be refreshed on main thread
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                        waitUntilDone:NO];
        }
        
    }
}

- (IBAction)dialBusinessPhone {
    // TODO: Implement once taps are passed through
    return;
}

- (IBAction)goToURL:(id)sender {
    //TODO implement
    return;
}

#pragma mark - Handle taps to rating



#pragma mark - Table view delegate



- (void)tableView:(UITableView *)tableViewdidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case ASZBusinessDetailsHeaderSection:
            return 230;
            break;
        case ASZBusinessDetailsInfoSection:
            return 22;
        case ASZBusinessDetailsTopicSection:
        {
                        
            NSArray *topics =  self.dataController.business.topics;
            id topic = topics[indexPath.row];
            
            NSString * text = [topic valueForKey:@"summary"];

            CGSize constraint = CGSizeMake(CELL_WIDTH - (CELL_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light" size:12] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
            
            CGFloat height = MAX(size.height, DEFAULT_HEIGHT);
            
            return height + (CELL_MARGIN * 2);
            break;
        }
        default:
            return tableView.rowHeight;
            break;
    }
    }
    
    @end