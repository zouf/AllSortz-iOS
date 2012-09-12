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
    [super viewDidUnload];
    [self.queryDataController removeObserver:self forKeyPath:@"query"];
    self.queryDataController = nil;
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


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.queryDataController removeObserver:self forKeyPath:@"query"];
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (section == TYPES_SECTION)
    {
        NSString *CellIdentifier = @"TypeCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *label =(UILabel *)[cell viewWithTag:LABEL_VIEW];

        label.text = [[self.queryDataController.query.allTypes objectAtIndex:indexPath.row] objectForKey:@"typeName"];
        
        UIImageView *imageView =(UIImageView*)[cell viewWithTag:ICON_IMAGE_VIEW];
        
        NSString *imageName = [[self.queryDataController.query.allTypes objectAtIndex:indexPath.row] objectForKey:@"typeIcon"];
        if([imageName isEqualToString:@"none.png"])
        {
            imageView.image = [UIImage imageNamed: @"dining.png"];
            imageView.backgroundColor = [UIColor lightGrayColor];
        }
        else
        {
            imageView.image = [UIImage imageNamed: [[self.queryDataController.query.allTypes objectAtIndex:indexPath.row] objectForKey:@"typeIcon"]];
            imageView.backgroundColor = [UIColor lightGrayColor];
        }
        

        return cell;        
    }
    else if (section == SORTS_SECTION)
    {
        static NSString *CellIdentifier = @"SortCell";
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        UILabel *label =(UILabel *)[cell viewWithTag:LABEL_VIEW];
        label.text = [[self.queryDataController.query.allSorts objectAtIndex:indexPath.row] objectForKey:@"topicName"];
        
        /*UIImageView *imageView =(UIImageView*)[cell viewWithTag:ICON_IMAGE_VIEW];
        imageView.image = [UIImage imageNamed: [[self.queryDataController.query.allSorts objectAtIndex:indexPath.row] objectForKey:@"topicIcon"]];
        imageView.backgroundColor = [UIColor lightGrayColor];*/
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
		sectionHeader = @"Browse Types";
        
	}
    else if(section == 2) {
		sectionHeader = @"Sort Discussionss";
	}
    label.text = sectionHeader;
    label.font = [UIFont fontWithName:@"Gill Sans" size:18.0];
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
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(IBAction)doneTapped:(id)sender{
    
    NSMutableArray *lTypes =[[NSMutableArray alloc]init];
    NSMutableArray *lSorts =[[NSMutableArray alloc]init];

    for (NSInteger i = 0; i < [self.queryDataController.query.allTypes count]; ++i)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        if ([cell isSelected])
        {
            NSDictionary *typeEntry =  [self.queryDataController.query.allTypes objectAtIndex:i];
            [lTypes addObject:[typeEntry objectForKey:@"typeID" ]];
            
        }
    }

    
    UISegmentedControl *distanceProx = (UISegmentedControl*)[self.tableView viewWithTag:DISTANCE_PROXIMITY_VIEW];
    CGFloat dw = 0.0;
    if (distanceProx.selectedSegmentIndex == 0) //walk
    {
        dw =1;
    }
    else if (distanceProx.selectedSegmentIndex == 1) //bike
    {
        dw = 0.6;
    }
    else  //anywhere
    {
        dw = 0.3;
    }
    self.queryDataController.query.selectedTypes = lTypes;
    self.queryDataController.query.selectedSorts = lSorts;
    self.queryDataController.query.searchText = ((UITextField*)[self.tableView viewWithTag:SEARCH_TEXT_VIEW]).text;

  //  [self.queryDataController uploadData];
    ASQuery *newQ = [[ASQuery alloc] init];
    newQ.distanceWeight = [NSString stringWithFormat:@"%f",dw];
    newQ.searchText =  ((UITextField*)[self.tableView viewWithTag:SEARCH_TEXT_VIEW]).text;
    newQ.selectedSorts = lSorts;
    newQ.selectedTypes = lTypes;
    newQ.searchLocation = ((UITextField*)[self.tableView viewWithTag:LOCATION_TEXT_VIEW]).text;
    [self.delegate waitOnQueryResponse:newQ];
    [self.navigationController dismissModalViewControllerAnimated:YES];


    
}

@end
