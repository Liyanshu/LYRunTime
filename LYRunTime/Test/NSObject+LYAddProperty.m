//
//  NSObject+LYAddProperty.m
//  LYRunTime
//
//  Created by 李岩 on 2019/5/3.
//  Copyright © 2019 李岩. All rights reserved.
//
#import <objc/runtime.h>
#import "NSObject+LYAddProperty.h"

static void * name = &name;

@implementation NSObject (LYAddProperty)

-(void)setName:(NSString *)name{
    objc_setAssociatedObject(self, &name, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)name{
    NSString * name = objc_getAssociatedObject(self, &name);
    return name;
}
-(NSString *)description{
    //这里改写了元类的方法，分类不管原理的问题，可以粗略理解是一个类的分支
    return @"LYAddProperty,添加属性";
}
@end
