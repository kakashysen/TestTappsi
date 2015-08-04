//
//  ViewController.m
//  GPSDeviceTappsi
//
//  Created by Jose Aponte on 8/2/15.
//  Copyright (c) 2015 Jose Aponte. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
{
    CLLocationDegrees _latitude;
    CLLocationDegrees _longitude;
    NSMutableArray *points;
    BOOL isLocationCalculate;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupLocation];
    
    points =[NSMutableArray array];
    
    NSURL *urlJson = [NSURL URLWithString:@"https://raw.githubusercontent.com/tappsi/test_recruiting/master/sample_files/driver_info.json"];
    NSDictionary *jsonTaxiDrivers = [self retrieveDataFromURL:urlJson];
    
    NSLog(@"Taxistas: %@", [jsonTaxiDrivers description]);
    
    NSDictionary *bookings = [jsonTaxiDrivers objectForKey:@"bookings"];
    
    //CLLocationCoordinate2D points[3] = {0.f,0.f,0.0f};
    
    

    
    if (bookings != nil)
    {
        int  i = 0;
        for (NSDictionary *booking in bookings)
        {
            NSNumber *lat = [booking objectForKey:@"lat"];
            NSNumber *lon = [booking objectForKey:@"lon"];
            
           // CLLocationCoordinate2D position = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
            //points[i] = position;
            NSValue *point = [NSValue valueWithCGPoint:CGPointMake(lat.doubleValue, lon.doubleValue)];
            [points addObject:point];
            
            i++;
        }
    }

}

// Configuracion de la localicacion y solicitud de permisos
// para usar el GPS del dispositivo
-(void)setupLocation
{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied)
    {
        NSLog(@"El usuario no autorizo el acceso al GPS");
    }
    else
    {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        
        if (status == kCLAuthorizationStatusNotDetermined)
        {
            [_locationManager requestWhenInUseAuthorization];
            status = [CLLocationManager authorizationStatus];
            
            if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied)
            {
                NSLog(@"El usuario no autorizo el acceso al GPS");
            }
        }
   
        [_locationManager startUpdatingLocation];
        
        NSLog(@"latitude: %f" , _latitude);
    }
}

// Calculando la posicion del dispositivo
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
 
    if (!isLocationCalculate)
    {
        _latitude = manager.location.coordinate.latitude;
        _longitude = manager.location.coordinate.longitude;
        
        NSLog(@"Latitud: %f", manager.location.coordinate.latitude);
        NSLog(@"Longitud: %f", manager.location.coordinate.longitude);
        
        NSValue *point = [NSValue valueWithCGPoint:CGPointMake(_latitude, _longitude)];
        [points addObject:point];
        
        [self centroidFromPoints:points];
        
        [_locationManager stopUpdatingLocation];
        
        isLocationCalculate = YES;
    }
    
}


// @author japonte
// Obtiene los datos de un JSON y los carga dentro de un NSDictionary, si se genera algun error
// en la obtencion de la informacion el NSDictionary sera nil.
-(NSDictionary*)retrieveDataFromURL:(NSURL*) urlJson
{
    NSData *data = [NSData dataWithContentsOfURL:urlJson];
    NSError *error = nil;
    NSDictionary *json = nil;
    
    
    if (data == nil)
    {
        NSLog(@"error [retriveDataFromURL] - No hay data");
        return nil;
    }
    
    json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    if (error != nil)
    {
        NSLog(@"error [retriveDataFromURL]: %@",[error description]);
        return nil;
    }
    
    return json;
    
}

#pragma mark - Calculate the Centroid of Array of coordinates

// @author japonte
// Recibe un arreglo de posiciones y calcula la posicion del centroide sobre estas posiciones dadas
// @return NSArray de dos posiciones con las coordenadas del centroide latitud - longitud respectivamente
-(NSArray*)centroidFromPoints:(NSArray*)points
{
    
    double longitudTotal, latitudTotal;
    double centroidLongitud, centroidLatitud;
    
    for (NSValue *value in points)
    {
        CGPoint point = [value CGPointValue];
        latitudTotal += point.x;
        longitudTotal += point.y;
    }
    
    
    centroidLatitud = latitudTotal / points.count;
    centroidLongitud = longitudTotal / points.count;
    
    NSLog(@"Centroide - latitud: %f , longitud: %f", centroidLatitud, centroidLongitud);
    NSArray *result = [NSArray arrayWithObjects:[NSNumber numberWithDouble:centroidLatitud], [NSNumber numberWithDouble:centroidLongitud], nil];
    
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
