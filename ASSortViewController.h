//
//  ASSortViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/13/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol NewSortDelegate;

@interface ASSortViewController : UITableViewController
{
    id<NewSortDelegate>delegate;
    UITextField *sortNameField;
}

@property(strong,nonatomic)id<NewSortDelegate>delegate;
@property(strong,nonatomic)IBOutlet UITextField *sortNameField;


- (IBAction)cancelTapped:(id)sender;
- (IBAction)doneTapped:(id)sender;

// Key-value observing
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

@end

@protocol NewSortDelegate <NSObject>

-(void)newASSortViewController:(ASSortViewController *)nsvc didCreateNewSort:(NSString *)url;
-(void)cancelNewASSortViewController:(ASSortViewController *)nsvc;

@end



