//
//  ASMapViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASMapViewController.h"

@interface ASMapViewController()

@property (strong, nonatomic) IBOutlet ASBusinessListDataController *listingsTableDataController;

@property (weak, nonatomic) IBOutlet MKMapView *mv;
@property (weak, nonatomic) NSMutableArray *businessPoints;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

- (IBAction)refreshTheMap:(id)sender;

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView;

@end



@implementation ASMapViewController
@synthesize overlayView = _overlayView;
@synthesize mv;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.listingsTableDataController = [[ASBusinessListDataController alloc]init];
    [self.listingsTableDataController addObserver:self
                                       forKeyPath:@"businessList"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=self.overlayView.center;
    
    [activityView startAnimating];
    
    [self.overlayView addSubview:activityView];

    
    
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
	
	
    [super viewDidLoad];
}

- (IBAction)refreshTheMap:(id)sender {
    [self.listingsTableDataController setRect:self.mv.region];
    [self.listingsTableDataController setIsListingView:NO];
    [self.listingsTableDataController updateWithRect];
    

}

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView
{
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(ASMapPoint* annotation in mapView.annotations)
    {
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

//this is the required method implementation for MKMapView annotations
- (MKAnnotationView *) mapView:(MKMapView *)thisMapView
             viewForAnnotation:(ASMapPoint *)annotation
{
   /*
    ASMapAnnotation *annotationView =
    (ASMapAnnotation *)[self.mv dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil)
    {
        annotationView = [[ASMapAnnotation alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] ;
    }
    annotationView.annotation = annotation;
    annotationView.canShowCallout = YES;
    return annotationView;

*/
    
    if ((MKUserLocation*)annotation==self.mv.userLocation)
        return nil;
    static NSString *AnnotationViewID = @"annotationViewID";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[thisMapView
                                                                  dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
	if(annotationView == nil)
	{
		annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
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
	}
    else
    {
        annotationView.annotation = annotation;
    }
    return annotationView;
}


- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    ASMapPoint *mp = (ASMapPoint*)view.annotation;
    NSLog(@"Go to detail for business with id %d", mp.tag);
    
}
- (void)viewDidUnload {
    [self setMv:nil];
    [self setOverlayView:nil];

    [super viewDidUnload];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    NSLog(@"Annotation added!");

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.listingsTableDataController.businessList)
    {
        MKMapRect  rect = self.mv.visibleMapRect;
        [self.listingsTableDataController setRect:self.mv.region];
        [self.listingsTableDataController setIsListingView:NO];
        [self.listingsTableDataController updateWithRect];
        
    }
}



#pragma mark - Key-value observing



- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"businessList"]) {
        
        // remove all annotations
        NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
        for (id annotation in self.mv.annotations)
            if (annotation != self.mv.userLocation)
                [toRemove addObject:annotation];
        [self.mv removeAnnotations:toRemove];
        
        //create annotations and add to the busStopAnnotations array
        NSMutableArray *myArray = [[NSMutableArray alloc] init];
        self.businessPoints = myArray;
        for (ASListing *bus in self.listingsTableDataController.businessList.entries)
        {
            CLLocationCoordinate2D annotationCenter;
            annotationCenter.latitude = bus.latitude;
            annotationCenter.longitude = bus.longitude;
            ASMapPoint *mp = [[ASMapPoint alloc] initWithCoordinate:annotationCenter withScore:bus.recommendation withTag:bus.ID withTitle:bus.businessName withSubtitle:[NSString stringWithFormat:@"%0.2f",   bus.recommendation]];
            [self.businessPoints addObject:mp];
        }
        
        //add annotations array to the mapView
        [self.mv addAnnotations:self.businessPoints];
        [self zoomToFitMapAnnotations:self.mv];
        
        [self.overlayView removeFromSuperview];
    }
}



#pragma mark - Query



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"NewSort"]){
        UINavigationController *nv = (UINavigationController *)segue.destinationViewController;
        ASSortViewController *nsvc = (ASSortViewController *)nv.topViewController;
        nsvc.delegate = self.listingsTableDataController;
    }
}

@end
