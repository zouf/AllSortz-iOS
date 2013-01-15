//
//  ASZHealthMenuViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/3/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZBusinessHealthViewController.h"
#import "ASZEditBusinessDetailsViewController.h"
#import "ASZNewRateView.h"
#import "ASBusiness.h"
#import "ASGlobal.h"
#import "ASZBusinessReviewsViewController.h"
#import "ASZMenuViewController.h"

@interface ASZBusinessHealthViewController ()

@end

@implementation ASZBusinessHealthViewController
@synthesize businessID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark - Handle tab changes
- (IBAction)newTabSelected:(id)sender {
    UISegmentedControl *segmented = (UISegmentedControl*)sender;
    if(segmented.selectedSegmentIndex == 0)
    {
        return;
    }
    else if (segmented.selectedSegmentIndex == 1)
    {
        ASZMenuViewController *menuController = (ASZMenuViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewID"];
        menuController.dataController.business = self.dataController.business;
        [self.navigationController pushViewController:menuController animated:YES];
    }
    else if(segmented.selectedSegmentIndex == 2)
    {
        ASZBusinessReviewsViewController *reviewsController = (ASZBusinessReviewsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"ReviewViewID"];
        reviewsController.dataController.business = self.dataController.business;
        [self.navigationController pushViewController:reviewsController animated:YES];    
    }
    else{
        NSLog(@"Wrong index!\n");
    }
    return;
}


#pragma mark - Update View Elements

-(void) updateViewElements
{
    
    if(!self.customRateView)
    {
        self.customRateView = [[ASZNewRateView alloc]initWithFrame:CGRectMake(10,40,30,150)];
        
        [self.mainView addSubview:self.customRateView];
    }
    UILabel *distance = (UILabel*)[self.mainView  viewWithTag:BUSINESSDIST_TAG];
    UILabel* businessName = (UILabel*)[self.mainView viewWithTag:BUSINESSNAMELABEL_TAG];
    
    if (self.dataController.business)
    {
        UIColor* starYellow = [UIColor colorWithRed: 1 green: .8 blue: 0 alpha: 1];
        
        [self.customRateView setVertical:NO];
        [distance setHidden:NO];
        [businessName setHidden:NO];
        float rat = roundf(self.dataController.business.recommendation*MAX_RATING);
        businessName.text = self.dataController.business.name;
        distance.text = [NSString stringWithFormat:@"%0.2fmi.",[self.dataController.business.distance floatValue]];
        [self.customRateView refresh:starYellow rating:rat];
        
    }
    else{
        [distance setHidden:YES];
        [businessName setHidden:YES];
    }
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];
        
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(25,0,100,30)];
    [lbl setFont:[UIFont fontWithName:@"Gill Sans" size:24]];
    [lbl setText:@"AllSortz"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView = lbl;
    [self.dataController  getAdditionalBusinessData];
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


#pragma mark - Storyboard segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"Segue!\n");
}




#pragma mark - Storyboard segue

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.segmentedController setSelectedSegmentIndex:0];    
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

    UIImageView *imageView = (UIImageView*)[self.mainView viewWithTag:BUSINESSIMAGEVIEW_TAG];
    imageView.image = [self.dataController valueForKeyPath:@"business.image"];

    
}

- (void)viewDidUnload {
    
    self.dataController = nil;
    
    [self setTableView:nil];
    [self setMainView:nil];
    [self setSegmentedController:nil];
    [self setCustomRateView:nil];
    [self setDataController:nil];
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
                UIImageView *imageView = (UIImageView*)[self.mainView viewWithTag:BUSINESSIMAGEVIEW_TAG];
                imageView.image = [self.dataController valueForKeyPath:@"business.image"];
            });
        } else {
            // Table view has to be refreshed on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateViewElements];
                //[self.tableView reloadData];
            });
        }
        
    }
    
}



#pragma mark - Table view delegate
// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView
heightForFooterInSection:(NSInteger)section {
    
     if (section == LAST_SECTION)
        return 50;
    return 0;

}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if(indexPath.section == 1) // address and map section
    {
        if(indexPath.row == 1)
            return MAP_HEIGHT;
    }
    return DEFAULT_CELL_HEIGHT;
}



-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(indexPath.row==1)
        {
            if(self.dataController.business.certLevel == 0)
            {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Request Certification"
                                                   message:[NSString stringWithFormat:@"Get %@ certified. Let us know you're interested in getting them certified", self.dataController.business.name]
                                                  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
                [alert show];
            }
            else if(self.dataController.business.certLevel==1)
            {
                
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Request Certificaiton"
                                                   message:[NSString stringWithFormat:@"The health and nutrition data at %@ is self reported. Let us know you're interested in getting the information certificated and validated!",
                                                            self.dataController.business.name] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
                [alert show];
                
            }
            else
            {
                UIAlertView *alert;
                alert = [[UIAlertView alloc] initWithTitle:@"Enjoy!"
                                                   message:[NSString stringWithFormat:@"The health and nutrition data at %@ is certified by SPE.",
                                                            self.dataController.business.name] delegate:self cancelButtonTitle:@"Thanks!" otherButtonTitles:nil];
                [alert show];
            }

        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

        switch(indexPath.section)
        {
            case 1:
            {
                switch(indexPath.row)
                {
                    case 0:  // address
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
   

                        
                        break;
                    }
                    case 1:  // map
                    {
                        break;
                    }
                    case 2:  //phone
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

                        break;
                    }
                    case 3:  //website
                    {
                        NSURL *url =self.dataController.business.website;
                        [[UIApplication sharedApplication]openURL:url];
                        break;
                    }
                }                
                break;
            }
            case 2:
            {
                
                switch(indexPath.row)
                {
                    case 0: //report a problem
                    {
                        UIAlertView *alert;
                        
                        alert = [[UIAlertView alloc] initWithTitle:@"Report a Problem"
                                                           message:@"See something that you think is inaccurate. Report it here."
                                                          delegate:self
                                                 cancelButtonTitle:@"Report"
                                                 otherButtonTitles:nil];
                        [alert show];

                        break;
                    }
                    case 1:  // request modification
                    {
                        UIAlertView *alert;
                        
                        alert = [[UIAlertView alloc] initWithTitle:@"Modify info"
                                                           message:@"See something wrong? Modify it"
                                                          delegate:self
                                                 cancelButtonTitle:@"Modify"
                                                 otherButtonTitles:nil];
                        [alert show];
                        break;
                    }
                }
                
                
                break;
            }
            default:
            {
                break;
            }
        }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    return;
}

#pragma mark - User Actions

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
@end
