//
//  ViewController.m
//  HeartRateMonitor
//
//  Created by Wouter Lemaire on 18/01/15.
//  Copyright (c) 2015 Wouter Lemaire. All rights reserved.
//

#import "ViewController.h"
#import "MultiplePulsingHaloLayer.h"

@import CoreLocation;

@interface ViewController ()
@property (nonatomic, weak) MultiplePulsingHaloLayer *multiHalo;
@property (weak, nonatomic) IBOutlet UILabel *pulseLabel;
@property (nonatomic, strong) IBOutlet UIButton    *pulseButton;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UISwitch *Status;

@end

@implementation ViewController {
    
}

@synthesize timer = _timer;
@synthesize myAudioPlayer;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.polarH7DeviceData = nil;
    
    //Create the Pulse effect
    [self.pulseButton setTitle:@"Searching ..." forState:UIControlStateNormal ];
    [self.pulseButton.titleLabel setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:28]];
    //self.pulseButton.titleLabel = self.pulseLabel;
    MultiplePulsingHaloLayer *multiLayer = [[MultiplePulsingHaloLayer alloc] initWithHaloLayerNum:3 andStartInterval:1];
    self.multiHalo = multiLayer;
    
    [self.multiHalo setPosition: self.pulseButton.titleLabel.center];
    //[self.multiHalo setPosition: self.pulseButton.center];
    [self.multiHalo setRadius: 400];
    UIColor *color = [UIColor colorWithRed:0
                                     green:0.487
                                      blue:1.0
                                     alpha:1.0];
    
    [self.multiHalo setHaloLayerColor:color.CGColor];
    //[multiLayer setPulseInterval: 6];
    
    [self.multiHalo buildSublayers];
    
    [self.pulseButton.layer addSublayer:self.multiHalo];
    
    //save to signleton of multiHalo
    [[SharedController getSharedController] setMultiHalo:self.multiHalo];
    
    // Scan for all available CoreBluetooth LE devices
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = centralManager;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //NSLog(@"%@", [locations lastObject]);
}
- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
        NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)oraPressed:(id)sender{
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"houston_problem" ofType: @"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    myAudioPlayer.numberOfLoops = -1; //infinite loop
    [myAudioPlayer play];
}

- (IBAction)stopMusic
{
    [myAudioPlayer stop];
}

- (IBAction)startMusic
{
    [myAudioPlayer play];
}


-(void)startMonitor{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10
                                                  target:self
                                                selector:@selector(sendHeartRateToCloud)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void)sendHeartRateToCloud{
    
    NSString * urlBaseString = [NSString stringWithFormat:@"https://heartrates0007035481trial.hanatrial.ondemand.com/HeartRateMonitor/?"];
    
    
    if ([[[SharedController getSharedController] Status ] isOn]) {
        //int lowerBound = 30;
        //int upperBound = 100;
        int rate = 0;
        //rate = lowerBound + arc4random() % (upperBound - lowerBound);
        rate = self.heartRate;
        //gps
        double latitude = self.locationManager.location.coordinate.latitude;
        double longitude = self.locationManager.location.coordinate.longitude;
        
        //unique identifier
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        
        //timestamp
        NSDate *currentDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *dateString = [dateFormatter stringFromDate:currentDate];
        
        NSString *seizure = @"false";
        
        //construct url
        NSString * urlActionString =
        [NSString stringWithFormat:
         @"action=addHeartrate&deviceid=%@&sendat=%@.000&rate=%d&longitude=%f&latitude=%f&seizure=%@",
         idfv,
         dateString,
         rate,
         longitude,
         latitude,
         seizure
         ];
        
        urlActionString = [urlActionString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString * urlString = [NSString stringWithFormat: @"%@%@", urlBaseString , urlActionString];
        
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        //create request
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Error,%@", [error localizedDescription]);
                 //[self.log setText:[@"Error\n" stringByAppendingString:text]];
             }
             else
             {
                 NSLog(@"OK ,%i", rate);
                 //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding]);
                 //[self.log setText:[@"Verzonden\n" stringByAppendingString:text]];
             }
         }];
        
    }
    
}
// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
        
        NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID], [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
        //NSArray *services = @[[CBUUID UUIDWithString:HEART_RATE_SERVICE]];
        [self.centralManager scanForPeripheralsWithServices:services options: nil];
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}

#pragma mark - CBCentralManagerDelegate

// method called whenever we have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.connected = [NSString stringWithFormat:@"Connected: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    
    self.Status = [[SharedController getSharedController] Status ] ;
    if ([self.Status isOn]) {
        [self startMonitor];
    }
}

#pragma mark CBPeripheralDelegate
// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if (![localName isEqual:@""]) {
        // We found the Heart Rate Monitor
        [self.centralManager stopScan];
        self.polarH7HRMPeripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID]])  {  // 1
        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Request heart rate notifications
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 2
                [self.polarH7HRMPeripheral setNotifyValue:YES forCharacteristic:aChar];
            }
            // Request body sensor location
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_UUID]]) { // 3
                [self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
            }
            //			else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_ENABLE_SERVICE_UUID]]) { // 4
            //				// Read the value of the heart rate sensor
            //				UInt8 value = 0x01;
            //				NSData *data = [NSData dataWithBytes:&value length:sizeof(value)];
            //				[peripheral writeValue:data forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
            //			}
        }
    }
    // Retrieve Device Information Services for the Manufacturer Name
    if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]])  { // 5
        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_UUID]]) {
                [self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a Device Manufacturer Name Characteristic");
            }
        }
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Updated value for heart rate measurement received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_NOTIFICATIONS_SERVICE_UUID]]) { // 1
        // Get the Heart Rate Monitor BPM
        [self getHeartBPMData:characteristic error:error];
    }
    // Retrieve the characteristic value for manufacturer name received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_UUID]]) {  // 2
        [self getManufacturerName:characteristic];
        //[[SharedController getSharedController] manufacturer];
    }
    // Retrieve the characteristic value for the body sensor location received
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_UUID]]) {  // 3
        [self getBodyLocation:characteristic];
    }
    
    // Add our constructed device information to our UITextView
    [[SharedController getSharedController] setBodyData: self.bodyData];
    [[SharedController getSharedController] setManufacturer:self.manufacturer];
    [[SharedController getSharedController] setConnected: self.connected];
    
}

#pragma mark - CBCharacteristic helpers
// Instance method to get the heart rate BPM information
- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Get the Heart Rate Monitor BPM
    NSData *data = [characteristic value];      // 1
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {          // 2
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));  // 3
    }
    // Display the heart rate value to the UI if no error occurred
    if( (characteristic.value)  || !error ) {   // 4
        self.heartRate = bpm;
        //[self.pulseButton.titleLabel setText:[NSString stringWithFormat:@"%i bpm", bpm]];
        [self.pulseButton setTitle:[NSString stringWithFormat:@"%i bpm", bpm] forState:UIControlStateNormal];
        [self.pulseButton.titleLabel setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:28]];
        
        [self doHeartBeat];
        self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
    }
    return;
}
// Instance method to get the manufacturer name of the device
- (void) getManufacturerName:(CBCharacteristic *)characteristic
{
    NSString *manufacturerName = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    self.manufacturer = [NSString stringWithFormat:@"Manufacturer: %@", manufacturerName];
    return;
}

// Instance method to get the body location of the device
- (void) getBodyLocation:(CBCharacteristic *)characteristic
{
    NSData *sensorData = [characteristic value];
    uint8_t *bodyData = (uint8_t *)[sensorData bytes];
    if (bodyData ) {
        uint8_t bodyLocation = bodyData[0];
        self.bodyData = [NSString stringWithFormat:@"Body Location: %@", bodyLocation == 1 ? @"Chest" : @"Undefined"];
    }
    else {
        self.bodyData = [NSString stringWithFormat:@"Body Location: N/A"];
    }
    return;
}




// instance method to stop the device from rotating - only support the Portrait orientation
- (NSUInteger) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
}

// instance method to simulate our pulsating Heart Beat
- (void) doHeartBeat
{
    
    //green
    if ((self.heartRate > 50) && (self.heartRate < 60) ) {
        UIColor *color = [UIColor colorWithRed:0
                                         green:1
                                          blue:0
                                         alpha:1.0];
        //[self.multiHalo setHaloLayerColor:color.CGColor];
        [[[SharedController getSharedController] multiHalo] setHaloLayerColor:color.CGColor];
        
        
    }
    //Yellow
    else if ((self.heartRate > 61) && (self.heartRate < 75) ){
        UIColor *color = [UIColor colorWithRed:1
                                         green:1
                                          blue:0
                                         alpha:1.0];
        [[[SharedController getSharedController] multiHalo] setHaloLayerColor:color.CGColor];
        
        
    }
    //Orange
    else if ((self.heartRate > 76) && (self.heartRate < 99) ){
        UIColor *color = [UIColor colorWithRed:1
                                         green:0.6
                                          blue:0
                                         alpha:1.0];
        [[[SharedController getSharedController] multiHalo] setHaloLayerColor:color.CGColor];
        
        
    }
    
    //Red
    else if ((self.heartRate > 100) && (self.heartRate < 200) ){
        UIColor *color = [UIColor colorWithRed:1
                                         green:0
                                          blue:0
                                         alpha:1.0];
        [[[SharedController getSharedController] multiHalo] setHaloLayerColor:color.CGColor];
        
    }
    //Blue
    else {
        UIColor *color = [UIColor colorWithRed:0
                                         green:0.487
                                          blue:1.0
                                         alpha:1.0];
        
        [[[SharedController getSharedController] multiHalo] setHaloLayerColor:color.CGColor];
        
    }
    
    
    //self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate) target:self selector:@selector(doHeartBeat) userInfo:nil repeats:NO];
    
}
@end
