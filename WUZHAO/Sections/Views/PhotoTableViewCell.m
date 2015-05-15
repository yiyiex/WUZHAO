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

-(void)setAppearance
{
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
    
    //self.backgroundColor = [UIColor clearColor];
       
}
-(void)setConstraints
{
    
}
-(void)configureCellWithData:(WhatsGoingOn *)content parentController:(UIViewController *)parentController
{
    [self setAppearance];
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
    [self.commentView setFont:WZ_FONT_COMMON_SIZE];
    [self.commentView setTextColor:THEME_COLOR_DARK_GREY_PARENT];
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
            [zanAvatar setFrame:CGRectMake( 8 + 32*i , 2, 28, 28)];
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
    
    [self.homeCellImageView setFrame:CGRectMake(0, 48, WZ_APP_SIZE.width, WZ_APP_SIZE.width)];

    if ([self.content.poiName isEqualToString:@""])
    {
        self.addressLabel.text = @"";
        [self.addressIcon setHidden:YES];
        [self.addressLabelView setHidden:YES];
        [self.addressLabel setHidden:YES];
    }
    else
    {
        self.addressLabel.text = self.content.poiName;
        [self.addressIcon setHidden:NO];
        [self.addressLabel setHidden:NO];
        [self.addressLabelView setHidden:NO];
        
       
    }
    //description label
    self.descriptionTextView.text = self.content.imageDescription;
    [self updateFrameOfTextView:self.descriptionTextView heightConstraint:self.descriptionViewHeightConstraint];
    if ([self.content.imageDescription isEqualToString:@""])
    {
         [self.descriptionViewVerticalSpaceToUpView setConstant:0.0f];
    }
    else
    {
        [self.descriptionViewVerticalSpaceToUpView setConstant:10.0f];
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
        CGSize maxSize = CGSizeMake( WZ_APP_SIZE.width -16.0f, FLT_MAX);
        CGSize newSize = [textView sizeThatFits:maxSize];
        frame.size = newSize;
        textView.frame = frame;
        if (heightConstraint)
        {
            [heightConstraint setConstant:newSize.height];
        }
    }
    

}

@end
