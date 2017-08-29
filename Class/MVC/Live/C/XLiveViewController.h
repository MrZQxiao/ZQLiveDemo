//
//  CLiveViewController.h
//  ZQLiveDemo
//
//  Created by 肖兆强 on 2017/8/28.
//  Copyright © 2017年 BTV. All rights reserved.
//
//

#import <UIKit/UIKit.h>
//#import "EILPublisher.h"
//#import "VCSimpleSession.h"
@class Set;

typedef NS_ENUM(NSUInteger, RecognizeSegment) {
    RecognizeSegment_Min,
    RecognizeSegment_Mid,
    RecognizeSegment_Max,
};



typedef NS_ENUM(NSUInteger, FpsSegment) {
    FpsSegment_15th,
    FpsSegment_25th,
    FpsSegment_30th,
    FpsSegment_50th,
    FpsSegment_60th,
};




@interface XLiveViewController : UIViewController

@property (nonatomic ,strong)Set *setView;

@end
