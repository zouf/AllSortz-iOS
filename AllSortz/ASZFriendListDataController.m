//
//  ASZFriendListDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/22/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZFriendListDataController.h"
#import "ASZFriendList.h"
#import "ASDeviceInterfaceSingleton.h"
#import "ASZFriendListViewController.h"

@interface ASZFriendListDataController ()

@property NSOperationQueue *queue;  // Assume we only need one for now

@end

@implementation ASZFriendListDataController

- (id)init {
    self = [super init];
    if (self) {
        self.deviceInterface = [ASDeviceInterfaceSingleton sharedDeviceInterface];
        [self.deviceInterface.locationManager startUpdatingLocation];
        self.deviceInterface.delegate = self;
    }
    return self;
}


- (void)pullFriendListFromServer
{
    //get a base review for the business with ID
    // need a list of topics (and maybe what topics are already assoc. with busines)
    // might include text you've already written
    
    NSString *address = [NSString stringWithFormat:@"http://allsortz.com/api/users/?uname=%@&password=%@&lat=%f&lon=%f&deviceID=%@", [self.deviceInterface getStoredUname] , [self.deviceInterface getStoredPassword], self.currentLocation.coordinate.latitude,self.currentLocation.coordinate.longitude, [self.deviceInterface getDeviceUIUD]];
    NSLog(@"Get review base with query %@",address);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:address]];
    void (^handler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        self.friendList = [[ASZFriendList alloc]initWithJSON:JSONresponse[@"result"] delegateForUserProfilePic:self];
    };
    
    if (!self.queue)
        self.queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queue completionHandler:handler];
    
    return;
}

-(void)imageDidLoad:(ASUser*)user
{
    
    for (int i = 0; i < self.friendList.users.count ; i++)
    {
        ASUser *asuser = [self.friendList.users objectAtIndex:i];
        
        if([asuser isEqual:user])
        {
            [self.viewController.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject: [NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}


#pragma mark - Receive Location info
- (void)locationUpdate:(CLLocation *)location
{
    self.currentLocation = [location copy];
}
- (void)locationError:(NSError *)error
{
    NSLog(@"Error in getting location!\n");
}


#pragma mark - Table view data souce
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.friendList)
        return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (!self.friendList)
        return 0;
    switch(section)
    {
        case 0:
            return self.friendList.users.count;   //the actual friendlist
            break;
        default:
            return 0;
            break;

    }
}






- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	//
	static NSString *CellIdentifier = @"UserCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    CGFloat kUserLabelX = 0;
    CGFloat kUserLabelY = 5;
    CGFloat kUserLabelWidth = 120;
    CGFloat kUserLabelHeight = 25;
    
    CGFloat kUserPicWidth = 50;
    CGFloat kUserPicHeight = 50;
    CGFloat kUserPicY = 5;
    
    CGFloat kUserPicX = CELL_WIDTH - kUserPicHeight - 30;
    UILabel *userName;
    UIImageView *userPic;

    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        
        userName = [[UILabel alloc]initWithFrame:CGRectMake(kUserLabelX,kUserLabelY,kUserLabelWidth,kUserLabelHeight)];
        [userName setFont:[UIFont fontWithName:@"Gill Sans:" size:10]];
        
        userName.tag = USERNAME_LABEL_TAG;
        
        userPic = [[UIImageView alloc]initWithFrame:CGRectMake(kUserPicX,kUserPicY,kUserPicWidth,kUserPicHeight)];
        userPic.tag = USERPIC_VIEW_TAG;
        [cell.contentView addSubview:userName];
        [cell.contentView addSubview:userPic];
    }
    else
    {
        userName = (UILabel*)[cell.contentView viewWithTag:USERNAME_LABEL_TAG];
        userPic = (UIImageView*)[cell.contentView viewWithTag:USERPIC_VIEW_TAG];
    }

    ASUser *user = [self.friendList.users objectAtIndex:indexPath.row];
    if([[self.friendList.selectedUsers objectForKey:user.userName] boolValue])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    
    userPic.image = user.profilePicture;
    userName.text = user.userName;
    
    
    
    return cell;
    
}


@end
