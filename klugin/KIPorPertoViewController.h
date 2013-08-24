//
//  KIPorPertoViewController.h
//  klugin
//
//  Created by Jader Belarmino on 03/08/13.
//  Copyright (c) 2013 velum. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Foursquare2.h"
#import "FSVenue.h"
#import "FSConverter.h"

@interface KIPorPertoViewController : UITableViewController<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapaFS;
@property (strong,nonatomic)FSVenue* selected;
@property (strong,nonatomic)NSArray* nearbyVenues;

@end
