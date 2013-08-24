//
//  PontoRota.h
//  klugin
//
//  Created by Jader Belarmino on 24/07/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Rota;

@interface PontoRota : NSManagedObject

@property (nonatomic, retain) NSString * geoText;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * longi;
@property (nonatomic, retain) NSString * marcador;
@property (nonatomic, retain) NSNumber * ordem;
@property (nonatomic, retain) NSString * tipo;
@property (nonatomic, retain) NSNumber * erroHorizontal;
@property (nonatomic, retain) Rota *minhaRota;

-(NSDictionary *)dictionary;

@end
