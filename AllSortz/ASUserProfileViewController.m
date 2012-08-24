//
//  ASUserProfileViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/23/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASUserProfileViewController.h"

@interface ASUserProfileViewController ()
@property (strong, nonatomic) IBOutlet ASUserProfileDataController *userProfileDataController;
@property (weak, nonatomic) IBOutlet UILabel *questionText;
@property (weak, nonatomic) IBOutlet UISlider *importanceValue;
- (IBAction)importanceValueChanged:(id)sender;
@end

@implementation ASUserProfileViewController
@synthesize questionText = _questionText;
@synthesize importanceValue = _importanceValue;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    [self.userProfileDataController addObserver:self
                                       forKeyPath:@"userProfile"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];
    
    if (self.userProfileDataController.userProfile.topics != nil)
    {
        self.questionText.text = [[self.userProfileDataController.userProfile.topics objectAtIndex:self.questionPosition] valueForKey:@"topicName"];
        self.importanceValue.value = 0;
    }
    NSLog(@"%@\n", self.userProfileDataController.userProfile.topics);

    
}

- (void)viewDidUnload
{
    [self setQuestionText:nil];
    [self setImportanceValue:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Imitate default behavior of UITableViewController
    // deselectRowAtIndexPath:animated: should be fine taking a possible nil

    
    // Download data automatically if there's no data source
    if (!self.userProfileDataController.userProfile)
    {
        [self.userProfileDataController updateData];
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"UserProfileData";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}



#pragma mark - Key value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"userProfile"]) {
        id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];

        self.questionText.text = [[self.userProfileDataController.userProfile.topics objectAtIndex:self.questionPosition] valueForKey:@"topicName"];
        self.importanceValue.value = 0;

    }
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    ASUserProfileViewController *upvc = [segue destinationViewController];
    [upvc setQuestionPosition:self.questionPosition + 1];
    [upvc setUserProfileDataController:self.userProfileDataController];
}


- (IBAction)importanceValueChanged:(id)sender {
    NSNumber *imp = [self.userProfileDataController.userProfile.importance objectAtIndex:self.questionPosition];
    imp = [NSNumber numberWithFloat:self.importanceValue.value];
}
@end
