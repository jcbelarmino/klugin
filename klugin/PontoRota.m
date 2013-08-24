//
//  PontoRota.m
//  klugin
//
//  Created by Jader Belarmino on 24/07/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import "PontoRota.h"
#import "Rota.h"


@implementation PontoRota

@dynamic geoText;
@dynamic lat;
@dynamic longi;
@dynamic marcador;
@dynamic ordem;
@dynamic tipo;
@dynamic erroHorizontal;
@dynamic minhaRota;

-(NSDictionary *)dictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys:self.ordem,@"ordem",
            self.lat,@"lat",
            self.longi,@"longi",
            self.tipo,@"tipo",
            self.erroHorizontal,@"erroHorizontal",
            self.marcador, @"marcador",
            self.geoText,@"geoText",nil];
}
@end
