//#########################################################################################################
//# Obtener la posicion del dispositivo
//# tiempo de desarrollo 1.5 horas 
//######################################################################################################### 
- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupLocation];
}

/**
* @author japonte
* Configuracion y autorizacion para usar el GPS del dispositivo
*/
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
    }
}

/**
 * @author japonte
 * Recibe un arreglo de posiciones y calcula la posicion del centroide sobre estas posiciones dadas
 * @return NSArray de dos posiciones con las coordenadas del centroide latitud - longitud respectivamente
 */
-(NSArray*)centroidFromPoints:(CLLocationCoordinate2D[])points andNumberOfPoints:(int) numberOfPoints
{

    double longitudTotal, latitudTotal;
    double centroidLongitud, centroidLatitud;
    
    for (int i = 0; i < numberOfPoints; i++)
    {
        latitudTotal += points[i].latitude;
        longitudTotal += points[i].longitude;
    }
    
    centroidLatitud = latitudTotal / numberOfPoints;
    centroidLongitud = longitudTotal / numberOfPoints;
    
    NSLog(@"latitud: %f , longitud: %f", centroidLatitud, centroidLongitud);
    NSArray *result = [NSArray arrayWithObjects:[NSNumber numberWithDouble:centroidLatitud], [NSNumber numberWithDouble:centroidLongitud], nil];
    
    return result;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    _latitude = manager.location.coordinate.latitude;
    _longitude = manager.location.coordinate.longitude;

    CLLocationCoordinate2D points[4] = {0.f,0.f,0.0f};
    CLLocationCoordinate2D position = CLLocationCoordinate2DMake(4.703230, -74.028926);
    points[0] = position;
    position = CLLocationCoordinate2DMake(4.699359, -74.027681);
    points[1] = position;
    position = CLLocationCoordinate2DMake(4.699594, -74.034720);
    points[2] = position;
    position = CLLocationCoordinate2DMake(_latitude, _longitude);
    points[3] = position;


    NSArray *centroid = [self centroidFromPoints:points andNumberOfPoints:4];
}
