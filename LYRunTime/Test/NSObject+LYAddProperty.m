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


-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self = [self init]) {
        unsigned int count = 0;
        objc_property_t * proList = class_copyPropertyList([self class], &count);
        for (int i = 0; i < count; i++) {
            const char * proChar = property_getName(proList[i]);
            NSString * key = [NSString stringWithUTF8String:proChar];
            id value = [dic objectForKey:key];
            if (value) {
                [self setValue:value forKey:key];
            }
        }
        
        free(proList);
    }
    return self;
}

// 解档所有属性
- (void)initAllPropertiesWithCoder:(NSCoder *)coder{
    unsigned int count = 0;
    objc_property_t * proList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i ++) {
        const char * proChar = property_getName(proList[i]);
        NSString * key = [NSString stringWithUTF8String:proChar];
        [coder decodeObjectForKey:key];
    }
}

// 归档所有属性
- (void)encodeAllPropertiesWithCoder:(NSCoder *)coder{
    unsigned int count = 0;
    objc_property_t * proList = class_copyPropertyList([self class], &count);
    for (int i = 0; i < count; i ++) {
        const char * proChar = property_getName(proList[i]);
        NSString * key = [NSString stringWithUTF8String:proChar];
        id value = [self valueForKey:key];
        [coder encodeObject:value forKey:key];
    }
}

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
