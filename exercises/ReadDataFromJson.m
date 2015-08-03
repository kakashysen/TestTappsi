//#########################################################################################################
//# Carga los datos desde un JSON a un Dictionay
//# Tiempo de desarrollo 1 hora
//######################################################################################################### 
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURL *urlJson = [NSURL URLWithString:@"https://raw.githubusercontent.com/tappsi/test_recruiting/master/sample_files/driver_info.json"];
    NSDictionary *jsonTaxiDrivers = [self retrieveDataFromURL:urlJson];
    
    NSLog(@"Taxistas: %@", [jsonTaxiDrivers description]);
}

/**
* @author japonte
* Obtiene los datos de un JSON y los carga dentro de un NSDictionary, si se genera algun error
* en la obtencion de la informacion el NSDictionary sera nil.
*/
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