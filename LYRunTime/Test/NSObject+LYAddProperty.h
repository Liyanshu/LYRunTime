//
//  NSObject+LYAddProperty.h
//  LYRunTime
//
//  Created by 李岩 on 2019/5/3.
//  Copyright © 2019 李岩. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 测试使用runtime给分类添加属性
 */
@interface NSObject (LYAddProperty)

typedef void(^OberverChangBlock)(id observerObject,NSString * key ,id oldValue, id newValue);

@property (copy, nonatomic)NSString * name;

-(instancetype)initWithDic:(NSDictionary *)dic;

// 解档所有属性
- (void)initAllPropertiesWithCoder:(NSCoder *)coder;

// 归档所有属性
- (void)encodeAllPropertiesWithCoder:(NSCoder *)coder;


//实现KVO


/**
 添加观察者

 @param object 观察者
 @param key 观察的key
 @param options 键值对
 @param block 发生变化回调
 */
-(void)ly_addObserver:(NSObject *)object forKey:(NSString *)key Options:(NSKeyValueObservingOptions)options ChangClock:(OberverChangBlock)block;


/**
 移除观察者的制定key

 @param object 观察者
 @param key key description
 @param context context description
 */
-(void)ly_removeObserVer:(NSObject *)object forKey:(NSString *)key context:(NSString *)context;


/**
 移除观察者

 @param object 观察者
 */
-(void)ly_removeObserver:(NSObject *)object;


@end

NS_ASSUME_NONNULL_END
