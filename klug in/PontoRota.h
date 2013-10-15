//
//  PontoRota.h
//  klug in
//
//  Created by Jader Belarmino on 14/10/13.
//  Copyright (c) 2013 Velum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Rota;

@interface PontoRota : NSManagedObject

@property (nonatomic, retain) NSNumber * distanciaProxPonto;
@property (nonatomic, retain) NSNumber * erroHorizontal;
@property (nonatomic, retain) NSString * geoText;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * longi;
@property (nonatomic, retain) NSString * marcador;
@property (nonatomic, retain) NSNumber * ordem;
@property (nonatomic, retain) NSString * orientacao;
@property (nonatomic, retain) NSString * tipo;
@property (nonatomic, retain) Rota *minhaRota;

@end
