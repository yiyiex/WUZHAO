//
//  UploadPhotoIndicatorView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "UploadPhotoIndicatorView.h"
#import "UIImageView+ChangeAppearance.h"
#import "macro.h"

#define imageViewHeight 48
#define spacing 8
#define buttonWidth 32

@interface UploadPhotoIndicatorView()
@property (nonatomic, strong) UIActivityIndicatorView *aiv;
@property (nonatomic, strong) UIView *maskView;

@end

@implementation UploadPhotoIndicatorView

-(instancetype)init
{
    self = [super initWithFrame:CGRectMake(0, 0, WZ_APP_SIZE.width, imageViewHeight + spacing*2)];
    if (self)
    {
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(spacing, spacing, imageViewHeight, imageViewHeight)];
        [self.imageView setRoundConerWithRadius:2.0f];
        [self.imageView addSubview:self.maskView];
        [self.imageView addSubview:self.aiv];
        [self.aiv setCenter:CGPointMake(imageViewHeight/2, imageViewHeight/2)];
        
        [self addSubview:self.imageView];
        
        self.infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(spacing*2 + imageViewHeight, (imageViewHeight-24)/2+spacing, 180, 24)];
        [self.infoLabel setTextColor:THEME_COLOR_FONT_DARK_GREY];
        [self.infoLabel setFont:WZ_FONT_LARGE_SIZE];
        [self addSubview:self.infoLabel];
        
        [self addSubview:self.deleteButton];
        [self addSubview:self.reloadButton];
    }
    return self;
}

-(UIActivityIndicatorView *)aiv
{
    if (!_aiv)
    {
        _aiv = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _aiv;
}

-(UIView *)maskView
{
    if (!_maskView)
    {
        _maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, imageViewHeight, imageViewHeight)];
        [_maskView setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
    }
    return _maskView;
}

-(UIButton *)deleteButton
{
    if (!_deleteButton)
    {
        _deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - buttonWidth - spacing, (imageViewHeight - buttonWidth)/2+spacing, buttonWidth, buttonWidth)];
        [_deleteButton setImage:[UIImage imageNamed:@"cancel_reload"] forState:UIControlStateNormal];
    }
    return _deleteButton;
}
-(UIButton *)reloadButton
{
    if (!_reloadButton)
    {
        _reloadButton = [[UIButton alloc]initWithFrame:CGRectMake(WZ_APP_SIZE.width - (buttonWidth + spacing)*2, (imageViewHeight - buttonWidth)/2+spacing, buttonWidth, buttonWidth)];
        [_reloadButton setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
    }
    return _reloadButton;
    
}

-(void)setStatus:(UPLOAD_STATUS)status withInfo:(NSString *)info
{
    if (status == UPLOAD_STATUS_UPLOADING)
    {
        [self.maskView setHidden:NO];
        [self.aiv setHidden:NO];
        [self.aiv startAnimating];
        
        [self.deleteButton setHidden:YES];
        [self.reloadButton setHidden:YES];
        
        [self.infoLabel setText:info];
    }
    else if (status == UPLOAD_STATUS_UPLOAD_SUCCESS)
    {
        [self.maskView setHidden:YES];
        [self.aiv setHidden:YES];
        [self.aiv stopAnimating];
        
        [self.deleteButton setHidden:YES];
        [self.reloadButton setHidden:YES];
        
        [self.infoLabel setText:info];
    }
    else if (status == UPLOAD_STATUS_UPLOAD_FAILED)
    {
        [self.maskView setHidden:YES];
        [self.aiv setHidden:YES];
        [self.aiv stopAnimating];
        
        [self.deleteButton setHidden:NO];
        [self.reloadButton setHidden:NO];
        
        [self.infoLabel setText:info];
    }
}

@end
