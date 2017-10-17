//
//  ViewController.m
//  Runloop
//
//  Created by xyj on 2017/9/26.
//  Copyright © 2017年 xyj. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)action:(id)sender {
    NSLog(@"-----");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self function2];
    [self function3];
    
}
-(void)function3{
    
    // 创建observer
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"----监听到RunLoop状态发生改变---%zd", activity);
    });
    //添加观察者,监听runloop的状态
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    // 释放Observer
    CFRelease(observer);
    /*
     //需要自己管理内存
     CF的内存管理（Core Foundation）
     1.凡是带有Create、Copy、Retain等字眼的函数，创建出来的对象，都需要在最后做一次release
     * 比如CFRunLoopObserverCreate
     2.release函数：CFRelease(对象);
     */
}
-(void)function2{
    //知识点二:
    //向sb中拖入一个textView
    //    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(test) userInfo:nil repeats:YES];
    //上面一段代码做了很多事情,等价代码如下:
    //timer添加到defaultMode里面去,mode再添加到runloop中去,runloop在启动时候再指定这个mode->拿出timer来用
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(test) userInfo:nil repeats:YES];
    //也就说只能在Defaultmode下好使
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    //情况一:没有滚动textView时,1秒打印一次,一旦滚动textView,定时器无用了,停止滚动,定时器有起作用了
    //情况二:如果想要一滚动timer就有用,一停止滚动timer就失效,那么模式就用UITrackingRunLoopMode
    //     [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    //情况三:滚动不影响定时器
    //定时器只会跑在标记为CommonModes的模式下
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    //通过打印runloop,我们发现kCFRunLoopDefaultMode/UITrackingRunLoopMode这两种模式都被标记为了commonmodes标签了,因此就可以做到了
    NSLog(@"%@",[NSRunLoop currentRunLoop]);
}
-(void)function1{
    //知识点一:
        //当前线程就是主线程
        NSLog(@"%p--%p",[NSRunLoop mainRunLoop],[NSRunLoop currentRunLoop]);
        //创建一个线程
        NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
        [thread start];
}
- (void)test {
    NSLog(@"----");
}

-(void)run{
    /*
     [NSRunLoop currentRunLoop]:这就是在子线程中创建了一个runloop,不是通过alloc/init,创建是懒加载的
     通过MJ分析runloop(C语言)源码:
     创建runloop函数只有一个参数t:线程(这也说明一个runloop只有一个源码)
     _CFRunLoopGet0(pthread_t t) {
     1.如果t==kNilPthreadT(0的意思),那么t就等于主线程
     __CFRunLoops:本身是一个可变字典,用于存储所有的runloop,key值为线程,value为runloop
     __CFRunLoops :{
     mainthread : mainloop,
     thread1:loop1,
     ...
     }
     2.如果发现__CFRunLoops为空值
       2.1先创一个可变字典(就是__CFRunLoops)
       2.2根据主线程创建一个主runloop,即mainloop
       2.3将mainloop存入可变字典,key值为主线程
     3.根据传进来的线程到字典中拿到相应的runloop
     4.没有创建一个newloop->将newloop存入可变字典->返回这个newloop
     5.有就直接返回loop
     }
     */
    NSLog(@"%p",[NSRunLoop currentRunLoop]);
}

@end
