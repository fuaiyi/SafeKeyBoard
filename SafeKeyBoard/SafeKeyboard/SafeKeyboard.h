//
//  SafeKeyboard.h
//  demo
//
//  Created by gaofu on 2017/3/27.
//  Copyright © 2017年 siruijk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SafeKeyboard : UIView

//字体颜色
@property (nonatomic,strong) UIColor *fontColor;
//字体大小
@property (nonatomic,assign) CGFloat fontSize;
//间隙
@property (nonatomic,assign) CGFloat itemSpace;




/**
 textField内容变化回调
 */
-(void)safeKeyBoardDidChanged:(void(^)(NSString*value))safeKeyboardDidChangedBlock;

/**
 初始化类方法
 */
+ (instancetype)keyboardWithTextField:(UITextField *)textField;

@end



@interface SafeKeyboardImageCell : UICollectionViewCell

//图片
@property (nonatomic,strong) UIImageView *cellImageView;

@end


@interface SafeKeyboardTextCell : UICollectionViewCell

//文字
@property (nonatomic,strong) UILabel *cellTextLabel;


@end
