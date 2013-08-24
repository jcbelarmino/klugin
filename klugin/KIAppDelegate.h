//
//  KIAppDelegate.h
//  klugin
//
//  Created by Jader Belarmino on 09/06/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <AVFoundation/AVFoundation.h>
#import "Foursquare2.h"

@class KIIincialViewController;

@interface KIAppDelegate : UIResponder <UIApplicationDelegate>
{
    AVAudioPlayer *myAudioPlayer;
}


@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) UIWindow *window;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;



@end
