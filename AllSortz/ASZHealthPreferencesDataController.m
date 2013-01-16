//
//  ASZHealthPreferencesDataController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 1/8/13.
//  Copyright (c) 2013 AllSortz, Inc. All rights reserved.
//

#import "ASZHealthPreferencesDataController.h"

@implementation ASZHealthPreferencesDataController

@synthesize categories, name, email, age, workoutDays,gender;
-(void)loadCoreDataElements
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.name = [defaults objectForKey:@"name"];
    self.gender = [defaults objectForKey:@"gender"];
    self.email = [defaults objectForKey:@"email"];
    self.workoutDays = [defaults objectForKey:@"workout"];
    self.age = [defaults objectForKey:@"age"];
    id cat = [defaults objectForKey:@"categories"];
    self.categories = [defaults objectForKey:@"categories"];
}

-(id)init
{
    if (!(self = [super init]))
        return nil;
    NSError *jsonParsingError = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"allergymodel" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray * JSONresponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonParsingError];
    self.categories = [NSMutableArray arrayWithArray:JSONresponse];
    [self loadCoreDataElements];
    return self;
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.categories)
    {
        return self.categories.count + 2;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch(section)
    {
        case 0:
            return 2;
        case 1:
            return 3;
        default:
        {
            NSArray *factors = [[self.categories objectAtIndex:section-2] objectForKey:@"factors"];
            return factors.count;
            break;
        }
    }
    // Return the number of rows in the section.
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSInteger labelTag = 100;
    static NSString *BasicID = @"BasicText";
    static NSString *GenderID = @"FemaleMale";
    static NSString *PreferenceID = @"NutritionPreference";

    static NSString *ExerciseID = @"WorkoutDays";
    switch(indexPath.section)
    {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:BasicID forIndexPath:indexPath];
            switch(indexPath.row)
            {
                case 0:
                {
                    UILabel * lbl = (UILabel*)[cell viewWithTag:labelTag];
                    lbl.text = @"Name";
                    if(self.name)
                    {
                        UITextField *tf = (UITextField*)[cell viewWithTag:101];
                        tf.text = self.name;
                    }

                    break;
                }
                default:
                {
                    UILabel * lbl =  (UILabel*)[cell viewWithTag:labelTag];
                    lbl.text = @"E-mail";
                    if(self.email)
                    {
                        UITextField *tf = (UITextField*)[cell viewWithTag:101];
                        tf.text = self.email;
                    }

                    break;
                }
            }
            break;
        }
        case 1:
        {
            switch(indexPath.row)
            {
                case 0:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:BasicID forIndexPath:indexPath];
                    UILabel * lbl =  (UILabel*)[cell viewWithTag:labelTag];
                    lbl.text = @"Age";
                    
                        UITextField *tf = (UITextField*)[cell viewWithTag:101];
                    if([self.age intValue])
                        tf.text = [NSString stringWithFormat:@"%d",[self.age intValue]];
                    
                    break;
                }
                case 1:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:GenderID forIndexPath:indexPath];
                    UISegmentedControl *sc = (UISegmentedControl*)[cell viewWithTag:101];

                    if(self.gender)
                    {
                        sc.selectedSegmentIndex = [self.gender intValue];
                    }
                    else
                    {
                        sc.selectedSegmentIndex = -1;
                    }
                    break;
                }
                default:
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:ExerciseID forIndexPath:indexPath];

                    UISegmentedControl *sc = (UISegmentedControl*)[cell viewWithTag:101];
                    if(self.workoutDays)
                    {
                        sc.selectedSegmentIndex = [self.workoutDays intValue];
                    }
                    else
                    {
                        sc.selectedSegmentIndex = -1;
                    }
                    break;
                }
            }
            break;
        }
        default:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:PreferenceID forIndexPath:indexPath];
            UILabel *lbl = (UILabel*)[cell viewWithTag:labelTag];
            NSMutableDictionary* dict = [self.categories objectAtIndex:indexPath.section-2];
            NSMutableArray *factors = [dict objectForKey:@"factors"];
            NSMutableDictionary* factor = [factors objectAtIndex:indexPath.row];
            
            
            NSLog(@"%@\n",factor);
            
            BOOL selected = [[factor objectForKey:@"selected"] boolValue];
            if(selected)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;

            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            lbl.text = [factor objectForKey:@"name"];
            break;
        }
    }
       // Configure the cell...
    
    return cell;
}



@end
