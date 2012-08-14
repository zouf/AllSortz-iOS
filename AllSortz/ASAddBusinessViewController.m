//
//  ASAddBusinessViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAddBusinessViewController.h"
#import "ASAddBusinessDataController.h"

@interface ASAddBusinessViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ASAddBusinessDataController *addBusinessDataController;

@end

@implementation ASAddBusinessViewController
@synthesize addBusinessDataController;

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
    [self.addBusinessDataController addObserver:self
                               forKeyPath:@"business"
                                  options:NSKeyValueObservingOptionNew
                                  context:NULL];
}

- (void)viewDidUnload
{
    [self setAddBusinessDataController:nil];

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
    if (!self.addBusinessDataController.business)
        [self.addBusinessDataController updateData];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    NSInteger sec = [indexPath section];
    if (sec == 0)
    {
        NSString *CellIdentifier = @"BusinessData";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    else
    {
        NSString *CellIdentifier = @"TypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell.textLabel.text = [self.addBusinessDataController.business.types objectAtIndex:indexPath.row];
        return cell;
    }
    // Configure the cell...
    
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section ]== 0)
        return 200;
    return 45;
}
/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Key value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"business"]) {
        id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];
        self.tableView.dataSource = (newDataSource == [NSNull null] ? nil : newDataSource);
        [self.tableView reloadData];
    }
}



- (IBAction)add:(id)sender {
    ASAddBusiness *business = self.addBusinessDataController.business;
    UITextField *nameField = (UITextField*)[self.tableView viewWithTag:BUSINESS_NAME];
    UITextField *streetField = (UITextField*)[self.tableView viewWithTag:BUSINESS_STREET];
    UITextField *cityField = (UITextField*)[self.tableView viewWithTag:BUSINESS_CITY];
    UITextField *urlField = (UITextField*)[self.tableView viewWithTag:BUSINESS_URL];
    UITextField *phoneField = (UITextField*)[self.tableView viewWithTag:BUSINESS_PHONE];
    UITextField *stateField =(UITextField*)[self.tableView viewWithTag:BUSINESS_STATE];

    
    business.businessName = nameField.text;
    business.businessAddress = streetField.text;
    business.businessCity = cityField.text;
    business.businessURL = urlField.text;
    business.businessPhone = phoneField.text;
    business.businessState = stateField.text;
    NSLog(@"ADD HIT!\n");
    [self.addBusinessDataController uploadData];
    
    [self.delegate newASAddBusinessViewController:self didCreateNewBusiness:self.addBusinessDataController.business];
}

- (IBAction)cancel:(id)sender {
    NSLog(@"Send a cancel command\n");
    
    [self.delegate cancelASAddBusinessViewController:self];

    
}

@end
