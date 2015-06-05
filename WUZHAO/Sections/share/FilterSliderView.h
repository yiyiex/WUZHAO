//
//  FilterSliderView.h
//  WUZHAO
//
//  Created by yiyi on 15/6/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HUMSlider.h"

@interface FilterParameters:NSObject
@property (nonatomic, strong) NSString *filterName;
@property (nonatomic ,strong) NSString *name;
@property (nonatomic ,strong) NSString *key;
@property (nonatomic) float minmumValue;
@property (nonatomic) float maxmumValue;
@property (nonatomic) float currentValue;
@property (nonatomic) float defaultValue;

@property (nonatomic) NSMutableArray *otherInputs;

-(instancetype)initWithName:(NSString *)name  filterName:(NSString *)filterName key:(NSString *)key  minmumValue:(float)min maxmumValue:(float)max currentValue:(float)current;
-(instancetype)initWithKey:(NSString *)key value:(float)value;

@end

@protocol FilterSliderDelegate ;


@interface FilterSliderView : UIView

@property (nonatomic, strong) FilterParameters *parameters;
@property (nonatomic, strong) HUMSlider *slider;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, weak) id<FilterSliderDelegate> delegate;

@end

@protocol FilterSliderDelegate <NSObject>

@required
-(void)filterSliderValueDidChange:(FilterParameters *)parameters;

@end









