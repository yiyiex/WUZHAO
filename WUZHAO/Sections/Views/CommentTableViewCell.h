//
//  CommentTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15-1-8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentTextView.h"



@interface CommentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userAvatorView;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet CommentTextView *commentContent;
@property (strong, nonatomic) IBOutlet UILabel *commentTime;

@property (nonatomic, weak) UIViewController *parentController;
-(void)configureDataWith:(NSDictionary *)cellData parentController:(UIViewController *)parentController;
-(void)setAppearance;
@end
