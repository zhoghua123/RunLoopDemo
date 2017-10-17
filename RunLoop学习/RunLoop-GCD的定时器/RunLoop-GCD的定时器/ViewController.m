//
//  ViewController.m
//  RunLoop-GCD的定时器
//
//  Created by xyj on 2017/9/27.
//  Copyright © 2017年 xyj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
/** 定时器(这里不用带*，因为dispatch_source_t就是个类，内部已经包含了*) */
@property (nonatomic, strong) dispatch_source_t timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    //
    //    dispatch_after(when, dispatch_get_main_queue(), ^{
    //        NSLog(@"-------");
    //    });
}

int count = 0;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 获得队列
    //    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 创建一个定时器(dispatch_source_t本质还是个OC对象)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
    // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
    // 何时开始执行第一个任务
    // dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC) 比当前时间晚3秒
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    // 设置回调
    dispatch_source_set_event_handler(self.timer, ^{
        NSLog(@"------------%@", [NSThread currentThread]);
        count++;
        
                if (count == 4) {
                    // 取消定时器
                    dispatch_cancel(self.timer);
                    self.timer = nil;
                }
    });
    
    // 启动定时器
    dispatch_resume(self.timer);
}
@end
