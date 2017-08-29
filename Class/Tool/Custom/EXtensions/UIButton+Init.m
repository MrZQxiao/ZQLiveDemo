//
//  UIButton+Init.m
//  ZQLiveDemo
//
//  Created by 肖兆强 on 2017/8/28.
//  Copyright © 2017年 BTV. All rights reserved.
//

#import "UIButton+Init.h"

@implementation UIButton (Init)


+ (UIButton *)buttonWithnormalImg:(UIImage *)normalImg selectedImg:(UIImage *)selectedImg selector:(SEL)selector target:(id)target {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:normalImg forState:UIControlStateNormal];
    [button setImage:selectedImg forState:UIControlStateSelected];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}


+ (UIButton *)buttonWithnormalImg:(UIImage *)normalImg highlightedImg:(UIImage *)highlightedImg selector:(SEL)selector target:(id)target {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:normalImg forState:UIControlStateNormal];
    [button setImage:highlightedImg forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton *)buttonWithNormalImg:(UIImage *)normalImg withSelector:(SEL)selector withTarget:(id)target {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:normalImg forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}


@end
