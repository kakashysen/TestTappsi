//#########################################################################################################
//# Obtener la posicion del dispositivo
//# tiempo de desarrollo 1.5 horas 
//######################################################################################################### 
- (void)viewDidLoad {
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
* Obtiene la position del dispositivo
*/
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Latitud: %f", manager.location.coordinate.latitude);
    NSLog(@"Longitud: %f", manager.location.coordinate.longitude);
}