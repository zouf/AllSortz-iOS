//
//  ASSortViewController.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 8/13/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import "ASBusinessList.h"
#import "ASQuery.h"

#define ICON_IMAGE_VIEW 600
#define LABEL_VIEW 601
#define SEARCH_TEXT_VIEW 700
#define DISTANCE_PROXIMITY_VIEW 701
#define LOCATION_TEXT_VIEW 703

#define TYPES_SECTION 1
#define SORTS_SECTION 2

@protocol NewSortDelegate;

@interface ASSortViewController : UITableViewController 

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

-(void)waitOnQueryResponse:(ASQuery *)query;

@end



