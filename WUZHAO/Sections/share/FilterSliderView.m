//
//  FilterSliderView.m
//  WUZHAO
//
//  Created by yiyi on 15/6/2.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "FilterSliderView.h"
#import "macro.h"

@implementation FilterSliderView
@synthesize parameters = _parameters;
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self addsubviews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame parameters:(FilterParameters *)parameters
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.parameters = parameters;
        [self addsubviews];
    }
    return self;
}

-(FilterParameters *)parameters
{
    if (!_parameters)
    {
        _parameters = [[FilterParameters alloc]init];
        _parameters.filterName = @"";
        _parameters.currentValue = 0;
        _parameters.maxmumValue = 12;
        _parameters.minmumValue = 0;
        _parameters.name = @"";
        _parameters.key = @"";
        _parameters.defaultValue = 0;
    }
    return _parameters;
}
-(void)setParameters:(FilterParameters *)parameters
{
    _parameters= parameters;
    _slider.minimumValue = parameters.minmumValue;
    _slider.maximumValue = parameters.maxmumValue;
    _slider.value = parameters.currentValue;
    
}


-(void)addsubviews
{
    CGRect frame = self.frame;
    frame.size.width -= 32;
    frame.origin.x +=16;
    self.slider = [[HUMSlider alloc]initWithFrame:frame];
    self.slider.minimumValue = self.parameters.minmumValue;
    self.slider.maximumValue = self.parameters.maxmumValue;
    self.slider.value = self.parameters.currentValue;
    self.slider.tickColor = [UIColor whiteColor];
    self.slider.tintColor = THEME_COLOR_DARK;
    [self addSubview:self.slider];
    
    [self.slider addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.valueLabel = [[UILabel alloc]init];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    self.valueLabel.textColor = [UIColor whiteColor];
    self.valueLabel.font = [UIFont systemFontOfSize:14];
    self.valueLabel.text = [NSString stringWithFormat:@"%f",self.slider.value];
    [self addSubview:self.valueLabel];
    [self.valueLabel setHidden:YES];
}


#pragma mark - slider event
-(void)sliderValueDidChange:(id)sender
{
    self.valueLabel.text = [NSString stringWithFormat:@"%f",self.slider.value];
    self.parameters.currentValue = self.slider.value;
    if (self.delegate)
    {
        [self.delegate filterSliderValueDidChange:self.parameters];
    }
    
}
-(void)sliderTouchUpInside:(id)sender
{
    self.valueLabel.text = [NSString stringWithFormat:@"%f",self.slider.value];
    self.parameters.currentValue = self.slider.value;
    if (self.delegate)
    {
        [self.delegate filterSliderValueDidChange:self.parameters];
    }
}


@end

@implementation FilterParameters

-(instancetype)initWithKey:(NSString *)key value:(float)value
{
    self = [super init];
    if (self)
    {
        self.key = key;
        self.currentValue = value;
        self.defaultValue = value;
    }
    return self;
    
}

-(instancetype)initWithName:(NSString *)name filterName:(NSString *)filterName key:(NSString *)key minmumValue:(float)min maxmumValue:(float)max currentValue:(float)current
{
    self = [super init];
    if (self)
    {
        self.name = name;
        self.filterName = filterName;
        self.key = key;
        self.minmumValue = min;
        self.maxmumValue = max;
        self.currentValue = current;
        self.defaultValue = current;
    }
    return self;
}
-(NSMutableArray *)otherInputs
{
    if(!_otherInputs)
    {
        _otherInputs = [[NSMutableArray alloc]init];
    }
    return _otherInputs;
}

-(id)copyWithZone:(NSZone *)zone
{
    FilterParameters *copy = [[[self class]allocWithZone:zone]init];
    copy->_currentValue = _currentValue;
    copy->_defaultValue = _defaultValue;
    copy->_filterName = [_filterName copy];
    copy->_maxmumValue = _maxmumValue;
    copy->_minmumValue = _minmumValue;
    copy->_name = [_name copy];
    copy->_otherInputs = [_otherInputs copy];
    copy->_key = [_key copy];
    
    return copy;
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    FilterParameters *copy = [[[self class]allocWithZone:zone]init];
    copy->_currentValue = _currentValue;
    copy->_defaultValue = _defaultValue;
    copy->_filterName = [_filterName mutableCopy];
    copy->_maxmumValue = _maxmumValue;
    copy->_minmumValue = _minmumValue;
    copy->_name = [_name copy];
    copy->_otherInputs = [_otherInputs mutableCopy];
    copy->_key = [_key copy];
    
    return copy;
}

@end
