//
//  SearchViewController.h
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SearchViewController : UIViewController
@property (nonatomic,strong) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)segmentIndexChanged:(id)sender;



@end
