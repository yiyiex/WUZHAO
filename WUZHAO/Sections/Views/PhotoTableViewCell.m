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

#import "macro.h"

#define AvatorImageWidth 38

#define HorizontalInsets 10.0
#define VerticalInsets 10.0

@interface PhotoTableViewCell()



@end

@implementation PhotoTableViewCell

-(instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
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

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView updateConstraintsIfNeeded];
    [self.contentView layoutIfNeeded];
}

-(void)setAppearance
{
    [self.contentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    
    self.backgroundColor = [UIColor clearColor];
    
    
    [self.homeCellAvatorImageView setRoundConerWithRadius:18];
    [self.homeCellAvatorImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];

    [self.postUserName setDarkGreyLabelAppearance];
    [self.postUserSelfDescription setSmallReadOnlyLabelAppearance];
    [self.postTimeLabel setBoldReadOnlyLabelAppearance];
    
    
    //[self.addressLabelView setBackgroundColor:THEME_COLOR_DARK];
    [self.addressLabelView setBackgroundColor:rgba_WZ(44, 44, 44, 0.8)];
    [self.addressLabel setWhiteLabelAppearance];
   // [self.addressLabel setBackgroundColor: [UIColor clearColor]];
    //[self.addressLabel setThemeBoldLabelAppearance];
    
    [self.homeCellImageView setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    [self.descriptionLabel setDarkGreyBitParentLabelAppearance];
   // [self.descriptionLabel setTextColor:[UIColor blackColor]];

    [self.likeLabel setThemeLabelAppearance];
    [self.likeLabel setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
    
    [self.zanClickButton setNormalButtonWithBoldFontAppearance];
    //[self.zanClickButton setGreyBackGroundAppearance];
    [self.commentClickButton setNormalButtonWithBoldFontAppearance];
    [self.commentClickButton setGreyBackGroundAppearance];
    [self.moreButton setNormalButtonWithBoldFontAppearance];
    [self.moreButton setGreyBackGroundAppearance];
    
    //self.backgroundColor = [UIColor clearColor];
       
}
-(void)setConstraints
{
    
}
-(void)configureCellWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController
{
    self.content = content;
    self.parentViewController = parentController;
    [self configureBasicInfo];
    [self configureLikeView];
    [self configureComment];
    [self configureGesture];
    [self setAppearance];
}

-(void)configureComment
{
    //评论内容显示样式
    if (self.commentLabelView.subviews.count>0)
    {
        for (UILabel *subView in self.commentLabelView.subviews)
        {
            [subView removeFromSuperview];
        }
    }
    [self.commentViewHeightConstraint setConstant:0];
    if (self.content.commentList.count ==0)
    {
        return;
    }
    float commentViewHeight = 4;
    for (NSInteger i = 0;i<self.content.commentList.count;i++)
    {
        NSString *commentString = self.content.commentStringList[i];
        NSMutableAttributedString *commentAttributeString = [[NSMutableAttributedString alloc]initWithString:self.content.commentStringList[i]];
        NSRange commentRange = [commentString rangeOfString:(NSString *)[self.content.commentList[i] objectForKey:@"content"]];
        NSRange userNameRange = [commentString rangeOfString:[NSString stringWithFormat:@"%@:",[self.content.commentList[i] objectForKey:@"userName"]]];
        [commentAttributeString setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_DARK_GREY_BIT_PARENT,NSFontAttributeName:WZ_FONT_SMALLP_SIZE} range:userNameRange];
        [commentAttributeString setAttributes:@{NSForegroundColorAttributeName:THEME_COLOR_LIGHT_GREY,NSFontAttributeName:WZ_FONT_SMALLP_READONLY} range:commentRange];
        UILabel *commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, commentViewHeight, WZ_APP_SIZE.width-16, 24)];
        [commentLabel setNumberOfLines:0];
        [commentLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        commentLabel.attributedText = commentAttributeString;
        [commentLabel sizeToFit];
        
        if ([self.parentViewController respondsToSelector:@selector(commentLabelClick:)])
        {
            UITapGestureRecognizer *commentLabelClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(commentLabelClick:)];
            [commentLabel addGestureRecognizer:commentLabelClick];
            [commentLabel setUserInteractionEnabled:YES];
        }
        [self.commentLabelView addSubview:commentLabel];
        commentViewHeight += commentLabel.frame.size.height;
        
        
    }
    [self.commentViewHeightConstraint setConstant:commentViewHeight];
    if (self.content.hasMoreComments && self.content.commentNum >5 )
    {
        UILabel *moreCommentLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, commentViewHeight, WZ_APP_SIZE.width-16, 24)];
        moreCommentLabel.text =[NSString stringWithFormat:@"查看全部%lu条评论",(long)self.content.commentNum];
        if ([self.parentViewController respondsToSelector:@selector(moreCommentClick:)])
        {
            UITapGestureRecognizer *moreCommentClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(moreCommentClick:)];
            [moreCommentLabel addGestureRecognizer:moreCommentClick];
            [moreCommentLabel setUserInteractionEnabled:YES];
        }

        //[moreCommentLabel setDarkGreyLabelAppearance];
        [moreCommentLabel setFont:WZ_FONT_SMALL_SIZE];
        [moreCommentLabel setTextColor:THEME_COLOR_DARK_GREY_BIT_PARENT];
        [moreCommentLabel sizeToFit];
        [self.commentLabelView addSubview:moreCommentLabel];
        commentViewHeight += moreCommentLabel.frame.size.height;
        [self.commentViewHeightConstraint setConstant:commentViewHeight];
        
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
    for (UIView *likeViewSub in self.likeLabelView.subviews)
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
            [zanAvatar setFrame:CGRectMake( 8 + 32*i , 2, 28, 28)];
            [zanAvatar setBackgroundColor:THEME_COLOR_LIGHT_GREY_PARENT];
            [zanAvatar setOpaque:YES];
            [zanAvatar setRoundConerWithRadius:14];
            User *userInfo = [self.content.likeUserList objectAtIndex:i];
            
            [zanAvatar sd_setImageWithURL:[NSURL URLWithString:userInfo.avatarImageURLString]];
            [self.likeLabelView addSubview:zanAvatar];
            if ([self.parentViewController respondsToSelector:@selector(zanUserAvatarClick:)])
            {
                UITapGestureRecognizer *zanUserAvatarClick = [[UITapGestureRecognizer alloc]initWithTarget:self.parentViewController action:@selector(zanUserAvatarClick:)];
                [zanAvatar setUserInteractionEnabled:YES];
                [zanAvatar addGestureRecognizer:zanUserAvatarClick];
            }
            [self.likeLabelHeightConstraint setConstant:32];
            
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
    self.postTimeLabel.text = self.content.postTime;
    self.postUserName.text = self.content.photoUser.UserName;

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
    
    //[self.zanClikeButtonVerticalSpaceToCommentViewConstraint setConstant:8.0f];
    //address label
    if ([self.content.poiName isEqualToString:@""])
    {
        self.addressLabel.text = @"";
        [self.addressViewHeightConstraint setConstant:0];
        [self.addressIcon setHidden:YES];
        [self.addressLabelView setHidden:YES];
        [self.addressLabel setHidden:YES];
        
      //  [self.addressViewVerticalSpaceToImageView setConstant:0.0f];
    }
    else
    {
        self.addressLabel.text = self.content.poiName;
        [self.addressViewHeightConstraint setConstant:28];
       // [self.addressViewHeightConstraint setConstant:self.addressLabel.frame.size.height];
        [self.addressIcon setHidden:NO];
        [self.addressLabel setHidden:NO];
        [self.addressLabelView setHidden:NO];
        NSLog(@"addressView Height %f",self.addressViewHeightConstraint.constant);
       // [self.addressViewVerticalSpaceToImageView setConstant:12.0f];
        
       
    }
    //description label
    if ([self.content.imageDescription isEqualToString:@""])
    {
        [self.descriptionViewHeightConstraint setConstant:0.0];
        [self.descriptionViewVerticalSpaceToAddressView setConstant:0.0f];
        self.descriptionLabel.text = @"";
    }
    else
    {
        [self.descriptionLabel setFrame:CGRectMake(8, 0, WZ_APP_SIZE.width-16, 20)];
        self.descriptionLabel.text = self.content.imageDescription;

        [self.descriptionViewHeightConstraint setConstant:self.descriptionLabel.frame.size.height];
         NSLog(@"description Height %f",self.descriptionViewHeightConstraint.constant);
        [self.descriptionViewVerticalSpaceToAddressView setConstant:10.0f];
    }
   // if (imageUrl)
    [self.homeCellImageView sd_setImageWithURL:[NSURL URLWithString:self.content.imageUrlString]
                              placeholderImage:[UIImage imageNamed:@"placeholder"]];
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
    //点击图片 隐藏或者显示地址信息
    UITapGestureRecognizer *imageviewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImage:)];
    [self.homeCellImageView addGestureRecognizer:imageviewTap];
    [self.homeCellImageView setUserInteractionEnabled:YES];
    //点击照片描述，跳转照片详情页面
    /*
     UITapGestureRecognizer *thoughtClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(thoughtClick:)];
     [cell.descriptionLabel setUserInteractionEnabled:YES];
     [cell.descriptionLabel addGestureRecognizer:thoughtClick];
     */
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

#pragma mark - gesture
-(void)tapImage:(UITapGestureRecognizer *)gesture
{
    if (self.addressLabelView.hidden == YES)
    {
        if ([self.addressLabel.text isEqualToString:@""])
        {
            return;
        }
        else
        {
            [self.addressLabelView setHidden:NO];
            [self.addressIcon setHidden:NO];
            [self.addressLabel setHidden:NO];
        }
    }
    else
    {
            [self.addressLabelView setHidden:YES];
            [self.addressIcon setHidden:YES];
            [self.addressLabel setHidden:YES];
    }
}
@end
