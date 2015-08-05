//
//  ViewController.m
//  GPSDeviceTappsi
//
//  Created by Jose Aponte on 8/2/15.
//  Copyright (c) 2015 Jose Aponte. All rights reserved.
//

#import "ViewController.h"

@import GoogleMaps;

@interface ViewController ()

@end

@implementation ViewController
{
    CLLocationDegrees _latitude;
    CLLocationDegrees _longitude;
    NSMutableArray *totalPoints;
    BOOL isLocationCalculate;
    GMSMapView *_mapView;
    CLLocationCoordinate2D _centroid;
    GMSMutablePath *_path;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Inicializando el mapView
    GMSCameraPosition *camera = [GMSCameraPosition new] ;
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.myLocationEnabled = YES;
    self.view = _mapView;
    
    _path = [GMSMutablePath path];
    
    
    [self setupLocation];
    
    totalPoints =[NSMutableArray array];
    
    NSURL *urlJson = [NSURL URLWithString:@"https://raw.githubusercontent.com/tappsi/test_recruiting/master/sample_files/driver_info.json"];
    NSDictionary *jsonTaxiDrivers = [self retrieveDataFromURL:urlJson];
    
    NSLog(@"Taxistas: %@", [jsonTaxiDrivers description]);
    
    NSDictionary *bookings = [jsonTaxiDrivers objectForKey:@"bookings"];
    
    
    if (bookings != nil)
    {
        int  i = 0;
        for (NSDictionary *booking in bookings)
        {
            NSNumber *lat = [booking objectForKey:@"lat"];
            NSNumber *lon = [booking objectForKey:@"lon"];

            NSValue *point = [NSValue valueWithCGPoint:CGPointMake(lat.doubleValue, lon.doubleValue)];
            [totalPoints addObject:point];
            
            // Agregando marcadoes para cada posicion de los taxistas
            GMSMarker *marker = [[GMSMarker alloc] init];
            marker.position = CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue);
            marker.title = [booking objectForKey:@"booking_id"];
            marker.snippet = [booking objectForKey:@"neigborhood"];
            marker.map = _mapView;
            
            [_path addCoordinate:CLLocationCoordinate2DMake(lat.doubleValue, lon.doubleValue)];
            
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
        
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(_latitude, _longitude);
        marker.title = @"Device Location";
        marker.snippet = @"Device Location";
        marker.map = _mapView;
        
        [_path addCoordinate:CLLocationCoordinate2DMake(_latitude, _longitude)];
        
        NSLog(@"Latitud: %f", manager.location.coordinate.latitude);
        NSLog(@"Longitud: %f", manager.location.coordinate.longitude);
        
        NSValue *point = [NSValue valueWithCGPoint:CGPointMake(_latitude, _longitude)];
        [totalPoints addObject:point];
        
        [self centroidFromPoints:totalPoints];
        
        
        // Creando un marcador para el centroide
        GMSMarker *markerCentroid = [[GMSMarker alloc] init];
        markerCentroid.position = CLLocationCoordinate2DMake(_centroid.latitude, _centroid.longitude);
        markerCentroid.title = @"Centroid";
        markerCentroid.snippet = @"Centrorid";
        markerCentroid.map = _mapView;
        
        [_path addCoordinate:CLLocationCoordinate2DMake(_centroid.latitude, _centroid.longitude)];
        
        // Ajustando el zoom de la camara para que se visualicen todos los marcadores
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:_path];
        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
        [_mapView moveCamera:update];
        
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
    
    NSArray *result = [NSArray arrayWithObjects:[NSNumber numberWithDouble:centroidLatitud], [NSNumber numberWithDouble:centroidLongitud], nil];
    
    _centroid = CLLocationCoordinate2DMake(centroidLatitud, centroidLongitud);
    
    return result;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
