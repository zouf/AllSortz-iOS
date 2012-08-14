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

@interface ASListingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ASBusinessListDataController *listingsTableDataController;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end


@implementation ASListingsViewController

#pragma mark - View controller
@synthesize imageDownloadsInProgress;


@synthesize searchBar = _searchBar;


- (void)viewDidLoad
{
    [super viewDidLoad];
    imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.listingsTableDataController addObserver:self
                                       forKeyPath:@"businessList"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    
}


- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [super viewDidUnload];
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
        [self.listingsTableDataController updateData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Imitate default behavior of UITableViewController
    [self.tableView flashScrollIndicators];
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
#warning handle this?
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
        
        UILabel *typeLabel = (UILabel *)[cell viewWithTag:TYPE_LABEL];
        NSMutableString * allTypes = [NSMutableString string];
        for (NSMutableDictionary * t in listing.businessTypes)
        {
            NSString * tname = [[t valueForKey:@"type"] valueForKey:@"typeName"];
            [allTypes appendString:tname];
            [allTypes appendString:@" "];

        }
        typeLabel.text = allTypes;
        
        
        /*ASRateView *rateView = (ASRateView *)[cell viewWithTag:RATING_VIEW];
        rateView.notSelectedImage = [UIImage imageNamed:@"kermit_empty.png"];
        rateView.halfSelectedImage = [UIImage imageNamed:@"kermit_half.png"];
        rateView.fullSelectedImage = [UIImage imageNamed:@"kermit_full.png"];
       // NSLog(@"%@\n",[listing.userRating floatValue]);
        rateView.rating = (float)listing.userRating;
        rateView.editable = NO;
        rateView.maxRating = 4;
        rateView.delegate = self;*/
        
        UIProgressView *rateView =  (UIProgressView*)[cell viewWithTag:106];
        rateView.progress = listing.userRating/4.0;
        
        

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
            //NSLog(@"Assigning %@!\n",cell);
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.image = listing.businessPhoto;
        }
        
    }
    
    return cell;
    
}


#pragma mark - Load Icons
#pragma mark -
#pragma mark Table cell image support

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
        NSLog(@"Putting stuff intoindex %@\n",indexPath);

        [iconDownloader startDownload];
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    //NSLog(@"Loading imaages for onscreen rows\n");
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
    //NSLog(@"Getting stuff from %@ for index %@\n",self.imageDownloadsInProgress,indexPath);
    
    
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
    }
}

#pragma mark - Create New Sort

-(void)newASSortViewController:(ASSortViewController *)nsvc didCreateNewSort:(ASQuery *)query{
    // Update the data based on the new query
    //[self.listingsTableDataController.businessList.entries removeAllObjects];
    [self.listingsTableDataController updateData];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)cancelNewASSortViewController:(ASSortViewController *)nsvc{
    [self.navigationController dismissModalViewControllerAnimated:YES];
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

#pragma mark - Segue STuff

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"NewSort"]){
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        ASSortViewController *nsvc = (ASSortViewController *)nv.topViewController;
        nsvc.delegate = self;
    }
    else if([segue.identifier isEqualToString:@"AddBusiness"]){
        NSLog(@"%@\n",@"Whatup");
        UINavigationController *nv = (UINavigationController *)[segue destinationViewController];
        ASAddBusinessViewController *abvc = (ASAddBusinessViewController *)nv.topViewController;
        abvc.delegate = self;
    }
}

@end
