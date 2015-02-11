//
//  WPHotspotLabel.h
//  WPAttributedMarkupDemo
//
//  Created by Nigel Grange on 20/10/2014.
//  Copyright (c) 2014 Nigel Grange. All rights reserved.
//

#import "WPTappableLabel.h"
#import "macro.h"

@interface WPHotspotLabel : WPTappableLabel

//add appearence property
@property (nonatomic,weak) UIColor *textColour UI_APPEARANCE_SELECTOR;
@property (nonatomic,weak) UIFont *textFont UI_APPEARANCE_SELECTOR;

-(NSMutableAttributedString *)filterLinkWithContent:(NSString *)content;






@end
