///
//  ASMapViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASMapViewController.h"


#import "ASListingsViewController.h"

#import "ASZBusinessListingSingleton.h"

#import "ASGlobal.h"

#import "ASZCustomAnnotation.h"

#import "ASZBusinessHealthViewController.h"
@interface ASMapViewController ()
    

@property (weak, nonatomic) IBOutlet MKMapView *mv;
@property (weak, nonatomic) NSMutableArray *businessPoints;
@property(strong, nonatomic) UISearchBar*  searchBar;

@property NSOperationQueue *queue;  // Assume we only need one for now

//- (IBAction)refreshTheMap:(id)sender;

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView;
- (IBAction)goToMyLocation:(id)sender;

@end

@implementation ASMapViewController
@synthesize mv;

-(IBAction)addBusinessTapped:(id)sender
{
    
    ASAddBusinessViewController *vc = (ASAddBusinessViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"AddBusinessViewID"];
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController  pushViewController:vc animated:YES];
    
}
-(IBAction)tapBookmarks:(id)sender
{
    
    UIAlertView *alert;
  
    alert = [[UIAlertView alloc] initWithTitle:@"Bookmarks"
                                           message:@"Coming soon. A list of your favorite places to go, as well as recently visited places."
                                          delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
        [alert show];

    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listingsTableDataController =[[ASZBusinessListingSingleton sharedDataListing] getListDataController];

    UIImage *myLocButtonImage = [UIImage imageNamed:@"22-location-arrow.png"];
    UIBarButtonItem *myLoc = [[UIBarButtonItem alloc] initWithImage:myLocButtonImage landscapeImagePhone:myLocButtonImage  style:UIBarButtonItemStyleBordered target:self action:@selector(goToMyLocation:)];
    
    
    /*UIImage *directionImage = [UIImage imageNamed:@"40-forward.png"];
    UIBarButtonItem *directions = [[UIBarButtonItem alloc] initWithImage:directionImage landscapeImagePhone:directionImage  style:UIBarButtonItemStyleBordered target:self action:@selector(tapButton:)];*/
    
    UINavigationItem *item = [[UINavigationItem alloc] init];
    item.leftBarButtonItems = [NSArray arrayWithObjects:myLoc, nil];
    
    

    self.searchBar  = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 220, 40)] ;
    self.searchBar.backgroundImage = [[UIImage alloc] init];
    self.searchBar.delegate = self;

    UIBarButtonItem *searchBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.searchBar];
    
  /*  UIImage *bookmarkImage = [UIImage imageNamed:@"16-tag.png"];
    UIBarButtonItem *bookmarks = [[UIBarButtonItem alloc] initWithImage:bookmarkImage landscapeImagePhone:bookmarkImage  style:UIBarButtonItemStyleBordered target:self action:@selector(tapBookmarks:)];
    */
    
    UIImage *addBusinessImage = [UIImage imageNamed:@"05-plus.png"];
    UIBarButtonItem *addBusiness = [[UIBarButtonItem alloc] initWithImage:addBusinessImage landscapeImagePhone:addBusinessImage  style:UIBarButtonItemStyleBordered target:self action:@selector(addBusinessTapped:)];
    
    item.rightBarButtonItems = [NSArray arrayWithObjects:addBusiness,searchBarButtonItem, nil];
    
    
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
    

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // For selecting cell.
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}


#pragma mark - Map delegate
-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    //if theres no business list and the map just loaded, refresh the results
    if(!self.listingsTableDataController.businessList)
    {
        [self.listingsTableDataController setRect:self.mv.region];
        [self.listingsTableDataController performUpdate];
    }

}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self.listingsTableDataController setRect:self.mv.region];
    [self.listingsTableDataController performUpdate];
}


- (IBAction)clearResults:(id)sender {
    self.listingsTableDataController.searchTerm = nil;
    [self.listingsTableDataController setRect:self.mv.region];
    [self.listingsTableDataController performUpdate];
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
    
//    UIColor *scaleColor =  [UIColor colorWithRed:colorScale green: colorScale blue: 0 alpha: 1];

    
    if(annotation.business.certLevel != 2)
    {
        pinView.contentMode = UIViewContentModeScaleAspectFit;
        pinView.image = [UIImage imageNamed:@"02-star.png" withColor:AS_DARK_BLUE];
    }
    else
    {
        pinView.contentMode = UIViewContentModeScaleAspectFit;
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(5,5,15,15)];
        imgView.image = [UIImage imageNamed:@"spe-icon.jpg"];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        pinView.image = nil; // withColor:scaleColor];
        [pinView addSubview:imgView];
        //pinView.image = [UIImage imageNamed:@"12-flag.png" withColor:AS_DARK_BLUE];

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
    if (!annotation.business.image)
    {
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:annotation.business.imageURLString]];
        void (^imageHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
            annotation.business.image = [UIImage imageWithData:data];
            UIImageView *myImageView = [[UIImageView alloc] initWithImage:annotation.business.image];
            myImageView.frame = CGRectMake(0,0,34,34); // Change the size of the image to fit the callout
            pinView.leftCalloutAccessoryView = myImageView;
        };
        if (!self.queue)
            self.queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:imageRequest queue:self.queue completionHandler:imageHandler];

    }
    else
    {
        UIImageView *myImageView = [[UIImageView alloc] initWithImage:annotation.business.image];
        myImageView.frame = CGRectMake(0,0,34,34); // Change the size of the image to fit the callout
        pinView.leftCalloutAccessoryView = myImageView;

        
        
        
    }

    return pinView;
}

#pragma mark - Annotation Selection

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    ASMapPoint *mp = (ASMapPoint*)view.annotation;
    NSString *targetViewControllerIdentifier = @"ShowHealthMenuDetails";
    ASZBusinessHealthViewController *vc = (ASZBusinessHealthViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
    
    [vc setBusinessID:mp.business.ID];
    
    
    ASZBusinessHealthDataController *detailsDataController = vc.dataController;
    detailsDataController.business = mp.business;
    
    // ASBusinessListDataController *listDataController = self.listingsTableDataController;
    
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController  pushViewController:vc animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
    
}
- (void)viewDidUnload {
    [self setMv:nil];
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
    
    if(!self.listingsTableDataController.searchTerm)
    {
        searchText.text = [NSString stringWithFormat:@"Displaying %d places to eat\n",self.listingsTableDataController.businessList.countOfBusinesses];

    }
    else
    {
        searchText.text = [NSString stringWithFormat:@"Displaying %d places for the '%@'\n",self.listingsTableDataController.businessList.countOfBusinesses,self.listingsTableDataController.searchTerm];

    }
    
    
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
    
    if (self.listingsTableDataController.searchTerm)
    {
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearResults:)];
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
    
    
    
    for (ASBusiness *bus in self.listingsTableDataController.businessList.entries)
    {
        CLLocationCoordinate2D annotationCenter;
        annotationCenter.latitude = bus.lat;
        annotationCenter.longitude = bus.lng;
        NSString *scoreText = [NSString stringWithFormat:@"%0.0f of %d stars.",roundf(bus.recommendation*MAX_RATING),MAX_RATING];
        
        
        ASMapPoint *mp = [[ASMapPoint alloc] initWithCoordinate:annotationCenter withScore:bus.recommendation withTag:bus.ID withTitle:bus.name withSubtitle:scoreText];
        
  
        mp.tag = bus.ID;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.listingsTableDataController.businessList != nil)
                [self loadMapElements];
        });
        

    }

}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    NSLog(@"region is at %f\n",self.mv.region.center.latitude);
    [self.listingsTableDataController setRect:self.mv.region];
    [self.listingsTableDataController setSearchTerm:searchBar.text];
    [self.view endEditing:YES];
    [self.searchBar resignFirstResponder];
    [self.listingsTableDataController performUpdate];
    
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
