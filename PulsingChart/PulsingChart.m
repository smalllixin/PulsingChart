//
//  LxRunningChart.m
//  RunningChart
//
//  Created by lixin on 5/26/14.
//  Copyright (c) 2014 lxtap. All rights reserved.
//

#import "PulsingChart.h"
#import <QuartzCore/QuartzCore.h>
#define INPUT_MAX_COUNT (100)

@implementation PulsingChart
{
    CADisplayLink *displayLink;
    CGFloat dynamicLineOriginX;
    CGFloat lineOrginX;
    CFTimeInterval startTimestamp;
    
    CGFloat inputValues[INPUT_MAX_COUNT];
    CFTimeInterval inputMoments[INPUT_MAX_COUNT];
//    int nextInputIdx;
    int firstInputIdx;
    int validInputLen;
    
    CGFloat lastValue;
    CFTimeInterval lastInputTimestamp;
    NSTimer *timer;
    
    
    NSTimeInterval pauseTime;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    displayLink.frameInterval = 2;//about 60/3 = 20fps
    displayLink.paused = YES;
    dynamicLineOriginX = 0;
    self.multiplier = 1;
    self.dynamicLineSpeed = 70; // n per second
    self.dynamicLineSpace = 320.0f/5;
    self.lineSpeed = 100;
    self.lineColor = [UIColor whiteColor];
    self.dynamicLineColor = [UIColor greenColor];
    self.backgroundColor = [UIColor blackColor];
    self.sampleFreq = 4;// per second
    self.fillDataMode = kRunningChartFillDataModeToZero;
//    self.fillDataMode = kRunningChartFillDataModeToLast;
    
    self.autoFillValue = 0.01f;
    
//    NSLog(@"%f", displayLink.timestamp);
    firstInputIdx = 0;
    validInputLen = 0;
    lastValue = 0.1f;
}

- (void)fillNumber:(id)sender
{
    //此处去掉timer，
    //
    switch (self.fillDataMode) {
        case kRunningChartFillDataModeToZero:
            [self putNextValue:self.autoFillValue];
            break;
        case kRunningChartFillDataModeToLast:
            [self putNextValue:lastValue];
            break;
        default:
            break;
    }
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (startTimestamp == 0) {
        startTimestamp =  displayLink.timestamp;
    }
    
    if (displayLink.timestamp - lastInputTimestamp > 1.0f/_sampleFreq) {
//        NSLog(@"auto fill data");
        [self fillNumber:nil];
        lastInputTimestamp = displayLink.timestamp;
    }
    
    CGFloat movDistance = self.dynamicLineSpeed*self.multiplier*(displayLink.timestamp-startTimestamp);
    dynamicLineOriginX = - movDistance;
    
//    CGRect rect = self.frame;
    CGFloat frameWidth = CGRectGetWidth(rect);
    CGFloat frameHeight = CGRectGetHeight(rect);
    
    CGFloat passedDynamicLineNumber = (dynamicLineOriginX / _dynamicLineSpace);
    
    int numberOfDynamicLines = frameWidth/_dynamicLineSpace;
    
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);

    CGContextSetStrokeColorWithColor(ctx, self.dynamicLineColor.CGColor);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    CGContextSetLineWidth(ctx, 1);
    for (int i = 0; i < numberOfDynamicLines; i ++) {
        CGFloat dyLineX = ((passedDynamicLineNumber - (int)passedDynamicLineNumber)*_dynamicLineSpace + i*_dynamicLineSpace) + _dynamicLineSpace;
    
        CGContextMoveToPoint(ctx, dyLineX, 0);
        CGContextAddLineToPoint(ctx, dyLineX, frameHeight);
        CGContextStrokePath(ctx);
    }
    CGContextRestoreGState(ctx);

   
    //让线动起来
    lineOrginX =  -self.lineSpeed*self.multiplier*(displayLink.timestamp-startTimestamp);
    
    CGFloat sampleSpace = self.lineSpeed/_sampleFreq;

    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
//    NSLog(@"-------");
    for (int i = 0; i < validInputLen; i ++) {
        int idx = (firstInputIdx + i)%INPUT_MAX_COUNT;
        
        CGFloat pX = lineOrginX + inputMoments[idx]*self.lineSpeed + frameWidth + sampleSpace;
        CGFloat value = inputValues[idx];
        CGFloat pY = (1-value)*frameHeight;
        if (i == 0) {
//            NSLog(@"px:%f, orig:%f",pX,originX);
            [bezierPath moveToPoint: CGPointMake(pX, pY)];
        } else {
//                NSLog(@"x:%f, y:%f", pX, pY);
            [bezierPath addLineToPoint: CGPointMake(pX, pY)];
        }
    }
    [self.lineColor setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
}

- (void)tick:(CADisplayLink*)sender
{
    
    //draw a verticle line here
    
    
    [self setNeedsDisplay];
}

- (void)run {
    if (pauseTime > 0) {
        startTimestamp += [[NSDate date] timeIntervalSince1970] - pauseTime;
        pauseTime = 0;
    }
    displayLink.paused = NO;
}

- (void)pause {
    displayLink.paused = YES;
    pauseTime = [[NSDate date] timeIntervalSince1970];
}

- (void)putNextValue:(CGFloat)nextValue {
    if (startTimestamp == 0)
        return;
    lastValue = nextValue;
    lastInputTimestamp = displayLink.timestamp;
    
    int idx = (firstInputIdx + validInputLen)%INPUT_MAX_COUNT;
    inputValues[idx] = nextValue;//arc4random()%10000*1.0f/10000;//0.2f; //fill empty value
    inputMoments[idx] = displayLink.timestamp - startTimestamp;

    validInputLen ++;
    
    if (validInputLen > INPUT_MAX_COUNT) {
        validInputLen --;//keep in max
        firstInputIdx = (firstInputIdx + 1)%INPUT_MAX_COUNT;
    }
//    NSLog(@"first:%d valid: %d",firstInputIdx, validInputLen);
}
@end
