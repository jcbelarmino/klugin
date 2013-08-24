//
//  KlugAppDelegateTest.m
//  klugin
//
//  Created by Jader Belarmino on 05/07/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import "KlugAppDelegateTest.h"
#import "KIAppDelegate.h"


@implementation KlugAppDelegateTest{
    UIWindow *window;
    UINavigationController *navigationController;
    KIAppDelegate *appDelegate;
}

- (void)setUp {
    window = [[UIWindow alloc] init];
    navigationController = [[UINavigationController alloc] init];
    appDelegate = [[KIAppDelegate alloc] init];
    appDelegate.window = window;
    appDelegate.window.rootViewController = navigationController;
}
- (void)tearDown {
    window = nil;
    navigationController = nil;
    appDelegate = nil;
}
- (void)testWindowIsKeyAfterApplicationLaunch {
    [appDelegate application: nil didFinishLaunchingWithOptions: nil];
    //STAssertTrue(window.keyWindow,@"App delegate's window should be key");
}
- (void)testWindowHasRootNavigationControllerAfterApplicationLaunch {
    [appDelegate application: nil didFinishLaunchingWithOptions: nil];
    STAssertEqualObjects(window.rootViewController, navigationController,@"App delegate's navigation controller should be the root VC");
}
- (void)testAppDidFinishLaunchingReturnsYES {
    STAssertTrue([appDelegate application: nil didFinishLaunchingWithOptions: nil], @"Method should return YES");
}

@end
