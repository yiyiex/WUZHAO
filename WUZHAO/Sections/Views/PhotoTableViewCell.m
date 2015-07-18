    //
//  PhotoTableViewCell.m
//  WUZHAO
//
//  Created by yiyi on 14-12-15.
//  Copyright (c) 2014年 yiyi. All rights reserved.
//

#import "PhotoTableViewCell.h"

#import "UIImageView+ChangeAppearance.h"

#import "UIView+ChangeAppearance.h"
#import "UILabel+ChangeAppearance.h"
#import "UIButton+ChangeAppearance.h"
#import "UIImageView+WebCache.h"
#import "HomeSmallImagesCollectionViewCell.h"
#import "QDYHTTPClient.h"
#import "SVProgressHUD.h"

#import "macro.h"

#define AvatorImageWidth 38
#define smallImagesWidth 70


@interface PhotoTableViewCell()<UICollectionViewDataSource,UICollectionViewDelegate>



@end

@implementation PhotoTableViewCell

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initView];
    }
    return self;
}
- (void)awakeFromNib {
    
    [self initView];
    // Initialization code
}
-(WhatsGoingOn *)content
{
    if (!_content)
    {
        _content = [[WhatsGoingOn alloc]init];
    }
    return _content;
}

-(void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    self.contentView.frame = self.bounds;
}

-(void)initView
{
    self.backgroundColor = [UIColor clearColor];
    
    
    [self.homeCellAvatorImageView setRoundConerWithRadius:18];
    [self.homeCellAvatorImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    
    [self.postUserName setDarkGreyLabelAppearance];
    [self.postUserSelfDescription setSmallReadOnlyLabelAppearance];
    [self.postTimeLabel setBoldReadOnlyLabelAppearance];
    
    [self.followButton setTitle:@"" forState:UIControlStateNormal];
    [self.followButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self.followButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.addressLabel setBackgroundColor: [UIColor clearColor]];
    [self.addressLabel setThemeLabelAppearance];
    
    [self.homeCellImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.descriptionTextView setTextColor:THEME_COLOR_DARK_GREY_BIT_PARENT];
    [self.descriptionTextView setFont:WZ_FONT_COMMON_SIZE];
    [self.descriptionTextView setScrollEnabled:NO];
    [self.descriptionTextView setEditable:NO];
    
    [self.likeLabel setThemeLabelAppearance];
    [self.likeLabel setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    
    [self.zanClickButton setNormalButtonWithBoldFontAppearance];
    //[self.zanClickButton setGreyBackGroundAppearance];
    [self.commentClickButton setNormalButtonWithBoldFontAppearance];
    [self.commentClickButton setGreyBackGroundAppearance];
    [self.moreButton setNormalButtonWithBoldFontAppearance];
    [self.moreButton setGreyBackGroundAppearance];
    
    [self initImagesCollectionView];
}
-(void)initImagesCollectionView
{
    UICollectionViewFlowLayout *collectionLayout = [[UICollectionViewFlowLayout alloc]init];
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionLayout.itemSize = CGSizeMake(smallImagesWidth,smallImagesWidth);
    collectionLayout.minimumInteritemSpacing = 8;
    collectionLayout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 0);
    [_imagesCollectionView setCollectionViewLayout:collectionLayout];
    _imagesCollectionView.dataSource = self;
    _imagesCollectionView.delegate = self;
    [_imagesCollectionView setBackgroundColor:[UIColor whiteColor]];
    [_imagesCollectionView registerClass:[HomeSmallImagesCollectionViewCell class] forCellWithReuseIdentifier:@"smallImageCell"];
    _imagesCollectionView.showsHorizontalScrollIndicator = NO;
    
}

-(void)configureCellWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController
{
    self.content = content;
    self.parentViewController = parentController;
    [self configureBasicInfo];
    [self configureLikeView];
    [self configureComment];
    [self configureGesture];
}



-(void)configureCommentWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController
{
    //评论内容显示样式
    self.content = content;
    self.parentViewController = parentController;
    [self configureComment];
    
}

-(void)configureComment
{
    //评论内容显示样式
    [self.commentView reset];
    self.commentView.delegate = (id<CommentTextViewDelegate>)self.parentViewController;
   
    [self.commentView setTextWithCommentStringList:self.content.commentStringList CommentList:self.content.commentList];
    [self updateFrameOfTextView:self.commentView heightConstraint:self.commentViewHeightConstraint];
    if (self.commentView.frame.size.height>0)
    {
        [self.commentViewVerticalSpaceToUpView setConstant:0.0f];
    }
    else
    {
        [self.commentViewVerticalSpaceToUpView setConstant:0.0f];
    }
}

-(void)configureLikeViewWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController
{
    self.content = content;
    self.parentViewController = parentController;
    [self configureLikeView];
}

-(void)configureLikeView
{
    //点赞用户头像展示区
    for (UIView *likeViewSub in self.likeView.subviews)
    {
        if( [likeViewSub isKindOfClass:[UIImageView class]])
        {
            [likeViewSub removeFromSuperview];
        }
        if ([likeViewSub isKindOfClass:[UILabel class]])
        {
            [likeViewSub setHidden:YES];
        }
    }
    if (self.content.likeCount >0)
    {
        
        NSInteger avatorNum = 0;
        BOOL isLikeCountShow = true;
        NSInteger likeUserCount = self.content.likeUserList.count;
        if (isIPHONE_6P)
        {
            avatorNum = likeUserCount>11?11:likeUserCount;
            isLikeCountShow = likeUserCount>11?true:false;
        }
        if (isIPHONE_6)
        {
            avatorNum = likeUserCount>10?10:likeUserCount;
            isLikeCountShow = likeUserCount>10?true:false;
        }
        if (isIPHONE_5)
        {
            avatorNum = likeUserCount>8?8:likeUserCount;
            isLikeCountShow = likeUserCount>8?true:false;
        }
        //[cell.likeLabel setHidden:NO];
        //cell.likeLabel.text = [NSString stringWithFormat:@"%lu赞", (long)self.content.likeCount];
        if (isLikeCountShow)
        {
            self.likeLabel.text = [NSString stringWithFormat:@"%lu", (long)self.content.likeCount];
            [self.likeLabel setHidden:NO];
            if ([self.parentViewController respondsToSelector:@selector(likeLabelClick:)])
            {
                
                UIGestureRecognizer *likeLabelClick = [[UIGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(likeLabelClick:)];
                [self.likeLabel addGestureRecognizer:likeLabelClick];
                [self.likeLabel setUserInteractionEnabled:YES];
            }
        }
        else
        {
            [self.likeLabel setHidden:YES];
        }
        for (NSInteger i = 0 ; i< avatorNum ; i++)
        {
            UIImageView *zanAvatar = [[UIImageView alloc]init];
            [zanAvatar setFrame:CGRectMake( 8 + 32*i , 8, 28, 28)];
            [zanAvatar setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
            [zanAvatar setOpaque:YES];
            [zanAvatar setRoundConerWithRadius:14];
            User *userInfo = [self.content.likeUserList objectAtIndex:i];
            
            [zanAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarImageURLString]];
            [self.likeView addSubview:zanAvatar];
            if ([self.parentViewController respondsToSelector:@selector(zanUserAvatarClick:)])
            {
                UITapGestureRecognizer *zanUserAvatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(zanUserAvatarClick:)];
                [zanAvatar setUserInteractionEnabled:YES];
                [zanAvatar addGestureRecognizer:zanUserAvatarClick];
            }
            [self.likeLabelHeightConstraint setConstant:36];
            
        }
        
    }
    else
    {
        self.likeLabel.text = @"";
        [self.likeLabelHeightConstraint setConstant:0];
    }
    
}

-(void)configureBasicInfo
{
    //判断时间线内容类别
    //1 -- 好友数据
    self.postTimeLabel.text = self.content.postTime;
    self.postUserName.text = self.content.photoUser.UserName;
    if ( self.content.isRecommend)
    {
        [self.followButton setHidden:NO];
        [self.postTimeLabel setHidden:YES];
    }
    else
    {
        [self.postTimeLabel setHidden:NO];
        [self.followButton setHidden:YES];

    }
    
    //2 -- 推荐数据
    self.postUserSelfDescription.text = [self.content.photoUser.selfDescriptions stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    if ([self.postUserSelfDescription.text isEqualToString:@""])
    {
        [self.userNameLabelTopAlignment setConstant:10.0f];
    }
    else
    {
        [self.userNameLabelTopAlignment setConstant:2.0f];
    }
    [self.homeCellAvatorImageView sd_setImageWithURL:[NSURL URLWithString:self.content.photoUser.avatarImageURLString]];
    
    [self.homeCellImageView setFrame:CGRectMake(0, 48, WZ_APP_SIZE.width, WZ_APP_SIZE.width)];
    

    
    //description label
    self.descriptionTextView.text = self.content.imageDescription;
    [self updateFrameOfTextView:self.descriptionTextView heightConstraint:self.descriptionViewHeightConstraint];
    if ([self.content.imageDescription isEqualToString:@""])
    {
         [self.descriptionViewVerticalSpaceToUpView setConstant:0.0f];
    }
    else
    {
        [self.descriptionViewVerticalSpaceToUpView setConstant:6.0f];
    }
   // if (imageUrl)
    [self.homeCellImageView sd_setImageWithURL:[NSURL URLWithString:self.content.imageUrlString]
                              placeholderImage:[UIImage imageNamed:@"placeholder"]];
    if (self.content.imageUrlList.count >1)
    {
        [self.imagesContainerViewHeightConstrant setConstant:86];
        CGRect frame = self.imagesContainerView.frame;
        frame.size.height = 86;
        self.imagesContainerView.frame = frame;
    }
    else
    {
        CGRect frame = self.imagesContainerView.frame;
        frame.size.height = 0;
        self.imagesContainerView.frame = frame;
        [self.imagesContainerViewHeightConstrant setConstant:0];
    }
    [self.imagesCollectionView reloadData];
    /*
    
    [self.imagesScrollView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if ([view isKindOfClass:[UIImageView class]])
        {
            [view removeFromSuperview];
        }
    }];
    float imageWidth = 70;
    float spacing = 8;
    if (self.content.imageUrlList.count>1)
    {
        [self.imagesContainerViewHeightConstrant setConstant:86];
        CGRect frame = self.imagesContainerView.frame;
        frame.size.height = 86;
        self.imagesContainerView.frame = frame;
        [self.imagesScrollView setContentSize:CGSizeMake(spacing +(imageWidth+spacing)*self.content.imageUrlList.count, 86)];
        //[self.imagesScrollView setDirectionalLockEnabled:YES];
        [self.content.imageUrlList enumerateObjectsUsingBlock:^(NSString *urlString, NSUInteger idx, BOOL *stop) {
            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(spacing +(spacing+imageWidth)*idx, spacing, imageWidth, imageWidth)];
            [self.imagesScrollView addSubview:imageView];
            [imageView setBackgroundColor:THEME_COLOR_LIGHT_GREY];
            [imageView.layer setCornerRadius:2.0f];
            [imageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"placeholder"]];
            imageView.tag = idx;
            UITapGestureRecognizer *imageTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(smallImageViewClick:)];
            [imageView addGestureRecognizer:imageTapGesture];
            [imageView setUserInteractionEnabled:YES];
        }];
        
    }
    else
    {
        CGRect frame = self.imagesContainerView.frame;
        frame.size.height = 0;
        self.imagesContainerView.frame = frame;
        [self.imagesContainerViewHeightConstrant setConstant:0];
    }*/
    //address
    if ([self.content.poiName isEqualToString:@""])
    {
        self.addressLabel.text = @"";
        [self.addressIcon setHidden:YES];
        [self.addressLabelView setHidden:YES];
        [self.addressLabel setHidden:YES];
        [self.addressViewHeightConstraint setConstant:0.0f];
        [self.addressViewVerticalSpaceToUpView setConstant:0];
        CGRect frame = self.addressLabelView.frame;
        frame.size.height = 0;
        [self.addressLabelView setFrame:frame];
    }
    else
    {
        self.addressLabel.text = self.content.poiName;
        [self.addressIcon setHidden:NO];
        [self.addressLabel setHidden:NO];
        [self.addressLabelView setHidden:NO];
        [self.addressViewHeightConstraint setConstant:22.0f];
        if (self.content.imageUrlList.count >1)
        {
            [self.addressViewVerticalSpaceToUpView setConstant:0];
        }
        else
        {
            [self.addressViewVerticalSpaceToUpView setConstant:8];
        }
        CGRect frame = self.addressLabelView.frame;
        frame.size.height = 22.0f;
        [self.addressLabelView setFrame:frame];
    }
    //cell.homeCellImageView.backgroundColor = [UIColor blackColor];
    //like button

    if (self.content.isLike)
    {
        [self.zanClickButton setTitle:@"赞了" forState:UIControlStateNormal];
        [self.zanClickButton setDarkGreyParentBackGroundAppearance];
    }
    else
    {
        [self.zanClickButton setTitle:@"赞" forState:UIControlStateNormal];
        [self.zanClickButton setGreyBackGroundAppearance];
    }

    
}

-(void)configureGesture
{
    
    if ([self.parentViewController respondsToSelector:@selector(avatarClick:)])
    {
        UITapGestureRecognizer *avatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(avatarClick:)];
        [self.homeCellAvatorImageView addGestureRecognizer:avatarClick];
    }
    //点击 “赞的数量” 跳转赞的用户列表
    if ([self.parentViewController respondsToSelector:@selector(likeLabelClick:)])
    {
        UITapGestureRecognizer *likeLabelClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(likeLabelClick:)];
        [self.likeLabel addGestureRecognizer:likeLabelClick];
    }
    //点击 ”赞“，添加”赞“数量
    if ([self.parentViewController respondsToSelector:@selector(zanButtonClick:)])
    {
        [self.zanClickButton addTarget:self.parentViewController action:@selector(zanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    //点击评论，跳转评论页面
    if ([self.parentViewController respondsToSelector:@selector(commentButtonClick:)])
    {
    [self.commentClickButton addTarget:self.parentViewController action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([self.parentViewController respondsToSelector:@selector(moreButtonClick:)])
    {
        [self.moreButton addTarget:self.parentViewController action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    //点击地址，跳转地址页面
    if ([self.parentViewController respondsToSelector:@selector(addressLabelClick:)])
    {
        UITapGestureRecognizer *addressClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(addressLabelClick:)];
    
        [self.addressLabel addGestureRecognizer:addressClick];
    }
    [self delayScrollViewTouch];
    
}

-(void)delayScrollViewTouch
{
    if (SYSTEM_VERSION_EQUAL_TO(@"7"))
    {
        for (id obj in self.subviews)
        {
            if ([NSStringFromClass([obj class])isEqualToString:@"UITableViewCellScrollView"])
                
            {
                
                UIScrollView *scroll = (UIScrollView *) obj;
                
                scroll.delaysContentTouches =NO;
                
                break;
                
            }
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - gesture and action
-(void)smallImageViewClick:(UITapGestureRecognizer *)gesture
{
    UIImageView *imageView = (UIImageView *)gesture.view;
    self.homeCellImageView.image = imageView.image;
}
- (void)followButtonPressed:(UIButton *)sender
{
    NSInteger myUserId = [[NSUserDefaults standardUserDefaults]integerForKey:@"userId"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[QDYHTTPClient sharedInstance]followUser:self.content.photoUser.UserID withUserId:myUserId whenComplete:^(NSDictionary *result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([result objectForKey:@"data"])
                {
                    [sender setHidden:YES];
                    [self.postTimeLabel setHidden:NO];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"updateUserInfo" object:nil];
                    
                }
                else if ([result objectForKey:@"error"])
                {
                    [SVProgressHUD showErrorWithStatus:[result objectForKey:@"error"]];
                }
            });
            
        }];
    });
}

#pragma mark - textview utility
-(void)updateFrameOfTextView:(UITextView *)textView heightConstraint:(NSLayoutConstraint *)heightConstraint
{
    if ([textView.text isEqualToString:@""])
    {
        CGRect frame = textView.frame;
        frame.size.height = 0;
        textView.frame = frame;
        if (heightConstraint)
        {
            [heightConstraint setConstant:0.0f];
        }
    }
    else
    {
        CGRect frame = textView.frame;
        CGSize maxSize = CGSizeMake( WZ_APP_SIZE.width -8.0f, FLT_MAX);
        CGSize newSize = [textView sizeThatFits:maxSize];
        frame.size = newSize;
        textView.frame = frame;
        if (heightConstraint)
        {
            [heightConstraint setConstant:newSize.height];
        }
    }
    

}

#pragma mark - collection view delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.content && self.content.imageUrlList.count >1)
    {
        return self.content.imageUrlList.count;
    }
    return 0;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeSmallImagesCollectionViewCell *cell =(HomeSmallImagesCollectionViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:@"smallImageCell" forIndexPath:indexPath];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:self.content.imageUrlList[indexPath.item]]];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    HomeSmallImagesCollectionViewCell *cell =(HomeSmallImagesCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    self.homeCellImageView.image = cell.imageView.image;
}

@end
