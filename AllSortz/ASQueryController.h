//
//  ASQueryController.h
//  AllSortz
//
//  Created by Lawrence Velázquez on 7/20/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

@interface ASQueryController : NSObject <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
