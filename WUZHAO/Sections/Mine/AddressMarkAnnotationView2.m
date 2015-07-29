//
//  AddressMarkAnnotationView2.m
//  WUZHAO
//
//  Created by yiyi on 15/7/27.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "AddressMarkAnnotationView2.h"
#import "macro.h"

@implementation AddressMarkAnnotationView2


#pragma mark - Life Cycle

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];

    if (self)
    {
        self.bounds = CGRectMake(0.f, 0.f, 24, 24);
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24 , 24)];
        [self.imageView setImage:[UIImage imageNamed:@"flag_green"]];
        [self addSubview:self.imageView];

        self.imageNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(12 , 0, 20, 20)];
            [self.imageNumLabel setBackgroundColor:THEME_COLOR_DARK];
            [self.imageNumLabel setTextColor:THEME_COLOR_WHITE];
            [self.imageNumLabel setFont:WZ_FONT_SMALL_SIZE];
            [self.imageNumLabel setTextAlignment:NSTextAlignmentCenter];
            [self.imageNumLabel.layer setCornerRadius:20/2];
            self.imageNumLabel.layer.masksToBounds = YES;
            [self addSubview:self.imageNumLabel];
        
    }
        return self;
}
-(void)setPhotoNumber:(NSInteger )num
{
    if (num >1)
    {
        self.imageNumLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
        [self.imageNumLabel setHidden:NO];
        [self.imageNumLabel sizeToFit];
        CGRect frame = self.imageNumLabel.frame;
        frame.size.width = MAX(frame.size.width, 20);
        frame.size.height = 20;
        [self.imageNumLabel setFrame:frame];
        
    }
    else
    {
        [self.imageNumLabel setHidden:YES];
    }
    
    // [self.imageNumLabel sizeToFit];
}


@end
