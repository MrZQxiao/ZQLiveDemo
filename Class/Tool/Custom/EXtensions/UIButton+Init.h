//
//  UIButton+Init.h
//  ZQLiveDemo
//
//  Created by 肖兆强 on 2017/8/28.
//  Copyright © 2017年 BTV. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Init)
+ (UIButton *)buttonWithnormalImg:(UIImage *)normalImg selectedImg:(UIImage *)selectedImg selector:(SEL)selector target:(id)target;

+ (UIButton *)buttonWithnormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg selector:(SEL)selector target:(id)target;

+ (UIButton *)buttonWithNormalImg:(UIImage *)normalImg withSelector:(SEL)selector withTarget:(id)target;
@end
