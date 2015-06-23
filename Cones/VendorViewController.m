//
//  ViewController.m
//  Cones
//
//  Created by Henry Chan & Alan Scarpa on 6/19/15.
//  Copyright (c) 2015 Henry Chan & Alan Scarpa. All rights reserved.
//

#import "VendorViewController.h"
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"
#import <Parse/Parse.h>


@interface VendorViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKUserLocation *currentVendorLocation;
@property (nonatomic, strong) PFObject *currentVendorData;

@end

#define METERS_PER_MILE 1609.344

@implementation VendorViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSString *vendorName = @"HenrysTruck";
    
    PFQuery *query = [PFQuery queryWithClassName:@"VendorLocationHistory"];
    
    [query whereKey:@"vendorName" equalTo:vendorName];
    
    // Retrieving user data here
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *vendorData, NSError *error){
        
        self.mapView.delegate = self; // Setting map view delegate
        
        if (vendorData){ // If an entry exists
            
            self.currentVendorData = vendorData; // Set our instance variable
            
            [self.mapView setShowsUserLocation:YES]; // Zoom into the user's current location
            
            
        } else {
            
            // Other wise we'll set up a new object to contain our new user data
            self.currentVendorData = [PFObject objectWithClassName:@"VendorLocationHistory"];
            
            self.currentVendorData[@"vendorName"] = vendorName;
            
            [self.currentVendorData saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    
                    [self.mapView setShowsUserLocation:YES]; // Zoom into our user AFTER we've saved the user
                    
                }
                 
            }];
            
        }
        
        NSLog(@"Error getting object: %@", error); // create new object

    }];
    
}

- (void) setCurrentVendorLocation:(MKUserLocation *)currentUserLocation {
    
    // Zooms in on user location only the first time it receives the user location
    if (!_currentVendorLocation) {
      
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentUserLocation.location.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
        
        [_mapView setRegion:viewRegion animated:YES];
        
        NSLog(@"Zooming into vendor's location");
        
    }
    
    _currentVendorLocation = currentUserLocation;
    
}

// Will only get called when user location updates are successful
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)vendorLocation{
    
    self.currentVendorLocation = vendorLocation;
    
    NSLog(@"Updating current user location to: %f, %f", vendorLocation.coordinate.latitude, vendorLocation.coordinate.longitude);
    
    [self sendVendorLocationToParse:vendorLocation.location];
    
}

-(void)sendVendorLocationToParse:(CLLocation*)vendorLocation {
    
    self.currentVendorData[@"geoPoint"] = [PFGeoPoint geoPointWithLatitude:vendorLocation.coordinate.latitude longitude:vendorLocation.coordinate.longitude];
    
    [self.currentVendorData saveInBackground];
    
}



@end
