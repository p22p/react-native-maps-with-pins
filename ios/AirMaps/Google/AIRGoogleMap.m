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
//static double mercadorOffset = 268435456;

id cameraPositionAsJSON(GMSCameraPosition *position) {
  return @{
           @"latitude": [NSNumber numberWithDouble:position.target.latitude],
           @"longitude": [NSNumber numberWithDouble:position.target.longitude],
           @"zoom": [NSNumber numberWithDouble:position.zoom],
           };
}

@implementation AIRGoogleMap
{
  NSMutableArray<UIView *> *_reactSubviews;
}

- (instancetype)init
{
  if ((self = [super init])) {
    _reactSubviews = [NSMutableArray new];
    _markers = [NSMutableArray array];
  }
  return self;
}

- (void)insertReactSubview:(id<RCTComponent>)subview atIndex:(NSInteger)atIndex {
  // Our desired API is to pass up markers/overlays as children to the mapview component.
  // This is where we intercept them and do the appropriate underlying mapview action.
  if ([subview isKindOfClass:[AIRGoogleMapMarker class]]) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)subview;
    marker.realMarker.map = self;
    [self.markers addObject:marker];
  }
  [_reactSubviews insertObject:(UIView *)subview atIndex:(NSUInteger) atIndex];

  // TODO
  if (false) [super insertReactSubview:(UIView*)subview atIndex:atIndex];
}

- (void)removeReactSubview:(id<RCTComponent>)subview {
  // similarly, when the children are being removed we have to do the appropriate
  // underlying mapview action here.
  if ([subview isKindOfClass:[AIRGoogleMapMarker class]]) {
    AIRGoogleMapMarker *marker = (AIRGoogleMapMarker*)subview;
    marker.realMarker.map = nil;
    [self.markers removeObject:marker];
  }
  [_reactSubviews removeObject:(UIView *)subview];

  // TODO
  if (false) [super removeReactSubview:(UIView*)subview];
}

- (void)setInitialRegion:(MKCoordinateRegion)initialRegion {
  _initialRegion = initialRegion;

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
  id event = @{@"action": @"region-change",
               @"region": cameraPositionAsJSON(position),
               };
  if (self.onRegionChange) self.onRegionChange(event);
}

- (void)idleAtCameraPosition:(GMSCameraPosition *)position {
  id event = @{@"action": @"region-change-complete",
               @"region": cameraPositionAsJSON(position),
               };
  if (self.onRegionChangeComplete) self.onRegionChangeComplete(event);
}

@end
