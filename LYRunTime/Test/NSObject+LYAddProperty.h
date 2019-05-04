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
@property (copy, nonatomic)NSString * name;
@end

NS_ASSUME_NONNULL_END
