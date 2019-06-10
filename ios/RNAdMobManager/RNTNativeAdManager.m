//
//  RNTNativeAdManager.m
//  PeriodicTable
//
//  Created by Hoang Trong Tue on 6/9/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNTNativeAdManager.h"
#import <React/RCTUIManager.h>
#import <React/RCTConvert.h>

#import "RNTNativeAdView.h"

@interface RNTNativeAdManager ()
@end

@implementation RNTNativeAdManager

RCT_EXPORT_MODULE(RNTNativeAdView)

+(BOOL)requiresMainQueueSetup {
  return YES;
}

-(dispatch_queue_t) methodQueue{
  return dispatch_get_main_queue();
}

- (UIView *)view
{
  return [[RNTNativeAdView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(adUnitId, NSString)
RCT_EXPORT_VIEW_PROPERTY(textColor, UIColor)
RCT_EXPORT_VIEW_PROPERTY(primaryTextColor, UIColor)

RCT_EXPORT_VIEW_PROPERTY(onReceivedAd, RCTDirectEventBlock)


RCT_EXPORT_METHOD(refreshAds: (nonnull NSNumber *)reactTag) {
  dispatch_async(dispatch_get_main_queue(), ^{
    RNTNativeAdView *nativeAdView = (RNTNativeAdView *)[self.bridge.uiManager viewForReactTag:reactTag];
    if (!nativeAdView) {
      return;
    }
    [nativeAdView refreshAd];
  });
}


@end
