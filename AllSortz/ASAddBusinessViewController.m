//
//  ASAddBusinessViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/14/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASAddBusinessViewController.h"
#import "ASAddBusinessDataController.h"
#define IMAGE_VIEW 600
#define LABEL_VIEW 601

#define BUSINESS_NAME 200
#define BUSINESS_STREET 201
#define BUSINESS_CITY 202
#define BUSINESS_STATE 203
#define BUSINESS_URL 204
#define BUSINESS_PHONE 205
#define PHOTO_URL 206
@interface ASAddBusinessViewController ()
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ASAddBusinessDataController *addBusinessDataController;

@end

@implementation ASAddBusinessViewController

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

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.addBusinessDataController removeObserver:self forKeyPath:@"business"];
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


#pragma mark - Table view delegate


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
        UILabel *label =(UILabel *)[cell viewWithTag:LABEL_VIEW];
        
        id type = [self.addBusinessDataController.business.allTypes objectAtIndex:indexPath.row];
        
        
        if([[self.addBusinessDataController.business.selectedTypes objectForKey:[type objectForKey:@"typeName"] ] boolValue])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        label.text = [type objectForKey:@"typeName"];
        
        UIImageView *imageView =(UIImageView*)[cell viewWithTag:IMAGE_VIEW];
        imageView.image = [UIImage imageNamed: [type objectForKey:@"typeIcon"]];
        imageView.backgroundColor = [UIColor lightGrayColor];
        return cell;
    }
    // Configure the cell...
    
    return nil;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc]init];
    
	NSString *sectionHeader = nil;
	
	if(section == 0) {
		sectionHeader = @"Business Info";
	}
	if(section == 1) {
		sectionHeader = @"Business Type";
	}
    label.text = sectionHeader;
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.textAlignment=NSTextAlignmentCenter;

    label.backgroundColor = [UIColor clearColor];
    return label;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([indexPath section ]== 0)
        return 244;
    return 45;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 1)
        return;
    id type = [self.addBusinessDataController.business.allTypes objectAtIndex:indexPath.row];
    [self.addBusinessDataController.business.selectedTypes setValue:[NSNumber numberWithBool:YES] forKey:[type valueForKey:@"typeName"]];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id type = [self.addBusinessDataController.business.allTypes objectAtIndex:indexPath.row];
    [self.addBusinessDataController.business.selectedTypes setValue:[NSNumber numberWithBool:NO] forKey:[type valueForKey:@"typeName"]];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
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
    
   /* NSMutableDictionary *lTypes =[[NSMutableDictionary alloc]init];
    for (NSInteger i = 0; i < [self.tableView numberOfRowsInSection:1]; ++i)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
        if ([])
        {
            NSDictionary *typeEntry =  [self.addBusinessDataController.business.allTypes objectAtIndex:i];
            [lTypes addObject:[typeEntry objectForKey:@"typeName" ]];
        }
    }*/
    
    ASAddBusiness *business = self.addBusinessDataController.business;

    UITextField *nameField = (UITextField*)[self.tableView viewWithTag:BUSINESS_NAME];
    UITextField *streetField = (UITextField*)[self.tableView viewWithTag:BUSINESS_STREET];
    UITextField *cityField = (UITextField*)[self.tableView viewWithTag:BUSINESS_CITY];
    UITextField *urlField = (UITextField*)[self.tableView viewWithTag:BUSINESS_URL];
    UITextField *phoneField = (UITextField*)[self.tableView viewWithTag:BUSINESS_PHONE];
    UITextField *stateField =(UITextField*)[self.tableView viewWithTag:BUSINESS_STATE];
    UITextField *photoURL =(UITextField*)[self.tableView viewWithTag:PHOTO_URL];

    
    business.businessName = nameField.text;
    business.businessAddress = streetField.text;
    business.businessCity = cityField.text;
    business.businessURL = urlField.text;
    business.businessPhone = phoneField.text;
    business.businessState = stateField.text;

    business.businessPhotoURL = photoURL.text;

    
    
    [self.addBusinessDataController uploadData];
    [self.navigationController popViewControllerAnimated:YES];
    
    //    [self.delegate newASAddBusinessViewController:self didCreateNewBusiness:self.addBusinessDataController.business];
}

- (IBAction)cancel:(id)sender {
    [self.delegate cancelASAddBusinessViewController:self];
}

@end
