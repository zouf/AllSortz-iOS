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
        if (!self.children)
            [self.userProfileDataController updateData];
        else
        {
            [self.userProfileDataController updateWithArray:self.children];
            [self.tableView setDataSource:self.userProfileDataController.userProfile];
            [self.tableView reloadData];
        }

    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"TopicCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *topicLabel = (UILabel*)[cell viewWithTag:TOPIC_TEXT];
    topicLabel.text = [[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"topicName"];
    NSArray *children= [[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row]valueForKey:@"children"];
    NSLog(@"For %@ the num of children are %@\n",topicLabel.text,children.count);
    if (children.count == 0)
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ASTopicBrowseViewController *viewControl = [[ASTopicBrowseViewController alloc] init];
   // viewControl.selectedRegion = [regions objectAtIndex:indexPath.row];
    NSMutableArray *children = [[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"children"];
    if ( children.count != 0)
    {
        
        NSString *targetViewControllerIdentifier = nil;
        targetViewControllerIdentifier = @"BrowseViewControllerID";
        ASTopicBrowseViewController *vc = (ASTopicBrowseViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
        [vc setChildren:children];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
        return;
}

#pragma mark - Segues

- (IBAction)importanceValueChanged:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

//    NSString *parentTopic = [[self.userProfileDataController.userProfile.topics objectAtIndex:indexPath.row] valueForKey:@"topicName"];

   // NSNumber *imp = [self.userProfileDataController.userProfile.importance objectAtIndex:self.questionPosition];
   // imp = [NSNumber numberWithFloat:self.importanceValue.value];
}
@end
