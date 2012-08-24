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
        NSLog(@"Running update with %@\n",self.parentTopic);
        [self.userProfileDataController updateData:self.parentTopic];
        
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
    topicLabel.text = [[self.userProfileDataController.userProfile.sorts objectAtIndex:indexPath.row] valueForKey:@"topicName"];

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


#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *parentTopic = [[self.userProfileDataController.userProfile.sorts objectAtIndex:indexPath.row] valueForKey:@"topicName"];
   // NSLog(@"Setting parent to  %@\n",parentTopic);
    ASTopicBrowseViewController *upvc = [segue destinationViewController];
    [upvc setParentTopic:parentTopic];
    //[upvc setUserProfileDataController:self.userProfileDataController];
}


- (IBAction)importanceValueChanged:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

    NSString *parentTopic = [[self.userProfileDataController.userProfile.sorts objectAtIndex:indexPath.row] valueForKey:@"topicName"];

   // NSNumber *imp = [self.userProfileDataController.userProfile.importance objectAtIndex:self.questionPosition];
   // imp = [NSNumber numberWithFloat:self.importanceValue.value];
}
@end
