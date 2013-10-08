//
//  KIMainViewController.h
//  klug in
//
//  Created by Adriano Lemos on 12/09/13.
//  Copyright (c) 2013 Velum. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface KIMainViewController : UIViewController

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSMutableDictionary *pontosNotificadosAbaixo15;
@property (nonatomic, strong) NSMutableDictionary *pontosNotificados40para15;
@property (nonatomic, strong) NSMutableDictionary *pontosNotificados65para40;

@end
