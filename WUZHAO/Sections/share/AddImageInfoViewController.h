//
//  AddImageInfoViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WhatsGoingOn.h"


@protocol AddImageInfoViewDelegate;


@interface AddImageInfoViewController : UIViewController <UITableViewDataSource,UITableViewDelegate ,UITextViewDelegate>

@property (nonatomic,assign) id<AddImageInfoViewDelegate> addImageInfoDelegate;

@property (strong, nonatomic) IBOutlet UIImageView *postImageView;
@property (strong, nonatomic) IBOutlet UITextField *postImageDescription;
@property (strong, nonatomic) IBOutlet UITableView *addressTableView;
@property (strong, nonatomic) IBOutlet UILabel *addressInfoLabel;

@property (strong,nonatomic) WhatsGoingOn *whatsGoingOnItem;

@property (nonatomic,strong) UIImage *postImage;
- (IBAction)PostButtonPressed:(UIBarButtonItem *)sender;
@end

@protocol AddImageInfoViewDelegate <NSObject>

-(void)endPostImageInfo;

@end



