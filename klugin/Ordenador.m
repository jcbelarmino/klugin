//
//  Ordenador.m
//  klugin
//
//  Created by Jader Belarmino on 17/07/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import "Ordenador.h"

@implementation Ordenador


+(NSArray *) ordenaPontos:(NSSet *)pontosDesordenados{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"ordem" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSMutableArray *pontosDaRotaOrdenado = [NSMutableArray arrayWithArray:[pontosDesordenados allObjects]];
    [pontosDaRotaOrdenado sortUsingDescriptors:sortDescriptors];
    return  pontosDaRotaOrdenado ;
}

@end
