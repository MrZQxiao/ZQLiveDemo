//
//  UINavigationController+Autorotate.h
//  TestLandscape
//
//  Created by swhl on 13-4-16.
//  Copyright (c) 2013年 swhl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Autorotate)

- (BOOL)shouldAutorotate;
- (UIInterfaceOrientationMask)supportedInterfaceOrientations;

@end
