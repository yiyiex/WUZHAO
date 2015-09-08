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
@property (nonatomic, strong) IBOutlet UITextView *title;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *titleLabelHeightConstraint;
@property (nonatomic, strong) IBOutlet UIImageView *photo;
@property (nonatomic, strong) IBOutlet UITextView *photoDescription;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *photoDescriptionlHeightConstraint;

@property (nonatomic, strong) NSDictionary *titleTextAttributes;
@property (nonatomic, strong) NSDictionary *photoDescriptionAttributes;


-(void)configureWithContent:(SubjectPost *)subjectPost;
@end
