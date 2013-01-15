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
#import "ASAddBusinessViewController.h"
#import "ASZBusinessDetailsViewController.h"
#import "ASMapViewController.h"
#import "ASZBusinessListingSingleton.h"
#import "ASZNewRateView.h"
#import "ASZBusinessHealthViewController.h"
#define BUSINESS_NAME 200

#define RELOAD_DISTANCE 15


@interface ASListingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchDisplayBar;


//- (IBAction)goToMap:(id)sender;


@end


@implementation ASListingsViewController

#pragma mark - View controller


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.listingsTableDataController =[[ASZBusinessListingSingleton sharedDataListing] getListDataController];
    
    
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    [self.listingsTableDataController addObserver:self
                                       forKeyPath:@"businessList"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    [self.listingsTableDataController addObserver:self
                                       forKeyPath:@"businessList.entries"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];


}


- (void)viewDidUnload
{
    [self.listingsTableDataController removeObserver:self forKeyPath:@"businessList"];

    [self setSearchDisplayBar:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self setTitle:@"The Listings"];

    // Imitate default behavior of UITableViewController
    
    [self.tableView flashScrollIndicators];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}



#pragma mark - Table specific operations


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *targetViewControllerIdentifier = @"ShowHealthMenuDetails";
    ASZBusinessHealthViewController *vc = (ASZBusinessHealthViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
    
    ASBusiness *listing = [self.listingsTableDataController.businessList.entries  objectAtIndex:indexPath.row];
    [vc setBusinessID:listing.ID];
    
    
    ASZBusinessHealthDataController *detailsDataController = vc.dataController;
    detailsDataController.business = listing;
    
   // ASBusinessListDataController *listDataController = self.listingsTableDataController;

    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController  pushViewController:vc animated:YES];
    [self.navigationController setNavigationBarHidden:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	//
	static NSString *CellIdentifier = @"ListingCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.listingsTableDataController.businessList.entries  count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
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
        ASBusiness *listing = [self.listingsTableDataController.businessList.entries  objectAtIndex:indexPath.row];
        
        UILabel *busName = (UILabel *)[cell viewWithTag:BUSINESS_NAME];
        busName.text = listing.name;
        
        UILabel *distanceLabel = (UILabel *)[cell viewWithTag:DISTANCE_VIEW];
        distanceLabel.text = [NSString stringWithFormat:@"%.2fmi.",[listing.distance floatValue]];
        
        
        UIImageView *certView = (UIImageView*)[cell viewWithTag:PRICE_VIEW];
        
        
        certView.image = listing.certImage;
        
        // if there's been a recommendation or user rating
        ASZNewRateView * rView = (ASZNewRateView*)[cell viewWithTag:106];
        NSLog(@"%f\n",listing.recommendation);
        NSInteger intRating = roundf(listing.recommendation * MAX_RATING);
        if(rView)
        {
            rView.vertical = NO;
            [rView refresh:AS_DARK_BLUE rating:intRating];
        }
        else
        {
            ASZNewRateView * rView = [[ASZNewRateView alloc]initWithFrame:CGRectMake(55,25,100,10) color:[UIColor blueColor] rating:intRating];
            rView.tag = 106;
            [cell addSubview:rView];
        }
      

        UIImageView *imageView = (UIImageView*)[cell viewWithTag:IMAGE_VIEW];
        
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!listing.image)
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
            imageView.image = listing.image;
        }
        
    }
    
    return cell;
    
}


#pragma mark - Load Icons
- (void)startIconDownload:(ASBusiness *)listing forIndexPath:(NSIndexPath *)indexPath
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
            ASBusiness *listing = [self.listingsTableDataController.businessList.entries objectAtIndex:indexPath.row];
            
            if (!listing.image) // avoid the app icon download if the app already has an icon
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
        imageView.image = iconDownloader.listing.image;
    
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


#pragma mark - Dynamic load list
/*

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
    
    if(![visiblePaths count])
        return;
    
    NSIndexPath *max = [visiblePaths objectAtIndex:[visiblePaths count]-1];
    
    if (max.row > [self.listingsTableDataController.businessList.entries count] - RELOAD_DISTANCE)
                    {
                        [self.listingsTableDataController setUpdateAList:YES];
                        [self.listingsTableDataController updateData];
                    }
}
*/
#pragma mark - Key-value observing

-(void)loadListElements
{
    
    UILabel *searchText = (UILabel*)[self.searchDisplayBar viewWithTag:1001];
    searchText.hidden = NO;
    searchText.text = self.listingsTableDataController.businessList.searchText;
    if (self.listingsTableDataController.searchTerm)
    {
        UILabel *action = (UILabel*)[self.searchDisplayBar viewWithTag:1002];
        action.text = self.listingsTableDataController.searchTerm;
    }
    else
    {
        UILabel *action = (UILabel*)[self.searchDisplayBar viewWithTag:1002];
        action.text = @"";
    }
    
    [self.imageDownloadsInProgress removeAllObjects];
    [self.tableView reloadData];
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
            {
                id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];
                self.tableView.dataSource = (newDataSource == [NSNull null] ? nil : newDataSource);
                [self setTitle:@"Listings"];
                [self loadListElements];
            }
        });
        

    }
}
#pragma mark - #pragma mark - Create New Sort

-(void) newASAddBusinessViewController:(ASAddBusinessViewController *)abvc didCreateNewBusiness:(ASAddBusiness *)business
{
    
    [self.listingsTableDataController performUpdate];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)cancelASAddBusinessViewController:(ASAddBusinessViewController *)abvc{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Storyboard

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destinationViewController = segue.destinationViewController;
    
    UIViewController* vc = (UIViewController*)destinationViewController;
    [vc setHidesBottomBarWhenPushed:YES];


    if ([segue.identifier isEqualToString:@"AddBusiness"]) {
        UINavigationController *nv = destinationViewController;
        ASAddBusinessViewController *abvc = (ASAddBusinessViewController *)nv.topViewController;
        abvc.delegate = self;
    }
}



@end
