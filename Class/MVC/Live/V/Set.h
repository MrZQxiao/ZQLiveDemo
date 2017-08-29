//
//  set.h
//  ZQLiveDemo
//
//  Created by 肖兆强 on 2017/8/28.
//  Copyright © 2017年 BTV. All rights reserved.
//





#import <UIKit/UIKit.h>
#import "XLiveViewController.h"
#import "NYSliderPopover.h"
#import "LFLiveVideoConfiguration.h"

@protocol setDelegate <NSObject>

- (void)setDelegate:(UIView *)set withRecognize:(NSInteger)recognize;
- (void)setDelegate:(UIView *)set withFps:(NSInteger)fps withFpsENUM:(FpsSegment)segment;
- (void)setDelegate:(UIView *)set withRate:(NSInteger)rate;
@end

@interface Set : UIView



@property (nonatomic ,assign)LFLiveVideoSessionPreset recognizeSegment_selected;


@property (nonatomic ,assign)FpsSegment fpsSegment_selected;

@property (nonatomic ,assign)NSInteger rateValue ;

@property (nonatomic ,strong)NYSliderPopover *rate;

@property (nonatomic ,strong)id<setDelegate> delegate;

@end
