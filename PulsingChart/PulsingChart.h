//
//  LxRunningChart.h
//  RunningChart
//
//  Created by lixin on 5/26/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import <UIKit/UIKit.h>
enum RunningChartFillDataMode {
    kRunningChartFillDataModeToZero = 0,
    kRunningChartFillDataModeToLast = 1,
};
@interface PulsingChart : UIControl

@property (nonatomic, assign) CGFloat multiplier;
@property (nonatomic, assign) CGFloat dynamicLineSpeed;
@property (nonatomic, assign) CGFloat dynamicLineSpace;
@property (nonatomic, strong) UIColor *dynamicLineColor;

@property (nonatomic, assign) CGFloat lineSpeed;
@property (nonatomic, assign) int sampleFreq;
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat autoFillValue;

@property (nonatomic, assign) enum RunningChartFillDataMode fillDataMode;
- (void)run;
- (void)pause;
- (void)putNextValue:(CGFloat)nextValue; //nextValue range [0,1] 
@end
