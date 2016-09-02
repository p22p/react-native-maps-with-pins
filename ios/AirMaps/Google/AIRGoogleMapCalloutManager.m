//
//  AIRGoogleMapCalloutManager.m
//  AirMaps
//
//  Created by Gil Birman on 9/6/16.
//
//

#import "AIRGoogleMapCalloutManager.h"
#import "AIRGoogleMapCallout.h"
#import "RCTView.h"

@implementation AIRGoogleMapCalloutManager
RCT_EXPORT_MODULE()

- (UIView *)view
{
  AIRGoogleMapCallout *callout = [AIRGoogleMapCallout new];
  //  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleTap:)];
  //  // setting this to NO allows the parent MapView to continue receiving marker selection events
  //  tapGestureRecognizer.cancelsTouchesInView = NO;
  //  [marker addGestureRecognizer:tapGestureRecognizer];
  return callout;
}

RCT_EXPORT_VIEW_PROPERTY(tooltip, BOOL)
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)

@end
