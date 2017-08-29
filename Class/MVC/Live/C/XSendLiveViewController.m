//
//  CSendLiveViewController.m
//  ZQLiveDemo
//
//  Created by 肖兆强 on 2017/8/28.
//  Copyright © 2017年 BTV. All rights reserved.
//
//

#import "XSendLiveViewController.h"
#import "XLiveViewController.h"
#import "UIViewExt.h"
#import "UIButton+Init.h"
#import "OrientationControl.h"
#import "LivePrefixHeader.pch"

@interface XSendLiveViewController ()

@end

@implementation XSendLiveViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [OrientationControl setOrientationMaskPortrait];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initViews];
}

- (void)_initViews {

    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *beginLive = [UIButton buttonWithType:UIButtonTypeCustom];
    beginLive.frame = CGRectMake((IphoneWidth - 200)/2.0,  IphoneHeight - 200, 200, 40);
    [beginLive addTarget:self action:@selector(button) forControlEvents:UIControlEventTouchUpInside];
    [beginLive setTitle:@"开 始 直 播" forState:UIControlStateNormal];
    beginLive.backgroundColor = kColor_navigationBarColor;
    beginLive.layer.cornerRadius = 10;
    [self.view addSubview:beginLive];
}

- (void)button
{
    XLiveViewController *live =[[XLiveViewController alloc] init];
    live.title = @"直播回传";
    [self presentViewController:live animated:NO completion:nil];
}


#pragma mark -shouldAutorotate (类目)
//返回最上层的子Controller的supportedInterfaceOrientations
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

//不自动旋转
- (BOOL)shouldAutorotate {
    
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
