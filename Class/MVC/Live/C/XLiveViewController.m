//
//  CLiveViewController.m
//  ZQLiveDemo
//
//  Created by 肖兆强 on 2017/8/28.
//  Copyright © 2017年 BTV. All rights reserved.
//


#import "XLiveViewController.h"
#import "Masonry.h"
#import "MTBlockAlertView.h"
#import "MBProgressHUD.h"
#import "UIButton+Init.h"
#import "Set.h"
#import "UIViewExt.h"
#import "UINavigationController+Autorotate.h"
#import "LFLiveKit.h"
#import "UIColor+HEX.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h> //声音提示
#import "LivePrefixHeader.pch"
#import "StatusBarTool+JWZT.h"



#define  menuSpace   (kScreen_width - 120 - 55 *4) /3.0
#define  menuTop     (100 - 55) /2.0
#define  menuButtonWidth 55
#define  maxSignValue 8000
struct config_s {
    CGSize videosize;
    LIVE_BITRATE vBitRate;
    LIVE_FRAMERATE fps;
    BOOL voice;
    AVCaptureDevicePosition videoposition;
    
};
@interface XLiveViewController ()<setDelegate,LFLiveSessionDelegate>




{
    
    UIView *previewView;
    /**
     *RIGHT
     */
    UIButton *_reportButton; //直播
    UIButton *_screenshotsButton;//截屏
    UIButton *_setButton; //设置
    
    /**
     *LEFT
     */
    UIView *_LeftBGView;//左侧背景
    UIButton *_backButton;//返回按钮
    UIButton *_cameraButton; //摄像头
    UIButton *_torchButton; //闪光灯
    UIButton *_micSwitcButton; //声音
    UIButton *_beautiyButton; //美颜
    
    
    /**
     *TOP
     */

    
    UIView *_topBGView;//顶部背景图
    UIImageView *_netImage;//网络状态图片
    UIImageView *_redPoint;//红点
    
    NSTimer *_timer;//
    UILabel *_timelabel;//时间显示
    int _timeNum;//时间值
    UIImageView *_batteryImage;//电量
    
    //码流显示
    UILabel *_streamTitleLable;
    UILabel *_streamValueLable;
    
    //流量显示
    UILabel *_trafficTitleLable;
    UILabel *_trafficValueLable;
    
    
    
    /**
     *beauty
     */
    UIView *_beautySettingView;
    
    UIView *_beautySettingBGView;//底部背景
    
    UILabel *_beautyLabel;//美颜
    UILabel *_beautyValue;
    UILabel *_brightLabel;//亮度
    UILabel *_brightValue;
    UISlider *_beautySlider;//美颜
    UISlider *_brightSlider;//亮度
    
    


    
    //    设置删除
    UIButton *_deleSet;
    //    直播是否开始
    BOOL _isBegin;
//    是否后置
    BOOL _isBackCamera;

//   点击的分辨率为
    LFLiveVideoSessionPreset recognizeSegment;
//   点击的帧率为
    FpsSegment fpsSegment;
//   点击的码率为
    NSInteger rateValue;

    struct config_s _cfg;
    
    
}


@property(nonatomic,strong)LFLiveDebug *debugInfo;



@property (nonatomic, strong)LFLiveSession *session;


/**
 是否手动退出
 */
@property (nonatomic,assign)BOOL isHandout;


/**
 当前总流量
 */
@property (nonatomic,assign)CGFloat dataFlow;


/**
 设置是否变化
 */
@property (nonatomic,assign)BOOL settingIsChanged;



/**
 记录上一次美颜值
 */
@property (nonatomic,assign)CGFloat lastBeautyValue;


/**
 记录上一次亮度值
 */
@property (nonatomic,assign)CGFloat lastBrightValue;



/**
 网络监察定时器
 */
@property (nonatomic,strong)NSTimer *checkTimer;


@end

@implementation XLiveViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self layout];
    [self initNotification];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
 }

//隐藏statusBar
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self RtmpInit];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    [AppDelegate shareAppDelegate].allowRotation = NO;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [_timer invalidate];
    [_checkTimer invalidate];

}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)initNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillResignActiveNotification) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WillDidBecomeActiveNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    // 接受屏幕改变的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];


}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    previewView = [[UIView alloc] init];
    [self.view addSubview:previewView];
    
    [self requestAccessForVideo];
    [self requestAccessForAudio];
    [self requestAccessForPhoto];
    
    _settingIsChanged = NO;//设置改变初始化
    _isBegin = NO; //默认为未直播状态
    _isBackCamera = YES;//默认为后摄像头
    recognizeSegment = LFCaptureSessionPreset720x1280; //默认分辨率为1280x720
    fpsSegment = FpsSegment_25th; //默认帧率为30
    rateValue = 1000;
   
    
    
    _checkTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(checkStatusBar) userInfo:nil repeats:YES];
    
    [_checkTimer setFireDate:[NSDate distantPast]];
    
    //
    [self initRightMenuButton];
    [self initLeftMenuButton];
    [self initTopMenubutton];
    [self initBeautyMenuButton];
    
}





#pragma mark --LFLivesession
-(void) RtmpInit{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_cfg.videosize.width > 0) {
            //
        }else{
            _cfg.videosize = LIVE_VIEDO_SIZE_HORIZONTAL_720P;
        }
        if (_cfg.vBitRate > 0) {
            
        }else{
            _cfg.vBitRate = LIVE_BITRATE_1Mbps;
        }
        if (_cfg.fps > 0) {
            
        }else{
            _cfg.fps = 25;
        }

        /***   默认分辨率368 ＊ 640  音频：44.1 iphone6以上48  双声道  方向竖屏 ***/
        LFLiveVideoConfiguration *videoConfiguration = [LFLiveVideoConfiguration new];
        videoConfiguration.videoSize = _cfg.videosize;
        videoConfiguration.videoBitRate = _cfg.vBitRate;
        videoConfiguration.videoMaxBitRate = 1000*1024;
        videoConfiguration.videoMinBitRate = 300*1024;
        
        videoConfiguration.videoFrameRate = _cfg.fps;
        videoConfiguration.videoMaxKeyframeInterval = 60;
        videoConfiguration.videoMinFrameRate = 15;
        videoConfiguration.outputImageOrientation = UIInterfaceOrientationLandscapeRight;
        videoConfiguration.autorotate = YES;
        
        videoConfiguration.sessionPreset = LFCaptureSessionPreset720x1280;
        LFLiveSession *session  = [[LFLiveSession alloc] initWithAudioConfiguration:[LFLiveAudioConfiguration defaultConfiguration] videoConfiguration:videoConfiguration captureType:LFLiveCaptureDefaultMask];
        session.mirror = NO;
        session.captureDevicePosition =  _cfg.videoposition;
        session.delegate = self;
        session.showDebugInfo = YES;
        session.running = YES;
        session.muted = _cfg.voice;
        session.preView= previewView;
        session.reconnectInterval = 2;
        session.reconnectCount = 2;
        _session = session;
        _settingIsChanged = NO;
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
    });
}










#pragma mark -- 请求权限
- (void)requestAccessForVideo {
    __weak typeof(self) _self = self;
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            // 许可对话没有出现，发起授权许可
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_self.session setRunning:YES];
                    });
                }
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            // 已经开启授权，可继续
            dispatch_async(dispatch_get_main_queue(), ^{
                [_self.session setRunning:YES];
            });
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            // 用户明确地拒绝授权，或者相机设备无法访问
            
            break;
        default:
            break;
    }
}

- (void)requestAccessForAudio {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (status) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}


- (void)requestAccessForPhoto
{
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    switch (authStatus) {
        case PHAuthorizationStatusNotDetermined:
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            }];
            break;
            //无法授权
        case PHAuthorizationStatusRestricted:
            
            break;
            //明确拒绝
        case PHAuthorizationStatusDenied:
            
            break;
            
            //已授权
        case PHAuthorizationStatusAuthorized:
            
            break;
            
        default:
            break;
    }
}


#pragma mark  --初始化UI
- (void)initLeftMenuButton
{
    //   背景
    _LeftBGView = [[UIView alloc] init];
    _LeftBGView.backgroundColor = [UIColor whiteColor];
    _LeftBGView.alpha = .5;
    [self.view addSubview:_LeftBGView];
    
    
    //    返回按钮
    _backButton = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"return")] highlightedImg:[UIImage imageNamed:LiveImageName(@"return")]  selector:@selector(topAction:) target:self];
    
    [self.view addSubview:_backButton];
    
    
    
    //    摄像头
    _cameraButton = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"shot-change")]  highlightedImg:[UIImage imageNamed:LiveImageName(@"shot-change")] selector:@selector(cameraButton:) target:self];
    [self.view addSubview:_cameraButton];
    
    //    闪光灯
    _torchButton = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"lamp-closed")] selectedImg:[UIImage imageNamed:LiveImageName(@"lamp-open")] selector:@selector(MenuAction:) target:self];
    _torchButton.tag = 101;
    [self.view addSubview:_torchButton];
    
    //   声音
    _micSwitcButton = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"voice-open")] selectedImg:[UIImage imageNamed:LiveImageName(@"voice-closed")] selector:@selector(MenuAction:) target:self];
    _micSwitcButton.tag = 102;
    [self.view addSubview:_micSwitcButton];
    
    //    美颜
    _beautiyButton = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"meiyan-open")] selectedImg:[UIImage imageNamed:LiveImageName(@"meiyan-closed")] selector:@selector(MenuAction:) target:self];
    _beautiyButton.tag = 103;
    [self.view addSubview:_beautiyButton];
    
    
    

}


- (void)initRightMenuButton
{
    
    //截屏
    _screenshotsButton = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"photo")] selectedImg:[UIImage imageNamed:LiveImageName(@"photo")] selector:@selector(screenshotsButtonClick) target:self];
    [_screenshotsButton setBackgroundImage:[UIImage imageNamed:LiveImageName(@"photo-round")] forState:UIControlStateNormal];
    [self.view addSubview:_screenshotsButton];
    
    
    //    直播开始
    _reportButton = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"camera")] selectedImg:[UIImage imageNamed:LiveImageName(@"camera-living")] selector:@selector(reportAction:) target:self];
    [_reportButton setBackgroundImage:[UIImage imageNamed:LiveImageName(@"cemera-round")] forState:UIControlStateNormal];
    _reportButton.selected = NO;
    //    开始直播有延迟。  避开这个之间的延迟时间
    _reportButton.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        _reportButton.enabled = YES;
    });
    [self.view addSubview:_reportButton];
    
    
    //设置
    _setButton = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"set")] selectedImg:[UIImage imageNamed:LiveImageName(@"set")] selector:@selector(MenuAction:) target:self];
    [_setButton setBackgroundImage:[UIImage imageNamed:LiveImageName(@"set-round")] forState:UIControlStateNormal];

    _setButton.tag = 104;
    [self.view addSubview:_setButton];
    
}


- (void)initTopMenubutton {
    
    
    
    //顶部背景图
    
    _topBGView = [[UIView alloc] init];
    _topBGView.backgroundColor = [UIColor whiteColor];
    _topBGView.alpha = .5;
    [self.view addSubview:_topBGView];
    
    //网络状态图片
    _netImage = [[UIImageView alloc] init];
    _netImage.image = [UIImage imageNamed:LiveImageName(@"net")];
    [self.view addSubview:_netImage];
    
    

    //网络状态图片
    _redPoint = [[UIImageView alloc] init];
    _redPoint.image = [UIImage imageNamed:LiveImageName(@"count")];
    [self.view addSubview:_redPoint];

    
//        定时器
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
        [_timer setFireDate:[NSDate distantFuture]];
    
//        时间显示
        _timelabel =[[UILabel alloc] init];
        _timelabel.text = @"00:00:00";
        _timelabel.textAlignment = NSTextAlignmentCenter;
        _timelabel.textColor = [UIColor whiteColor];
        _timelabel.font = [UIFont systemFontOfSize:14];
        [self.view addSubview:_timelabel];

    //电量
    _batteryImage = [[UIImageView alloc] init];
    _batteryImage.image = [UIImage imageNamed:LiveImageName(@"100-ttery")];
    [self checkBattery];
    [self.view addSubview:_batteryImage];

    
    
    //码流显示
    _streamTitleLable =[[UILabel alloc] init];
    _streamTitleLable.text = @"实时码流";
    _streamTitleLable.textAlignment = NSTextAlignmentLeft;
    _streamTitleLable.textColor = [UIColor colorWithHexString:@"#dddce3"];
    _streamTitleLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_streamTitleLable];

    
    _streamValueLable =[[UILabel alloc] init];
    _streamValueLable.text = @"";
    _streamValueLable.textAlignment = NSTextAlignmentCenter;
    _streamValueLable.textColor = [UIColor colorWithHexString:@"#fd0303"];
    _streamValueLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_streamValueLable];

    //流量显示
    _trafficTitleLable =[[UILabel alloc] init];
    _trafficTitleLable.text = @"总流量";
    _trafficTitleLable.textAlignment = NSTextAlignmentLeft;
    _trafficTitleLable.textColor = [UIColor colorWithHexString:@"#dddce3"];
    _trafficTitleLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_trafficTitleLable];
    
    
    _trafficValueLable =[[UILabel alloc] init];
    _trafficValueLable.text = @"";
    _trafficValueLable.textAlignment = NSTextAlignmentLeft;
    _trafficValueLable.textColor = [UIColor colorWithHexString:@"#dddce3"];
    _trafficValueLable.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:_trafficValueLable];
    
}


- (void)initBeautyMenuButton {
  
    _beautySettingView = [[UIView alloc] init];
    _beautySettingView.backgroundColor = [UIColor clearColor];
    _beautySettingView.layer.cornerRadius = 5;
    _beautySettingView.clipsToBounds = YES;
    
    _beautySettingBGView = [[UIView alloc] init];
    _beautySettingBGView.backgroundColor = [UIColor whiteColor];
    _beautySettingBGView.alpha = .5;
    _beautySettingBGView.layer.cornerRadius = 5;
    _beautySettingBGView.clipsToBounds = YES;
    
    [self.view addSubview:_beautySettingView];
    
    
    [_beautySettingView addSubview:_beautySettingBGView];
    
    
    
    
    //美颜
    _beautyLabel =[[UILabel alloc] init];
    _beautyLabel.text = @"美颜调节";
    
    _beautyLabel.textColor = [UIColor blackColor];
    _beautyLabel.font = [UIFont systemFontOfSize:14];
    [_beautySettingView addSubview:_beautyLabel];
    
    
    //亮度
    _brightLabel = [[UILabel alloc] init];
    _brightLabel.text = @"亮度调节";
    
    _brightLabel.textColor = [UIColor blackColor];
    _brightLabel.font = [UIFont systemFontOfSize:14];
    [_beautySettingView addSubview:_brightLabel];
    
    
    //美颜
    _beautySlider =[[UISlider alloc] init];
    _beautySlider.tag = 105;
    _beautySlider.minimumValue = 0.0;
    _beautySlider.maximumValue = 100.0;
    _beautySlider.value = 50;
    _lastBeautyValue = 50;
    _beautySlider.minimumTrackTintColor = RGB(17, 195, 236);
    [_beautySlider setThumbImage:[UIImage imageNamed:LiveImageName(@"Handle")] forState:UIControlStateNormal];
    
    [_beautySlider addTarget:self action:@selector(sliderValueChage:) forControlEvents:UIControlEventValueChanged];
    [_beautySettingView addSubview:_beautySlider];
    
    _beautyValue = [[UILabel alloc] init];
    _beautyValue.text = @"50";
    _beautyValue.textColor = [UIColor blackColor];
    _beautyValue.font = [UIFont systemFontOfSize:10];
    _beautyValue.textAlignment = NSTextAlignmentCenter;
    [_beautySettingView addSubview:_beautyValue];
    
    
    //亮度
    _brightSlider = [[UISlider alloc] init];
    _brightSlider.minimumValue = 0.0;
    _brightSlider.maximumValue = 100.0;
    _brightSlider.value = 50;
    _lastBrightValue = 50;
    _brightSlider.tag = 106;
    _brightSlider.minimumTrackTintColor = RGB(17, 195, 236);
    [_brightSlider setThumbImage:[UIImage imageNamed:LiveImageName(@"Handle")] forState:UIControlStateNormal];
    
    [_brightSlider addTarget:self action:@selector(sliderValueChage:) forControlEvents:UIControlEventValueChanged];
    [_beautySettingView addSubview:_brightSlider];
    
    _brightValue = [[UILabel alloc] init];
    _brightValue.text = @"50";
    _brightValue.textColor = [UIColor blackColor];
    _brightValue.font = [UIFont systemFontOfSize:10];
    _brightValue.textAlignment = NSTextAlignmentCenter;
    [_beautySettingView addSubview:_brightValue];
    
    
    _beautySettingView.hidden = YES;
    
}

#pragma mark - layout
- (void) layout
{
    [_topBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(395 , 39));
        make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
        make.top.equalTo(self.view.mas_top).with.offset(0);
    }];
    
    UIImage *netImage = [UIImage imageNamed:LiveImageName(@"net")];
    [_netImage mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(netImage.size.width ,netImage.size.height));
        make.top.equalTo(self.view.mas_top).with.offset(11);
        make.left.equalTo(_topBGView.mas_left).with.offset(20);
        
        
    }];
    
    UIImage *count = [UIImage imageNamed:LiveImageName(@"count")];
    [_redPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(count.size.width ,count.size.height));
        make.centerY.equalTo(_netImage.mas_centerY).with.offset(0);
        make.left.equalTo(_netImage.mas_right).with.offset(115);
    }];
    
    
    
    [_timelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(70 ,30));
        make.centerY.equalTo(_netImage.mas_centerY).with.offset(0);
        make.left.equalTo(_redPoint.mas_right).with.offset(6);
    }];
    
    
    UIImage *batteryImage = [UIImage imageNamed:LiveImageName(@"100-ttery")];
    [_batteryImage mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(batteryImage.size.width ,batteryImage.size.height));
        make.centerY.equalTo(_netImage.mas_centerY).with.offset(0);
        make.right.equalTo(_topBGView.mas_right).with.offset(-20);
    }];
    
    [_streamTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(60 ,20));
        make.left.equalTo(self.view.mas_left).with.offset(180);
        make.top.equalTo(_topBGView.mas_bottom).with.offset(10);
        
    }];
    
    [_streamValueLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(80 ,20));
        make.centerY.equalTo(_streamTitleLable.mas_centerY).with.offset(0);
        make.left.equalTo(_streamTitleLable.mas_right).with.offset(10);
        
        
    }];
    
    
    [_trafficTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(50 ,20));
        make.centerY.equalTo(_streamTitleLable.mas_centerY).with.offset(0);
        make.left.equalTo(_streamValueLable.mas_right).with.offset(70);
        
        
    }];
    
    
    
    [_trafficValueLable mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(80 ,20));
        make.centerY.equalTo(_streamTitleLable.mas_centerY).with.offset(0);
        make.left.equalTo(_trafficTitleLable.mas_right).with.offset(19);
        
        
    }];
    
    UIImage *screenshotsimage = [UIImage imageNamed:LiveImageName(@"photo-round")];
    
    [_screenshotsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(screenshotsimage.size.width ,screenshotsimage.size.height));
        make.top.equalTo(self.view.mas_top).with.offset(15);
        make.right.equalTo(self.view.mas_right).with.offset(-15);
        
    }];
    
    UIImage *reportimage = [UIImage imageNamed:LiveImageName(@"cemera-round")];
    
    [_reportButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(reportimage.size.width ,reportimage.size.height));
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.top.equalTo(_screenshotsButton.mas_bottom).with.offset(95);
    }];
    
    UIImage *setimage = [UIImage imageNamed:LiveImageName(@"set-round")];
    [_setButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(setimage.size.width ,setimage.size.height));
        make.right.equalTo(self.view.mas_right).with.offset(-15);
        make.top.equalTo(_reportButton.mas_bottom).with.offset(95);
    }];
    
    
    [previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.view);
        make.width.height.equalTo(self.view);
        
    }];
    
    
    
    [_LeftBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49 , IphoneHeight));
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.top.equalTo(self.view.mas_top).with.offset(0);
    }];
    
    UIImage *backImage = [UIImage imageNamed:LiveImageName(@"return")];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49 ,backImage.size.height));
        make.centerX.equalTo(_LeftBGView.mas_centerX);
        
        //        make.left.equalTo(self.view.mas_left).with.offset(15);
        make.top.equalTo(self.view.mas_top).with.offset(15);
    }];
    
    UIImage *micSwitcImage = [UIImage imageNamed:LiveImageName(@"lamp-open")];
    
    [_micSwitcButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49,micSwitcImage.size.height));
        make.centerX.equalTo(_LeftBGView.mas_centerX);
        
        //        make.right.equalTo(_menuBGImg.mas_right).with.offset(- 66);
        make.top.equalTo(_backButton.mas_bottom).with.offset(47);
    }];
    
    
    UIImage *cameraImage = [UIImage imageNamed:LiveImageName(@"shot-change")];
    [_cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49 ,cameraImage.size.height));
        make.centerX.equalTo(_LeftBGView.mas_centerX);
        //        make.left.equalTo(self.view.mas_left).with.offset(15);
        make.top.equalTo(_micSwitcButton.mas_bottom).with.offset(47);
    }];
    
    
    UIImage *torchImage = [UIImage imageNamed:LiveImageName(@"lamp-open")];
    
    [_torchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49,torchImage.size.height));
        make.centerX.equalTo(_LeftBGView.mas_centerX);
        
        //        make.right.equalTo(_menuBGImg.mas_right).with.offset( - 10);
        make.top.equalTo(_cameraButton.mas_bottom).with.offset(47);
    }];
    
    
    UIImage *beautiyImage = [UIImage imageNamed:LiveImageName(@"lamp-open")];
    
    [_beautiyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(49 ,beautiyImage.size.height));
        make.centerX.equalTo(_LeftBGView.mas_centerX);
        
        //        make.right.equalTo(_menuBGImg.mas_right).with.offset(- 66);
        make.top.equalTo(_torchButton.mas_bottom).with.offset(47);
    }];
    
    
    
    [_beautySettingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(310 , 100));
        make.left.equalTo(_LeftBGView.mas_right).with.offset(20);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
    }];
    
    [_beautySettingBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(310 , 100));
        make.left.equalTo(_LeftBGView.mas_right).with.offset(20);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-20);
    }];
    
    [_beautyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(70 ,20));
        make.left.equalTo(_beautySettingView.mas_left).with.offset(10);
        make.top.equalTo(_beautySettingView.mas_top).with.offset(10);
        
        
    }];
    
    
    [_brightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(70 ,20));
        
        make.left.equalTo(_beautySettingView.mas_left).with.offset(10);
        
        make.bottom.equalTo(_beautySettingView.mas_bottom).with.offset(-20);
        
        
    }];
    
    [_beautySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(200 ,20));
        make.left.equalTo(_beautyLabel.mas_right).with.offset(10);
        make.top.equalTo(_beautySettingView.mas_top).with.offset( 10);
        
        
    }];
    [_beautyValue mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(20 ,10));
        make.centerX.equalTo(_beautySlider.mas_centerX).with.offset(0);
        make.top.equalTo(_beautySlider.mas_bottom).with.offset(0);
        
        
    }];
    
    
    [_brightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(200 ,20));
        make.left.equalTo(_brightLabel.mas_right).with.offset(10);
        make.bottom.equalTo(_beautySettingView.mas_bottom).with.offset(-20);
        
    }];
    [_brightValue mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.mas_equalTo(CGSizeMake(20 ,10));
        make.centerX.equalTo(_brightSlider.mas_centerX).with.offset(0);
        make.top.equalTo(_brightSlider.mas_bottom).with.offset(0);
        
        
    }];
    
    
}

#pragma mark --美颜效果调节
- (void)sliderValueChage:(id)slider
{
    UISlider *searchSlider = slider;
    
    switch (searchSlider.tag) {
        case 105:
        {
            self.session.beautyLevel = searchSlider.value/100;
            
            NSString *voiceValue = [NSString stringWithFormat:@"%.0f",searchSlider.value];
            _beautyValue.text = voiceValue;
            
            CGFloat change = (_lastBeautyValue - searchSlider.value) *2;
            
            if (searchSlider.value < 20) {
                _beautyValue.textAlignment = NSTextAlignmentRight;
                
            }else if (searchSlider.value>80)
            {
                _beautyValue.textAlignment = NSTextAlignmentLeft;
            }else
            {
                _beautyValue.textAlignment = NSTextAlignmentCenter;
                
            }
            [UIView animateWithDuration:0.1 animations:^{
                _beautyValue.x -= change;
            }];
            _lastBeautyValue = searchSlider.value;
        }
            
            break;
        case 106:
        {
            self.session.brightLevel = searchSlider.value/100;
            
            NSString *voiceValue = [NSString stringWithFormat:@"%.0f",searchSlider.value];
            _brightValue.text = voiceValue;
            
            CGFloat change = (_lastBrightValue - searchSlider.value) *2;
            
            if (searchSlider.value < 20) {
                _brightValue.textAlignment = NSTextAlignmentRight;
                
            }else if (searchSlider.value>80)
            {
                _brightValue.textAlignment = NSTextAlignmentLeft;
            }else
            {
                _brightValue.textAlignment = NSTextAlignmentCenter;
                
            }
            
            
            [UIView animateWithDuration:0.1 animations:^{
                _brightValue.x -= change;
            }];
            _lastBrightValue = searchSlider.value;
            
            
        }
            
            break;
            
            
        default:
            break;
    }
    
}


#pragma mark --截屏
- (void)screenshotsButtonClick
{
    
    
    UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
    AudioServicesPlaySystemSound(1108);
    
    
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
    UIImage *image = [_session currentImage];
    
    
    
    ALAssetsLibrary * library = [ALAssetsLibrary new];
    
    NSData * data = UIImageJPEGRepresentation(image, 1.0);
    

    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
       
        if (!error) {
            


        }
        
    }];
    [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:nil];

}


- (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    
    return newPic;
}



-(UIImage *)captureImageFromView:(UIView *)view
{
    
    CGRect screenRect = [view bounds];
    
    UIGraphicsBeginImageContext(screenRect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [view.layer renderInContext:ctx];
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}






#pragma mark - 计时器
- (void)timeAction {
    _timeNum ++;
    //shi
    NSInteger hour= _timeNum/3600;
    NSString *hourText = hour <10 ? [NSString stringWithFormat:@"0%ld",(long)hour] :[NSString stringWithFormat:@"%ld",(long)hour];
    //   fen
    NSInteger minute = ( _timeNum -hour *3600)/60;
    NSString *minuteText = minute <10 ? [NSString stringWithFormat:@"0%ld",(long)minute] :[NSString stringWithFormat:@"%ld",(long)minute];
    //miao
    NSInteger second = (_timeNum -hour *3600 -minute *60);
    NSString *secondText = second <10 ? [NSString stringWithFormat:@"0%ld",(long)second] :[NSString stringWithFormat:@"%ld",(long)second];
    _timelabel.text = [NSString stringWithFormat:@"%@:%@:%@",hourText,minuteText,secondText];
}

#pragma mark - 摄像头切换按钮
- (void)cameraButton:(UIButton *)button {
    button.selected = !button.selected;
    AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
    self.session.captureDevicePosition = (devicePositon == AVCaptureDevicePositionBack) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;

    
}

#pragma mark -开始直播
- (void)reportAction:(UIButton *)button {
    
    
    NetWorkType status = [StatusBarTool_JWZT currentNetworkType];
    
    if (!(status == NetWorkTypeNone)) {
        
   
    
    
    
    if (!_isBegin) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    
    if (button.selected == YES) {
        MTBlockAlertView *alertview = [[MTBlockAlertView alloc] initWithTitle:@"是否结束直播" message:nil
    completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [self.session stopLive];
            _isBegin = NO;
            _isHandout = YES;
            _reportButton.selected = NO;

            
        }else if(buttonIndex == 1){
        }
    }
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles: @"确定", @"取消" , nil];
        [alertview show];
    }else {

        _reportButton.enabled = NO;
        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
        
        #warning --填写推流地址
        stream.url = RTMP_URL_1;
        [self.session startLive:stream];
        
    }
    }else
    {
        MTBlockAlertView *alertview = [[MTBlockAlertView alloc] initWithTitle:@"当前网络断开连接，请检查网络" message:nil completionHanlder:nil                                                        cancelButtonTitle:@"确定" otherButtonTitles:  nil];
        [alertview show];

    }
    
        
}

#pragma mark - 菜单栏按钮点击
- (void)MenuAction:(UIButton *)button {
    
    
    switch (button.tag) {
        case 101:
            if (self.session.captureDevicePosition !=AVCaptureDevicePositionFront) {
                
                
                
                UIView *alertView = [[UIView alloc] init];
                alertView.backgroundColor = [UIColor whiteColor];
                alertView.alpha = .5;
                [self.view addSubview:alertView];
                UILabel *alertLabel = [[UILabel alloc] init];
                alertLabel.textColor = [UIColor whiteColor];
                alertLabel.font = [UIFont systemFontOfSize:14];
                alertLabel.textAlignment = NSTextAlignmentCenter;
                [self.view addSubview:alertLabel];
                
                
                if (_session.torch) {
                    
                    alertLabel.text = @"闪光灯已关闭!";
                    
                }else
                {
                    alertLabel.text = @"闪关灯已开启!";
                }
                _session.torch =!_session.torch;
                button.selected = !button.selected;
                
                [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(100 , 30));
                    make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
                    make.centerY.equalTo(self.view.mas_centerY).with.offset(0);
                }];
                [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    
                    make.size.mas_equalTo(CGSizeMake(90 , 20));
                    make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
                    make.centerY.equalTo(self.view.mas_centerY).with.offset(0);
                    
                    
                }];
                
                [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    alertLabel.alpha = 0;
                    alertView.alpha =0;
                } completion:^(BOOL finished) {
                    
                    [alertView removeFromSuperview];
                    [alertLabel removeFromSuperview];
                    
                }];
            }
            
            break;
        case 102:
            //        语音开关,默认是trun。 当直播开始录制的时候endle = no 不可以调节。
            //       关闭_>打开
            
            
        {
            button.selected = !button.selected;
            
            UIView *alertView = [[UIView alloc] init];
            alertView.backgroundColor = [UIColor whiteColor];
            alertView.alpha = .5;
            [self.view addSubview:alertView];
            UILabel *alertLabel = [[UILabel alloc] init];
            alertLabel.textColor = [UIColor whiteColor];
            alertLabel.font = [UIFont systemFontOfSize:14];
            alertLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:alertLabel];
            
            
            if (_session.muted) {
                
                alertLabel.text = @"语音已开启!";
                
            }else
            {
                alertLabel.text = @"语音已关闭!";
            }
            
            _session.muted = !_session.muted;
            _cfg.voice = !_cfg.voice;
            [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(100 , 30));
                make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
                make.centerY.equalTo(self.view.mas_centerY).with.offset(0);
            }];
            [alertLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.size.mas_equalTo(CGSizeMake(90 , 20));
                make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
                make.centerY.equalTo(self.view.mas_centerY).with.offset(0);
            }];
            
            [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
                alertLabel.alpha = 0;
                alertView.alpha =0;
            } completion:^(BOOL finished) {
                
                [alertView removeFromSuperview];
                [alertLabel removeFromSuperview];
                
            }];
        }
            break;
            //美颜
        case 103:
        {
            _beautySettingView.hidden = !_beautySettingView.hidden;
            
        }
            break;
            
            //设置按钮
        case 104:
            if (_setView ==nil) {
                _setView = [[Set alloc] initWithFrame:CGRectMake(80, 40, IphoneWidth - 160, IphoneHeight - 80)];
            }
            _setView.delegate = self;

            _setView.recognizeSegment_selected = recognizeSegment;
            _setView.fpsSegment_selected = fpsSegment;
            _setView.rateValue = rateValue;
            
            if (_deleSet == nil) {
                _deleSet = [UIButton buttonWithnormalImg:[UIImage imageNamed:LiveImageName(@"close.png")] highlightedImg:[UIImage imageNamed:LiveImageName(@"close_highlight.png")] selector:@selector(deleset) target:self];
            }
            _deleSet.frame = CGRectMake(_setView.right - menuButtonWidth/2.0, _setView.y - menuButtonWidth/2.0, menuButtonWidth, menuButtonWidth);
            
            _setView.hidden = NO;
            _deleSet.hidden = NO;
            [self.view addSubview:_setView];
            [self.view addSubview:_deleSet];
            break;
            
        default:
            break;
    }
}


#pragma mark - 删除设置界面
- (void)deleset {
    [_setView removeFromSuperview];
    _setView = nil;
    [_deleSet removeFromSuperview];
    _deleSet =nil;
    if (_settingIsChanged) {
        
        [self.session stopLive];
        AVCaptureDevicePosition devicePositon = self.session.captureDevicePosition;
        _cfg.videoposition = devicePositon;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self RtmpInit];
            
        });

    }
    
   
    
}
#pragma mark -  pop
- (void)topAction:(UIButton *)button {
        MTBlockAlertView *alertview = [[MTBlockAlertView alloc] initWithTitle:@"是否退出直播？" message:nil
        completionHanlder:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [_session stopLive];
                _isHandout = YES;
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            }
        }
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles: @"确定", @"取消" , nil];
        [alertview show];
    }

#pragma  maek - kvo（屏幕旋转通知）
-(void)orientationChanged:(NSNotification*)notification{

    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    
    if (currentOrientation == UIDeviceOrientationPortrait){
        
        DebugLog(@"UIDeviceOrientationPortrait");
        
    }else if (UIDeviceOrientationLandscapeRight) {
     
        DebugLog(@"UIDeviceOrientationLandscapeRight");
    }
}

//强制旋转某个方向
- (void)screenRotationStatus:(UIInterfaceOrientation)interfaceOrientation {
    
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = interfaceOrientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark- setDelegate

- (void)setDelegate:(UIView *)set withRecognize:(NSInteger)recognize {
    
    if (!(recognizeSegment == recognize)) {
        recognizeSegment = recognize;
        _settingIsChanged = YES;
    
    switch (recognize) {
        case 0:
        {
            _cfg.videosize = LIVE_VIEDO_SIZE_HORIZONTAL_720P;
        }
            break;
        case 1:
        {
            _cfg.videosize = LIVE_VIEDO_SIZE_HORIZONTAL_D1;
        }
            break;
        case 2:
        {
            _cfg.videosize = LIVE_VIEDO_SIZE_HORIZONTAL_CIF;
        }
            break;
            
        default:
            break;
    }
    }
}
- (void)setDelegate:(UIView *)set withFps:(NSInteger)fps withFpsENUM:(FpsSegment)segment{
   
    if (!(fpsSegment == segment)) {
        _settingIsChanged = YES;
        fpsSegment = segment;
        _cfg.fps = fps;
        
        
    }
    
    

}
- (void)setDelegate:(UIView *)set withRate:(NSInteger)rate {

    if (!(rateValue == rate)) {
        rateValue = rate;
        _settingIsChanged = YES;
        if (rate >= 1000 && rate < 2000) {
            _cfg.vBitRate = LIVE_BITRATE_1Mbps;
        }else if (rate >= 2000){
            _cfg.vBitRate = LIVE_BITRATE_2Mbps;
        }
        else if (rate > 800 && rate <= 1000){
            _cfg.vBitRate = LIVE_BITRATE_800Kbps;
        }
        else if (rate > 600 && rate <= 800){
            _cfg.vBitRate = LIVE_BITRATE_600Kbps;
        }else{
            _cfg.vBitRate = LIVE_BITRATE_400Kbps;
        }
 
    }
   }


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];//删除去激活界面的回调
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];//删除激活界面的回调
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




#pragma mark -- LFStreamingSessionDelegate
/** live status changed will callback */
- (void)liveSession:(nullable LFLiveSession *)session liveStateDidChange:(LFLiveState)state {
    switch (state) {
        case LFLiveReady:
            NSLog(@"准备完成");
            break;
        case LFLivePending:
           ;
            break;
        case LFLiveStart:
            [_timer setFireDate:[NSDate date]];
            _reportButton.selected = YES;
            _reportButton.enabled = YES;
            _isBegin = YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];

            break;
        case LFLiveError:
            _reportButton.enabled = YES;
            break;
        case LFLiveStop:
            
            if (_isHandout) {
                
                
                _trafficValueLable.text = @"";
                _streamValueLable.text = @"";
                [_timer setFireDate:[NSDate distantFuture]];
                _reportButton.selected = NO;
                _timelabel.text = @"00:00:00";
                _timeNum =0;
            }else
            {
                if (_isBegin) {
                    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        _reportButton.enabled = NO;
                        LFLiveStreamInfo *stream = [LFLiveStreamInfo new];
                        stream.url = RTMP_URL_1;
                        [self.session startLive:stream];

                       
                    });
                }
                
            }
            break;
        default:
            break;
    }
}


- (void)liveSession:(LFLiveSession *)session errorCode:(LFLiveSocketErrorCode)errorCode
{
    _reportButton.selected = NO;
    _reportButton.enabled = YES;
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.isHandout = YES;
    [self.session stopLive];
    MTBlockAlertView *alertview = [[MTBlockAlertView alloc] initWithTitle:@"连接服务器失败" message:nil completionHanlder:nil                                                        cancelButtonTitle:@"确定" otherButtonTitles:  nil];
    [alertview show];
}



- (void)liveSession:(LFLiveSession *)session debugInfo:(LFLiveDebug *)debugInfo
{
    NetWorkType status = [StatusBarTool_JWZT currentNetworkType];

    if (!(status == NetWorkTypeNone)) {
        CGFloat dataWith = debugInfo.dataFlow - _dataFlow;
        _dataFlow = debugInfo.dataFlow;
        if (dataWith >0) {
            CGFloat FrameRate = dataWith * 8 /1000;
            NSString *gaugeText = [NSString stringWithFormat:@"%.0fKps",FrameRate];
            
            
            if (FrameRate>1000) {
                gaugeText = [NSString stringWithFormat:@"%.2fMps",FrameRate/1000];
                }
            
            CGFloat dataflow = debugInfo.dataFlow/1024;
            NSString *Bandwidth = [NSString stringWithFormat:@"%.0fK",dataflow];
            if (dataflow > 1024) {
                Bandwidth = [NSString stringWithFormat:@"%.2fM",dataflow/1024];
            }else if (dataflow > 1024 *1024)
            {
                Bandwidth = [NSString stringWithFormat:@"%.2fG",dataflow/(1024 * 1024)];

            }
            _streamValueLable.text = gaugeText;
            _trafficValueLable.text = Bandwidth;
        }
        
    }

}


#pragma mark --获取电池电量
- (void)checkBattery
{
    NSString *str = [StatusBarTool_JWZT currentBatteryPercent];
    CGFloat batteryLevel = [str intValue];
    NSLog(@"%f",batteryLevel);
    if (batteryLevel >0&&batteryLevel<=10) {
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"10-ttery")];
    }else if (batteryLevel >10&&batteryLevel<=20){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"20-ttery")];
    }else if (batteryLevel >20&&batteryLevel<=30){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"30-ttery")];
    }else if (batteryLevel >30&&batteryLevel<=40){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"40-ttery")];
    }else if (batteryLevel >40&&batteryLevel<=50){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"50-ttery")];
    }else if (batteryLevel >50&&batteryLevel<=60){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"60-ttery")];
    }else if (batteryLevel >60&&batteryLevel<=70){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"70-ttery")];
        
    }else if (batteryLevel >70&&batteryLevel<=80){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"80-ttery")];
        
    }else if (batteryLevel >80&&batteryLevel<=90){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"90-ttery")];
        
    }else if (batteryLevel >90&&batteryLevel<=100){
        _batteryImage.image = [UIImage imageNamed:LiveImageName(@"100-ttery")];
    }
    
}

#pragma mark --获取网络信号强度

- (void)checkStatusBar
{
    int wifiStrength = [StatusBarTool_JWZT getSignalStrength];
    
    NSLog(@"%d",wifiStrength);
    switch (wifiStrength) {
            
        case 0:
            _netImage.image = [UIImage imageNamed:LiveImageName(@"net3")];
            break;
            
        case 1:
            _netImage.image =[UIImage imageNamed:LiveImageName(@"net3")];
            break;
        case 2:
            _netImage.image = [UIImage imageNamed:LiveImageName(@"net6")];
            
            break;
        case 3:
            _netImage.image =[UIImage imageNamed:LiveImageName(@"net")];
            
            break;
            
        default:
            break;
    }
    
    
    [self checkBattery];
    
}




- (void) appWillEnterForegroundNotification{
    NSLog(@"trigger event when will enter foreground.");
    if (![self hasPermissionOfCamera]) {
        return;
    }
    
}
- (void)WillDidBecomeActiveNotification{
    NSLog(@"CameraViewController: WillDidBecomeActiveNotification");
    
}
- (BOOL)hasPermissionOfCamera
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus != AVAuthorizationStatusAuthorized){
        
        NSLog(@"相机权限受限");
        return NO;
    }
    return YES;
}



- (void)WillResignActiveNotification{
    NSLog(@"LiveShowViewController: WillResignActiveNotification");
    
    if (![self hasPermissionOfCamera]) {
        return;
    }
    //得到当前应用程序的UIApplication对象
    UIApplication *app = [UIApplication sharedApplication];
    
    //一个后台任务标识符
    UIBackgroundTaskIdentifier taskID = 0;
    taskID = [app beginBackgroundTaskWithExpirationHandler:^{
        //如果系统觉得我们还是运行了太久，将执行这个程序块，并停止运行应用程序
        [app endBackgroundTask:taskID];
    }];
    //UIBackgroundTaskInvalid表示系统没有为我们提供额外的时候
    if (taskID == UIBackgroundTaskInvalid) {
        NSLog(@"Failed to start background task!");
        return;
    }
    
    [self.session stopLive];
   
    
//    告诉系统我们完成了
    [app endBackgroundTask:taskID];
}

#pragma mark -shouldAutorotate (类目)
//返回最上层的子Controller的supportedInterfaceOrientations


//不自动旋转
- (BOOL)shouldAutorotate {
    
    return NO;
}


- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


@end
