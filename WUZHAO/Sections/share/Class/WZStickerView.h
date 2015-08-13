//
//  WZStickerView.h
//  WUZHAO
//
//  Created by yiyi on 15/8/12.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    WZSTICKERVIEW_BUTTON_NULL,
    WZSTICKERVIEW_BUTTON_DEL,
    WZSTICKERVIEW_BUTTON_RESIZE,
    WZSTICKERVIEW_BUTTON_CUSTOM,
    WZSTICKERVIEW_BUTTON_MAX
} WZSTICKERVIEW_BUTTONS;

@protocol WZStickerViewDelegate;


@interface WZStickerView : UIView

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic) BOOL preventsPositionOutsideSuperview;    // default = YES
@property (nonatomic) BOOL preventsResizing;                    // default = NO
@property (nonatomic) BOOL preventsDeleting;                    // default = NO
@property (nonatomic) BOOL preventsCustomButton;                // default = YES
@property (nonatomic) BOOL translucencySticker;                // default = YES
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat deltaAngle;

@property (weak, nonatomic) id <WZStickerViewDelegate> stickerViewDelegate;

- (void)hideDelHandle;
- (void)showDelHandle;
- (void)hideEditingHandles;
- (void)showEditingHandles;
- (void)showCustomHandle;
- (void)hideCustomHandle;
- (void)setButton:(WZSTICKERVIEW_BUTTONS)type image:(UIImage *)image;
- (BOOL)isEditingHandlesHidden;
@end


@protocol WZStickerViewDelegate <NSObject>
@required
@optional
- (void)stickerViewDidBeginEditing:(WZStickerView *)sticker;
- (void)stickerViewDidEndEditing:(WZStickerView *)sticker;
- (void)stickerViewDidCancelEditing:(WZStickerView *)sticker;
- (void)stickerViewDidClose:(WZStickerView *)sticker;
#ifdef ZDSTICKERVIEW_LONGPRESS
- (void)stickerViewDidLongPressed:(WZStickerView *)sticker;
#endif
- (void)stickerViewDidCustomButtonTap:(WZStickerView *)sticker;
@end


