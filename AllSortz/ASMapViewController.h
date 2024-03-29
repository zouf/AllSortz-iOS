//
//  ASMapViewController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Code created by Matt Zoufaly on 8/29/12
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ASBusinessListDataController.h"
#import "ASBusinessList.h"
#import "ASMapPoint.h"
#import "ASListingsViewController.h"
#import "ASMapAnnotation.h"


#define NUM_MERCHANTS_STARRED 3



@interface ASMapViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate>


@property (strong, nonatomic) IBOutlet ASBusinessListDataController *listingsTableDataController;


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;


-(void)loadMapElements;


@end
