//
//  YZTTraceManager.m
//  YZTAlpha
//
//  Created by easy on 2019/3/12.
//  Copyright © 2019 easy. All rights reserved.
//

#import "YZTTraceManager.h"


#import "UIApplication+Information.h"
#import "UIApplication+Version.h"

#import "UIDevice+Network.h"

#import <QuartzCore/QuartzCore.h>

#define kHardwareFramesPerSecond 60

static NSTimeInterval const kNormalFrameDuration = 1.0 / kHardwareFramesPerSecond;

@interface YZTTraceManager( ) {
    BOOL _isTracing;
    
    CFTimeInterval _lastSecondOfFrameTimes[kHardwareFramesPerSecond];
}
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger frameNumber;
@property (nonatomic, strong) NSTimer *tracingTimer;
@end

@implementation YZTTraceManager


+ (instancetype)defaultManager
{
    static YZTTraceManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}

-(BOOL)isTracing {
    return _isTracing;
}

-(void)startTracing {
    if (!_isTracing) {
        _isTracing = YES;
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkWillDraw:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        [self clearLastSecondOfFrameTimes];
        
        self.tracingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tracing) userInfo:nil repeats:NO];
    }
}

-(void)stopTracing {
    if(_isTracing) {
        _isTracing = NO;
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

-(void) tracing {
    if (!self.isTracing) {
        return;
    }
    
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"cpu_usage"] = @([UIApplication sharedApplication].alpha_cpuUsage);// 1%
    data[@"memory_size"] = @([UIApplication sharedApplication].alpha_memorySize); //bytes
    data[@"wifi_received"] = @([UIDevice currentDevice].alpha_receivedWiFi.longLongValue);
    data[@"wifi_sent"] = @([UIDevice currentDevice].alpha_sentWifi.longLongValue);
    data[@"cellular_received"] = @([UIDevice currentDevice].alpha_receivedCellular.longLongValue);
    data[@"cellular_sent"] = @([UIDevice currentDevice].alpha_sentCellular.longLongValue);
    
    data[@"fps"] = @(self.drawnFrameCountInLastSecond);
    
    if ([self.delegate respondsToSelector:@selector(traceManager:data:)]) {
        [self.delegate traceManager:self data:data];
    }
    
    self.tracingTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(tracing) userInfo:nil repeats:NO];
}

- (CFTimeInterval)lastFrameTime
{
    return _lastSecondOfFrameTimes[self.frameNumber % kHardwareFramesPerSecond];
}

- (void)recordFrameTime:(CFTimeInterval)frameTime
{
    ++self.frameNumber;
    _lastSecondOfFrameTimes[self.frameNumber % kHardwareFramesPerSecond] = frameTime;
}

- (void)clearLastSecondOfFrameTimes
{
    CFTimeInterval initialFrameTime = CACurrentMediaTime();
    for (NSInteger i = 0; i < kHardwareFramesPerSecond; ++i) {
        _lastSecondOfFrameTimes[i] = initialFrameTime;
    }
    self.frameNumber = 0;
}


- (NSInteger)droppedFrameCountInLastSecond
{
    NSInteger droppedFrameCount = 0;
    
    CFTimeInterval lastFrameTime = CACurrentMediaTime() - kNormalFrameDuration;
    for (NSInteger i = 0; i < kHardwareFramesPerSecond; ++i) {
        if (1.0 <= lastFrameTime - _lastSecondOfFrameTimes[i]) {
            ++droppedFrameCount;
        }
    }
    
    return droppedFrameCount;
}

- (NSInteger)drawnFrameCountInLastSecond
{
    if (!_isTracing || self.frameNumber < kHardwareFramesPerSecond) {
        return -1;
    }
    
    return kHardwareFramesPerSecond - self.droppedFrameCountInLastSecond;
}


- (void)displayLinkWillDraw:(CADisplayLink *)displayLink
{
    CFTimeInterval currentFrameTime = displayLink.timestamp;
    
    [self recordFrameTime:currentFrameTime];
}


@end
