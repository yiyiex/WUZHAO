//
//  LinkTextView.m
//  WZLinkTextView
//
//  Created by yiyi on 15/4/29.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "LinkTextView.h"

@interface LinkTextView()
@property (nonatomic, strong) NSString *activeString;
@property (nonatomic, strong) NSMutableDictionary *linkedTextRangeDictionary;
@property (nonatomic, strong) NSMutableDictionary *linkedTextTapHandlerDictionary;
@property (nonatomic, strong) NSMutableDictionary *linkedTextDefaultAttributesDictionary;
@property (nonatomic, strong) NSMutableDictionary *linkedTextHighlightedAttributesDictionary;

@end

@implementation LinkTextView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}


-(NSMutableDictionary *)linkedTextRangeDictionary
{
    if (!_linkedTextRangeDictionary)
    {
        _linkedTextRangeDictionary = [[NSMutableDictionary alloc]init];
    }
    return _linkedTextRangeDictionary;
}
-(NSMutableDictionary *)linkedTextTapHandlerDictionary
{
    if (!_linkedTextTapHandlerDictionary)
    {
        _linkedTextTapHandlerDictionary = [[NSMutableDictionary alloc]init];
    }
    return _linkedTextTapHandlerDictionary;
}
-(NSMutableDictionary *) linkedTextDefaultAttributesDictionary
{
    if (!_linkedTextDefaultAttributesDictionary)
    {
        _linkedTextDefaultAttributesDictionary = [[NSMutableDictionary alloc]init];
    }
    return _linkedTextDefaultAttributesDictionary;
}
-(NSMutableDictionary *)linkedTextHighlightedAttributesDictionary
{
    if (!_linkedTextHighlightedAttributesDictionary)
    {
        _linkedTextHighlightedAttributesDictionary = [[NSMutableDictionary alloc]init];
    }
    return _linkedTextHighlightedAttributesDictionary;
}


#pragma mark - Set Link Strings

-(void)linkString:(NSString *)string defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)tapHandler
{
    if (!string || !defaultAttributes)
    {
        return;
    }
    NSDictionary *linkedStringDictionary = [self dictionaryForLinkedString:string defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandler:tapHandler];
    [self addLinkedStringAndAttributes:linkedStringDictionary];
   
    

}

-(void)linkStrings:(NSArray *)strings defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tabHandler:(LinkedStringTapHandler)tabHandler
{
 
}

-(void)linkStringWithRegEx:(NSRegularExpression *)regex defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tabHandler:(LinkedStringTapHandler)tabHandler
{
    
}

-(void)addLinkedStringAndAttributes:(NSDictionary *)linkedStringDictionary
{
    if (!self.text)
    {
        self.text = linkedStringDictionary[@"string"];
        self.attributedText = [[NSAttributedString alloc]initWithString:linkedStringDictionary[@"string"]];
    }
    NSString *text = self.text;
    NSAttributedString *attributedString = self.attributedText;
    NSString *string = linkedStringDictionary[@"string"];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedString];
    NSRange rangeOfString = [text rangeOfString:string];
    [mutableAttributedString beginEditing];
    if (rangeOfString.length)
    {
        [self setRange:rangeOfString forLinkedString:string];
        [self setHandler:linkedStringDictionary[@"handler"] forLinkedString:string];
        [self setDefaultAttributes:linkedStringDictionary[@"defaultAttributes"] forLinkedString:string];
        [self setHighlightedAttributes:linkedStringDictionary[@"highlightedAttributes"] forLinkedString:string];
        [mutableAttributedString addAttributes:linkedStringDictionary[@"defaultAttributes"] range:rangeOfString];
        
    }
    [mutableAttributedString endEditing];
    self.attributedText = mutableAttributedString;
    
}
#pragma mark - Touch Handling Methods
-(NSString *)handleTouches:(NSSet *)touches
{
    CGPoint location = [touches.allObjects.lastObject locationInView:self];
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    return  [self findLinkedStringAtPoint:location inDictionary:self.linkedTextRangeDictionary];
}
-(NSString *)findLinkedStringAtPoint:(CGPoint)point inDictionary:(NSDictionary *)dictionary
{
    if (!dictionary)
    {
        return nil;
    }
    NSUInteger characterIndex;
    characterIndex = [self.layoutManager characterIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    __block NSString *result = nil;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSValue *value = (NSValue*)obj;
        NSRange rangeToCheck = [value rangeValue];
        NSUInteger min = rangeToCheck.location;
        NSUInteger max = min + rangeToCheck.length;
        if (characterIndex >=min && characterIndex <=max)
        {
            result = key;
            *stop = YES;
        }
    }];
    return result;
}
-(NSValue *)locationOfTouches:(NSSet *)touches
{
    CGPoint location = [touches.allObjects.lastObject locationInView:self];
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    return [NSValue valueWithCGPoint:location];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *tappedString = [self handleTouches:touches];
    NSDictionary *highlightAttributes = self.linkedTextHighlightedAttributesDictionary[tappedString];
    if (tappedString && highlightAttributes)
    {
        self.activeString = tappedString;
        [self setAttributes:highlightAttributes forLinkedString:tappedString];
    }

    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *tappedString = [self handleTouches:touches];
    NSDictionary *defaultAttributes = self.linkedTextDefaultAttributesDictionary[tappedString];
    if (tappedString && defaultAttributes)
    {
        if ([self.activeString isEqualToString:tappedString])
        {
            LinkedStringTapHandler tapHandler = self.linkedTextTapHandlerDictionary[self.activeString];
            tapHandler(self.activeString);
            [self setAttributes:defaultAttributes forLinkedString:tappedString];
        }
        self.activeString = nil;
    }

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *tappedStrng = [self handleTouches:touches];
    if (![tappedStrng isEqualToString:self.activeString])
    {
        if (self.activeString)
        {
            NSDictionary *defaultAttributes = self.linkedTextDefaultAttributesDictionary[self.activeString];
            [self setAttributes:defaultAttributes forLinkedString:self.activeString];
        }
        if (tappedStrng)
        {
            self.activeString = tappedStrng;
            NSDictionary *highlightedAttributes = self.linkedTextHighlightedAttributesDictionary[tappedStrng];
            [self setAttributes:highlightedAttributes forLinkedString:tappedStrng];
        }
    }
}




#pragma mark - Private Method
-(NSDictionary *)dictionaryForLinkedString:(NSString *)linkedString defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)handler
{
    if (!defaultAttributes)
    {
        return nil;
    }
    if (!highlightedAttributes)
    {
        highlightedAttributes = [defaultAttributes copy];
    }
    return @{
             @"string":linkedString,
             @"defaultAttributes":defaultAttributes,
             @"highlightedAttributes":highlightedAttributes,
             @"handler":handler
             };
}
-(void)setRange:(NSRange)range forLinkedString:(NSString *)linkedString
{
    if (linkedString && range.length)
    {
        NSValue *rangeValue = [NSValue valueWithRange:range];
        [self.linkedTextRangeDictionary setObject:rangeValue forKey:linkedString];
    }
}
-(void)setHandler:(LinkedStringTapHandler)handler forLinkedString:(NSString *)linkedString
{
    if (linkedString && handler!=NULL)
    {
        self.linkedTextTapHandlerDictionary[linkedString] = [handler copy];
    }
}
-(void)setDefaultAttributes:(NSDictionary *)defaultAttributes forLinkedString:(NSString *)linkedString
{
    if (linkedString && defaultAttributes)
    {
        self.linkedTextDefaultAttributesDictionary[linkedString] = [defaultAttributes copy];
    }
}
-(void)setHighlightedAttributes:(NSDictionary *)highlightedAttributes forLinkedString:(NSString *)linkedString
{
    if (linkedString && highlightedAttributes)
    {
        self.linkedTextHighlightedAttributesDictionary[linkedString] = [highlightedAttributes mutableCopy];
    }
}

#pragma mark - Utility Methods
-(void)setAttributes:(NSDictionary *)attributes forLinkedString:(NSString *)linkedString
{
    if (!attributes || !linkedString)
    {
        return;
    }
      NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    NSRange linkedStringRange = [self.text rangeOfString:linkedString];
    [mutableAttributedString beginEditing];
    [mutableAttributedString addAttributes:attributes range:linkedStringRange];
    [mutableAttributedString endEditing];
    self.attributedText = mutableAttributedString;
}
-(void)setTextColor:(UIColor *)color forLinkedString:(NSString *)linkedString
{
    if (!color || !linkedString)
    {
        return;
    }
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    NSRange linkedStringRange = [self.text rangeOfString:linkedString];
    [mutableAttributedString beginEditing];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:color range:linkedStringRange];
    [mutableAttributedString endEditing];
    self.attributedText = mutableAttributedString;
}

#pragma mark - initializer
-(void)commonInit
{
    self.editable = NO;
    self.scrollEnabled = NO;
    self.selectable = NO;
    self.allowsEditingTextAttributes = NO;

}



@end
