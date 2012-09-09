        //
//  ASZEditBusinessDetailsViewController.m
//  AllSortz
//
//  Created by Matthew Zoufaly on 9/5/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASZEditBusinessDetailsViewController.h"

@interface ASZEditBusinessDetailsViewController ()

@end

@implementation ASZEditBusinessDetailsViewController
- (IBAction)doneTapped:(id)sender {
    
}
- (IBAction)cancelTapped:(id)sender {
    [self.navigationController dismissModalViewControllerAnimated:YES];
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
                                      waitUntilDone:NO];
    }
}

#pragma mark - Table view delegate



- (void)tableView:(UITableView *)tableViewdidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 300;
            break;
        case 1:
            return 45;
        default:
            return tableView.rowHeight;
            break;
    }
}

@end
