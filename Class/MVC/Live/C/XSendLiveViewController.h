//
//  CSendLiveViewController.h
//  ZQLiveDemo
//
//  Created by 肖兆强 on 2017/8/28.
//  Copyright © 2017年 BTV. All rights reserved.
//
//

#import <UIKit/UIKit.h>

typedef void(^SendLiveViewisOpenBlock)(BOOL isOpen);

@interface XSendLiveViewController : UIViewController

@property (nonatomic ,strong)SendLiveViewisOpenBlock isopenBlock;

@property (nonatomic ,assign)BOOL isOpen;

@end
