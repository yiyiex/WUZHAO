//
//  SearchResultViewController.h
//  WUZHAO
//
//  Created by yiyi on 15/4/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"
/*
typedef NS_ENUM(NSInteger, SearchTableDataType)
{
    SEARCHTABLEDATAADDRESS = 0,
    SEARCHTABLEDATAUSER  = 1
    
};
typedef NS_ENUM(NSInteger, SearchStatus)
{
    SEARCHSTATUSEND = 0,
    SEARCHSTATUSERROR = 1,
    SEARCHSTATUSNOTBEGIN = 2
};
*/
@interface SearchResultViewController : UIViewController

@property (nonatomic, strong) IBOutlet HMSegmentedControl * segmentControl;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *searchUserListTableView;
@property (nonatomic, strong) UITableView *searchAddressListTableView;

@property (nonatomic, strong) NSMutableArray *searchUserListData;
@property (nonatomic, strong) NSMutableArray *searchAddressListData;
@property (nonatomic) NSInteger searchType;
@property (nonatomic) NSInteger searchStatus;

-(void)updateSearchResultWithData:(NSDictionary *)data;

@end
