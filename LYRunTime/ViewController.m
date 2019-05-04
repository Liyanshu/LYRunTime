//
//  ViewController.m
//  LYRunTime
//
//  Created by 李岩 on 2019/5/2.
//  Copyright © 2019 李岩. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSObject+LYAddProperty.h"
#import "LYOtherTest.h"

#define  LY_FREE(a) if(a){free(a);a=NULL;}
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
    
    LYOtherTest * otPro = [LYOtherTest new];
    
    //3.测试获取对象的方法类表
//    [self testGetMethods:otPro];
    
    //4.测试获取对象的属性列表
    
//    [self testGetPropertyList:otPro];
    
    //5.测试获取对象变量列表
//    [self testGetIvar:otPro];
//    NSLog(@"otName:%@",otPro.otName);
    
    //6.测试方法交换
    //    [LYOtherTest otClassMethod];
//    [self testMethodExchange:otPro];
    
    //7.测试动态添加方法
//    [otPro performSelector:NSSelectorFromString(@"runPace:") withObject:@"LY" withObject:@20];
    
//    objc_msgSend();
    objc_msgSend(otPro,@selector(otPublicMethod));
//    [otPro performSelector:@selector(run:) withObject:@10];
    
    //8.测试字典转模型
    NSDictionary * testDic = [NSDictionary dictionaryWithObjectsAndKeys:@"LiYan",@"otName",@"男",@"otSex",@"otPrivateName",@"otPrivateName", nil];
    LYOtherTest * testModel = [[LYOtherTest alloc] initWithDic:testDic];
    NSLog(@"testModelName:%@",testModel.otName);
    
    //9.测试归档
    NSString * path = [NSString stringWithFormat:@"%@/test.plist",NSHomeDirectory()];
    BOOL success = [NSKeyedArchiver archiveRootObject:testModel toFile:path];
    if (success) {
        NSLog(@"归档成功");
    }
    
    //10.测试解档
    LYOtherTest * testModel2 = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    NSLog(@"otName:%@",testModel2.otName);
}

/**
 测试获取对象方法列表（暂时没有找到获取实例方法的方法）
 */
-(void)testGetMethods:(id)test{
    
    const char * charName = class_getName([test class]);
    NSString * className = [NSString stringWithCString:charName encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@类中的方法如下：",className);
    unsigned int methodCount = 0;
    Method * method = class_copyMethodList([test class], &methodCount);
    
    //方法列表数组
    NSMutableArray <NSString *> * methodNameArr = [NSMutableArray arrayWithCapacity:methodCount];
    
    for (int i = 0; i < methodCount; i ++) {
        SEL methodSel = method_getName(method[i]);
        NSString * methodName = NSStringFromSelector(methodSel);
        [methodNameArr addObject:methodName];
        NSLog(@"方法:%d:%@",i,methodName);
    }
    
    //执行其中一个方法
    SEL cMethodSel = NSSelectorFromString(methodNameArr[0]);
    if ([test respondsToSelector:cMethodSel]) {
        //直接这样写会有警告，但不会有问题，已经进行过函数检测
//        [test performSelector:cMethodSel withObject:nil];
        
        //这种写法不会出现警告
        //得到函数指针
        IMP imp = [test methodForSelector:cMethodSel];
        //将函数指针进行转换
        void (*func)(id,SEL) = (void *)imp;
        func(test,cMethodSel);
        
        //    SEL selector = NSSelectorFromString(@"otPublicMethod");
        //    ((void (*)(id, SEL))[test methodForSelector:selector])(test, selector);
        
        //这种是有参数传入，以及有返回值的写法
//        SEL selector = NSSelectorFromString(@"processRegion:ofView:");
//        IMP imp = [_controller methodForSelector:selector];
//        CGRect (*func)(id, SEL, CGRect, UIView *) = (void *)imp;
//        CGRect result = _controller ?
//        func(_controller, selector, someRect, someView) : CGRectZero;
    }

}

/**
 获取对象属性列表

 @param test test description
 */
-(void)testGetPropertyList:(id)test{
    unsigned int proCount = 0;
    objc_property_t  * pro = class_copyPropertyList([test class], &proCount);
    for (int i = 0; i < proCount; i ++) {
        //获取属性名称
        const char * name  = property_getName(pro[i]);

        NSString * nameStr = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        NSLog(@"属性%d:%@",i,nameStr);
        
        //获取属性信息
        const char *attributes = property_getAttributes(pro[i]);
        NSLog(@"attributes:%@",[NSString stringWithUTF8String:attributes]);
    }
    free(pro);
}


/**
 获取对象中的变量列表

 @param test test description
 */
-(void)testGetIvar:(id)test{
    unsigned int count = 0;
    Ivar * ivars = class_copyIvarList([test class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar ivar = ivars[i];
        const char * ivarName = ivar_getName(ivar);
        const char * ivarType = ivar_getTypeEncoding(ivar);
        
        NSString * ivarNameStr = [NSString stringWithUTF8String:ivarName];
        NSString * ivarTypeStr = [NSString stringWithUTF8String:ivarType];
        
        ptrdiff_t ptr = ivar_getOffset(ivar);
        NSLog(@"变量：%@，变量类型：%@，变量:%td",ivarNameStr,ivarTypeStr,ptr);
        
        //这里通过变量名给变量赋值
        if ([ivarNameStr isEqual:@"_otName"]) {
            object_setIvar(test, ivar, @"这里是通过runtime给变量赋值");
        }
    }
    LY_FREE(ivars);
}

+(void)load{
    //这里也可以进行函数替换（注意每个位置替换的时序问题）
    Method meth = class_getClassMethod([LYOtherTest class], @selector(otClassMethod));
    Method methSe = class_getClassMethod(self, @selector(vcPublicMethod));
    method_exchangeImplementations(meth, methSe);
}
-(void)testMethodExchange:(id)test{
    IMP imp = [test methodForSelector:NSSelectorFromString(@"otPublicMethod")];
    void (*func) (id,SEL) = (void *)imp;
    func(test, NSSelectorFromString(@"otPublicMethod"));
}

+(void)vcPublicMethod{
    [ViewController vcPublicMethod];
    NSLog(@"这里是在ViewController中进行的函数替换");
}



-(NSString *)description{
    return @"ViewController";
}
@end
