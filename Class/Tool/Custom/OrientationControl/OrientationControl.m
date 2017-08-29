//
//  OrientationControl.m
//  LiveDemo
//
//  Created by MengXianLiang on 2017/5/13.
//  Copyright © 2017年 MengXianLiang. All rights reserved.
//

#import "OrientationControl.h"
#import <UIKit/UIKit.h>

@implementation OrientationControl

+(void)setOrientationMaskPortrait{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = UIInterfaceOrientationMaskPortrait;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

@end
