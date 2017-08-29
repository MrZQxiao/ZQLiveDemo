//
//  StatusBarTool+JWZT.h
//  LivePubDemo
//
//  Created by 肖兆强 on 2017/5/18.
//  Copyright © 2017年 jwzt. All rights reserved.
//

#import <Foundation/Foundation.h>

//0 - 无网络 ; 1 - 2G ; 2 - 3G ; 3 - 4G ; 5 - WIFI

typedef NS_ENUM(NSUInteger, NetWorkType) {
    NetWorkTypeNone=0,
    NetWorkType2G=1,
    NetWorkType3G=2,
    NetWorkType4G=3,
    NetWorkTypeWiFI=5,
};




@interface StatusBarTool_JWZT : NSObject



/**
 *
 *
 *  @return 当前网络类型
 */
+(NetWorkType )currentNetworkType;


/**
 *
 *
 *  @return SIM卡所属的运营商（公司）
 */
+(NSString *)serviceCompany;

/**
 *
 *
 *  @return 当前电池电量百分比
 */
+(NSString *)currentBatteryPercent;

/**
 *
 *
 *  @return 当前时间显示的字符串
 */
+(NSString *)currentTimeString;




/**
 *
 *
 *
 @return 当前信号强度
 */
+ (int )getSignalStrength;


@end
