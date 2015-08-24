//
//  UploadPhotoIndicatorView.h
//  WUZHAO
//
//  Created by yiyi on 15/8/22.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//



#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UPLOAD_STATUS)
{
    UPLOAD_STATUS_UPLOADING = 0,
    UPLOAD_STATUS_UPLOAD_SUCCESS = 1,
    UPLOAD_STATUS_UPLOAD_FAILED = 2
};

@interface UploadPhotoIndicatorView : UIView
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *reloadButton;

-(instancetype)init;
-(void)setStatus:(UPLOAD_STATUS)status withInfo:(NSString *)info;

@end
