//
//  PhotoScrollViewController.m
//  WUZHAO
//
//  Created by yiyi on 15/5/18.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "PhotoScrollViewController.h"
#import "HomeTableViewController.h"

@interface PhotoScrollViewController ()


@property (nonatomic, strong) NSMutableArray *reusePhotoDetailViewControllers;


@end

@implementation PhotoScrollViewController

-(instancetype)init
{
    self = [super init];
    if (self)
    {
         self.dataSource = self;
        [self initViewWithCapacity:1];
       
    }
    return self;
}
-(instancetype)initWithDatas:(NSMutableArray *)datas
{
    self = [super init];
    if (self)
    {
        
        self.dataSource = self;
        self.allPhotos = datas;
        [self initViewWithCapacity:datas.count];
    }

    return self;
}
- (void)viewDidLoad {

    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initViewWithCapacity:(NSInteger)capacity
{
    NSUInteger pageNum;
    if (capacity >=3)
    {
        pageNum = 3;
    }
    else
    {
        pageNum = capacity;
    }
    self.reusePhotoDetailViewControllers = [[NSMutableArray alloc]initWithCapacity:pageNum];
  
    for (int i =0;i<pageNum;i++)
    {
        [self.reusePhotoDetailViewControllers addObject:[NSNull null]];
    }
    for (int i =0;i<pageNum;i++)
    {
          UIStoryboard *whatsNew = [UIStoryboard storyboardWithName:@"WhatsNew" bundle:nil];
          HomeTableViewController *controller = [whatsNew instantiateViewControllerWithIdentifier:@"HomeTableViewController"];
        [self.reusePhotoDetailViewControllers replaceObjectAtIndex:i withObject:controller];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(NSUInteger)numberOfViewControllerInDDScrollView:(DDScrollViewController *)DDScrollView
{
    return self.allPhotos.count;
}

-(UIViewController *)ddScrollView:(DDScrollViewController *)ddScrollView contentViewControllerAtIndex:(NSUInteger)index
{
    HomeTableViewController *controller = self.reusePhotoDetailViewControllers[index %3];
    controller.dataSource = [[NSMutableArray alloc]initWithArray:@[[self.allPhotos objectAtIndex:index]]];
    controller.tableStyle = WZ_TABLEVIEWSTYLEDETAIL;
    [controller GetLatestDataList];
    return controller;
}

@end
