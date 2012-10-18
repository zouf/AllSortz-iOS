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
#import "ASZRateView.h"


@interface ASZBusinessDetailsBaseViewController ()

@end

@implementation ASZBusinessDetailsBaseViewController

#pragma mark - Tab switching

-(void)createTableviewForTab
{
    UITableView *newView = nil;
    switch(self.segmentedController.selectedSegmentIndex)
    {
        case DISCUSSION_TAB:
        {
            newView = [[UITableView alloc]initWithFrame:self.tableView.frame style:UITableViewStylePlain];
            newView.delegate = self;
            [newView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
            newView.dataSource = self.dataController;
            break;
        }
        case INFO_TAB:
        {
            newView = [[UITableView alloc]initWithFrame:self.tableView.frame style:UITableViewStyleGrouped];
            newView.backgroundView = nil;
            self.mainView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
            //: CGRectMake(];
            newView.delegate = self;
            newView.dataSource = self.dataController;
            break;
        }
        case REDEEM_TAB:
        {
            newView = [[UITableView alloc]initWithFrame:self.tableView.frame style:UITableViewStylePlain];
            newView.delegate = self;
            newView.dataSource = self.dataController;
            break;
        }
        case REVIEW_TAB:
        {
            newView = [[UITableView alloc]initWithFrame:self.tableView.frame style:UITableViewStylePlain];
            newView.delegate = self;
            newView.dataSource = self.dataController;
            break;
        }
        default:
            break;
            
    }
    UIView *superview = self.tableView.superview;
    [self.tableView removeFromSuperview];
    [self setTableView:newView];
    [superview addSubview:self.tableView];
    self.mapView = [[MKMapView alloc] init];
    [self.tableView reloadData];
}

- (IBAction)switchDetailTab:(id)sender {
    [self createTableviewForTab];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) updateViewElements
{
    self.rateView.notSelectedImage = [UIImage imageNamed:@"empty-circle.png"];
    self.rateView.halfSelectedImage = [UIImage imageNamed:@"half-circle.png"];
    self.rateView.fullSelectedImage = [UIImage imageNamed:@"full-circle.png"];
    self.rateView.editable = NO;
    self.rateView.maxRating = MAX_RATING;

    
    ASZRateView *rv = self.rateView;
    UILabel *distance = (UILabel*)[self.mainView  viewWithTag:BUSINESSDIST_TAG];
    UILabel* businessName = (UILabel*)[self.mainView viewWithTag:BUSINESSNAMELABEL_TAG];
    
    if (self.dataController.business)
    {
        [rv setHidden:NO];
        [distance setHidden:NO];
        [businessName setHidden:NO];
        float rat = self.dataController.business.recommendation*MAX_RATING;
        businessName.text = self.dataController.business.name;
        distance.text = [NSString stringWithFormat:@"%0.2fmi.",[self.dataController.business.distance floatValue]];
        [rv setRating:rat];
        
    }
    else{
        [rv setHidden:YES];
        [distance setHidden:YES];
        [businessName setHidden:YES];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateViewElements];
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions on page
- (IBAction)editTapped:(id)sender {
    //create a view for editing. Has almost all of the same features as this view, but will allow for editing
    NSString * targetViewControllerIdentifier = @"EditBusinessViewControllerID";
    ASZEditBusinessDetailsViewController *detailsViewController =     (ASZEditBusinessDetailsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:detailsViewController];

    detailsViewController.dataController.business = self.dataController.business;
    detailsViewController.dataController.username = self.dataController.username;
    detailsViewController.dataController.password = self.dataController.password;
    detailsViewController.dataController.UUID = self.dataController.UUID;
    detailsViewController.dataController.currentLatitude = self.dataController.currentLatitude;
    detailsViewController.dataController.currentLongitude = self.dataController.currentLongitude;
    detailsViewController.businessID  = self.businessID;
    
    [self.navigationController presentViewController:navBar animated:YES completion:nil];
}

- (IBAction)reviewTapped:(id)sender {
    //create a view for editing. Has almost all of the same features as this view, but will allow for editing
    NSString * targetViewControllerIdentifier = @"ReviewBusinessControllerID";

    ASZReviewViewController *detailsViewController =     (ASZReviewViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
    UINavigationController *navBar=[[UINavigationController alloc]initWithRootViewController:detailsViewController];
    detailsViewController.dataController.username = self.dataController.username;
    detailsViewController.dataController.password = self.dataController.password;
    
    detailsViewController.dataController.UUID = self.dataController.UUID;
    detailsViewController.dataController.currentLatitude = self.dataController.currentLatitude;
    detailsViewController.dataController.currentLongitude = self.dataController.currentLongitude;
    detailsViewController.businessID  = self.businessID;

    [self.navigationController presentViewController:navBar animated:YES completion:nil];
}

- (IBAction)reportProblem:(id)sender {


    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Report a Problem"
                                                    message:@"Here we'll allow you to report an error to us about the business"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (IBAction)busTopicNegRateTap:(id)sender{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSMutableDictionary *topic = self.dataController.business.topics[indexPath.row];
    NSLog(@"User gave %@ a %d\n",[topic valueForKey:@"name"], 0);
    NSInteger btID = [[topic valueForKey:@"bustopicID"] intValue];
    CGFloat curRating = [[topic valueForKey:@"rating"] floatValue];

    NSLog(@"IN NEG VOTE: TOPIC IS %@\n",topic);
    NSLog(@"floorf(curRating*MAX_RATING) is %0.2f\n",floorf(curRating*MAX_RATING));
    CGFloat newRating= floorf(curRating*MAX_RATING) - 1;
    if (newRating < 0)
        newRating = 0;
    if (newRating > MAX_RATING)
        newRating = MAX_RATING;
    newRating = newRating / MAX_RATING;
    
    ASZRateView *rv1 = (ASZRateView*)[cell.contentView viewWithTag:TOPICUSER_RATING];
    [rv1 setRating:newRating*MAX_RATING];
    
    [topic setObject:[NSNumber numberWithFloat:newRating] forKey:@"rating"];
    NSLog(@"New rating is %f\n", newRating);
    [self.dataController rateBusinessTopicAsynchronously:btID withRating:newRating];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (IBAction)busTopicPosRateTap:(id)sender{
    UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];

      NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    NSMutableDictionary *topic = self.dataController.business.topics[indexPath.row];
    NSLog(@"Positive rating gave %@ a %d\n",[topic valueForKey:@"name"], 1);
    NSInteger btID = [[topic valueForKey:@"bustopicID"] intValue];
    NSLog(@"%@\n",topic);
    CGFloat curRating = [[topic valueForKey:@"rating"] floatValue];
    NSLog(@"IN POS VOTE: TOPIC IS %@\n",topic);

    CGFloat newRating= floorf(curRating*MAX_RATING) + 1;
    if (newRating < 0)
        newRating = 0;
    if (newRating > MAX_RATING)
        newRating = MAX_RATING;
    newRating = newRating / MAX_RATING;
    
    ASZRateView *rv1 = (ASZRateView*)[cell.contentView viewWithTag:TOPICUSER_RATING];
    [rv1 setRating:newRating*MAX_RATING];
    
    [topic setObject:[NSNumber numberWithFloat:newRating] forKey:@"rating"];
    NSLog(@"New rating is %f\n", newRating);
    [self.dataController rateBusinessTopicAsynchronously:btID withRating:newRating];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (IBAction)commentRateTap:(id)sender{
    UISegmentedControl*rateControl = (UISegmentedControl*)sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[[sender superview] superview]];
    NSDictionary *comment = self.dataController.reviewList.comments[indexPath.row];
    NSLog(@"User gave %@ a %d\n",[comment valueForKey:@"content"], rateControl.selectedSegmentIndex);
    NSInteger cID = [[comment valueForKey:@"commentID"] intValue];
    
    [self.dataController rateCommentAsynchronously:cID withRating:rateControl.selectedSegmentIndex];
}

#pragma mark - Storyboard segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"HealthDetailSegueID"])
    {
        UIViewController *dvc = (UIViewController*)segue.destinationViewController;
        UIImageView * healthImage = (UIImageView*)[dvc.view viewWithTag:2];
        UITextView * detailText = (UITextView*)[dvc.view viewWithTag:1];
        
        
        [healthImage setImage:[self.dataController getImageForGrade:self.dataController.business.healthGrade]];
        
        [detailText setText:self.dataController.business.healthViolationText];
        
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
    [self.dataController addObserver:self
                          forKeyPath:@"reviewList"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    [self.dataController getAllReviews:self.businessID];
    [self.dataController refreshBusinessAsynchronouslyWithID:self.businessID];
}

- (void)viewDidUnload {

    self.dataController = nil;
    
    [self setTableView:nil];
    [self setMainView:nil];
    [self setSegmentedController:nil];
    [self setRateView:nil];
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{

    [self.dataController removeObserver:self forKeyPath:@"reviewList"];
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
                [self updateViewElements];
                [self createTableviewForTab];
                //[self.tableView reloadData];
            });
        }
        
    }
    else if ([keyPath isEqual:@"reviewList"])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self createTableviewForTab];

        });
    }
}



#pragma mark - Table view delegate
// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    
    switch(self.segmentedController.selectedSegmentIndex)
    {
        case INFO_TAB:
        {
            if (section == LAST_SECTION)
                return 50;
            return 0;
        }
        case REVIEW_TAB:
        {
            return 50;
        }
        default:
            return 0;
    }
    
}


// custom view for footer. will be adjusted to default or specified footer height
// Notice: this will work only for one section within the table view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    
    switch(self.segmentedController.selectedSegmentIndex)
    {
        case INFO_TAB:
        {
            if (section == LAST_SECTION)
            {
                //allocate the view if it doesn't exist yet
                UIView * footerView  = [[UIView alloc] init];
                
                //we would like to show a gloosy red button, so get the image first
                
                [footerView setBackgroundColor:[UIColor clearColor]];
                //create the button
                UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                
                
                //the button should be as big as a table view cell
                [button setFrame:CGRectMake(10, 3, 100, 44)];
                
                //set title, font size and font color
                [button setTitle:@"Edit" forState:UIControlStateNormal];
                [button.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
                [button setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
                
                //set action of the button
                [button addTarget:self action:@selector(editTapped:)
                 forControlEvents:UIControlEventTouchUpInside];
                
                
                
                UIButton *reportProblem = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                
                
                //the button should be as big as a table view cell
                [reportProblem setFrame:CGRectMake(200, 3, 110, 44)];
                
                //set title, font size and font color
                [reportProblem setTitle:@"Report a Problem" forState:UIControlStateNormal];
                [reportProblem.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
                [reportProblem setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
                
                //set action of the button
                [reportProblem addTarget:self action:@selector(reportProblem:)
                       forControlEvents:UIControlEventTouchUpInside];
                
                
                //add the button to the view
                [footerView addSubview:reportProblem];
                [footerView addSubview:button];
                
                [footerView setAlpha:0.5];
                //return the view for the footer
                return footerView;
            }
            return nil;
        }
        case REVIEW_TAB:
        {
            //allocate the view if it doesn't exist yet
            UIView * footerView  = [[UIView alloc] init];
            
            //we would like to show a gloosy red button, so get the image first
            
            [footerView setBackgroundColor:[UIColor whiteColor]];
            UIButton *reviewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            
            //the button should be as big as a table view cell
            [reviewButton setFrame:CGRectMake(120, 3, 100, 44)];
            
            //set title, font size and font color
            [reviewButton setTitle:@"Review" forState:UIControlStateNormal];
            [reviewButton.titleLabel setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
            [reviewButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
            
            
            //set action of the button
            [reviewButton addTarget:self action:@selector(reviewTapped:)
                    forControlEvents:UIControlEventTouchUpInside];
            
            
            //add the button to the view
            [footerView addSubview:reviewButton];

            
            [footerView setAlpha:1];
            //return the view for the footer
            return footerView;

        }
            break;
        default:
            return nil;

    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.segmentedController.selectedSegmentIndex) {
        case REDEEM_TAB:
            return 65;
            break;
        case INFO_TAB:
            if (indexPath.section == 0)  //phone and website
            {
                return 35;
            }
            if(indexPath.section == 1) // address and map section
            {
                if(indexPath.row == ADDRESS_ROW)
                    return 50;
                else //MAP_ROW
                    return MAP_HEIGHT;
            }
            if(indexPath.section == 2) // health and type section
            {
                //health icon
                if (indexPath.row == 1)
                {
                    return 70;
                }
            }
            return 35;
            break;
        case DISCUSSION_TAB:
        {
            
            NSArray *topics =  self.dataController.business.topics;
            id topic = topics[indexPath.row];
            
            NSString * text = [topic valueForKey:@"summary"];
            
            CGSize constraint = CGSizeMake(CELL_WIDTH - (CELL_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:10] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
            CGFloat height = MAX(size.height, DEFAULT_HEIGHT);
            
            return height + (CELL_MARGIN * 2);
            break;
        }
        case REVIEW_TAB:
        {
            
            NSArray *reviews   =  self.dataController.reviewList.comments;
            id review = reviews[indexPath.row];
            
            NSString * text = [review valueForKey:@"content"];
            
            CGSize constraint = CGSizeMake(COMMENT_WIDTH - (CELL_MARGIN * 2), 20000.0f);
            
            CGSize size = [text sizeWithFont:[UIFont fontWithName:@"GillSans-Light"  size:14] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
            
            CGFloat height = MAX(size.height, DEFAULT_HEIGHT);
            
            return height + (CELL_MARGIN * 2);
            break;
        }
        default:
            return tableView.rowHeight;
            break;
    }
}

-(void)callBusTap:(id)sender
{

    UIDevice *device = [UIDevice currentDevice];
    if ([[device model] isEqualToString:@"iPhone"] ) {
        NSString * phoneString = [NSString stringWithFormat:@"tel://%@",self.dataController.business.phone];
        //NSString *phoneString = @"tel://8004664411";
        NSLog(@"Phone string is %@\n",phoneString);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneString]];
    } else {
        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Your device doesn't support this feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [Notpermitted show];
    }
   
}


-(void)busWebsiteTap:(id)sender
{

    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",self.dataController.business.website.path]];
    
    [[UIApplication sharedApplication]openURL:url];
    
    

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentedController.selectedSegmentIndex == INFO_TAB)
    {
        switch(indexPath.section)
        {
            case ADDRESS_MAP_SECTION:
            {
                
                CLLocationCoordinate2D mapCenter;
                mapCenter.latitude = self.dataController.business.lat;
                mapCenter.longitude = self.dataController.business.lng;


                //mkmapitem available (ios6)
                Class itemClass = [MKMapItem class];
                if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
                {
                    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:mapCenter addressDictionary: nil];
                    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
                    destination.name =self.dataController.business.name;
                    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
                    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
                                             MKLaunchOptionsDirectionsModeDriving,
                                             MKLaunchOptionsDirectionsModeKey, nil];
                    [MKMapItem openMapsWithItems: items launchOptions: options];
                    
                }
                else
                {
                    CLLocationCoordinate2D currentLocation = self.mapView.userLocation.location.coordinate;
                    // this uses an address for the destination.  can use lat/long, too with %f,%f format
                    NSString* address = [NSString stringWithFormat:@"%@ %@, %@ %@",self.dataController.business.address,self.dataController.business.city, self.dataController.business.state, self.dataController.business.zipcode];
                    NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%@",
                                     currentLocation.latitude, currentLocation.longitude,
                                     [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];

                }
                

                break;
            }
            case PHONE_WEBSITE_SECTION:
            {
                

                if (indexPath.row == WEBSITE_ROW)
                {
                    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",self.dataController.business.website.path]];

                    [[UIApplication sharedApplication]openURL:url];
    
                    
                }
                else
                {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.dataController.business.phone]];
                    if([[UIApplication sharedApplication] canOpenURL:url])
                    {
                        [[UIApplication sharedApplication] openURL:url];

                    }
                    else
                    {
                        NSLog(@"Could not place a call on your device.\n");
                    }
                }
                break;
            }
            default:
            {
                break;
            }
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
}

@end
