//
//  ASZCommentCell.h
//  AllSortz
//
//  Created by Matthew Zoufaly on 10/12/12.
//  Copyright (c) 2012 AllSortz, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ASZCommentCell : UITableViewCell {
    UILabel *valueLabel;
    UIImageView *arrowImage;
    
    int level;
    BOOL expanded;
}

@property (nonatomic, retain) UILabel *valueLabel;
@property (nonatomic, retain) UIImageView *arrowImage;
@property (nonatomic) int level;
@property (nonatomic) BOOL expanded;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              level:(NSUInteger)_level
           expanded:(BOOL)_expanded;

@end