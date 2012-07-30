//
//  ASListingsViewController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/19/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@interface ASListingsViewController : UIViewController <UITableViewDelegate>

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context;

@end
