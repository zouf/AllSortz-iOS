//
//  ASZMenuViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/8/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZMenuViewController.h"

@interface ASZMenuViewController ()

@end

@implementation ASZMenuViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
 
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(25,0,100,30)];
    [lbl setFont:[UIFont fontWithName:@"Gill Sans" size:24]];
    [lbl setText:@"Your Menu"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    self.navigationItem.titleView = lbl;
    self.dataController.menulist  = [[ASZMenuList alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *mealName = [self.dataController.menulist mealNameAtIndex:section];
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0,0,320,30)];
    lbl.text = mealName;
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(0,0,320,30)];
    [v addSubview:lbl];
    [lbl setBackgroundColor:[UIColor darkGrayColor]];
    [lbl setTextColor:[UIColor whiteColor]];
    [ v setBackgroundColor:[UIColor darkGrayColor]];
    return v;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 70;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableString* newStr = [[NSMutableString alloc]initWithString:@""];
    for(NSIndexPath *indexPath  in [self.tv indexPathsForSelectedRows])
    {
        ASZMenuItem * mi = [self.dataController.menulist menuItemsForIndex:indexPath];
        [newStr appendString:mi.name];
        [newStr appendString:@", "];

    }
    self.selectedDescription.text = newStr;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableString* newStr = [[NSMutableString alloc]initWithString:@""];
    for(NSIndexPath *indexPath  in [self.tv indexPathsForSelectedRows])
    {
        ASZMenuItem * mi = [self.dataController.menulist menuItemsForIndex:indexPath];
        [newStr appendString:mi.name];
        [newStr appendString:@", "];
        
    }
    self.selectedDescription.text = newStr;

}



- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Coming Soon!"
                                                    message:@"Details on the Dish"
                                                   delegate:nil
                                          cancelButtonTitle:@"Awesome"
                                          otherButtonTitles:nil];

    [alert show];
}


- (void)viewDidUnload {
    [self setDataController:nil];
    [self setDataController:nil];
    [self setOverlayView:nil];
    [self setSelectedDescription:nil];
    [self setTv:nil];
    [super viewDidUnload];
}
@end
