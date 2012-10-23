//
//  ASZFriendListViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZFriendListViewController.h"
#import "ASZFriendListDataController.h"
#import "ASZFriendList.h"

@interface ASZFriendListViewController ()

@end

@implementation ASZFriendListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    self.title = @"Socialize!";
    
    
    [self.friendListDataController addObserver:self
                                       forKeyPath:@"friendList"
                                          options:NSKeyValueObservingOptionNew
                                          context:NULL];


    [self.friendListDataController pullFriendListFromServer];


}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.friendListDataController removeObserver:self forKeyPath:@"friendList"];
}

- (IBAction)goOutTapped:(id)sender {
    NSMutableString *selectedUsers = [[NSMutableString alloc]init];
    
    for(ASUser *u in self.friendListDataController.friendList.users)
    {
        if([[self.friendListDataController.friendList.selectedUsers valueForKey:u.userName]boolValue])
        {
            
            [selectedUsers appendFormat:@"%@, ",u.userName];
        }
    }
    if([selectedUsers isEqualToString:@""] )
    {
        selectedUsers=   [NSMutableString stringWithString:@"you and your friends!"];
    }
    else
    {
        [selectedUsers appendString:@"and you!"];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coming Soon!"
                                                    message:[NSString stringWithFormat:@"A new way to socialize. We'll find the best place for %@", selectedUsers]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"friendList"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            
        });

        
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASUser *u = [self.friendListDataController.friendList.users objectAtIndex:indexPath.row];
    [self.friendListDataController.friendList.selectedUsers setValue:[NSNumber numberWithBool:YES] forKey:u.userName];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ASUser *u = [self.friendListDataController.friendList.users objectAtIndex:indexPath.row];
    [self.friendListDataController.friendList.selectedUsers setValue:[NSNumber numberWithBool:NO]  forKey:u.userName];
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryNone;

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [self setFriendListDataController:nil];
    [super viewDidUnload];
}
@end
