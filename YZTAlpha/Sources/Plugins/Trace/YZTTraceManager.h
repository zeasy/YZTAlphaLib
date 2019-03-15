//
//  YZTTraceManager.h
//  YZTAlpha
//
//  Created by easy on 2019/3/12.
//  Copyright © 2019 easy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class YZTTraceManager;

@protocol YZTTraceManagerDelegate <NSObject>

-(void) traceManager:(YZTTraceManager *) manager data:(NSDictionary *) data;

@end

@interface YZTTraceManager : NSObject
+ (instancetype)defaultManager;

@property (nonatomic, weak) id<YZTTraceManagerDelegate> delegate;

- (void) startTracing;
- (void) stopTracing;
- (BOOL) isTracing;

@end

NS_ASSUME_NONNULL_END
