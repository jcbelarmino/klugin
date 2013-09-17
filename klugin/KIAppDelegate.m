//
//  KIAppDelegate.m
//  klugin
//
//  Created by Jader Belarmino on 09/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import "KIAppDelegate.h"
#import "KRRotaViewController.h"
#import "KlugViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>
#import <sqlite3.h>

@implementation KIAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //impede o lock do celular
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [GMSServices provideAPIKey:@"AIzaSyDQN9g0LYVXkdqTcwMKgjP-Ca6Ci1xmgEQ"];
    // Create a location manager instance to determine if location services are enabled. This manager instance will be
    // immediately released afterwards.
    if (CLLocationManager.locationServicesEnabled == NO) {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Serviço de localização desabilitado" message:@"Todos os seus serviços de localização estão desabilitados." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    UIStoryboard *workoutSB = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    UINavigationController *navController = [workoutSB instantiateInitialViewController];

    
    //  The following two lines are used to create the view controllers when not using storyboards
    //    UYLCountryTableViewController *countryViewController = [[UYLCountryTableViewController alloc]
    //                                                            initWithNibName:@"UYLCountryTableViewController"
    //                                                            bundle:nil];
    //    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:countryViewController];
    
    self.window.rootViewController = navController;
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    UITableViewController *viewController = (UITableViewController *)[[tabBarController viewControllers] objectAtIndex:0];
    KlugViewController   *ondeEstouController = (KlugViewController *)viewController;
    ondeEstouController.managedObjectContext = self.managedObjectContext;
    
    UINavigationController *navigationController = (UINavigationController *)[[tabBarController viewControllers] objectAtIndex:1];
    KRRotaViewController   *rotaController = (KRRotaViewController *)navigationController.topViewController;
    rotaController.managedObjectContext = self.managedObjectContext;
    
    [self setupFourSquare];
    //[self playJingle];
   
    //limpa as 4 rotas default
    //[self limpaBase:self.managedObjectContext];
    //cadastra as 4 rotas default
    //[self initBase:self.managedObjectContext];
    
    self.window.backgroundColor = [UIColor yellowColor];
    [self.window makeKeyAndVisible];
   
    return YES;
}



- (void) setupFourSquare{
    [Foursquare2 setupFoursquareWithKey:@"L2F0UQ5M4VQLX0QC5BQABNZ4DJ3VFHOKPVXRFSVKTGL3RO1I"
                                 secret:@"V0MQN3ZGWEKXO2HFFD2JVXDXQOZZSN43F2ERFZBW2XKZXIKH"
                            callbackURL:@"http://www.velum.com.br"];

}

-(void) playJingle{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"jingle_teste" ofType: @"m4a"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    myAudioPlayer.numberOfLoops = 0;
    [myAudioPlayer play];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"klugrota" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"klugin.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
