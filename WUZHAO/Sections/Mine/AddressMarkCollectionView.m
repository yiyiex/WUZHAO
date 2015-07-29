//
//  AddressMarkCollectionView.m
//  WUZHAO
//
//  Created by yiyi on 15/7/23.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressMarkCollectionView.h"
#import "AddressMarkCollectionViewCell.h"
#import "macro.h"
#define spacing 8
#define headViewHeight 40
@interface AddressMarkCollectionView()
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation AddressMarkCollectionView

-(instancetype)initWithFrame:(CGRect)frame
{
    CGRect outFrame = CGRectMake(0, 0, WZ_APP_SIZE.width, WZ_APP_SIZE.height+20);
    self = [super initWithFrame:outFrame];
    if (self)
    {
        self.backgroundColor = THEME_COLOR_DARK_GREY_PARENT;
        _containerView = [[UIView alloc]initWithFrame:frame];
        _containerView.layer.masksToBounds = YES;
        [_containerView.layer setCornerRadius:2.0f];
        [_containerView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        [_containerView.layer setShadowOpacity:0.0f];
        [_containerView.layer setShadowOffset:CGSizeMake(0, 0)];
        [_containerView.layer setShadowRadius:10.0f];
        [self addSubview:_containerView];
        
        //init collection view
        float cellwidth = (frame.size.width - spacing*4)/3;
        UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc]init];
        collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        collectionLayout.itemSize = CGSizeMake(cellwidth, cellwidth);
        collectionLayout.minimumInteritemSpacing = 4;
        collectionLayout.minimumLineSpacing = 8;
        collectionLayout.sectionInset = UIEdgeInsetsMake(8, 8, 0, 8);
        //[collectionLayout setHeaderReferenceSize:CGSizeMake(WZ_APP_SIZE.width - 40, 40)];
        
        _photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, headViewHeight, frame.size.width, frame.size.height - headViewHeight) collectionViewLayout:collectionLayout];
        [_photoCollectionView setBounces:NO];
        _photoCollectionView.backgroundColor = VIEW_COLOR_WHITEGREY;

        [_photoCollectionView registerClass:[AddressMarkCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];

        //headView
        _headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, headViewHeight)];
        [_headView setBackgroundColor:THEME_COLOR_DARK];
        _closeButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 70, 0, 65, headViewHeight)];
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeButton.titleLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
        [_closeButton.titleLabel setTextColor:[UIColor whiteColor]];
        [_headView addSubview:_closeButton];
        [_closeButton addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((frame.size.width - 180)/2, 0, 180, headViewHeight)];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:[UIColor whiteColor]];
        [_titleLabel setFont:WZ_FONT_LARGE_BOLD_SIZE];
        [_headView addSubview:_titleLabel];
        
        [self.containerView addSubview:_headView];
        [self.containerView addSubview:_photoCollectionView];
        

        [self setHidden:YES];
        
    }
    return self;
}

-(void)setDelegate:(id<UICollectionViewDelegate>)delegate
{
    self.photoCollectionView.delegate = delegate;
}
-(void)setDatasource:(id<UICollectionViewDataSource>)datasource
{
    self.photoCollectionView.dataSource = datasource;
}

-(void)resizeWithContentCount:(float)count
{
    float cellwidth = (self.containerView.frame.size.width - spacing*4)/3;
    float collectionViewHeight = ceil(count/3)*(cellwidth+spacing) + headViewHeight;
    collectionViewHeight = MIN(WZ_APP_SIZE.height - 120, collectionViewHeight);
    CGRect viewFrame = self.containerView.frame;
    viewFrame.size.height = collectionViewHeight;
    self.containerView.frame = viewFrame;
    self.photoCollectionView.frame = CGRectMake(0, headViewHeight, self.containerView.frame.size.width,self.containerView.frame.size.height - headViewHeight);
    self.containerView.center = CGPointMake(WZ_APP_SIZE.width/2, WZ_APP_SIZE.height/2+20);
    [self setTitleNum:count];
    [self.photoCollectionView reloadData];
}

-(void)showView
{
    self.containerView.alpha = 0.0;
    [self setHidden:NO];
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:0x00 animations:^{
        self.containerView.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideView
{
    self.alpha = 1.0;
    [UIView animateWithDuration:0.3 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:0x00 animations:^{
        self.containerView.alpha = 0.0;
    } completion:^(BOOL finished) {
           [self setHidden:YES];
    }];
    
}

-(void)setTitleNum:(NSInteger)num
{
    [self.titleLabel setText:[NSString stringWithFormat:@"%ld张照片",(long)num]];
}

@end
