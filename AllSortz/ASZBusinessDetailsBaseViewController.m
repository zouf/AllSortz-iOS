//
//  ASZBusinessDetailsBaseViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/24/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessDetailsBaseViewController.h"
#import "ASZBusinessDetailsDataController.h"
#import "ASBusiness.h"
#import "ASZReviewViewController.h"
#import "ASZEditBusinessDetailsViewController.h"
#import "ASZBusinessTopicDataController.h"
#import "ASZBusinessTopicViewController.h"
#define CELL_WIDTH 201
#define CELL_MARGIN 8
#define DEFAULT_HEIGHT 52

@interface ASZBusinessDetailsBaseViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ASZBusinessDetailsBaseViewController
- (IBAction)switchDetailTab:(id)sender {
    [self.tableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.dataController updateView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions on page
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
    NSLog(@"%@\n",segue.identifier);
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
        detailsViewController.businessID  = self.businessID;        
        
    }
    else if ([segue.identifier isEqualToString:@"HealthDetailSegueID"])
    {
        UIViewController *dvc = (UIViewController*)segue.destinationViewController;
        UIImageView * healthImage = (UIImageView*)[dvc.view viewWithTag:2];
        UITextView * detailText = (UITextView*)[dvc.view viewWithTag:1];
        
        
        [healthImage setImage:[self.dataController getImageForGrade:self.dataController.business.healthGrade]];
        
        [detailText setText:self.dataController.business.healthViolationText];
        
    }
    else if ([segue.identifier isEqualToString:@"BusinessReviewSegueID"])
    {
        ASZReviewViewController *rvc = (ASZReviewViewController*)segue.destinationViewController;
        rvc.dataController.username = self.dataController.username;
        
        assert(rvc.dataController.username);
        
        rvc.dataController.password = self.dataController.password;
        
        rvc.dataController.UUID = self.dataController.UUID;
        rvc.dataController.currentLatitude = self.dataController.currentLatitude;
        rvc.dataController.currentLongitude = self.dataController.currentLongitude;
        rvc.businessID  = self.businessID;//.currentLongitude;
        rvc.businessName = self.dataController.business.name;
        
    }
    else if ([segue.identifier isEqualToString:@"BusinessTopicDetailID"])
    {
        id topics = [self.dataController.business valueForKey:@"topics"];
        NSLog(@"The sender is %@",sender);
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        
        NSArray *topicsArray = (NSArray*)topics;
        id topic = topicsArray[indexPath.row];
        NSInteger topicID = [[topic valueForKey:@"bustopicID"] integerValue];

        ASZBusinessTopicViewController *vc = (ASZBusinessTopicViewController*)segue.destinationViewController;
        
        [vc setBusiness:self.dataController.business];
        [vc setBusinessTopicName:[topic valueForKey:@"name"]];
        ASZBusinessTopicDataController *topicDetailsController = vc.dataController;
        ASZBusinessDetailsDataController *businessDetailsController = self.dataController;
        topicDetailsController.username = businessDetailsController.username;
        topicDetailsController.password = businessDetailsController.password;
        topicDetailsController.UUID = businessDetailsController.UUID;
        topicDetailsController.currentLatitude = businessDetailsController.currentLatitude;
        topicDetailsController.currentLongitude = businessDetailsController.currentLongitude;
        [vc setBusinessTopicID:topicID];
    }
}




#pragma mark - Storyboard segue


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
    
    [self setTableView:nil];
    [self setMainView:nil];
    [self setSegmentedController:nil];
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
                UIImageView *imageView = (UIImageView*)[self.mainView viewWithTag:1000];
                imageView.image = [self.dataController valueForKeyPath:@"business.image"];
            });
        } else {
            // Table view has to be refreshed on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataController updateView];
                [self.tableView reloadData];
            });
        }
        
    }
}



#pragma mark - Table view delegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentedController.selectedSegmentIndex) {
        case 1:
            return 250;
            break;
        case 2:
            return 45;
            break;
        case 0:
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
