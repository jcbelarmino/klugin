//
//  KlugOrdenaPontosTest.m
//  klugin
//
//  Created by Jader Belarmino on 17/07/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import "KlugOrdenaPontosTest.h"
#import "PontoRota.h"
#import "Ordenador.h"

@implementation KlugOrdenaPontosTest{
    NSMutableSet *pontosDesordenados;
    NSArray *pontosOrdenados;
}
- (void)setUp {
    [super setUp];
    pontosDesordenados = [[NSMutableSet alloc] initWithCapacity:10];
    for (int i=1; i<=10; i++) {
        PontoRota *pr = [[PontoRota alloc] init];
        [pr setValue:[NSNumber numberWithInt:i%10] forKey:@"ordem"];
        [pontosDesordenados addObject:pr];
    }
    
}
- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}
-(void) testOrdenacao{
    pontosOrdenados = [Ordenador ordenaPontos:pontosDesordenados];
    int ordemPrimeiro = [[[pontosOrdenados objectAtIndex:1] ordem] intValue];
    int ordemUltimo = [[[pontosOrdenados objectAtIndex:10] ordem] intValue];
    STAssertEquals(ordemPrimeiro, 1, @"primeiro ponto tem ordem 1");
    
    STAssertEquals(ordemUltimo, 10, @"Decimo ponto tem ordem 10");
}
@end
