//
//  LinkTextView.m
//  WZLinkTextView
//
//  Created by yiyi on 15/4/29.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "LinkTextView.h"
#import "macro.h"

@interface LinkTextView()
@property (nonatomic) NSRange currentRange;
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

-(void)reset
{
    self.linkedTextDefaultAttributesDictionary = nil;
    self.linkedTextRangeDictionary = nil;
    self.linkedTextHighlightedAttributesDictionary = nil;
    self.linkedTextTapHandlerDictionary = nil;
    
    self.text = nil;
    self.attributedText = nil;
    self.currentRange = NSMakeRange(0, 0);
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
-(void)linkTextWithString:(NSString *)string defaultAttributes:(NSDictionary *)defaultAttributes highlightAttributes:(NSDictionary *)highlightAttributes tabHandler:(LinkedStringRangeTapHandler)tapHandler
{
    if (!string || !defaultAttributes)
    {
        return;
    }
    NSRange stringRange = [self.text rangeOfString:string];
    NSDictionary *linkedStringDictionary = [self dictionaryForLinkedString:string stringRange:stringRange defaultAttributes:defaultAttributes highlightedAttributes:highlightAttributes tapHandler:tapHandler];
    [self addLinkedStringAndAttributes:linkedStringDictionary];
}
-(void)setText:(NSAttributedString *)string linkStrings:(NSArray *)linkStrings defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandlers:(NSArray *)tapHandlers
{
    if (!string ||!defaultAttributes)
    {
        return;
    }
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:string];
    
    self.attributedText = mutableAttributedString;
    
    if (tapHandlers.count == 0)
    {
        return;
    }
    for (NSInteger i = 0;i<linkStrings.count;i++)
    {
        NSString *s = [string string];
        NSRange linkStringInnerRange = [s rangeOfString:linkStrings[i]];
        NSDictionary *linkedStringDictionary;
        if (tapHandlers.count >=linkStrings.count)
        {
            linkedStringDictionary = [self dictionaryForLinkedString:linkStrings[i] stringRange:linkStringInnerRange defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandler:tapHandlers[i]];
        }
        else
        {
            linkedStringDictionary = [self dictionaryForLinkedString:linkStrings[i] stringRange:linkStringInnerRange defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandler:tapHandlers[0]];
        }
        
        [self addLinkedStringAndAttributes:linkedStringDictionary];
    }

    
}

-(void)appendText:(NSAttributedString *)string linkStrings:(NSArray *)linkStrings defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandlers:(NSArray *)tapHandlers
{
    if (!string || !defaultAttributes)
    {
        return;
    }
    NSUInteger oldLength = self.text.length;
    NSMutableAttributedString *mutableAttributedString;
    if (oldLength == 0)
    {
        mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:string];
    }
    else
    {
        mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
        NSMutableAttributedString *appendString = [[NSMutableAttributedString alloc]initWithAttributedString:string];
        [mutableAttributedString beginEditing];
        [mutableAttributedString appendAttributedString:appendString];
        [mutableAttributedString endEditing];
    }

    self.attributedText = mutableAttributedString;
    
    if (tapHandlers.count == 0)
    {
        return;
    }
    for (NSInteger i = 0;i<linkStrings.count;i++)
    {
        NSString *s = [string string];
        NSRange linkStringInnerRange = [s rangeOfString:linkStrings[i]];
        NSRange linkStringOutRange = NSMakeRange(linkStringInnerRange.location + oldLength, linkStringInnerRange.length);
        NSDictionary *linkedStringDictionary;
        if (tapHandlers.count >=linkStrings.count)
        {
            linkedStringDictionary = [self dictionaryForLinkedString:linkStrings[i] stringRange:linkStringOutRange defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandler:tapHandlers[i]];
        }
        else
        {
            linkedStringDictionary = [self dictionaryForLinkedString:linkStrings[i] stringRange:linkStringOutRange defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandler:tapHandlers[0]];
        }

        [self addLinkedStringAndAttributes:linkedStringDictionary];
    }
}

-(void)addLinkedStringAndAttributes:(NSDictionary *)linkedStringDictionary
{
    if (!self.text)
    {
        //self.text = linkedStringDictionary[@"string"];
        self.attributedText = [[NSAttributedString alloc]initWithString:linkedStringDictionary[@"string"]];
    }
   // NSString *text = self.text;
    NSAttributedString *attributedString = self.attributedText;
    NSString *string = linkedStringDictionary[@"string"];
    NSRange range = [linkedStringDictionary[@"stringRange"] rangeValue];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedString];
    [mutableAttributedString beginEditing];
    if (range.length)
    {
        [self setRange:range forLinkedString:string];
        [self setHandler:linkedStringDictionary[@"handler"] forLinkedStringRange:range];
        [self setDefaultAttributes:linkedStringDictionary[@"defaultAttributes"] forLinkedStringRange:range];
        [self setHighlightedAttributes:linkedStringDictionary[@"highlightedAttributes"] forLinkedStringRange:range];
        [mutableAttributedString addAttributes:linkedStringDictionary[@"defaultAttributes"] range:range];
        
    }
    [mutableAttributedString endEditing];
    self.attributedText = mutableAttributedString;
    
}
#pragma mark - Touch Handling Methods
-(NSRange)handleTouches:(NSSet *)touches
{
    CGPoint location = [touches.allObjects.lastObject locationInView:self];
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    return  [self findLinkedStringRangeAtPoint:location inDictionary:self.linkedTextRangeDictionary];
}
-(NSRange)findLinkedStringRangeAtPoint:(CGPoint)point inDictionary:(NSDictionary *)dictionary
{
    NSUInteger characterIndex;
    characterIndex = [self.layoutManager characterIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    __block NSRange result = NSMakeRange(0, 0) ;
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       // NSValue *value = (NSValue*)obj;
        NSRange rangeToCheck = [key rangeValue];
        NSUInteger min = rangeToCheck.location;
        NSUInteger max = min + rangeToCheck.length;
        if (characterIndex >=min && characterIndex <=max)
        {
            result = rangeToCheck;
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
    NSRange tappedStringRange = [self handleTouches:touches];
    NSDictionary *highlightAttributes = self.linkedTextHighlightedAttributesDictionary[[NSValue valueWithRange:tappedStringRange]];
    if ( highlightAttributes)
    {
        self.currentRange = tappedStringRange;
        [self setAttributes:highlightAttributes forLinkedStringRange:tappedStringRange];
    }
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSRange tappedStringRange = [self handleTouches:touches];
    NSDictionary *defaultAttributes = self.linkedTextDefaultAttributesDictionary[[NSValue valueWithRange:tappedStringRange]];
    if (defaultAttributes)
    {
        if (self.currentRange.location == tappedStringRange.location &&self.currentRange.length == tappedStringRange.length )
        {
            LinkedStringRangeTapHandler tapHandler = self.linkedTextTapHandlerDictionary[[NSValue valueWithRange:self.currentRange]];
            tapHandler(self.currentRange);
            [self setAttributes:defaultAttributes forLinkedStringRange:self.currentRange];
        }
        self.currentRange = NSMakeRange(0 , 0);
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSRange tappedStringRange = [self handleTouches:touches];
    if ( tappedStringRange.location != self.currentRange.location || tappedStringRange.length != self.currentRange.length )
    {
        if (self.currentRange.length>0 && self.currentRange.location >0)
        {
            NSDictionary *defaultAttributes = self.linkedTextDefaultAttributesDictionary[[NSValue valueWithRange:self.currentRange ]];
            [self setAttributes:defaultAttributes forLinkedStringRange:self.currentRange];
        }
        if (tappedStringRange.location >0 && tappedStringRange.length >0)
        {
            self.currentRange = tappedStringRange;
            NSDictionary *highlightedAttributes = self.linkedTextHighlightedAttributesDictionary[[NSValue valueWithRange:tappedStringRange]];
            [self setAttributes:highlightedAttributes forLinkedStringRange:tappedStringRange];
        }
    }
}




#pragma mark - Private Method
-(NSDictionary *)dictionaryForLinkedString:(NSString *)linkedString stringRange:(NSRange)stringRange defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringRangeTapHandler)handler
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
             @"stringRange":[NSValue valueWithRange:stringRange],
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
        [self.linkedTextRangeDictionary setObject:linkedString forKey:rangeValue];
    }
}
-(void)setHandler:(LinkedStringRangeTapHandler)handler forLinkedStringRange:(NSRange)range
{
    if (handler!=NULL)
    {
        self.linkedTextTapHandlerDictionary[[NSValue valueWithRange:range]] = [handler copy];
    }
}
-(void)setDefaultAttributes:(NSDictionary *)defaultAttributes forLinkedStringRange:(NSRange)range
{
    if ( defaultAttributes)
    {
        self.linkedTextDefaultAttributesDictionary[[NSValue valueWithRange:range]] = [defaultAttributes copy];
    }
}
-(void)setHighlightedAttributes:(NSDictionary *)highlightedAttributes forLinkedStringRange:(NSRange)range
{
    if (highlightedAttributes)
    {
        self.linkedTextHighlightedAttributesDictionary[[NSValue valueWithRange:range]] = [highlightedAttributes mutableCopy];
    }
}

#pragma mark - Utility Methods
-(void)setAttributes:(NSDictionary *)attributes forLinkedStringRange:(NSRange)range
{
    if (!attributes)
    {
        return;
    }
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    [mutableAttributedString beginEditing];
    [mutableAttributedString addAttributes:attributes range:range];
    [mutableAttributedString endEditing];
    self.attributedText = mutableAttributedString;
}



-(void)setTextColor:(UIColor *)color forLinkedStringRane:(NSRange)range
{
    if (!color)
    {
        return;
    }
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    [mutableAttributedString beginEditing];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
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
