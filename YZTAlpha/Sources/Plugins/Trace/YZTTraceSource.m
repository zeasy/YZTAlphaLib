//
//  YZTTraceSource.m
//  YZTAlpha
//
//  Created by easy on 2019/3/12.
//  Copyright © 2019 easy. All rights reserved.
//

#import "YZTTraceSource.h"
#import "ALPHAFileManager.h"
#import "ALPHATableScreenModel.h"
NSString *const ALPHATraceDataIdentifier = @"com.yzt.data.trace";


@interface YZTTraceSource(){
    
}
@property (nonatomic, copy) NSArray *traces;

@property (nonatomic, strong) NSDateFormatter* dateFormatter;
@end
@implementation YZTTraceSource



- (instancetype)init
{
    self = [super init];
    
    if (self)
        {
        [self addDataIdentifier:ALPHATraceDataIdentifier];
        }
    
    return self;
}


- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter)
        {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterFullStyle;
        _dateFormatter.timeStyle = NSDateFormatterMediumStyle;
        }
    
    return _dateFormatter;
}


- (void)loadTraces
{
    NSError* error;
    
    NSString *directory = [NSString stringWithFormat:@"%@Alpha/Traces", [[ALPHAFileManager sharedManager] documentsDirectory].absoluteString];
    self.traces = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL URLWithString:directory] includingPropertiesForKeys:@[] options:0 error:&error];
}

- (ALPHAModel *)modelForRequest:(ALPHARequest *)request
{
    [self loadTraces];
    
    ALPHATableScreenModel* screenModel = [[ALPHATableScreenModel alloc] initWithIdentifier:ALPHATraceDataIdentifier];
    screenModel.title = @"Traces";
    
    ALPHAScreenSection* section = [[ALPHAScreenSection alloc] init];
    
    NSMutableArray* items = [NSMutableArray array];
    
    self.traces = [self.traces sortedArrayUsingComparator:^NSComparisonResult(NSURL *obj1, NSURL *obj2) {
        return [[obj2 lastPathComponent] compare:[obj1 lastPathComponent]];
    }];
    
    for (NSURL* trace in self.traces)
        {
        ALPHAScreenItem* item = [[ALPHAScreenItem alloc] init];
        item.title = [self titleForTrace:trace];
        item.object = trace;//[ALPHARequest requestForFile:trace.absoluteString];
        [items addObject:item];
        }
    
    section.items = items;
    
    screenModel.sections = @[ section ];
    
    return screenModel;
}

- (NSString *)titleForTrace:(NSURL *)trace
{
    NSString* filename = [trace.pathComponents lastObject];
    
    filename = [filename stringByReplacingOccurrencesOfString:@"ALPHA_TR_" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@".csv" withString:@""];
    
    NSDate *date = [[ALPHAFileManager sharedManager].fileDateFormatter dateFromString:filename];
    
    NSString *text = [self.dateFormatter stringFromDate:date];
    
    if (!text.length)
        {
        text = [trace.pathComponents lastObject];
        }
    
    return text;
}
@end
