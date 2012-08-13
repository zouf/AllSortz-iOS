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

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ASQueryDataController *queryDataController;

@end

@implementation ASSortViewController
@synthesize tableView;
@synthesize queryDataController;

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
    [self setQueryDataController:nil];
    [self setTableView:nil];
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
    if (!self.queryDataController.query)
        [self.queryDataController updateData];
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
        static NSString *CellID = @"SliderCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        return cell;
    }
    else if (section == 1)
    {
        static NSString *CellID = @"TypeCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        cell.textLabel.text = [self.queryDataController.query.types objectAtIndex:[indexPath row]];
        return cell;
        
    }
    else
    {
        static NSString *CellID = @"SortCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        cell.textLabel.text = [self.queryDataController.query.sorts objectAtIndex:[indexPath row]];
        return cell;
    }
    //NSString *contentForThisRow = [sectionContents objectAtIndex:[indexPath row]];
    
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

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
#pragma mark - Key value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"Observed change at %@\n", keyPath);
    // If the business list changes, reassign
    if ([keyPath isEqualToString:@"query"]) {
        id newDataSource = [change objectForKey:NSKeyValueChangeNewKey];
        self.tableView.dataSource = (newDataSource == [NSNull null] ? nil : newDataSource);
        [self.tableView reloadData];
    }
}


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
#pragma mark - Actions

#pragma mark - Actions
-(IBAction)cancelTapped:(id)sender{ 
    NSLog(@"Send a cancel command\n");
    [self.delegate cancelNewASSortViewController:self];
}

-(IBAction)doneTapped:(id)sender{
    NSLog(@"Send a done command\n");

    [self.delegate newASSortViewController:self didCreateNewSort:self.queryDataController.query];
}
@end
