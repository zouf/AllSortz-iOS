        //
//  ASZEditBusinessDetailsViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/5/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZEditBusinessDetailsViewController.h"
#import "ASBusiness.h"
@interface ASZEditBusinessDetailsViewController ()

@end

@implementation ASZEditBusinessDetailsViewController
- (IBAction)doneTapped:(id)sender {
    [self.dataController editBusinessAsynchronouslyWithID:self.businessID];
    
}
- (IBAction)cancelTapped:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.dataController addObserver:self
                          forKeyPath:@"business"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    [self.dataController addObserver:self
                          forKeyPath:@"business.image"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    [self.dataController addObserver:self
                          forKeyPath:@"allTypes"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
    
    [self.dataController refreshBusinessAsynchronouslyWithID:self.businessID];
    [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                     withObject:nil
                                  waitUntilDone:NO];
    [self.tableView reloadData];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    // For selecting cell.
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (void)viewDidUnload {
    [self.dataController removeObserver:self forKeyPath:@"business"];
    [self.dataController removeObserver:self forKeyPath:@"business.image"];
    [self.dataController removeObserver:self forKeyPath:@"allTypes"];

    self.dataController = nil;
    
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.dataController removeObserver:self forKeyPath:@"business"];
    [self.dataController removeObserver:self forKeyPath:@"business.image"];
    [self.dataController removeObserver:self forKeyPath:@"allTypes"];

    [super viewDidDisappear:animated];
}


#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:@"business"] || [keyPath isEqual:@"business.image"]) {
        if ([self.dataController valueForKeyPath:@"business.image"] != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImageView *imageView = (UIImageView*)[self.tableView viewWithTag:1000];
                imageView.image = [self.dataController valueForKeyPath:@"business.image"];
            });
        } else {
            // Table view has to be refreshed on main thread
            [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                          waitUntilDone:NO];
        }
        
    }
    if ([keyPath isEqual:@"allTypes"])
    {
        [self.tableView performSelectorOnMainThread:@selector(reloadData)
                                         withObject:nil
                                      waitUntilDone:YES];
        
        int i = 0;


        for (NSDictionary *dict in self.dataController.allTypes)
        {
            for (NSDictionary * d in self.dataController.business.types)
            {               
                if ([[d valueForKey:@"ID"] intValue] == [[dict valueForKey:@"typeID"] intValue])
                {
                    
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:1] ;
                    
                    [self.tableView selectRowAtIndexPath:ip animated:YES scrollPosition:UITableViewScrollPositionNone];
                    NSMutableArray* tp = (NSMutableArray*)self.dataController.allTypes[i];
                    [tp setValue:@"true" forKey:@"selected"];
                }
                
            }
            i++;
            
        }
        

        
    }
}

#pragma mark - Table view delegate


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray* tp = (NSMutableArray*)self.dataController.allTypes[indexPath.row];
    [tp setValue:@"true" forKey:@"selected"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 200;
            break;
        case 1:
            return 45;
        default:
            return tableView.rowHeight;
            break;
    }
}

@end
