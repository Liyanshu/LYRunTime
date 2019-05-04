//
//  LYOtherTest.m
//  LYRunTime
//
//  Created by 李岩 on 2019/5/3.
//  Copyright © 2019 李岩. All rights reserved.
//

#import "LYOtherTest.h"
#import <objc/message.h>
@interface LYOtherTest();
@property (copy , nonatomic) NSString * otPrivateName;

@end

@implementation LYOtherTest

void runPace(id self, SEL _cmd, NSString *name, NSNumber *meter){
    NSLog(@"我叫%@,我今年%@,我在?",name,meter);
    // _cmd 表示当前方法的方法编号
    NSLog(@"%@",NSStringFromSelector(_cmd));
}

+(void)otClassMethod{
    NSLog(@"otClassMethod");
}
-(void)otPublicMethod{
    NSLog(@"otherTest中的公共对象方法");
}

-(void)otPrivateMethod{
    NSLog(@"otherTest中的室友方法");
}

+(BOOL)resolveClassMethod:(SEL)sel{
    if (sel == NSSelectorFromString(@"runPace:")) {
        class_addMethod(self, sel, (IMP)runPace, "v@:@@");
        return YES;
    }
    return [super resolveClassMethod:sel];
}
@end
