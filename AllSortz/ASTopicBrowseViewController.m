//
//  ASTopicBrowseViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASTopicBrowseViewController.h"

@interface ASTopicBrowseViewController ()
@property (strong, nonatomic) IBOutlet ASUserProfileDataController *userProfileDataController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ASTopicBrowseViewController
@synthesize userProfileDataController;
@synthesize tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.userProfileDataController addObserver:self
                                       forKeyPath:@"userProfile"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    
    

}

- (void)viewDidUnload
{
    [self setUserProfileDataController:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Imitate default behavior of UITableViewController
    // deselectRowAtIndexPath:animated: should be fine taking a possible nil
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
    // Download data automatically if there's no data source
    if (!self.userProfileDataController.userProfile)
    {
        [self.userProfileDataController updateData:self.parentTopicID];

    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)segmentSelected:(id)sender {
    UISegmentedControl *weightControl = (UISegmentedControl*)sender;
    NSIndexPath *indexPath = nil;
    for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row++) {
        NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
        UITableViewCell* cl = [tableView cellForRowAtIndexPath:cellPath];
        UISegmentedControl *sc = (UISegmentedControl*)[cl viewWithTag:TOPIC_WEIGHT];
        if (sc == sender)
        {
            indexPath = [self.tableView indexPathForCell:cl];
        }
        
        //do stuff with 'cell'
    }
    NSInteger topicID = [[[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"topicID"] integerValue];
    float importance = 0.0;
    
    switch (weightControl.selectedSegmentIndex) {
        case 0:
            importance = -1.0;
            break;
        case 1:
            importance = 0.0;
            break;
        case 2:
            importance =  1.0;
            break;
        default:
            importance =  0.0;
            break;	
    }

    [self.userProfileDataController updateImportance:topicID importanceValue:importance];
    
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TopicCell";
    UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *topicLabel = (UILabel*)[cell viewWithTag:TOPIC_TEXT];
    topicLabel.text = [[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"topicName"];
    //NSArray *children= [[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row]valueForKey:@"children"];
    NSInteger isLeaf = [[[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row]valueForKey:@"isLeaf"] integerValue];
    
    
    UISegmentedControl *topicWeight = (UISegmentedControl*)[cell viewWithTag:TOPIC_WEIGHT];
    NSInteger weight = [[[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"userWeight"] integerValue];
    
    [topicWeight addTarget:self
                    action:@selector(segmentSelected:withEvent:)
               forControlEvents:UIControlEventValueChanged];

    switch(weight)
    {
        case -1:
            [topicWeight setSelectedSegmentIndex:0];
            break;
        case 0:
            [topicWeight setSelectedSegmentIndex:1];
            break;
        case 1:
            [topicWeight setSelectedSegmentIndex:2];
            break;
            
        default:
            [topicWeight setSelectedSegmentIndex:1];
     
    }
    
  //  NSLog(@"For %@ the num of children are %d weight %f\n",topicLabel.text,children.count,weight);
    if (isLeaf == 1)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else 
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    return cell;

}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"userProfile"]) {
        id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];
        self.tableView.dataSource = (newDataSource == [NSNull null] ? nil : newDataSource);
        [self.tableView reloadData];
        
    }
}
- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:NO];
   // ASTopicBrowseViewController *viewControl = [[ASTopicBrowseViewController alloc] init];
   // viewControl.selectedRegion = [regions objectAtIndex:indexPath.row];
   // NSMutableArray *children = [[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"children"];
    NSInteger  parentID = [[[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"topicID"] integerValue];
    NSInteger isLeaf = [[[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"isLeaf"] integerValue];
        
    if ( isLeaf == 0)
    {
        
        NSString *targetViewControllerIdentifier = nil;
        targetViewControllerIdentifier = @"BrowseViewControllerID";
        ASTopicBrowseViewController *vc = (ASTopicBrowseViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
        [vc setParentTopicID:parentID];
        [self.navigationController  pushViewController:vc animated:YES];
    }
    else
        return;
}


@end
