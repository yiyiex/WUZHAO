//
//  SearchResultTableViewController2.h
//  WUZHAO
//
//  Created by yiyi on 15/4/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SearchStatus)
{
    SEARCHSTATUSEND = 0,
    SEARCHSTATUSERROR = 1,
    SEARCHSTATUSNOTBEGIN = 2,
    SEARCHSTATUSING = 3
};
@interface SearchResultTableViewController2 : UITableViewController

@end
