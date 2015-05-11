//
//  CommentTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15-1-8.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface CommentTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userAvatorView;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *commentContent;
@property (strong, nonatomic) IBOutlet UILabel *commentTime;
-(void)setAppearance;
@end
