//
//  PopOverMenu.h
//  WUZHAO
//
//  Created by yiyi on 15/5/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"
@class PopOverMenu;

typedef NS_ENUM(NSUInteger, PopOverMenuDirection)
{
    PopOverMenuDirectionDown,
    PopOverMenuDirectionUp,
};
typedef void(^MenuSelectItemChangeBlock)(NSInteger selectedIndex);

@protocol PopOverMenuDelegate <NSObject>

-(void)popOverMenu:(PopOverMenu *)menu selectedItemAtIndex:(NSInteger)index;

@end

@interface PopOverMenu : UIView

@property (nonatomic, weak) id<PopOverMenuDelegate> delegate;

@property (nonatomic, strong, readonly) MenuItem *menuBar;
@property (nonatomic, strong) NSString *menuTitle;
@property (nonatomic, strong) UIImage *menuBarIconImage;
@property (nonatomic, strong) NSMutableArray *menuItems;

@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign,readonly) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL foldMenuWhenClickItem;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) CGFloat itemAnimationDelay;
@property (nonatomic, assign) PopOverMenuDirection direction;
@property (nonatomic, assign) CGFloat slidingInOffset;
@property (nonatomic, assign) CGFloat gutterY;
@property (nonatomic, assign) CGFloat alphaOnFold;

@property (nonatomic, assign, getter=isExpanding) BOOL expanding;
@property (nonatomic, assign, getter=shouldFlipWhenToggleView) BOOL flipWhenToggleView;
@property (nonatomic, assign, getter=shouldUseSpringAnimation) BOOL useSpringAnimation;

@end
