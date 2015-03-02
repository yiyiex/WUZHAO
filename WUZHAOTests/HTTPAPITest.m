//
//  HTTPAPITest.m
//  WUZHAO
//
//  Created by yiyi on 15/2/27.
//  Copyright (c) 2015年 yiyi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PIOSearchAPI.h"

@interface HTTPAPITest : XCTestCase

@end

@implementation HTTPAPITest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testAroundPlaceSearch
{
    
    [[PIOSearchAPI sharedInstance]SearchAroundPIOWithLongitude:23.5 Latitude:25.8 whenComplete:^(NSDictionary *returnData) {
        NSLog(@"%@",returnData);
        
        if ([returnData objectForKey:@"error_message"])
        {
            XCTAssert(YES,@"GOT DATA");
        }
        
        
    }];
    
}

@end