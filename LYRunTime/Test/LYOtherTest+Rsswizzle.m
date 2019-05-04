//
//  LYOtherTest+Rsswizzle.m
//  LYRunTime
//
//  Created by 李岩 on 2019/5/4.
//  Copyright © 2019 李岩. All rights reserved.
//

#import "LYOtherTest+Rsswizzle.h"
#import <objc/runtime.h>
@implementation LYOtherTest (Rsswizzle)

+(void)load{
    
    //替换实例方法
    Method meth = class_getClassMethod(self, @selector(otClassMethod));
    Method methSe = class_getClassMethod(self, @selector(testotClassMethod));

    method_exchangeImplementations(meth, methSe);
    
    //替换对象方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RSSwizzleInstanceMethod(self, @selector(otPublicMethod), RSSWReturnType(void), nil , RSSWReplacement({
            [self exOtPublicMethod];
            RSSWCallOriginal();
        }), RSSwizzleModeAlways, NULL);
    });
}

-(void)exOtPublicMethod{
     NSLog(@"这是替换的部分");
}

+(void)testotClassMethod{
    [LYOtherTest testotClassMethod];
    NSLog(@"testotClassMethod");
}
@end
