//
//  LYOtherTest.m
//  LYRunTime
//
//  Created by 李岩 on 2019/5/3.
//  Copyright © 2019 李岩. All rights reserved.
//

#import "LYOtherTest.h"

@interface LYOtherTest();
@property (copy , nonatomic) NSString * otPrivateName;

@end

@implementation LYOtherTest

+(void)otClassMethod{
    NSLog(@"otClassMethod");
}
-(void)otPublicMethod{
    NSLog(@"otherTest中的公共对象方法");
}

-(void)otPrivateMethod{
    NSLog(@"otherTest中的室友方法");
}
@end
