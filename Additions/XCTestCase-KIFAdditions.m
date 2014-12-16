//
//  XCTestCase-KIFAdditions.m
//  KIF
//
//  Created by Tony DiPasquale on 12/9/13.
//
//

#import "XCTestCase-KIFAdditions.h"
#import "LoadableCategory.h"
#import <objc/runtime.h>

MAKE_CATEGORIES_LOADABLE(TestCase_KIFAdditions)

static inline void Swizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@interface XCTestCase ()
- (void)_recordUnexpectedFailureWithDescription:(id)arg1 exception:(id)arg2;
@end

@implementation XCTestCase (KIFAdditions)

- (void)failWithException:(NSException *)exception stopTest:(BOOL)stop
{
    self.continueAfterFailure = YES;
        NSLog(@"HDP··1111222");
    [self recordFailureWithDescription:exception.description inFile:exception.userInfo[@"SenTestFilenameKey"] atLine:[exception.userInfo[@"SenTestLineNumberKey"] unsignedIntegerValue] expected:NO];
    
    if (stop) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Swizzle([XCTestCase class], @selector(_recordUnexpectedFailureWithDescription:exception:), @selector(KIF_recordUnexpectedFailureWithDescription:exception:));
        });
        [exception raise];
    }
}

- (void)failWithExceptions:(NSArray *)exceptions stopTest:(BOOL)stop
{    NSLog(@"HDP·123123·");
    NSException *lastException = exceptions.lastObject;
    for (NSException *exception in exceptions) {
        [self failWithException:exception stopTest:(exception == lastException ? stop : NO)];
    }
}

- (void)KIF_recordUnexpectedFailureWithDescription:(id)arg1 exception:(NSException *)arg2
{
        NSLog(@"HDP··1234123412341234");
    if (![[arg2 name] isEqualToString:@"KIFFailureException"]) {
        [self KIF_recordUnexpectedFailureWithDescription:arg1 exception:arg2];
    }
}

@end

#ifdef __IPHONE_8_0

@interface XCTestSuite ()
- (void)_recordUnexpectedFailureForTestRun:(id)arg1 description:(id)arg2 exception:(id)arg3;
@end

@implementation XCTestSuite (KIFAdditions)

+ (void)load


{
    NSLog(@"HDP··54564567");
    Swizzle([XCTestSuite class], @selector(_recordUnexpectedFailureForTestRun:description:exception:), @selector(KIF_recordUnexpectedFailureForTestRun:description:exception:));
}

- (void)KIF_recordUnexpectedFailureForTestRun:(XCTestSuiteRun *)arg1 description:(id)arg2 exception:(NSException *)arg3
{
    NSLog(@"HDP··");
    if (![[arg3 name] isEqualToString:@"KIFFailureException"]) {
            NSLog(@"HDP··1");
        NSLog(@"arg2 %@",arg2);
        NSLog(@"arg3 %@",arg3);
        [self KIF_recordUnexpectedFailureForTestRun:arg1 description:arg2 exception:arg3];
    } else {
            NSLog(@"HDP··2");
        [arg1 recordFailureWithDescription:[NSString stringWithFormat:@"Test suite stopped on fatal error: %@", arg3.description] inFile:arg3.userInfo[@"SenTestFilenameKey"] atLine:[arg3.userInfo[@"SenTestLineNumberKey"] unsignedIntegerValue] expected:NO];
    }
}

@end

#endif