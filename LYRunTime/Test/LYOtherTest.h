//
//  LYOtherTest.h
//  LYRunTime
//
//  Created by 李岩 on 2019/5/3.
//  Copyright © 2019 李岩. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 不相关类
 */
@interface LYOtherTest : NSObject

@property (copy, nonatomic) NSString * otName;
@property (copy, nonatomic) NSString * otSex;

- (void)otPublicMethod;

+ (void)otClassMethod;
@end

NS_ASSUME_NONNULL_END
