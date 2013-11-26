//
//  KIAppDelegate.h
//  klug in
//
//  Created by Adriano Lemos on 12/09/13.
//  Copyright (c) 2013 Velum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KIMainViewController.h"

@interface KIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) KIMainViewController *mainViewController;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)openSession;

@end
