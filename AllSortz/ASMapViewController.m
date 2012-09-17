//
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

#import "ASZBusinessDetailsViewController.h"

@interface ASMapViewController()
@property (weak, nonatomic) IBOutlet MKMapView *mv;
@property (weak, nonatomic) NSMutableArray *businessPoints;

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
     
    [self.listingsTableDataController addObserver:self
                                       forKeyPath:@"businessList"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    
    //declare latitude and longitude of map center
	CLLocationCoordinate2D center;
	center.latitude =  40.350816;
	center.longitude = -74.654278;
	
	//declare span of map (height and width in degrees)
	MKCoordinateSpan span;
	span.latitudeDelta = .02;
	span.longitudeDelta = .01;
	
	//add center and span to a region,
	//adjust the region to fit in the mapview
	//and assign to mapview region
	MKCoordinateRegion region;
	region.center = center;
	region.span = span;
	self.mv.region = [self.mv regionThatFits:region];
    

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
        //[self zoomToFitMapAnnotations:self.mv];
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
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setTitle:@"Map"];

    
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
- (IBAction)refreshTapped:(id)sender {
    [self.listingsTableDataController setRect:self.mv.region];
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

//this is the required method implementation for MKMapView annotations
- (MKAnnotationView *) mapView:(MKMapView *)thisMapView
             viewForAnnotation:(ASMapPoint *)annotation
{    
    if ((MKUserLocation*)annotation==self.mv.userLocation)
        return nil;
    static NSString *AnnotationViewID = @"annotationViewID";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[thisMapView
                                                                  dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
	if(annotationView == nil)
	{
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        
        
	}
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    annotationView.rightCalloutAccessoryView = rightButton;
    //I choose to color all the annotations green, except for the one with tag == 4
    if((annotation).score  >0.5)
        annotationView.pinColor = MKPinAnnotationColorGreen;
    else
        annotationView.pinColor = MKPinAnnotationColorRed;
    
    annotationView.animatesDrop=FALSE;
    
    //tapping the pin produces a gray box which shows title and subtitle
    annotationView.canShowCallout = YES;
    
    // Change this to rightCallout... to move the image to the right side
    annotationView.annotation = annotation;
        
   
    // Fetch image asynchronously
    
    if (!annotation.business.businessPhoto)
    {
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:annotation.business.imageURLString]];
        void (^imageHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
            annotation.business.businessPhoto = [UIImage imageWithData:data];
            UIImageView *myImageView = [[UIImageView alloc] initWithImage:annotation.business.businessPhoto];
            myImageView.frame = CGRectMake(0,0,31,31); // Change the size of the image to fit the callout
            annotationView.leftCalloutAccessoryView = myImageView;

        };
        if (!self.queue)
            self.queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:imageRequest queue:self.queue completionHandler:imageHandler];

    }
    else
    {
        UIImageView *myImageView = [[UIImageView alloc] initWithImage:annotation.business.businessPhoto];
        myImageView.frame = CGRectMake(0,0,31,31); // Change the size of the image to fit the callout
        annotationView.leftCalloutAccessoryView = myImageView;
    }

    return annotationView;
}

#pragma mark - Annotation Selection

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    ASMapPoint *mp = (ASMapPoint*)view.annotation;
    NSString *targetViewControllerIdentifier = @"ShowBusinessDetails";
    ASZBusinessDetailsViewController *vc = (ASZBusinessDetailsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
    [vc setBusinessID:mp.tag];
    
    
    ASZBusinessDetailsDataController *detailsDataController = vc.dataController;
    ASBusinessListDataController *listDataController = self.listingsTableDataController;
    detailsDataController.username = [listDataController.deviceInterface getStoredUname];
    detailsDataController.password = [listDataController.deviceInterface getStoredPassword];
    detailsDataController.UUID = [listDataController.deviceInterface getDeviceUIUD];
    detailsDataController.currentLatitude = listDataController.currentLocation.coordinate.latitude;
    detailsDataController.currentLongitude = listDataController.currentLocation.coordinate.longitude;

    
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
    // TODO: can we loadMapElements only if there's been a change to the business list?
    
    //create annotations and add to the busStopAnnotations array
    NSMutableArray *myArray = [[NSMutableArray alloc] init];
    self.businessPoints = myArray;
    for (ASListing *bus in self.listingsTableDataController.businessList.entries)
    {
        CLLocationCoordinate2D annotationCenter;
        annotationCenter.latitude = bus.latitude;
        annotationCenter.longitude = bus.longitude;
        ASMapPoint *mp = [[ASMapPoint alloc] initWithCoordinate:annotationCenter withScore:bus.recommendation withTag:bus.ID withTitle:bus.businessName withSubtitle:[NSString stringWithFormat:@"Score %0.2f",   bus.recommendation]];
        mp.business = bus;
        [self.businessPoints addObject:mp];
    }

    // remove all annotations
   /* NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
    for (id annotation in self.mv.annotations)
        if (annotation != self.mv.userLocation)
            [toRemove addObject:annotation];
    [self.mv removeAnnotations:toRemove];*/
    
    //add annotations array to the mapView
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

       // [self zoomToFitMapAnnotations:self.mv];
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
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}


@end
