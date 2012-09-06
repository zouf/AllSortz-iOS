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
@property (weak, nonatomic) IBOutlet UISegmentedControl *importanceValue;
- (IBAction)importanceValueChanged:(id)sender;
@end


@implementation ASUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.userProfileDataController addObserver:self
                                     forKeyPath:@"userProfile"
                                        options:NSKeyValueObservingOptionNew
                                        context:NULL];
}

- (void)viewDidUnload
{
    self.questionText = nil;
    self.importanceValue = nil;
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Imitate default behavior of UITableViewController
    // deselectRowAtIndexPath:animated: should be fine taking a possible nil

    
    // Download data automatically if there's no data source
    if (!self.userProfileDataController.userProfile)
    {
        [self.userProfileDataController updateData:self.parentTopicID];        
    }
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
    return 175;
}

#pragma mark - Key value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"userProfile"]) {
        //id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];

        self.questionText.text = [[self.userProfileDataController.userProfile.topics objectAtIndex:self.questionPosition] valueForKey:@"topicName"];
        NSInteger topicID = [[[self.userProfileDataController.userProfile.topics objectAtIndex:self.questionPosition] valueForKey:@"topicID"] integerValue];
        //NSInteger isLeaf = [[[self.userProfileDataController.userProfile.topics objectAtIndex:self.questionPosition] valueForKey:@"isLeaf"] integerValue];
        [self.questionPath addObject:[NSNumber numberWithInt:topicID]];
    }
}

#pragma mark - Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    ASUserProfileViewController *upvc = [segue destinationViewController];
    [upvc setQuestionPosition:self.questionPosition + 1];
    [upvc setUserProfileDataController:self.userProfileDataController];
}




- (IBAction)importanceValueChanged:(id)sender {
    
    
    //go back up the tree
    if (self.questionPosition >= self.userProfileDataController.userProfile.topics.count)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    switch (self.importanceValue.selectedSegmentIndex)
    {
        case 0:
        case 1:
        {

            NSString *targetViewControllerIdentifier = @"TopicQuestionID";
            ASUserProfileViewController *vc = (ASUserProfileViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
            
            [vc setQuestionPosition:self.questionPosition +1];
            [vc setParentTopicID:self.parentTopicID];
            [vc setQuestionPath:[NSMutableArray arrayWithArray:self.questionPath]];
             
            [self.navigationController  pushViewController:vc animated:YES];
            break;
        }
        case 2:  // dive down
        {
            NSInteger topicID = [[[self.userProfileDataController.userProfile.topics objectAtIndex:self.questionPosition] valueForKey:@"topicID"] integerValue];
            NSInteger isLeaf = [[[self.userProfileDataController.userProfile.topics objectAtIndex:self.questionPosition] valueForKey:@"isLeaf"] integerValue];
            
            if (isLeaf)
            {
                NSString *targetViewControllerIdentifier = @"TopicQuestionID";
                ASUserProfileViewController *vc = (ASUserProfileViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
                
                [vc setQuestionPosition:self.questionPosition +1];
                [vc setParentTopicID:self.parentTopicID];
                [vc setQuestionPath:[NSMutableArray arrayWithArray:self.questionPath]];
                [self.navigationController  pushViewController:vc animated:YES];
            }
            else
            {
             
                NSString *targetViewControllerIdentifier = @"TopicQuestionID";
                ASUserProfileViewController *vc = (ASUserProfileViewController*)[self.storyboard instantiateViewControllerWithIdentifier:targetViewControllerIdentifier];
                [vc setQuestionPosition:0];
                [vc setParentTopicID:topicID];
                [vc setQuestionPath:[NSMutableArray arrayWithArray:self.questionPath]];

                [self.navigationController  pushViewController:vc animated:YES];
            }
            break;
        }
    }
    
}
@end
