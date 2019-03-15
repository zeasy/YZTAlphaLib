//
//  YZTTraceTaskSource.m
//  YZTAlpha
//
//  Created by easy on 2019/3/12.
//  Copyright © 2019 easy. All rights reserved.
//

#import "YZTTraceTaskSource.h"
#import "ALPHATableScreenModel.h"
#import "ALPHABlockActionItem.h"
#import "ALPHAScreenManager.h"

#import "UIApplication+Version.h"
#import "UIDevice+DeviceInfo.h"
NSString *const ALPHATraceTaskDataIdentifier = @"com.yzt.data.trace.task";
#define boundary @"yzt_trace_file"


@implementation YZTTraceTaskSource


- (instancetype)init
{
    self = [super init];
    
    if (self)
        {
        [self addDataIdentifier:ALPHATraceTaskDataIdentifier];
        [self addActionIdentifier:ALPHATraceTaskDataIdentifier];
        }
    
    return self;
}

-(void)dataForRequest:(ALPHARequest *)request completion:(ALPHADataSourceRequestCompletion)completion {
    
    NSURL *url = [NSURL URLWithString:@"https://api.hisprintgo.com:8084/report-core/scene/getScenes.do"];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (!error) {
                ALPHATableScreenModel *model = [[ALPHATableScreenModel alloc] initWithIdentifier:ALPHATraceTaskDataIdentifier];
                model.title = @"Select a Scene";
                
                
                ALPHAScreenSection* section = [[ALPHAScreenSection alloc] init];
                
                NSMutableArray* items = [NSMutableArray array];
                
                NSArray *scenes = resp[@"data"][@"scenes"];
                for (int i = 0;i < scenes.count;i ++)
                    {
                    NSDictionary *scene = scenes[i];
                    ALPHABlockActionItem* item = [[ALPHABlockActionItem alloc] init];
                    
                    item.actionBlock = ^id(id sender) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self selectedRequest:request scene:scene];
                        });
                        return nil;
                    };
                    item.title = scene[@"name"];
                    item.detailText = scene[@"steps"];
                    item.object = scene;
                    item.request = [ALPHARequest requestWithIdentifier:ALPHATraceTaskDataIdentifier];
                    
                    [items addObject:item];
                    }
                
                section.items = items;
                
                model.sections = @[ section ];
                
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(model,nil);
                    });
                }
                
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[ALPHAManager defaultManager] displayNotificationWithMessage:[error localizedFailureReason] forDuration:1.5];
                });
                
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[ALPHAManager defaultManager] displayNotificationWithMessage:[error localizedFailureReason] forDuration:1.5];
            });
        }
        
    }];
    
    [task resume];
    

}

-(void) selectedRequest:(ALPHARequest *) request scene:(NSDictionary *) scene {
    
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    body[@"umid"] = @"huqin683";
    body[@"deviceinfo"] = [[UIDevice currentDevice] alpha_modelName];
    body[@"createtime"] = @([[NSDate date] timeIntervalSince1970]);
    body[@"appname"] = [NSBundle mainBundle].infoDictionary[@"CFBundleName"];//[[UIApplication sharedApplication] alpha_name];
    body[@"appversion"] = [[UIApplication sharedApplication] alpha_version];
    body[@"scene"] = scene[@"name"]?:@"";
    body[@"pkgname"] = [[UIApplication sharedApplication] alpha_bundleIdentifier];
    
    NSMutableString *urlString = [NSMutableString stringWithString:@"https://api.hisprintgo.com:8084/report-core/report/reportPerformance.do?"];
    for (NSString *k in [body allKeys]) {
        NSString *v = [NSString stringWithFormat:@"%@",body[k]];
        v = [v stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [urlString appendFormat:@"%@=%@&",k,v];
    }
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; charset=utf-8;boundary=%@",boundary];
    
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    req.timeoutInterval = 30;
    req.HTTPMethod = @"POST";

    NSURL *fileUrl = [NSURL fileURLWithPath:request.parameters[@"file"]];
//    req.HTTPBody = [[NSString stringWithFormat:@"file=%@",[fileUrl lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding];
//
    [[ALPHAManager defaultManager] displayNotificationWithMessage:[NSString stringWithFormat:@"Uploading %@",[fileUrl lastPathComponent]] forDuration:1.5];
    
    NSData *data = [self buildBodyDataWithPath:request.parameters[@"file"]];
    NSURLSessionUploadTask *task = [[NSURLSession sharedSession] uploadTaskWithRequest:req fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!error) {
                [[ALPHAManager defaultManager] removeViewControllerAnimated:YES completion:^{
                    [[ALPHAManager defaultManager] displayNotificationWithMessage:[NSString stringWithFormat:@"%@ Upload to %@",scene[@"name"],[fileUrl lastPathComponent]] forDuration:1.5];
                }];
            } else {
                [[ALPHAManager defaultManager] displayNotificationWithMessage:[error localizedFailureReason] forDuration:1.5];
            }
        });
        
    }];
    
//    NSURLSessionUploadTask *task = [[NSURLSession sharedSession] uploadTaskWithRequest:req fromFile:fileUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(!error) {
//                [[ALPHAManager defaultManager] removeViewControllerAnimated:YES completion:^{
//                    [[ALPHAManager defaultManager] displayNotificationWithMessage:[NSString stringWithFormat:@"%@ Upload to %@",scene[@"name"],[fileUrl lastPathComponent]] forDuration:1.5];
//                }];
//            } else {
//                [[ALPHAManager defaultManager] displayNotificationWithMessage:[error localizedFailureReason] forDuration:1.5];
//            }
//        });
//
//    }];
    
    [task resume];
    
    
}


-(NSData*)buildBodyDataWithPath:(NSString *)path{
    
    //创建可变字符串
    NSMutableString *bodyStr = [NSMutableString string];
    
    //1 access_token
//    [bodyStr appendFormat:@"--%@\r\n",boundary];//\n:换行 \n:切换到行首
//    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"access_token\""];
//    [bodyStr appendFormat:@"\r\n\r\n"];
//    [bodyStr appendFormat:@"%@\r\n",Access_Token];
    
    //2 stutas
//    [bodyStr appendFormat:@"--%@\r\n",boundary];//\n:换行 \n:切换到行首
//    [bodyStr appendFormat:@"Content-Disposition: form-data; name=\"status\""];
//    [bodyStr appendFormat:@"\r\n\r\n"];
//    [bodyStr appendFormat:@"%@\r\n",text];
    
    //3 pic
    /*
     --AaB03x
     Content-disposition: form-data; name="pic"; filename="file"
     Content-Type: application/octet-stream
     */
    [bodyStr appendFormat:@"--%@\r\n",boundary];
    [bodyStr appendFormat:@"Content-disposition: form-data; name=\"file\"; filename=\"%@\"",[path lastPathComponent]];
    [bodyStr appendFormat:@"\r\n"];
    [bodyStr appendFormat:@"Content-Type: application/octet-stream"];
    [bodyStr appendFormat:@"\r\n\r\n"];
    
    
    NSMutableData *bodyData = [NSMutableData data];
    
    //(1)startData
    NSData *startData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:startData];
    
    //(2)pic
    NSData *picdata  =[NSData dataWithContentsOfFile:path];
    [bodyData appendData:picdata];
    
    //(3)--Str--
    NSString *endStr = [NSString stringWithFormat:@"\r\n--%@--\r\n",boundary];
    NSData *endData = [endStr dataUsingEncoding:NSUTF8StringEncoding];
    [bodyData appendData:endData];
    
    
    return bodyData;
    
    
}

@end
