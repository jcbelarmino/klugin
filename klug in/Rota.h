//
//  Rota.h
//  klug in
//
//  Created by Jader Belarmino on 14/10/13.
//  Copyright (c) 2013 Velum. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PontoRota;

@interface Rota : NSManagedObject

@property (nonatomic, retain) NSString * destino;
@property (nonatomic, retain) NSNumber * idRota;
@property (nonatomic, retain) NSString * origem;
@property (nonatomic, retain) NSSet *pontosDaRota;
@end

@interface Rota (CoreDataGeneratedAccessors)

- (void)addPontosDaRotaObject:(PontoRota *)value;
- (void)removePontosDaRotaObject:(PontoRota *)value;
- (void)addPontosDaRota:(NSSet *)values;
- (void)removePontosDaRota:(NSSet *)values;

@end
