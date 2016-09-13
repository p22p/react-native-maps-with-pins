//
//  AIRGoogleMap.m
//  AirMaps
//
//  Created by Gil Birman on 9/1/16.
//

#import "AIRGoogleMap.h"
#import "AIRGoogleMapMarker.h"
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "RCTConvert+MapKit.h"
#import "UIView+React.h"

static double mercadorRadius = 85445659.44705395;

id cameraPositionAsJSON(GMSCameraPosition *position) {
  // todo: convert zoom to delta lat/lng
  return @{
           @"latitude": [NSNumber numberWithDouble:position.target.latitude],
           @"longitude": [NSNumber numberWithDouble:position.target.longitude],
           @"zoom": [NSNumber numberWithDouble:position.zoom],
           };
}

@implementation AIRGoogleMap
{
  NSMutableArray<UIView *> *_reactSubviews;
  BOOL _initialRegionSet;
}

- (instancetype)init
{
  if ((self = [super init])) {
    _reactSubviews = [NSMutableArray new];
    _markers = [NSMutableArray array];
    _initialRegionSet = false;
  }
  return self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)insertReactSubview:(id<RCTComponent>)subview atIndex:(NSInteger)atIndex {
  // Our desired API is to pass up markers/overlays as children to the mapview component.
  // This is where we intercept them and do the appropriate underlying mapview action.
  if ([subview isKindOfClass:[AIRGoogleMapMarker class]]) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)subview;
    marker.realMarker.map = self;
    [self.markers addObject:marker];
  }
  [_reactSubviews insertObject:(UIView *)subview atIndex:(NSUInteger) atIndex];
}
#pragma clang diagnostic pop


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-missing-super-calls"
- (void)removeReactSubview:(id<RCTComponent>)subview {
  // similarly, when the children are being removed we have to do the appropriate
  // underlying mapview action here.
  if ([subview isKindOfClass:[AIRGoogleMapMarker class]]) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)subview;
    marker.realMarker.map = nil;
    [self.markers removeObject:marker];
  }
  [_reactSubviews removeObject:(UIView *)subview];
}
#pragma clang diagnostic pop

- (void)setInitialRegion:(MKCoordinateRegion)initialRegion {
  if (_initialRegionSet) return;

  _initialRegion = initialRegion;
  _initialRegionSet = true;

  // TODO: move to some utility lib?
  static double maxGoogleLevels = -1.0;
  if (maxGoogleLevels < 0.0)
    maxGoogleLevels = log2(MKMapSizeWorld.width / 256.0);
  CLLocationDegrees longitudeDelta = initialRegion.span.longitudeDelta;
  CGFloat mapWidthInPixels = [UIScreen mainScreen].bounds.size.width; // TODO?: self.bounds.size.width;
  double zoomScale = longitudeDelta * mercadorRadius * M_PI / (180.0 * mapWidthInPixels);
  double zoomer = maxGoogleLevels - log2( zoomScale );
  if ( zoomer < 0 ) zoomer = 0;

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:initialRegion.center.latitude
                                                          longitude:initialRegion.center.longitude
                                                               zoom:zoomer];

  // TODO: why don't this work?
//  CLLocationCoordinate2D a = CLLocationCoordinate2DMake(initialRegion.center.latitude + initialRegion.span.latitudeDelta,
//                                                         initialRegion.center.longitude - initialRegion.span.longitudeDelta);
//  CLLocationCoordinate2D b = CLLocationCoordinate2DMake(initialRegion.center.latitude - initialRegion.span.latitudeDelta,
//                                                         initialRegion.center.longitude + initialRegion.span.longitudeDelta);
//  GMSCoordinateBounds *cBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:a coordinate:b];
//  GMSCameraPosition *c = [self cameraForBounds:cBounds insets:UIEdgeInsetsZero];

  self.camera = camera;

}

- (void)setRegion:(MKCoordinateRegion)region {
  _region = region;

  printf("LTTTTTT: %f\n", region.span.latitudeDelta);

  // TODO: move to some utility lib?
  static double maxGoogleLevels = -1.0;
  if (maxGoogleLevels < 0.0)
    maxGoogleLevels = log2(MKMapSizeWorld.width / 256.0);
  CLLocationDegrees longitudeDelta = region.span.longitudeDelta;
  CGFloat mapWidthInPixels = [UIScreen mainScreen].bounds.size.width; // TODO?: self.bounds.size.width;
  double zoomScale = longitudeDelta * mercadorRadius * M_PI / (180.0 * mapWidthInPixels);
  double zoomer = maxGoogleLevels - log2( zoomScale );
  if ( zoomer < 0 ) zoomer = 0;

  GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:region.center.latitude
                                                          longitude:region.center.longitude
                                                               zoom:zoomer];

  // TODO: why don't this work?
  //  CLLocationCoordinate2D a = CLLocationCoordinate2DMake(initialRegion.center.latitude + initialRegion.span.latitudeDelta,
  //                                                         initialRegion.center.longitude - initialRegion.span.longitudeDelta);
  //  CLLocationCoordinate2D b = CLLocationCoordinate2DMake(initialRegion.center.latitude - initialRegion.span.latitudeDelta,
  //                                                         initialRegion.center.longitude + initialRegion.span.longitudeDelta);
  //  GMSCoordinateBounds *cBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:a coordinate:b];
  //  GMSCameraPosition *c = [self cameraForBounds:cBounds insets:UIEdgeInsetsZero];

  self.camera = camera;
}

- (BOOL)didTapMarker:(GMSMarker *)marker {
  AIRGMSMarker *airMarker = (AIRGMSMarker *)marker;

  id event = @{@"action": @"marker-press",
               @"id": airMarker.identifier ?: @"unknown",
              };

  if (airMarker.onPress) airMarker.onPress(event);
  if (self.onMarkerPress) self.onMarkerPress(event);

  // TODO: not sure why this is necessary
  [self setSelectedMarker:marker];
  return NO;
}

- (void)didChangeCameraPosition:(GMSCameraPosition *)position {
  id event = @{@"continuous": @YES,
               @"region": cameraPositionAsJSON(position),
               };
  if (self.onChange) self.onChange(event);
}

- (void)idleAtCameraPosition:(GMSCameraPosition *)position {
  id event = @{@"continuous": @NO,
               @"region": cameraPositionAsJSON(position),
               };
  if (self.onChange) self.onChange(event);  // complete
}


- (void)setScrollEnabled:(BOOL)scrollEnabled {
  self.settings.scrollGestures = scrollEnabled;
}

- (BOOL)scrollEnabled {
  return self.settings.scrollGestures;
}

- (void)setZoomEnabled:(BOOL)zoomEnabled {
  self.settings.zoomGestures = zoomEnabled;
}

- (BOOL)zoomEnabled {
  return self.settings.zoomGestures;
}

- (void)setRotateEnabled:(BOOL)rotateEnabled {
  self.settings.rotateGestures = rotateEnabled;
}

- (BOOL)rotateEnabled {
  return self.settings.rotateGestures;
}

- (void)setPitchEnabled:(BOOL)pitchEnabled {
  self.settings.tiltGestures = pitchEnabled;
}

- (BOOL)pitchEnabled {
  return self.settings.tiltGestures;
}

- (void)setShowsTraffic:(BOOL)showsTraffic {
  self.trafficEnabled = showsTraffic;
}

- (BOOL)showsTraffic {
  return self.trafficEnabled;
}

- (void)setShowsBuildings:(BOOL)showsBuildings {
  self.buildingsEnabled = showsBuildings;
}

- (BOOL)showsBuildings {
  return self.buildingsEnabled;
}

- (void)setShowsCompass:(BOOL)showsCompass {
  self.settings.compassButton = showsCompass;
}

- (BOOL)showsCompass {
  return self.settings.compassButton;
}
@end
