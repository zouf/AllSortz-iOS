///
//  ASMapViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASMapViewController.h"

#import "ASZBusinessDetailsDataController.h"

#import "ASListingsViewController.h"

#import "ASZBusinessListingSingleton.h"

#import "ASURLEncoding.h"

#import "ASZCustomAnnotation.h"

#import "ASZBusinessDetailsBaseViewController.h"
@interface ASMapViewController ()
    

@property (weak, nonatomic) IBOutlet MKMapView *mv;
@property (weak, nonatomic) NSMutableArray *businessPoints;
@property(strong, nonatomic) UISearchBar*  searchBar;
@property(nonatomic, assign) BOOL  searchIsOn;

@property(assign) MKCoordinateRegion prevRegion;

@property NSOperationQueue *queue;  // Assume we only need one for now

//- (IBAction)refreshTheMap:(id)sender;

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView;
- (IBAction)goToMyLocation:(id)sender;

@end

@implementation ASMapViewController
@synthesize mv;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listingsTableDataController =[[ASZBusinessListingSingleton sharedDataListing] getListDataController];
    
    
    // Do any additional setup after loading the view from its
    
    [self.navigationController.navigationBar setTintColor:AS_DARK_BLUE];
    
    UIImage *myLocButtonImage = [UIImage imageNamed:@"22-location-arrow.png"];
    UIBarButtonItem *myLoc = [[UIBarButtonItem alloc] initWithImage:myLocButtonImage landscapeImagePhone:myLocButtonImage  style:UIBarButtonItemStyleBordered target:self action:@selector(goToMyLocation:)];
    
    
    UIImage *directionImage = [UIImage imageNamed:@"40-forward.png"];
    UIBarButtonItem *directions = [[UIBarButtonItem alloc] initWithImage:directionImage landscapeImagePhone:directionImage  style:UIBarButtonItemStyleBordered target:self action:@selector(tapButton:)];
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.leftBarButtonItems = [NSArray arrayWithObjects:myLoc,directions, nil];
    
    

    self.searchBar  = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 130, 40)] ;
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchBar.delegate = self;

    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    
    
    
    
    
    UIImage *bookmarkImage = [UIImage imageNamed:@"16-tag.png"];
    UIBarButtonItem *bookmarks = [[UIBarButtonItem alloc] initWithImage:bookmarkImage landscapeImagePhone:bookmarkImage  style:UIBarButtonItemStyleBordered target:self action:@selector(tapButton:)];
    
    
    UIImage *addBusinessImage = [UIImage imageNamed:@"05-plus.png"];
    UIBarButtonItem *addBusiness = [[UIBarButtonItem alloc] initWithImage:addBusinessImage landscapeImagePhone:addBusinessImage  style:UIBarButtonItemStyleBordered target:self action:@selector(tapButton:)];
    
    item.rightBarButtonItems = [NSArray arrayWithObjects:addBusiness,bookmarks,searchBarButtonItem, nil];
    
    
    [self.navigationController.navigationBar pushNavigationItem:item animated:NO];
    
     
    [self.listingsTableDataController addObserver:self
                                       forKeyPath:@"businessList"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    

	
    
    [self.mv setMapType:MKMapTypeStandard];
    [self.mv  setZoomEnabled:YES];
    [self.mv  setScrollEnabled:YES];
    self.mv .showsUserLocation = YES;
    MKCoordinateRegion region = { {0.0, 0.0 }, { 0.0, 0.0 } };
    region.center.latitude = 40.350816;
    region.center.longitude = -74.654278;
    region.span.longitudeDelta = 0.015f;
    region.span.latitudeDelta = 0.015f;
    [self.mv  setRegion:region animated:YES];
    [self.mv  setDelegate:self];
    
       
    
    // on initial load of this view controller, update from the server if there's no business list
    if (!self.listingsTableDataController.businessList)
    {
        NSLog(@"Map view entered on latitude %f\n",self.mv.region.center.latitude);
        [self.listingsTableDataController setRect:self.mv.region];
        [self.listingsTableDataController setUpdateAList:NO];
        [self.listingsTableDataController updateData];
        
    }
    else // business list comes from somewhere else
    {
        [self loadMapElements];
        [self zoomToFitMapAnnotations:self.mv];
    }

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // For selecting cell.
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  //  [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];


    //this should never be called. but, in case we get to a situation where there is no businessList, call update on the server
    if (!self.listingsTableDataController.businessList)
    {
       // NSLog(@"Map view entered on latitude %f\n",self.mv.region.center.latitude);
        [self.listingsTableDataController setRect:self.mv.region];
        [self.listingsTableDataController setUpdateAList:NO];
        [self.listingsTableDataController updateData];
        
    }
    
    // fit to the elements on the map
    //[self zoomToFitMapAnnotations:self.mv];

}

-(void)openSearchBox:(id)sender
{
    NSLog(@"Tap search!\n");
    [self.searchBar sizeToFit];
    
}

- (IBAction)refreshTapped:(id)sender {
    [self.listingsTableDataController setRect:self.mv.region];
    [self.listingsTableDataController setSearchQuery:nil];
    [self.listingsTableDataController setUpdateAList:NO];
    [self.listingsTableDataController updateData];
}


#pragma mark - Load as scroll
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    
  //  NSLog(@"Map view entered on latitude %f\n",self.mv.region.center.latitude);
    
 
    
    MKCoordinateRegion region = self.mv.region;
 //   CLLocationCoordinate2D location =  self.prevRegion.center;
    
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
  /*  if (
        location.latitude  >= northWestCorner.latitude &&
        location.latitude  <= southEastCorner.latitude &&
        
        location.longitude >= northWestCorner.longitude &&
        location.longitude <= southEastCorner.longitude
        )
    {
        // Old center is in this region dont update
        NSLog(@"Center (%f, %f) span (%f, %f) user: (%f, %f)| IN!", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta, location.latitude, location.longitude);
        self.prevRegion = self.mv.region;
        
    }else {*/
        
        // User location (location) out of the region - NOT ok :-(
        //NSLog(@"Center (%f, %f) span (%f, %f) user: (%f, %f)| OUT!", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta, location.latitude, location.longitude);
        [self.listingsTableDataController setRect:self.mv.region];
        [self.listingsTableDataController setUpdateAList:NO];
        [self.listingsTableDataController updateData];
        self.prevRegion = self.mv.region;
    //}
    



}


-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;
    
    if ([self.listingsTableDataController.businessList.entries count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(ASMapPoint* annotation in mapView.annotations)
    {
        //ignore the user's location annotation
        if ((MKUserLocation*)annotation==self.mv.userLocation)
            continue;
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

- (IBAction)goToMyLocation:(id)sender {
    
    
    MKCoordinateRegion region;
    if (!self.mv.userLocation.coordinate.latitude)
        return;
    region.center.latitude= self.mv.userLocation.coordinate.latitude;
    region.center.longitude= self.mv.userLocation.coordinate.longitude;

    region.span = self.mv.region.span;
//    region = [self.mv regionThatFits:region];
    [self.mv setRegion:region animated:YES];

    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.searchBar isFirstResponder] && [touch view] != self.searchBar)
    {
        [self.searchBar resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}


//this is the required method implementation for MKMapView annotations
- (MKAnnotationView *) mapView:(MKMapView *)thisMapView
             viewForAnnotation:(ASMapPoint *)annotation
{    
    if ((MKUserLocation*)annotation==self.mv.userLocation)
        return nil;
    static NSString *AnnotationViewID = @"annotationViewID";
    
    MKAnnotationView *pinView = nil;
    ASZCustomAnnotation *cust = nil;
    
    //TODO figure out how to use the reuse identifier
    //pinView = (MKAnnotationView *)[self.mv dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    //if ( pinView == nil )
    //{
    pinView = [[MKAnnotationView alloc]
                   initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    
    //pinView.pinColor = MKPinAnnotationColorGreen;
    pinView.canShowCallout = YES;
    //pinView.animatesDrop = YES;
    
    CGFloat colorScale = annotation.business.recommendation + .25;
    if(colorScale < .25)
        colorScale = .25;
    
    if(colorScale > 1)
        colorScale = 1;
    
    
    
    
    
    UIColor *scaleColor =  [UIColor colorWithRed:colorScale green: colorScale blue: 0 alpha: 1];

    
    if(annotation.business.starred)
    {
        pinView.image = [UIImage imageNamed:@"02-star.png" withColor:scaleColor];
    }
    else
    {
        pinView.image = [UIImage imageNamed:@"12-flag.png" withColor:AS_DARK_BLUE];

    }
    
    CGSize sz = pinView.image.size;
    
    CGRect r = pinView.frame;
    
    r.size = sz;
    
    [pinView setFrame:r];
    
    //cust = [[ASZCustomAnnotation alloc]initWithFrame:CGRectMake(-10,-10,25,25) rec:annotation.business.recommendation];
    //[cust setStarred:annotation.business.starred];

    //[pinView addSubview:cust];
    //[cust setBackgroundColor:[UIColor clearColor]];

    //}
    
    
    
   /* ASZRateView *rateView = [[ASZRateView alloc] initWithFrame:CGRectMake(0,35,30,20)];
    rateView.notSelectedImage = [UIImage imageNamed:@"empty-circle.png"];
    rateView.halfSelectedImage = [UIImage imageNamed:@"half-circle.png"];
    rateView.fullSelectedImage = [UIImage imageNamed:@"full-circle.png"];
    rateView.editable = NO;
    rateView.maxRating = 5;
    [rateView setRating:annotation.business.recommendation*5];
    UIView *leftCAV = [[UIView alloc] initWithFrame:CGRectMake(0,0,36,36)];
     [leftCAV addSubview : myImageView];
     [leftCAV addSubview : rateView];*/
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pinView.rightCalloutAccessoryView = rightButton;
    
    
    

    
    // Change this to rightCallout... to move the image to the right side
    pinView.annotation = annotation;
    
    
    // Fetch image asynchronously
    if (!annotation.business.businessPhoto)
    {
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:annotation.business.imageURLString]];
        void (^imageHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
            annotation.business.businessPhoto = [UIImage imageWithData:data];
            UIImageView *myImageView = [[UIImageView alloc] initWithImage:annotation.business.businessPhoto];
            myImageView.frame = CGRectMake(0,0,34,34); // Change the size of the image to fit the callout
            pinView.leftCalloutAccessoryView = myImageView;
        };
        if (!self.queue)
            self.queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:imageRequest queue:self.queue completionHandler:imageHandler];

    }
    else
    {
        UIImageView *myImageView = [[UIImageView alloc] initWithImage:annotation.business.businessPhoto];
        myImageView.frame = CGRectMake(0,0,34,34); // Change the size of the image to fit the callout
        pinView.leftCalloutAccessoryView = myImageView;

        
        
        
    }

    return pinView;
}

#pragma mark - Annotation Selection

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    ASMapPoint *mp = (ASMapPoint*)view.annotation;
    NSString *targetViewControllerIdentifier = @"ShowBusinessDetails2";
    ASZBusinessDetailsBaseViewController *vc = (ASZBusinessDetailsBaseViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
    [vc setBusinessID:mp.tag];
    
    
    ASZBusinessDetailsDataController *detailsDataController = vc.dataController;
    ASBusinessListDataController *listDataController = self.listingsTableDataController;
    detailsDataController.username = [listDataController.deviceInterface getStoredUname];
    detailsDataController.password = [listDataController.deviceInterface getStoredPassword];
    
    assert(detailsDataController.username);
    detailsDataController.UUID = [listDataController.deviceInterface getDeviceUIUD];
    detailsDataController.currentLatitude = listDataController.currentLocation.coordinate.latitude;
    detailsDataController.currentLongitude = listDataController.currentLocation.coordinate.longitude;

    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController  pushViewController:vc animated:YES];
//    [self.navigationController setNavigationBarHidden:NO];
    
}
- (void)viewDidUnload {
    [self setMv:nil];

    [self setNavItem:nil];
    [super viewDidUnload];
}



#pragma mark - Key-value observing

-(void)loadMapElements
{
    
    UIView *actionBackground = (UIView*)[self.mv viewWithTag:1000];
    if(!actionBackground)
    {
        actionBackground = [[UIView alloc]initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width,25)];
        [actionBackground setBackgroundColor:[UIColor colorWithWhite:.3333f alpha:.7]];
        actionBackground.tag = 1000;
        [self.mv addSubview:actionBackground];
    }
    
    
    UILabel *searchText = (UILabel*)[actionBackground viewWithTag:1001];
    if(!searchText)
    {
        searchText = [[UILabel alloc]initWithFrame:CGRectMake(0,0,[UIScreen mainScreen].bounds.size.width-100,25)];
        [actionBackground addSubview:searchText];
        [searchText setBackgroundColor:[UIColor colorWithWhite:.333 alpha:1]];
        [searchText setFont:[UIFont fontWithName:@"Gill Sans" size:14]];
        searchText.tag = 1001;
        [searchText setBackgroundColor:[UIColor clearColor]];
    }
    searchText.hidden = NO;
    searchText.text = self.listingsTableDataController.businessList.searchText;
    
    
    UILabel *action = (UILabel*)[actionBackground viewWithTag:1002];
    if(!action)
    {
        action = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-100,0,100,25)];
        [action setBackgroundColor:[UIColor colorWithWhite:.333 alpha:1]];
        [action setFont:[UIFont fontWithName:@"GillSans-Light" size:14]];
        [actionBackground addSubview:action];
        action.tag = 1002;
        [action setBackgroundColor:[UIColor clearColor]];
    }
    
    if (self.listingsTableDataController.searchQuery)
    {
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshTapped:)];
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        singleTap.cancelsTouchesInView = NO;
        [actionBackground addGestureRecognizer:singleTap];

        action.text = @"Tap to clear";

    }
    else
    {
        action.text = @"";
        
    }
    // TODO: can we loadMapElements only if there's been a change to the business list?
    
    //create annotations and add to the busStopAnnotations array
    NSMutableArray *myArray = [[NSMutableArray alloc] init];
    self.businessPoints = myArray;
    
    
    
    for (ASListing *bus in self.listingsTableDataController.businessList.entries)
    {
        CLLocationCoordinate2D annotationCenter;
        annotationCenter.latitude = bus.latitude;
        annotationCenter.longitude = bus.longitude;
        NSString *scoreText = [NSString stringWithFormat:@"%0.0f of %d stars.",roundf(bus.recommendation*MAX_RATING),MAX_RATING];
        
        
        ASMapPoint *mp = [[ASMapPoint alloc] initWithCoordinate:annotationCenter withScore:bus.recommendation withTag:bus.ID withTitle:bus.businessName withSubtitle:scoreText];
        
  
        
        mp.business = bus;
        [self.businessPoints addObject:mp];
    }

    // remove all annotations
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
    for (id annotation in self.mv.annotations)
        if (annotation != self.mv.userLocation)
        {
            
            
            [toRemove addObject:annotation];
        }
    [self.mv removeAnnotations:toRemove];
    //add annotations array to the mapView
    [self.mv removeAnnotations:toRemove];
    
    [self.mv addAnnotations:self.businessPoints];
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"businessList"]) {
        [self loadMapElements];
        if (self.listingsTableDataController.businessList.newAddress)
        {
            [self zoomToFitMapAnnotations:self.mv];
        }
    }

}


/*
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    id destinationViewController = segue.destinationViewController;
    
    if([segue.identifier isEqualToString:@"NewSort"]){
        UINavigationController *nv = (UINavigationController *)(destinationViewController);
        ASSortViewController *nsvc = (ASSortViewController *)nv.topViewController;
        [self.listingsTableDataController setRect:self.mv.region];
        nsvc.delegate = self.listingsTableDataController;
    }
    else if ([segue.identifier isEqualToString:@"ShowBusinessDetailsSegue"]) {
        ASZBusinessDetailsViewController *detailsViewController = destinationViewController;
        ASZBusinessDetailsDataController *detailsDataController = detailsViewController.dataController;
        ASBusinessListDataController *listDataController = self.listingsTableDataController;
        detailsDataController.username = [listDataController.deviceInterface getStoredUname];
        detailsDataController.password = [listDataController.deviceInterface getStoredPassword];
        detailsDataController.UUID = [listDataController.deviceInterface getDeviceUIUD];
        detailsDataController.currentLatitude = listDataController.currentLocation.coordinate.latitude;
        detailsDataController.currentLongitude = listDataController.currentLocation.coordinate.longitude;

    }

}*/


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    ASQuery *newQ = [[ASQuery alloc] init];
    newQ.distanceWeight = [NSString stringWithFormat:@"0"];
    newQ.searchText =  searchBar.text;
    [self.listingsTableDataController setSearchQuery:newQ];
    
   // NSLog(@"region is at %f\n",self.mv.region.center.latitude);
    [self.listingsTableDataController setRect:self.mv.region];
    [self.listingsTableDataController setUpdateAList:NO];
    [self.listingsTableDataController updateWithQuery];
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void) searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    controller.searchBar.showsCancelButton = YES;
}

@end
