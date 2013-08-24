//
//  Rota.h
//  klugin
//
//  Created by Jader Belarmino on 09/07/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PontoRota;

@interface Rota : NSManagedObject

@property (nonatomic, retain) NSString * destino;
@property (nonatomic, retain) NSString * origem;
@property (nonatomic, retain) NSSet *pontosDaRota;
@end

@interface Rota (CoreDataGeneratedAccessors)

- (void)addPontosDaRotaObject:(PontoRota *)value;
- (void)removePontosDaRotaObject:(PontoRota *)value;
- (void)addPontosDaRota:(NSSet *)values;
- (void)removePontosDaRota:(NSSet *)values;

@end
