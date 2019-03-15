//
//  YZTTracePlugin.m
//  YZTAlpha
//
//  Created by easy on 2019/3/12.
//  Copyright © 2019 easy. All rights reserved.
//

#import "YZTTracePlugin.h"

#import "ALPHAActions.h"

#import "ALPHAAssetManager.h"

#import "ALPHAManager.h"
#import "ALPHACoreAssets.h"
#import "YZTTraceSource.h"
#import "YZTTraceTaskSource.h"
#import "ALPHAFileManager.h"
#import "YZTTraceManager.h"
#import "ALPHAScreenManager.h"
#import "ALPHAStatusBarNotification.h"
@interface YZTTracePlugin ()<YZTTraceManagerDelegate>
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) ALPHAStatusBarNotification *notification ;
@end

@implementation YZTTracePlugin


- (id)init
{
    self = [super initWithIdentifier:@"com.yzt.plugin.trace"];
    
    if (self)
        {
        ALPHABlockActionItem *touchAction = [ALPHABlockActionItem itemWithIdentifier:@"com.yzt.plugin.trace.make"];
        touchAction.title = @"YZT Trace";
        touchAction.icon = [[ALPHAAssetManager sharedManager] imageWithIdentifier:ALPHALogoIdentifier color:nil size:CGSizeMake(28.0, 28.0)];
        touchAction.priority = 2000.0;
        touchAction.actionBlock = ^id(id sender)
            {
            [self tracing];
            
            return nil;
            };
        
        [self registerAction:touchAction];
        
        ALPHAScreenActionItem* menuAction = [ALPHAScreenActionItem itemWithIdentifier:@"com.yzt.plugin.trace.main"];
        menuAction.icon = [[ALPHAAssetManager sharedManager] imageWithIdentifier:ALPHALogoIdentifier color:nil size:CGSizeMake(20.0, 20.0)];
        menuAction.title = @"YZT Traces";
        menuAction.dataIdentifier = ALPHATraceDataIdentifier;
        menuAction.isMain = YES;
        
        [self registerAction:menuAction];
        
        [self registerSource:[YZTTraceSource new]];
        [self registerSource:[YZTTraceTaskSource new]];
        }
    
    return self;
}

-(void) tracing {
    if ([[YZTTraceManager defaultManager] isTracing]) {
        [self stopTracing];
    } else {
        [self startTracing];
    }
}

- (void) startTracing {
    [YZTTraceManager defaultManager].delegate = self;
    [[YZTTraceManager defaultManager] startTracing];
    
    self.filename = [self stringForFile];
    self.notification = [[ALPHAManager defaultManager] displayNotificationWithMessage:[NSString stringWithFormat:@"Start Tracing at: %@", self.filename] completion:^{
        
    }];
}

-(void) stopTracing {
    [[YZTTraceManager defaultManager] stopTracing];
    [YZTTraceManager defaultManager].delegate = nil;
    
    
    
    NSString *dir = [[NSString alloc] initWithUTF8String:[[ALPHAFileManager sharedManager] documentsDirectory].fileSystemRepresentation];
    NSString *directory = [NSString stringWithFormat:@"%@/Alpha/Traces", dir];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directory, [self filename]];

    ALPHARequest *req = [ALPHARequest requestWithIdentifier:ALPHATraceTaskDataIdentifier];
    req.parameters = @{@"file":filePath};
    
    
    [[ALPHAScreenManager defaultManager] pushObject:req];
    
    
    [self.notification dismissNotification];
    self.filename = nil;
}

-(void)traceManager:(YZTTraceManager *)manager data:(NSDictionary *)data {
    [self saveTracing:data];
}

- (void)saveTracing:(NSDictionary *) tracing
{
    NSString *dir = [[NSString alloc] initWithUTF8String:[[ALPHAFileManager sharedManager] documentsDirectory].fileSystemRepresentation];
    NSString *directory = [NSString stringWithFormat:@"%@/Alpha/Traces", dir];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directory, [self filename]];

    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir];
    
    if (!exists || !isDir)
        {
        NSError *error;
        
        [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL URLWithString:directory] withIntermediateDirectories:YES attributes:nil error:&error];
        }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:tracing options:0 error:0];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    str = [str stringByAppendingString:@"\n"];
    NSData *writeData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    exists = [[NSFileManager defaultManager] fileExistsAtPath:filePath];
   if (!exists) {
       [writeData writeToFile:filePath atomically:YES];
   } else {
       NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
       [handle seekToEndOfFile];
       [handle writeData:writeData];
       [handle closeFile];
   }
    
}


- (NSString *)stringForFile
{
    return [NSString stringWithFormat:@"ALPHA_TR_%@.csv", [[ALPHAFileManager sharedManager].fileDateFormatter stringFromDate:[NSDate date]]];
}

@end
