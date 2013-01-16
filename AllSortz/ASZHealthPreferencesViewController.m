//
//  ASZHealthPreferencesViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/8/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZHealthPreferencesViewController.h"
#define SECTION_HEADER_HEIGHT 76
@interface ASZHealthPreferencesViewController ()
@property(nonatomic,retain) UITextField *focusedTextField;
@end

@implementation ASZHealthPreferencesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dismissKeyboard {
    [self.focusedTextField resignFirstResponder];
}

- (void)viewDidLoad
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [tap setCancelsTouchesInView:NO];

    [self.tableView addGestureRecognizer:tap];
    [self setTitle:@"Your Preferences"];
    [super viewDidLoad];
    
    self.dataController = [self.dataController init];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Save button
- (IBAction)savePreferences:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
    for (int row = 0; row < [self.tableView numberOfRowsInSection:0]; row++)
    {
        NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:0];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellPath];
        UITextField *tf = (UITextField*)[cell viewWithTag:101];

        if(row == 0)
        {
            [defaults setObject:tf.text forKey:@"name"];
        }
        else
        {
            [defaults setObject:tf.text forKey:@"email"];

        }
        //do stuff with 'cell'
    }
    for (int row = 0; row < [self.tableView numberOfRowsInSection:1]; row++)
    {
        NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:1];
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellPath];
        
        if(row == 0)
        {
            UITextField *tf = (UITextField*)[cell viewWithTag:101];
            [defaults setObject:tf.text forKey:@"age"];
        }
        else if(row==1)
        {
            UISegmentedControl * segmented = (UISegmentedControl*)[cell viewWithTag:101];
            
                [defaults setObject:[NSNumber numberWithInt:segmented.selectedSegmentIndex] forKey:@"gender"];
            
        }
        else if(row==2)
        {
            UISegmentedControl * segmented = (UISegmentedControl*)[cell viewWithTag:101];
        
                
                [defaults setObject:[NSNumber numberWithInt:segmented.selectedSegmentIndex] forKey:@"workout"];
            }
        
    }
    
#pragma warning - doesnt work right
    // todo xxx
    

    NSMutableArray * restrictions = [[NSMutableArray alloc]init];
    for (int section = 2; section < [self.tableView numberOfSections]; section++)
    {
        
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[self.dataController.categories objectAtIndex:section-2]];

       NSMutableArray *factors = [NSMutableArray arrayWithArray:[dict objectForKey:@"factors"]];
        /*for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            //NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];

           // NSMutableDictionary* factor = [NSMutableDictionary dictionaryWithDictionary:[factors objectAtIndex:row]];
         //   [factors setObject:factor atIndexedSubscript:row];
        }*/
        [dict setObject:factors forKey:@"factors"];
        [restrictions addObject:dict];
    }
    [defaults setObject:restrictions forKey:@"categories"];
    [defaults synchronize];

   
    return;
}


#pragma mark - text field delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.focusedTextField = textField;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch(indexPath.section)
    {
        case 0:
        {
            break;
        }
        case 1:
        {
            break;
        }
        default:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
             
            NSMutableDictionary * dict = (NSMutableDictionary*)[self.dataController.categories objectAtIndex:indexPath.section-2];
            NSMutableArray *factors = [dict objectForKey:@"factors"];
            NSMutableDictionary* factor = [factors objectAtIndex:indexPath.row];
            [factor setObject:[NSNumber numberWithBool:NO] forKey:@"selected"];
            break;
        }
            
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch(indexPath.section)
    {
        case 0:
        {
            break;
        }
        case 1:
        {
            break;
        }
        default:
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSMutableDictionary * dict = (NSMutableDictionary*)[self.dataController.categories objectAtIndex:indexPath.section-2];
            NSMutableArray *factors = [dict objectForKey:@"factors"];
            NSMutableDictionary* factor = [factors objectAtIndex:indexPath.row];
            [factor setObject:[NSNumber numberWithBool:YES] forKey:@"selected"];
            break;
        }

    }
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *secView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, SECTION_HEADER_HEIGHT)];
    [secView setBackgroundColor:[UIColor clearColor]];
    
    
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, tableView.bounds.size.width, 30)];
    [title setBackgroundColor:[UIColor clearColor]];
    title.font = [UIFont boldSystemFontOfSize:20];
    title.textColor = [UIColor darkTextColor];
    
    UILabel* description = [[UILabel alloc]initWithFrame:CGRectMake(10, 40, tableView.bounds.size.width - 40, 30)];
    description.backgroundColor = [UIColor clearColor];
    [description setBackgroundColor:[UIColor clearColor]];

    description.numberOfLines = 0;
    description.backgroundColor = [UIColor clearColor];
    description.font =  [UIFont systemFontOfSize:10];
    description.textColor = [UIColor darkGrayColor];

    switch(section)
    {
        case 0:
        {
            title.text  = @"Basic Info";
            description.text = @"It's completely optional whether you give us your information, but we'd like to understand you as much as possible. Please let us know your name nad how to contact you.";
            break;
        }
        case 1:
        {
            title.text  = @"Additional Info";
            description.text = @"The more you tell us about yourself, the more we can help you figure out what's good for you to eat when you go out.";
            break;
        }
        case 2:
        {
            title.text  = @"Allergen";
            description.text = @"Help us find dishes that contain ingredients harmful to you. We will keep your allergen information confidential at all times.";
            break;
        }
        case 3:
        {
            title.text  = @"Sustainability";
            description.text = @"Do you eat food that is considered sustainable? We will keep this information confidential at all times.";
            break;

        }
        case 4:
        {
            title.text  = @"Lifestyle";
            description.text = @"Do you have any lifestyle choices that effect your diet? We'll keep this information confidential at all times.";
            break;
        }
        case 5:
        {
            title.text  = @"Diets";
            description.text = @"Are you on any diets? We will keep this information confidential at all times.";
            break;
        }
        default:
        {
            
            id category = [self.dataController.categories objectAtIndex:section-2];
            title.text  =  [category objectForKey:@"category"];
            description.text = [category objectForKey:@"category"];

            break;
        }
         
            
    }
    [secView addSubview:title];
    [secView addSubview:description];

    return secView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SECTION_HEADER_HEIGHT;
}
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 2 && indexPath.section == 1)
        return 70;
    return 45;}

- (void)viewDidUnload {
    [self setDataController:nil];
    [super viewDidUnload];
}
@end
