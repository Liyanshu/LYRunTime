//
//  ViewController.m
//  LYRunTime
//
//  Created by 李岩 on 2019/5/2.
//  Copyright © 2019 李岩. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "NSObject+LYAddProperty.h"
#import "LYOtherTest.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self test];
    // Do any additional setup after loading the view.
}

/**
 测试
 */
-(void)test{
    //1.这里测试给分类添加属性
    self.name = @"LiYan";
    NSLog(@"name:%@",self.name);
    
    //2.这里测试从写父类方法
    NSLog(@"%@",self.description);
    
    //3.测试获取类中的方法类表
    [self testGetMethods:[LYOtherTest new]];
}

/**
 测试获取方法列表
 */
-(void)testGetMethods:(id)test{
    const char * charName = class_getName([test class]);
    NSString * className = [NSString stringWithCString:charName encoding:NSUTF8StringEncoding];
    NSLog(@"%@类中的方法如下：",className);
    unsigned int methodCount = 0;
    Method * method = class_copyMethodList([test class], &methodCount);
    for (int i = 0; i < methodCount; i ++) {
        SEL methodSel = method_getName(method[i]);
        NSString * methodName = NSStringFromSelector(methodSel);
        NSLog(@"方法:%d:%@",i,methodName);
    }
    
    
//    SEL cMethodSel;
//    Method * cMethod = class_getClassMethod([], <#SEL  _Nonnull name#>)
}






-(NSString *)description{
    return @"ViewController";
}
@end
