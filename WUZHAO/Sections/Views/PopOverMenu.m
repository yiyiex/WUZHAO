//
//  PopOverMenu.m
//  WUZHAO
//
//  Created by yiyi on 15/5/7.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PopOverMenu.h"

#ifdef NSFoundationVersionNumber_iOS_6_1
#define IOS7_OR_GREATER (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
#else
#define IOS7_OR_GREATER NO
#endif

@interface PopOverMenu()
@property (nonatomic, strong) MenuItem *menuBar;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGRect oldFrame;
@property (nonatomic, assign) CGRect originalFrame;
@property (nonatomic, assign) CGFloat offsetX;

@property (nonatomic, copy) MenuSelectItemChangeBlock menuSelectItemChange;


@end

@implementation PopOverMenu

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
    
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    super.frame = frame;
    self.originalFrame = frame;
}

-(void)setExpanding:(BOOL)expanding
{
    _expanding = expanding;
    [self updateView];
}

-(void)setFlipWhenToggleView:(BOOL)flipWhenToggleView
{
    _flipWhenToggleView = flipWhenToggleView;
}

-(void)setFoldMenuWhenClickItem:(BOOL)foldMenuWhenClickItem
{
    _foldMenuWhenClickItem = foldMenuWhenClickItem;
}

-(CGFloat)alphaOnFold
{
    if (_alphaOnFold != -1)
    {
        return _alphaOnFold;
    }
    return 1.0;
}

-(void)setMenuItems:(NSArray *)menuItems
{
    if (!_menuItems)
    {
        _menuItems = [[NSMutableArray alloc]initWithArray:menuItems copyItems:YES];
    }
}


#pragma mark - Basic Method
-(void)selectItemAtIndex:(NSUInteger)index
{
    if (index < self.menuItems.count)
    {
   
    }
}
-(void)commonInit
{
    self.originalFrame = self.frame;
    [self resetParams];
    self.menuBar = [[MenuItem alloc]init];
}



-(void)resetParams
{
    self.frame = self.originalFrame;
    super.frame = self.originalFrame;
    
    self.selectedIndex = -1;
    self.flipWhenToggleView = NO;
    self.useSpringAnimation = NO;
    self.expanding = NO;
    self.useSpringAnimation = YES;
    
    self.animationDuration = 0.3;
    self.itemAnimationDelay = 0.0;
    self.gutterY = 0;
    self.alphaOnFold = -1;

    
}

-(void)updateView
{
    if (self.shouldFlipWhenToggleView)
    {
        [self flipMenuBar];
    }
    if (self.isExpanding)
    {
        [self expandView];
    }
    else
    {
        [self foldView];
    }
}

-(void)expandView
{
    
}

-(void)foldView
{
    
}

-(void)flipMenuBar
{

}

@end
