//
//  progressImageView.m
//  WUZHAO
//
//  Created by yiyi on 15/7/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "progressImageView.h"
#import "macro.h"

@implementation progressImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self.layer setMasksToBounds:YES];
        [self.layer setCornerRadius:2.0f];
        [self.layer setBackgroundColor:[[UIColor whiteColor]CGColor]];
    
        [self locateAiv];
        [self.aiv startAnimating];
        
    }
    return self;
}

-(void)setProgress:(float)progress
{
    //self.progressLabel.text = [NSString stringWithFormat:@"%f%%",progress];
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
        _maskView = [[UIView alloc]init];
        [_maskView setBackgroundColor:THEME_COLOR_DARK_GREY_PARENT];
    }
    return _maskView;
}
-(void)locateAiv
{

    CGRect aivRect = self.aiv.bounds;
    CGRect frame = self.bounds;
    [self addSubview:self.maskView];
    [self.maskView setFrame:frame];
    [self addSubview:self.aiv];
    float spacing = (frame.size.width - aivRect.size.width)/2;
    aivRect.origin.x = spacing;
    aivRect.origin.y = spacing;
    [self.aiv setFrame:aivRect];
}

-(void)setfinishState
{
    [self.aiv stopAnimating];
    CGRect frame = self.bounds;
    float imageWidth = frame.size.width/3;
    //[self.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    UIImageView *finishImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageWidth, imageWidth, imageWidth, imageWidth)];
    finishImageView.image = [UIImage imageNamed:@"check"];
    [self addSubview:finishImageView];
    
}

-(void)setErrorState
{
    [self.aiv stopAnimating];
    CGRect frame = self.bounds;
    float imageWidth = frame.size.width/3;
    //[self.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    UIImageView *errorImageView = [[UIImageView alloc]initWithFrame:CGRectMake(imageWidth, imageWidth, imageWidth, imageWidth)];
    errorImageView.image = [UIImage imageNamed:@"cancel"];
    [self addSubview:errorImageView];
}

@end
