//
//  Ordenador.m
//  klug in
//
//  Created by Adriano Lemos on 24/09/13.
//  Copyright (c) 2013 Velum. All rights reserved.
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
