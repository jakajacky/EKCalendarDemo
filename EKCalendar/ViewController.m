//
//  ViewController.m
//  EKCalendar
//
//  Created by XiaoQiang on 2017/11/7.
//  Copyright © 2017年 XiaoQiang. All rights reserved.
//

#import "ViewController.h"
#import <EventKit/EventKit.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self customCalendarWithTitle:@"悦享趋势" Color:[UIColor blueColor]];
    
}

- (void)customCalendarWithTitle:(NSString *)title Color:(UIColor *)color {
    //事件库
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    //6.0及以上通过下面方式写入事件
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // the selector is available, so we must be on iOS 6 or newer
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    //错误细心
                    // display error message here
                }
                else if (!granted)
                {
                    //被用户拒绝，不允许访问日历
                    // display access denied error message here
                }
                else
                {
                    //创建事件
                    EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
                    event.title     = @"Jakajacky";
                    event.location = @"海淀王庄路";
                    
                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
                    event.startDate = [[NSDate alloc] init];
                    event.endDate   = [[NSDate alloc] init];
                    event.allDay = YES;
                    
                    //为事件Event添加提醒
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -60.0f * 24]];
                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -15.0f]];
                    
                    /**
                     * 已有日历类型（个人、工作、家庭、Foxmail、生日等等）
                     *
                     * NSArray *ek = [eventStore calendarsForEntityType:EKEntityTypeEvent];
                     * //设置日历类型
                     * [event setCalendar:ek[2]];
                     */
                    
                    // 自定义日历类型
                    BOOL shouldAdd = YES;
                    EKCalendar *calendar;
                    EKSource *localSource = nil;
                    for (EKCalendar *ekcalendar in [eventStore calendarsForEntityType:EKEntityTypeEvent]) {
                        if ([ekcalendar.title isEqualToString:title]) {
                            shouldAdd = NO;
                            calendar = ekcalendar;
                        }
                    }
                    if (shouldAdd) {
                        
                        for (EKSource *source in eventStore.sources) {
                            
                            if (source.sourceType == EKSourceTypeCalDAV && [source.title isEqualToString:@"iCloud"]) {
                                localSource = source;
                                break;
                            }
                        }
                        if (localSource == nil) {
                            for (EKSource *source in eventStore.sources) {
                                if (source.sourceType == EKSourceTypeLocal) {
                                    localSource = source;
                                    break;
                                }
                            }
                        }
                        
                        calendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:eventStore];
                        calendar.source = localSource;
                        calendar.title = title;
                        calendar.CGColor =color.CGColor;
                        // 创建新的自定义日历类型
                        NSError *error;
                        [eventStore saveCalendar:calendar commit:YES error:&error];
                    }
                    
                    // 为事件Event设置日历类型
                    [event setCalendar:calendar];
                    
                    // 设置事件
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                    UIAlertView *alert = [[UIAlertView alloc]
                                          initWithTitle:@"Event Created"
                                          message:@"事件添加成功！"
                                          delegate:nil
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
                    [alert show];
                    
                    NSLog(@"保存成功");
                }
            });
        }];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
