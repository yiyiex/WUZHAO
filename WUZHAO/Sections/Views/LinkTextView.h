//
//  LinkTextView.h
//  WUZHAO
//
//  Created by yiyi on 15/5/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^LinkedStringRangeTapHandler)(NSRange linkStringRange);

@interface LinkTextView : UITextView

-(void)reset;
-(void)linkTextWithString:(NSString *)string defaultAttributes:(NSDictionary *)defaultAttributes highlightAttributes:(NSDictionary *)highlightAttributes tabHandler:(LinkedStringRangeTapHandler)tapHandler;
-(void)setText:(NSAttributedString *)string linkStrings:(NSArray *)linkStrings defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandlers:(NSArray *)tapHandlers;
-(void)appendText:(NSAttributedString *)string linkStrings:(NSArray *)linkStrings defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes :(NSDictionary *)highlightedAttributes tapHandlers:(NSArray *)tapHandlers;


-(NSRange)handleTouches:(NSSet *)touches;
-(NSRange)findLinkedStringRangeAtPoint:(CGPoint)point inDictionary:(NSDictionary *)dictionary;
@end
