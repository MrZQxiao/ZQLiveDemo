//
//  set.m
//  ZQLiveDemo
//
//  Created by 肖兆强 on 2017/8/28.
//  Copyright © 2017年 BTV. All rights reserved.
//


#import "Set.h"
#import "UIViewExt.h"
#import "LivePrefixHeader.pch"
@implementation Set{
    
    CGFloat space;
    
    //分辨率
    UISegmentedControl * _recognizeSegment;
    //桢率
    UISegmentedControl *_fpsSegment;
    
    //码率
    //    UIView *_rate;
    UIButton *_rateCount;
  
  }

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        self.alpha = .8;
        [self _initViews];
        
    }
    return self;
}

- (void)_initViews {
    NSArray *title = @[@"分辨率",@"帧率",@"码率"];
    space = (self.height - 30 *title.count) / (title.count +1);
    for (int i = 0; i < title.count; i ++) {
        UILabel *titleLabel = [[UILabel alloc]init];
        titleLabel.frame = CGRectMake(10, space + (space +30) *i, 80, 30);
        titleLabel.text = title[i];
        titleLabel.textColor  =[ UIColor whiteColor];
        [self addSubview:titleLabel];
    }
    
    NSArray *recognize = @[@"640*360P",@"960*540P",@"1280 *720P"];
    _recognizeSegment = [[UISegmentedControl alloc] initWithItems:recognize];
    _recognizeSegment.frame =  CGRectMake( 100 , space , 350, 30);
    //    segmented.tintColor = [UIColor greenColor];
    [_recognizeSegment addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged]; //添加事件
    _recognizeSegment.tag = 401;
    _recognizeSegment.backgroundColor = [UIColor blackColor];
    [self addSubview:_recognizeSegment];
    
    
    NSArray *fps = @[@"15",@"25",@"30",@"50",@"60"];
    _fpsSegment = [[UISegmentedControl alloc] initWithItems:fps];
    _fpsSegment.frame =CGRectMake(100, space + (space + 30) *1, 350, 30);
    _fpsSegment.selectedSegmentIndex = 2; //设置默认选中项
//    [_fpsSegment setEnabled:NO forSegmentAtIndex:0];
//    [_fpsSegment setEnabled:NO forSegmentAtIndex:3];
//    [_fpsSegment setEnabled:NO forSegmentAtIndex:4];
    [_fpsSegment addTarget:self action:@selector(segmentedAction:) forControlEvents:UIControlEventValueChanged]; //添加事件
    _fpsSegment.tag = 402;
    _fpsSegment.backgroundColor = [UIColor blackColor];
    [self addSubview:_fpsSegment];
    
    _rate = [[NYSliderPopover alloc] initWithFrame:CGRectMake(100, space + (space + 30) *2 + 10, 350, 20)];
    _rate.minimumValue = 400;
    _rate.maximumValue =  2000;
    _rate.value = _rateValue;
    _rate.tag = 1301;
    _rate.hidden = NO;
    UIImage *thu = [UIImage imageNamed:LiveImageName(@"Handle")];
    [_rate setThumbImage:thu forState:UIControlStateNormal];

    NSArray *rateLabelT =@[@"400",@"2000"];
    for (int i = 0; i <2 ; i ++) {
        UILabel *rateLabel =[[UILabel alloc] init];
        rateLabel.frame  = CGRectMake(_rate.x + (350 - 40)* i,
                                      _rate.bottom -5 , 70, 30);
        rateLabel.text = rateLabelT[i];
        rateLabel.backgroundColor  =[UIColor clearColor];
        rateLabel.textColor =[ UIColor whiteColor];
        [self addSubview:rateLabel];
    }

    //添加事件
    [_rate addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_rate];
    
}
#pragma mark - segmentedAction
- (void)segmentedAction:(UISegmentedControl *)seg {

    if (seg.tag == 401) { //_recognizeSegment
        
        int recognize;
            /**
         *发现这个分辨率的枚举值跟这个segment的值反着的 
         */
        switch (seg.selectedSegmentIndex) {
            case RecognizeSegment_Min:
                recognize = RecognizeSegment_Max;
                break;
            case RecognizeSegment_Mid:
                recognize = RecognizeSegment_Mid;
                break;
            case RecognizeSegment_Max:
                recognize = RecognizeSegment_Min;
                break;
            default:
                recognize = RecognizeSegment_Max;

                break;
        }
        [_delegate setDelegate:self withRecognize:recognize];
        
    }else if (seg.tag == 402) {//_fpsSegment
        int fps = 0;
        switch (seg.selectedSegmentIndex) {
            case FpsSegment_15th:
                fps = 15;
                break;
            case FpsSegment_25th:
                fps = 25;
                break;
            case FpsSegment_30th:
                fps = 30;
                break;
            case FpsSegment_50th:
                fps = 50;
                break;
            case FpsSegment_60th:
                fps = 60;
                break;
            default:
                break;
        }
        [_delegate setDelegate:self withFps:fps withFpsENUM:seg.selectedSegmentIndex];
        NSLog(@"_fpsSegment");
    }
}

#pragma mark - sliderAction
- (void)sliderAction:(NYSliderPopover *)slider {
    
    if (slider.tag == 1301) { //rate
        
        int c = (int)slider.value;
        CGFloat num =  (CGFloat)(c - 400 )/(CGFloat)(2000 - 400);
        int num1 =(((int)(num *2000)) / 100 ) * 100 +400;
        num1 = MIN(2000, num1);
        NSLog(@"num1num1num1num1:%d",num1);
        slider.popover.textLabel.text = [NSString stringWithFormat:@"%dkbps",num1];
        _rateCount.titleLabel.font = [UIFont systemFontOfSize:11];
        [_delegate setDelegate:self withRate:num1];

    }
}

#pragma mark - setting
//当前选中的分辨率
- (void)setRecognizeSegment_selected:(LFLiveVideoSessionPreset)recognizeSegment_selected
{
    if (_recognizeSegment_selected != recognizeSegment_selected) {
        _recognizeSegment_selected = recognizeSegment_selected;
    }
    if (_recognizeSegment_selected == 0) {
        _recognizeSegment.selectedSegmentIndex = 2;
    }else if (_recognizeSegment_selected == 2) {
        _recognizeSegment.selectedSegmentIndex = 2;
    }else {
        _recognizeSegment.selectedSegmentIndex = _recognizeSegment_selected;
    }
}


- (void)setFpsSegment_selected:(FpsSegment)fpsSegment_selected

{
    if (_fpsSegment_selected != fpsSegment_selected) {
        _fpsSegment_selected = fpsSegment_selected;
    }
    _fpsSegment.selectedSegmentIndex = _fpsSegment_selected;
}

- (void)setRateValue:(NSInteger)rateValue {
    if (_rateValue != rateValue) {
        _rateValue = rateValue;
    }
    _rate.value = _rateValue;

}






@end
