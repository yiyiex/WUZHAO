//
//  SubjectItemWithoutPostTableViewCell.h
//  WUZHAO
//
//  Created by yiyi on 15/8/10.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subject.h"

@interface SubjectItemWithoutPostTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UIImageView *photo;
@property (nonatomic, strong) IBOutlet UILabel *photoDescription;

-(void)configureWithContent:(SubjectPost *)subjectPost;
@end
