//
//  ASSortViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/13/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASSortViewController.h"
#import "ASQueryDataController.h"

@interface ASSortViewController ()

@property (strong, nonatomic) IBOutlet ASQueryDataController *queryDataController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ASSortViewController
@synthesize queryDataController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    // Download data automatically if there's no data source
    [self.queryDataController addObserver:self
                                       forKeyPath:@"query"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
}

- (void)viewDidUnload
{
    [self setQueryDataController:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Imitate default behavior of UITableViewController
    // deselectRowAtIndexPath:animated: should be fine taking a possible nil
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
    // Download data automatically if there's no data source
    if (!self.queryDataController.query)
        [self.queryDataController updateData];
}



#pragma mark - Update

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section =[indexPath section];
    if (section == 0)  // sliders and search bar
    {
        NSString *CellIdentifier = @"SliderCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
        return cell;
    }
    else if (section == TYPES_SECTION)
    {
        NSString *CellIdentifier = @"TypeCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *label =(UILabel *)[cell viewWithTag:LABEL_VIEW];
        label.text = [[self.queryDataController.query.allTypes objectAtIndex:indexPath.row] objectForKey:@"typeName"];
        
        UIImageView *imageView =(UIImageView*)[cell viewWithTag:ICON_IMAGE_VIEW];
        imageView.image = [UIImage imageNamed: [[self.queryDataController.query.allTypes objectAtIndex:indexPath.row] objectForKey:@"typeIcon"]];
        imageView.backgroundColor = [UIColor lightGrayColor];
        return cell;        
    }
    else if (section == SORTS_SECTION)
    {
        static NSString *CellIdentifier = @"SortCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *label =(UILabel *)[cell viewWithTag:LABEL_VIEW];
        label.text = [[self.queryDataController.query.allSorts objectAtIndex:indexPath.row] objectForKey:@"tagName"];
        
        UIImageView *imageView =(UIImageView*)[cell viewWithTag:ICON_IMAGE_VIEW];
        imageView.image = [UIImage imageNamed: [[self.queryDataController.query.allSorts objectAtIndex:indexPath.row] objectForKey:@"tagIcon"]];
        imageView.backgroundColor = [UIColor lightGrayColor];
        return cell;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc]init];
    
	NSString *sectionHeader = nil;
	
	if(section == 0) {
        return nil;
	}
	if(section == 1) {
		sectionHeader = @"Business Types";
	}
    else if(section == 2) {
		sectionHeader = @"Sort Discussionss";
	}
    label.text = sectionHeader;
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.textAlignment=UITextAlignmentCenter;
    
    [label setBackgroundColor:[UIColor clearColor]];
    return label;
}


#pragma mark - Key value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"query"]) {
        id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];
        self.tableView.dataSource = (newDataSource == [NSNull null] ? nil : newDataSource);
        [self.tableView reloadData];
    }
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section ]== 0)
        return 150;
    return 45;
}

#pragma mark - Actions
-(IBAction)cancelTapped:(id)sender{ 
    [self.delegate cancelNewASSortViewController:self];
}

-(IBAction)doneTapped:(id)sender{
    
    NSMutableArray *lTypes =[[NSMutableArray alloc]init];
    NSMutableArray *lSorts =[[NSMutableArray alloc]init];

    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:TYPES_SECTION]; ++i)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        if ([cell isSelected])
        {
            NSDictionary *typeEntry =  [self.queryDataController.query.allTypes objectAtIndex:i];
            [lTypes addObject:[typeEntry objectForKey:@"typeID" ]];
            
        }
    }
    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:SORTS_SECTION]; ++i)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        if ([cell isSelected])
        {
            NSDictionary *typeEntry =  [self.queryDataController.query.allTypes objectAtIndex:i];
            [lSorts addObject:[typeEntry objectForKey:@"tagID"]];
            
        }
    }
    
    UISlider *distanceProx = (UISlider*)[self.tableView viewWithTag:DISTANCE_PROXIMITY_VIEW];;
    self.queryDataController.query.selectedTypes = lTypes;
    self.queryDataController.query.selectedSorts = lSorts;
    self.queryDataController.query.searchText = ((UITextField*)[self.tableView viewWithTag:SEARCH_TEXT_VIEW]).text;

  //  [self.queryDataController uploadData];
    ASQuery *newQ = [[ASQuery alloc] init];
    newQ.searchText =  [((UITextField*)[self.tableView viewWithTag:SEARCH_TEXT_VIEW]).text copy];
    newQ.selectedSorts = lSorts;
    newQ.selectedTypes = lTypes;
    newQ.searchLocation = [NSString stringWithFormat:@"%f", distanceProx.value];
    [self.delegate waitOnQueryResponse:newQ];


}
@end
