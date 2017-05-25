//
//  kaisafaxUITests.m
//  kaisafaxUITests
//
//  Created by semny on 16/6/24.
//  Copyright © 2016年 kaisafax. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface kaisafaxUITests : XCTestCase

@end

@implementation kaisafaxUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testJumpAction
{
    
    XCUIApplication *app = app2;
    [app.buttons[@"\U8df3\U8fc7 3s"] tap];
    
    XCUIElement *table = [app.tables containingType:XCUIElementTypeStaticText identifier:@"- \U6295 \U8d44 \U6709 \U98ce \U9669  \U7406 \U8d22 \U9700 \U8c28 \U614e -"].element;
    [table tap];
    [table tap];
    [table tap];
    [table tap];
    [app.navigationBars[@"\U5468\U5e74\U4f73\U671f \U611f\U6069\U6709\U4f60 - \U4f73\U5146\U4e1a\U91d1\U670d\U5b98\U7f51 - \U5b89\U5168\U900f\U660e\U7684\U4e92\U8054\U7f51\U91d1\U878d\U5e73\U53f0\Uff0c\U4e13\U6ce8\U4e8e\U4ea7\U4e1a\U91d1\U878d\U548c\U793e\U533a\U91d1\U878d"].buttons[@"white left"] tap];
    
    XCUIElement *whiteLeftButton = app.navigationBars[@"\U4f73\U5146\U4e1a\U91d1\U670d\U5b98\U7f51 - \U5b89\U5168\U900f\U660e\U7684\U4e92\U8054\U7f51\U91d1\U878d\U5e73\U53f0\Uff0c\U4e13\U6ce8\U4e8e\U4ea7\U4e1a\U91d1\U878d\U548c\U793e\U533a\U91d1\U878d"].buttons[@"white left"];
    [whiteLeftButton tap];
    [whiteLeftButton tap];
    
    XCUIApplication *app2 = app;
    [app2.tables.buttons[@"\U7acb\U5373\U6295\U8d44"] tap];
    
    XCUIElement *textField = app.scrollViews.otherElements.scrollViews.otherElements.textFields[@"100\U5143\U8d77\U6295\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000"];
    [textField tap];
    [textField typeText:@"1"];
    [app2.keys[@"0"] tap];
    [textField typeText:@"000"];
    [app.toolbars.buttons[@"\U5b8c\U6210"] tap];
    [app.buttons[@"\U7acb\U5373\U6295\U8d44"] tap];
    
    XCUIElement *key = app2.keys[@"\U66f4\U591a\Uff0c\U6570\U5b57"];
    [key tap];
    [key tap];
    
    XCUIElement *secureTextField = [[[[[[[app.webViews.otherElements[@"\U6c47\U4ed8\U5929\U4e0b"] childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:4] childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1] childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:3] childrenMatchingType:XCUIElementTypeSecureTextField].element;
    [secureTextField typeText:@"123456"];
    [app2.buttons[@"Go"] tap];
    [secureTextField typeText:@"\n"];
    [[[[[[[[[[[[app childrenMatchingType:XCUIElementTypeWindow] elementBoundByIndex:0] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1].buttons[@"\U8fd4\U56de\U6295\U8d44\U5217\U8868"] tap];
    
}
@end
