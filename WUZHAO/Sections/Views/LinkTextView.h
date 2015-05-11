//
//  LinkTextView.h
//  WZLinkTextView
//
//  Created by yiyi on 15/4/29.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^LinkedStringTapHandler)(NSString *linkedString);
@interface LinkTextView : UITextView

-(void)linkString:(NSString *)string defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)tapHandler;

-(void)linkStrings:(NSArray *)strings defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tabHandler:(LinkedStringTapHandler)tabHandler;

-(void)linkStringWithRegEx:(NSRegularExpression *)regex defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tabHandler:(LinkedStringTapHandler)tabHandler;

@end
