//
//  NSObject+LYAddProperty.m
//  LYRunTime
//
//  Created by 李岩 on 2019/5/3.
//  Copyright © 2019 李岩. All rights reserved.
//
#import <objc/runtime.h>
#import "NSObject+LYAddProperty.h"
#import <objc/message.h>

#define force_inline __inline__ __attribute__((always_inline))
static char const * kObservers = "kObservers";
static void * name = &name;

/**
 观察者信息
 */
@interface LYObserObjectInfo : NSObject
@property(nonatomic, copy) NSString * observerName;
@property(nonatomic, copy) NSString * observerKey;
@property(nonatomic, copy) OberverChangBlock changBlock;

-(instancetype)initWithName:(NSString *)name key:(NSString *)key Block:(OberverChangBlock)block;
@end

@implementation LYObserObjectInfo
-(instancetype)initWithName:(NSString *)name key:(NSString *)key Block:(OberverChangBlock)block{
    if (self = [super init]) {
        self.observerName = name;
        self.observerKey = key;
        self.changBlock = block;
    }
    return self;
}
@end
@implementation NSObject (LYAddProperty)

#pragma mark --添加属性的get和set方法
-(void)setName:(NSString *)name{
    objc_setAssociatedObject(self, &name, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)name{
    NSString * name = objc_getAssociatedObject(self, &name);
    return name;
}

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

#pragma mark --KVO
/**
 添加观察者
 
 @param object 观察者
 @param key 观察的key
 @param options 键值对
 @param block 发生变化回调
 */
-(void)ly_addObserver:(NSObject *)object forKey:(NSString *)key Options:(NSKeyValueObservingOptions)options ChangClock:(OberverChangBlock)block{
    NSString *setterStr = private_setterForKey(key);
    
    Method setterMethod = class_getInstanceMethod(self.class, NSSelectorFromString(setterStr));
    
    NSString *oldClassName = NSStringFromClass(self.class);
    NSString *kvoClassName = [@"FOFKVO_" stringByAppendingString:oldClassName];
    Class kvoClass;
    kvoClass = objc_lookUpClass(kvoClassName.UTF8String);
    if (!kvoClass) {
        kvoClass = objc_allocateClassPair(self.class, kvoClassName.UTF8String, 0);
        objc_registerClassPair(kvoClass);
    }
    
    
    if (setterMethod) {//直接调用setXX方法改变值
        class_addMethod(kvoClass,NSSelectorFromString(setterStr), (IMP)setterIMP, "v@:@");
    }else{//通过kvc改变值,通过method-swizzling
        Method method1 = class_getInstanceMethod(self.class, @selector(setValue:forKey:));
        Method method2 = class_getInstanceMethod(self.class, @selector(swizz_setValue:forKey:));
        method_exchangeImplementations(method1, method2);
    }
    object_setClass(self, kvoClass);
    LYObserObjectInfo *info = [[LYObserObjectInfo alloc] initWithName:object.description key:key Block:block];
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    if (!observers) {
        observers = [NSMutableArray array];
        objc_setAssociatedObject(self, kObservers, observers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [observers addObject:info];
    
}


/**
 移除观察者的制定key
 
 @param object 观察者
 @param key key description
 @param context context description
 */
-(void)ly_removeObserVer:(NSObject *)object forKey:(NSString *)key context:(NSString *)context{
    NSMutableArray <LYObserObjectInfo *>* observers = objc_getAssociatedObject(self, kObservers);
    
    __block LYObserObjectInfo *info;
    [observers enumerateObjectsUsingBlock:^(LYObserObjectInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.observerName isEqualToString:observers.description] && [obj.observerKey isEqualToString:key]) {
            info = obj;
        }
    }];
    if (info) {
        [observers removeObject:info];
    }else{
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"%@ does not register observer for %@",object.description,key] userInfo:nil];
    }
}

/**
 移除观察者
 
 @param object 观察者
 */
-(void)ly_removeObserver:(NSObject *)object{
    NSMutableArray* observers = objc_getAssociatedObject(self, kObservers);
    NSMutableArray *array = [NSMutableArray array];
    [observers enumerateObjectsUsingBlock:^(LYObserObjectInfo * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.observerName isEqualToString:observers.description]) {
            [array addObject:obj];
        }
    }];
    if (array.count) {
        [observers removeObjectsInArray:array];
    }
}

-(void)swizz_setValue:(id)value forKey:(NSString *)key{
    id oldValue = [self valueForKey:key];
    [self swizz_setValue:value forKey:key];//如果这里没报错，说明正常设置值，现在开始回调
    NSMutableArray *observers = objc_getAssociatedObject(self, kObservers);
    [observers enumerateObjectsUsingBlock:^(LYObserObjectInfo *  obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.observerKey isEqual:key]) {
            obj.changBlock(self, key, oldValue, value);
        }
    }];
    
}

void setterIMP(id self,SEL _cmd, id newValue){
    NSString * setterName = NSStringFromSelector(_cmd);
    //去除set，并将大写改为小写
    NSString * temp = private_UpperToLower([setterName substringFromIndex:@"set".length], 0);
    NSString * key = [temp substringToIndex:temp.length - 1];
    id oldValue = [self valueForKey:key];
    
    struct objc_super superClazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    ((void (*) (void *,SEL,id))objc_msgSendSuper)(&superClazz,_cmd,newValue);
    
    NSMutableArray * observers = objc_getAssociatedObject(self, kObservers);
    [observers enumerateObjectsUsingBlock:^(LYObserObjectInfo * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.observerKey isEqual:key]) {
            obj.changBlock(self, key, oldValue, newValue);
        }
    }];
    
}

#pragma mark --inline

static force_inline NSString * private_setterForKey(NSString *key){
    key = private_lowerToUpper(key, 0);
    return [NSString stringWithFormat:@"set%@",key];
}

static force_inline NSString * private_lowerToUpper(NSString *str, int location){
    NSRange rang = NSMakeRange(location, 0);
    NSString * lowerStr = [str substringWithRange:rang];
    return [str stringByReplacingCharactersInRange:rang withString:lowerStr.uppercaseString];
}

static force_inline NSString * private_UpperToLower(NSString *str, int location){
    NSRange rang = NSMakeRange(location, 1);
    NSString * upperStr = [str substringWithRange:rang];
    return [str stringByReplacingCharactersInRange:rang withString:upperStr.lowercaseString];;
}



-(NSString *)description{
    //这里改写了元类的方法，分类不管原理的问题，可以粗略理解是一个类的分支
    return @"LYAddProperty,添加属性";
}
@end
