//
//  AddImageInfoViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-21.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"
#import "WhatsGoingOn.h"
#import "POI.h"

@interface AddImageInfoViewController : UIViewController <UITableViewDataSource,UITableViewDelegate ,UITextViewDelegate ,UIAlertViewDelegate>

@property (strong,nonatomic) WhatsGoingOn *whatsGoingOnItem;

@property (nonatomic,strong) NSMutableArray *imagesAndInfo;
@property (nonatomic, strong) NSDictionary *postImageInfo;

- (IBAction)PostButtonPressed:(UIBarButtonItem *)sender;
@end




