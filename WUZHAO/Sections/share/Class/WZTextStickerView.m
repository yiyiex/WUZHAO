//
//  WZTextStickerView.m
//  WUZHAO
//
//  Created by yiyi on 15/8/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import "WZTextStickerView.h"

#define kUserResizableViewGlobalInset 5.0
#define kUserResizableViewDefaultMinWidth 10.0
#define kUserResizableViewInteractiveBorderSize 10.0
#define kStickerViewControlSize 20.0

@implementation WZTextStickerView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initViews];
        
    }
    return self;
}


-(void)initViews
{
    self.textInfo = [[PhotoText alloc]init];
    self.textView = [[UITextView alloc]initWithFrame:self.bounds];
    
    [self.textView setBackgroundColor:[UIColor clearColor]];
   
    
    [self setContentView:self.textView];
    [self setTextString:self.textInfo.textString];
    [self setTextFont:self.textInfo.textFont];
    [self setTextSize:self.textInfo.textSize];
    [self setTextColor:self.textInfo.textColor];
    [self setAngle:self.textInfo.textAngle];
    
    [self setFrame:CGRectOffset(self.frame, self.textInfo.textPoint.x - self.center.x, self.textInfo.textPoint.y - self.center.y)];
    
    [self setEditState];
}


-(void)setTextString:(NSString *)textString
{
    _textInfo.textString = textString;
    _textView.text = textString;
}
-(void)setTextFont:(NSString *)textFont
{
    _textInfo.textFont = textFont;
    [_textView setFont:[UIFont fontWithName:_textInfo.textFont size:_textInfo.textSize]];
    [self resizeByContentView];

}
-(void)setTextSize:(NSInteger)textSize
{
    _textInfo.textSize = textSize;
    [_textView setFont:[UIFont fontWithName:_textInfo.textFont size:_textInfo.textSize]];
    [self resizeByContentView];
}


-(void)setAngle:(CGFloat)angle
{
    _textInfo.textAngle = angle;
    self.deltaAngle = angle;
}

-(void)setTextColor:(TEXTCOLOR)textColor
{
    if (textColor == TEXTCOLOR_WHITE)
    {
        _textInfo.textColor = TEXTCOLOR_WHITE;
        [_textView setTextColor:[UIColor whiteColor]];
    }
    else if (textColor == TEXTCOLOR_BLACK)
    {
        _textInfo.textColor = TEXTCOLOR_BLACK;
        [_textView setTextColor:[UIColor blackColor]];
    }
}

-(void)setTextDirection:(TEXTDIRECTION)textDirection
{
     _textInfo.textDirection =textDirection;
    if (textDirection == TEXTDIRECTION_LANDSCAPE)
    {
      // _textView setBaseWritingDirection:UITextWritingDirectionLeftToRight forRange:<#(UITextRange *)#>
    }
}

-(void)setEditState
{
    self.preventsResizing = NO;
    self.preventsPositionOutsideSuperview = NO;
    self.preventsDeleting = NO;
    self.preventsCustomButton = YES;
    [self showEditingHandles];
}
-(void)setEndEditState
{
    [self hideEditingHandles];
}


#pragma mark - utility
-(void)resizeByContentView
{
    [_textView sizeToFit];
    [self setFrame:CGRectInset(_textView.frame, -kUserResizableViewGlobalInset - kUserResizableViewInteractiveBorderSize/2, -kUserResizableViewGlobalInset -kUserResizableViewInteractiveBorderSize/2)];
}





@end
