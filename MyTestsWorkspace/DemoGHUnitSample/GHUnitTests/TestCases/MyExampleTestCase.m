//
//  MyExampleTestCase.m
//  DemoGHUnitSample
//
//  Created by Song Zhipeng on 1/10/13.
//  Copyright (c) 2013 Song Zhipeng. All rights reserved.
//

#import "MyExampleTestCase.h"

@interface ClassA : NSObject
+ (int)calculate:(int)a and:(int)b;
@end

@implementation ClassA
+ (int)calculate:(int)a and:(int)b {
	return a+b;
}
@end

@interface ClassB : NSObject
- (NSString *)testString:(NSString *)aString;
@end

@implementation ClassB
- (NSString *)testString:(NSString *)aString {
	return [NSString stringWithFormat:@"new:%@",aString];
}
@end

@implementation MyExampleTestCase

#pragma mark -
//- (void)test2 {
//	id mock = [OCMockObject mockForClass:NSString.class];
//	[[mock stub] lowercaseString];
//	GHAssertThrows([mock uppercaseString],nil);
//}
//
//- (void)test3 {
//	id mock = [OCMockObject mockForClass:[ClassB class]];
//	[[[mock expect] andReturn:@"2"] testString:OCMOCK_ANY];
////	NSString *ret = [mock testString:@"1"];
////	GHAssertEqualStrings(ret, @"2", nil);
//	GHAssertThrows([mock verify],nil);
//}
//
//- (void)test1 {
//	id mock = [OCMockObject mockForClass:[ClassB class]];
//	[[[mock stub] andReturn:@"2"] testString:OCMOCK_ANY];
//	/*
//	 stub 构造接口返回信息，但不验证，expect和stub在实现上的区别是，在mockobject上有个expectations数组，expect后会把stub后的对象加到该数组，verify时候对expectations数组验证。
//	 */
//	
////	[[mock expect] testString:@"1"];//预期
//	
////	[mock testString:@"1"];
//	NSString *ret = [mock testString:@"1"];
//	GHAssertEqualStrings(ret, @"2", nil);
//
////	[mock testString:@"2"];//非预期的调用
//	
//	[mock verify];//验证
//}
//
//- (int)calculate:(int)a and:(int)b {
//	return [ClassA calculate:a and:b];
//}
//
//- (void)testCalculateAnd {
//	MyExampleTestCase *realObject = [[[MyExampleTestCase alloc] init] autorelease];
//    id mock = [OCMockObject partialMockForObject:realObject];
//	
//	int a=1,b=2;
//	int r=3;
//	
//	int returnValue = [mock calculate:a and:b];
//	GHAssertEquals(returnValue, r, nil);
//}
//
//- (void)testOCMockPass
//
//{
//	
//    id mock = [OCMockObject mockForClass:NSString.class];
//	
//    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
//	
//    
//	
//    NSString *returnValue = [mock lowercaseString];
//	
//    GHAssertEqualObjects(@"mocktest", returnValue,
//						 
//                         @"Should have returned the expected string.");
//	
//}
//
//- (void)testOCMockFail
//
//{
//	
////    id mock = [OCMockObject mockForClass:NSString.class];
////	
////    [[[mock stub] andReturn:@"mocktest"] lowercaseString];
////	
////    NSString *returnValue = [mock lowercaseString];
////	
////    GHAssertEqualObjects(@"thisIsTheWrongValueToCheck",
////						 
////                         returnValue, @"Should have returned the expected string.");
//	
//}
@end
