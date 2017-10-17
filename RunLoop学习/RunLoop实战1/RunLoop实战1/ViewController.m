//
//  ViewController.m
//  RunLoop实战1
//
//  Created by xyj on 2017/9/27.
//  Copyright © 2017年 xyj. All rights reserved.
//

#import "ViewController.h"
#import "ZHThread.h"
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) ZHThread *thread;
@end

@implementation ViewController
/*
 知识点一:
 常驻线程:让一个线程永远不死
 通过继承NSThread并且从写delloc监听线程,可以看到,开启线程后执行完任务立马死掉
 注意:不能简单搞个属性强引用,因为线程一旦执行完毕,即使不释放掉,当前的线程也处于消亡状态,从新开启([self.thread start])会崩溃
 当然不通过start调用,通过performselector调用虽然不会崩溃,但是不会调用run2,因为线程处于消亡状态
 //解决办法:线程中添加runloop
 好处:可以随时让拿到这个线程让他做一些事情.没有做事情之前,这个runloop处于休眠状态,一旦调用该线程处理事件,就回唤醒runloop去执行该线程的事件
 使用:搞一个常驻线程监控联网状态
 原理:
 1.创建一个子线程并开启线程
 2.在开启方法(run)中添加一个runloop,并开启runloop
 3.runloop会一直跑圈不会执行完毕,阻止了开启方法的执行完毕即卡住子线程不让他执行完毕
 4.一旦子线程中有事件,runloop会被唤醒,让改事件在该线程中执行,一旦执行完毕,继续跑圈卡住该线程
 如果用一个死循环代替runloop是不可以的,因为死循环一直在处理这个事件,不会停下来先去执行触发事件
 */
- (void)viewDidLoad {
    [super viewDidLoad];
   self.thread = [[ZHThread alloc] initWithTarget:self selector:@selector(run) object:nil];
    //执行线程
     [self.thread start];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    //随时拿到这个子线程执行事件
    [self performSelector:@selector(run2) onThread:self.thread withObject:nil waitUntilDone:nil];
}
-(void)run{
    NSLog(@"=====run====");
    //run:默认为NSDefaultRunLoopMode模式,时间是永远,下面三行代码等价
    //往里面添加source(mode中啥都没有,runloop没用)
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
   //启动runloop
    [[NSRunLoop currentRunLoop] run];
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate distantFuture]];
    NSLog(@"永远不会调用======");
}
-(void)run2{
     NSLog(@"=====run2====");
}




//知识点二:在子线程搞个定时器一直调用
//创建子线程初始化调用这个方法
-(void)runx{
     @autoreleasepool {
    //创建定时器
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run2) userInfo:nil repeats:YES];
    //将定时器添加到runloop
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    //或者
//    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run2) userInfo:nil repeats:YES];
    //放在主线程中就不会用到这句,因为主线程一直在run,不用手动run
//    [[NSRunLoop currentRunLoop] run];
     }
}
//知识点:
- (void)test1 {
    //延迟3秒设置图片并且值只在NSDefaultRunLoopMode模式下
    [self.imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"123"] afterDelay:3.0 inModes:@[NSDefaultRunLoopMode]];
}
@end
