//
//  LaunchViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/3/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "LaunchViewController.h"
#import "UIButton+ChangeAppearance.h"

#import "LoginViewController.h"
#import "RegistViewController.h"

#import "MainTabBarViewController.h"
#import "SetAvatarIntroductionViewController.h"

#import "macro.h"
#import "QDYHTTPClient.h"
#import "PhotoCommon.h"

@interface LaunchViewController()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, strong) UIPageControl *pageControl;

@end


@implementation LaunchViewController
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initIntroView];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf) name:@"loginSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goToIntroductionPage) name:@"registSuccess" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dismissSelf) name:@"finishIntroduction" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self initAppearance];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavigationAppearance];
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"token"])
    {
        [self hideViews];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)setNavigationAppearance
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}
-(void)initAppearance
{
   // [self.view setBackgroundColor:THEME_COLOR_DARK];
   // [self.view setBackgroundColor:rgba_WZ(229, 229, 229, 1.0)];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"token"])
    {
        NSLog(@"user defaults in launch%@",[userDefaults objectForKey:@"token"]);
        [[QDYHTTPClient sharedInstance]updateLocalUserInfo];
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MainTabBarViewController *main = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTabBarController"];
        [self.navigationController pushViewController:main animated:YES];
        
    }
    else
    {
        [self showViews];
    }
    
}

-(void)initIntroView
{
    
    //scrollview and pageControl
    self.scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, WZ_APP_SIZE.height - 80)];
    self.scrollview.pagingEnabled = YES;
    self.scrollview.showsHorizontalScrollIndicator = NO;
    [self.scrollview setContentSize:CGSizeMake(WZ_APP_SIZE.width*5, self.scrollview.frame.size.height)];
    [self.scrollview setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.view addSubview:self.scrollview];
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, self.scrollview.frame.size.height , WZ_APP_SIZE.width, 10)];
    self.pageControl.currentPageIndicatorTintColor = THEME_COLOR_WHITE;
    self.pageControl.pageIndicatorTintColor = THEME_COLOR_LIGHT_GREY;
    self.pageControl.numberOfPages = 5;

    [self.view addSubview:self.pageControl];
    
    //intro Views
    
    NSArray *descriptionArray1 = @[
                                  @"分享",
                                  @"收获",
                                  @"发现",
                                  @"游览",
                                  @"成就"];
    NSArray *descriptionArray2 = @[
                                   @"分享你旅途中最棒的照片,标记地点",
                                   @"获得大家的赞同和关注",
                                   @"从不断更新的照片中发现旅程下一站",
                                   @"从他人作品中游览各地",
                                   @"将自己的足迹铺满整个世界"];
    /*
    for (int i = 0; i<5; i++)
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i*WZ_APP_SIZE.width, 0, WZ_APP_SIZE.width,self.scrollview.frame.size.height)];
        [view setBackgroundColor:[UIColor clearColor]];
    
        UIView *innerView = [[UIView alloc]initWithFrame:CGRectInset(view.bounds, 16, 16)];
        [innerView setBackgroundColor:[UIColor colorWithRed:238 green:238 blue:238 alpha:1.0]];
        [innerView.layer setCornerRadius:4.0f];
        [innerView.layer setMasksToBounds:YES];
        innerView.layer.shadowColor = [[UIColor blackColor] CGColor];
        innerView.layer.shadowRadius = 15.0f;
        innerView.layer.shadowOpacity = 0.2f;

        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, innerView.frame.size.width, innerView.frame.size.width*1.2)];
        [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"intro_%ld",(long)i]]];
        [innerView addSubview:imageView];
        
        UIView *labelView = [[UIView alloc]initWithFrame:CGRectMake(0,innerView.frame.size.width*1.2 , innerView.frame.size.width, innerView.frame.size.height - innerView.frame.size.width*1.2)];
        [labelView setBackgroundColor:[UIColor colorWithWhite:10 alpha:1.0f]];
        [innerView addSubview:labelView];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0,0, labelView.frame.size.width, 42)];
        [label1 setText:descriptionArray1[i]];
        //[label1 setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
        [label1 setTextColor:THEME_COLOR_FONT_DARK_GREY];
        [label1 setFont:WZ_FONT_HIRAGINO_MID_SIZE];
        [label1 setTextAlignment:NSTextAlignmentCenter];
        [labelView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0,42, labelView.frame.size.width, labelView.frame.size.height - 42)];
        [label2 setText:descriptionArray2[i]];
        //[label2 setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
        [label2 setTextColor:THEME_COLOR_FONT_GREY];
        [label2 setFont:WZ_FONT_HIRAGINO_SMALL_SIZE];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        [labelView addSubview:label2];
        
        [view addSubview:innerView];
        [self.scrollview addSubview:view];
    }*/
    
    for (int i = 0;i <5;i++)
    {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(i*WZ_APP_SIZE.width, 0, WZ_APP_SIZE.width, WZ_APP_SIZE.height - 90)];
        CGRect imageRect ;
        if (i == 4)
        {
            imageRect = CGRectMake(0, view.frame.size.height - WZ_APP_SIZE.width*0.8, WZ_APP_SIZE.width, WZ_APP_SIZE.width*0.6);
        }
        else
        {
            imageRect = CGRectMake(0, view.frame.size.height - WZ_APP_SIZE.width, WZ_APP_SIZE.width, WZ_APP_SIZE.width);
        }
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:imageRect];
        [view addSubview:imageView];
        
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, 49)];
        [headView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
        [view addSubview:headView];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(0,49, WZ_APP_SIZE.width, 30)];
        [label1 setText:descriptionArray1[i]];
        [label1 setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
        [label1 setTextColor:THEME_COLOR_DARK_GREY];
        [label1 setFont:WZ_FONT_HIRAGINO_MID_SIZE];
        [label1 setTextAlignment:NSTextAlignmentCenter];
        [view addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(0,79, WZ_APP_SIZE.width, view.frame.size.height - WZ_APP_SIZE.width - 79)];
        [label2 setText:descriptionArray2[i]];
        [label2 setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
        [label2 setTextColor:THEME_COLOR_LIGHT_GREY];
        [label2 setFont:WZ_FONT_HIRAGINO_SMALL_SIZE];
        [label2 setTextAlignment:NSTextAlignmentCenter];
        [view addSubview:label2];
        
        [PhotoCommon drawALineWithFrame:CGRectMake(0, view.frame.size.height-WZ_APP_SIZE.width -0.5, WZ_APP_SIZE.width, 0.5f) andColor:THEME_COLOR_DARK_GREY_PARENT inLayer:view.layer];
        
        
        
        [imageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"intro%ld",(long)i]]];
        [self.scrollview addSubview:view];
    }
    self.scrollview.delegate = self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = WZ_APP_SIZE.width;
    CGFloat pageFraction = self.scrollview.contentOffset.x / pageWidth;
    self.pageControl.currentPage = roundf(pageFraction);
}

-(void)hideViews
{
    [self.LoginButton setHidden:YES];
    [self.RegisterButton setHidden:YES];
    [self.scrollview setHidden:YES];
    [self.pageControl setHidden:YES];
    self.scrollview.alpha = 0;
}


-(void)showViews
{
    [self.LoginButton setBigButtonAppearance];
    [self.LoginButton setThemeFrameAppearence];
    [self.RegisterButton setBigButtonAppearance];
    [self.RegisterButton setThemeBackGroundAppearance];
    [UIView animateWithDuration:1.0 animations:^{
        self.QDYLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);
        self.QDYLabel2.transform = CGAffineTransformMakeScale(0.1, 0.1);
    } completion:^(BOOL finished) {
        self.QDYLabel.alpha = 0;
        self.QDYLabel2.alpha = 0;
        [self.scrollview setAlpha:1.0f];
        [self.pageControl setAlpha:1.0f];
    }];

}

-(void)dismissSelf
{
    if (self.navigationController)
    {
        if (self.navigationController.viewControllers.count ==1)
        {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
    
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    if (self.dismiss)
    {
        [self dismiss];
    }
}

-(void)goToIntroductionPage
{
    UIStoryboard *introductionStoryboard = [UIStoryboard storyboardWithName:@"Introduction" bundle:nil];
    SetAvatarIntroductionViewController *introduction = [introductionStoryboard instantiateViewControllerWithIdentifier:@"introduction"];
    if (self.navigationController)
    {

        [self.navigationController pushViewController:introduction animated:YES];
        
    }
    else
    {
        [self showViewController:introduction sender:nil];
    }
}


@end
