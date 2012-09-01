//
//  ASListingsViewController.m
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASListingsViewController.h"
#import "ASBusinessListDataController.h"
#import "ASRateView.h"
#import "ASIconDownloader.h"
#import "ASListing.h"
#import "ASQuery.h"
#import "ASAddBusinessViewController.h"
#import "ASZBusinessDetailsViewController.h"
#import "ASZBusinessDetailsDataController.h"

@interface ASListingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ASBusinessListDataController *listingsTableDataController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIView *overlayView;




//@property (strong, nonatomic) IBOutlet ASActivityWaitingViewController *activityWaiting;

@end


@implementation ASListingsViewController

#pragma mark - View controller
@synthesize overlayView = _overlayView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.listingsTableDataController = [[ASBusinessListDataController alloc]init];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.listingsTableDataController addObserver:self
                                       forKeyPath:@"businessList"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activityView.center=self.overlayView.center;
    
    [activityView startAnimating];
    
    [self.overlayView addSubview:activityView];

}


- (void)viewDidUnload
{
    [self setOverlayView:nil];
    [self setOverlayView:nil];
    [super viewDidUnload];
    self.searchBar = nil;
    // self.activityWaiting = nil;
    [self.listingsTableDataController removeObserver:self forKeyPath:@"businessList"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Imitate default behavior of UITableViewController
    // deselectRowAtIndexPath:animated: should be fine taking a possible nil
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];

    // Download data automatically if there's no data source
    if (!self.listingsTableDataController.businessList)
    {
        [self.listingsTableDataController setBus_low:0];
        [self.listingsTableDataController setBus_high:10];
        [self.listingsTableDataController setIsListingView:YES];
        [self.listingsTableDataController updateData];
    
    }
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Imitate default behavior of UITableViewController
    [self.tableView flashScrollIndicators];
}




#pragma mark - Table specific operations


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row<[self.listingsTableDataController.businessList.entries count])
        return 72;
    return 59;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	//
	static NSString *CellIdentifier = @"ListingCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    //Add business cell
    if (indexPath.row >= [self.listingsTableDataController.businessList.entries count])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddBusinessCell"];
        if ( cell == nil)
        {
            NSLog(@"Error case!\n");
            return nil;
            
        }
        return cell;
    }
    
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.listingsTableDataController.businessList.entries  count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
		cell.detailTextLabel.text = @"Loading…";
		
		return cell;
    }
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
        ASListing *listing = [self.listingsTableDataController.businessList.entries  objectAtIndex:indexPath.row];
        
        UILabel *busName = (UILabel *)[cell viewWithTag:BUSINESS_NAME];
        busName.text = listing.businessName;
        
        UILabel *distanceLabel = (UILabel *)[cell viewWithTag:DISTANCE_VIEW];
        distanceLabel.text = [listing.businessDistance  stringByAppendingString:@"mi."];

        UILabel *priceLabel = (UILabel *)[cell viewWithTag:PRICE_VIEW];
        priceLabel.text = [NSString stringWithFormat:@"$%@", listing.averagePrice] ;

        for (int i =0  ; i < NUM_TYPE_ICONS; i++ )
        {
            // first six types
            NSInteger imageID = TYPE_ICON_IMAGE_BASE + i;
            UIImageView *typeIcon = (UIImageView *)[cell viewWithTag:imageID];
            if (i >= listing.businessTypes.count)
            {
                typeIcon.hidden = YES;
            }
            else
            {
                NSMutableDictionary *t = [listing.businessTypes objectAtIndex:i];
                
                NSString * tIcon = [[t valueForKey:@"type"] valueForKey:@"typeIcon"];
                
                typeIcon.image = [UIImage imageNamed:tIcon];
                typeIcon.hidden = NO;
            }          
        }
        
        UIProgressView *rateView =  (UIProgressView*)[cell viewWithTag:RATE_VIEW];
        
        // if there's been a recommendation or user rating
        
        rateView.progress = listing.recommendation;
        

        UIImageView *imageView = (UIImageView*)[cell viewWithTag:IMAGE_VIEW];
        
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!listing.businessPhoto)
        {
            if (tableView.dragging == NO && tableView.decelerating == NO)
            {
                [self startIconDownload:listing forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            imageView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else
        {
            imageView.contentMode = UIViewContentModeScaleToFill;
            imageView.image = listing.businessPhoto;
        }
        
    }
    
    return cell;
    
}


#pragma mark - Load Icons
- (void)startIconDownload:(ASListing *)listing forIndexPath:(NSIndexPath *)indexPath
{
    ASIconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        iconDownloader = [[ASIconDownloader alloc] init];
        iconDownloader.listing =listing;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];

        [iconDownloader startDownload];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.listingsTableDataController.businessList.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            //exclude last row
            if (indexPath.row >= [self.listingsTableDataController.businessList.entries count])
                continue;
            ASListing *listing = [self.listingsTableDataController.businessList.entries objectAtIndex:indexPath.row];
            
            if (!listing.businessPhoto) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:listing forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)imageDidLoad:(NSIndexPath *)indexPath
{
    ASIconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];   
    
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        UIImageView *imageView = (UIImageView*)[cell viewWithTag:IMAGE_VIEW];
        
                // Display the newly loaded image
        imageView.image = iconDownloader.listing.businessPhoto;
    
        [self.tableView reloadData];
    }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"businessList"]) {
        id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];
        self.tableView.dataSource = (newDataSource == [NSNull null] ? nil : newDataSource);
        [self.imageDownloadsInProgress removeAllObjects];
        [self.tableView reloadData];
    
        [self.overlayView removeFromSuperview];

    }
}

#pragma mark - Query
/*
-(void)newASSortViewController:(ASSortViewController *)nsvc didCreateNewSort:(ASBusinessList *)newList{
    // Update the data based on the new query
    //[self.listingsTableDataController.businessList.entries removeAllObjects];
    
    [self.listingsTableDataController updateDataWithNewList:newList];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)cancelNewASSortViewController:(ASSortViewController *)nsvc{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(void)waitOnQueryResponse:(ASQuery *)query{
    [self.listingsTableDataController updateWithQuery:query];

}*/
#pragma mark - Tab bar
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    // ...
}
#pragma mark - #pragma mark - Create New Sort

-(void) newASAddBusinessViewController:(ASAddBusinessViewController *)abvc didCreateNewBusiness:(ASAddBusiness *)business
{

    [self.listingsTableDataController updateData];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
}

-(void)cancelASAddBusinessViewController:(ASAddBusinessViewController *)abvc{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Storyboard

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;

    if ([segue.identifier isEqualToString:@"NewSort"]) {
        UINavigationController *nv = destinationViewController;
        ASSortViewController *nsvc = (ASSortViewController *)nv.topViewController;
        nsvc.delegate = self.listingsTableDataController;
    }

    if ([segue.identifier isEqualToString:@"AddBusiness"]) {
        UINavigationController *nv = destinationViewController;
        ASAddBusinessViewController *abvc = (ASAddBusinessViewController *)nv.topViewController;
        abvc.delegate = self;
    }

    if ([segue.identifier isEqualToString:@"ShowBusinessDetails"]) {
        ASZBusinessDetailsViewController *detailsViewController = destinationViewController;
        ASBusinessList *businesses = self.listingsTableDataController.businessList;
        NSArray *businessIDs = [businesses valueForKeyPath:@"entries.ID"];
        NSInteger selectedRow = [self.tableView indexPathForSelectedRow].row;
        detailsViewController.businessID = [businessIDs[selectedRow] unsignedIntegerValue];

        ASZBusinessDetailsDataController *detailsDataController = detailsViewController.dataController;
        ASBusinessListDataController *listDataController = self.listingsTableDataController;
        detailsDataController.username = [listDataController.locationController getStoredUname];
        detailsDataController.password = [listDataController.locationController getStoredPassword];
        detailsDataController.UUID = [listDataController.locationController getDeviceUIUD];
        detailsDataController.currentLatitude = listDataController.currentLocation.coordinate.latitude;
        detailsDataController.currentLongitude = listDataController.currentLocation.coordinate.longitude;
    }
}

@end
