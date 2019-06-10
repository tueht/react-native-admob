//
//  RNTNativeAdView.m
//  PeriodicTable
//
//  Created by Hoang Trong Tue on 6/9/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import "RNTNativeAdView.h"
@import GoogleMobileAds;

@interface RNTNativeAdView()<GADUnifiedNativeAdLoaderDelegate,
                          GADVideoControllerDelegate,
                          GADUnifiedNativeAdDelegate>

@property(nonatomic, strong) GADAdLoader *adLoader;
@property(nonatomic, strong) GADUnifiedNativeAdView *nativeAdView;
@property(nonatomic) Boolean startedLoadAds;

@end

@implementation RNTNativeAdView

@synthesize startedLoadAds, adLoader;

- (instancetype)init
{
  self = [super init];
  if (self) {
    startedLoadAds = false;
    NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"UnifiedNativeAdView" owner:nil options:nil];
    GADUnifiedNativeAdView *nativeAdView = [nibObjects firstObject];
    [self addSubview:nativeAdView];
    self.nativeAdView = nativeAdView;
    [self.nativeAdView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_nativeAdView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_nativeAdView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDictionary]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_nativeAdView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewDictionary]];
  }
  return self;
}


-(void)setAdUnitId:(NSString *)adUnitId {
  _adUnitId = adUnitId;
  if (startedLoadAds && !adLoader) {
    [self refreshAd];
  }
}

-(void)refreshAd {
  startedLoadAds = true;
  if (_adUnitId) {
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    GADVideoOptions *videoOptions = [[GADVideoOptions alloc] init];
    adLoader = [[GADAdLoader alloc] initWithAdUnitID:_adUnitId
                                       rootViewController:rootViewController
                                                  adTypes:@[ kGADAdLoaderAdTypeUnifiedNative ]
                                                  options:@[ videoOptions ]];
    adLoader.delegate = self;
    GADRequest *request = [GADRequest request];
    request.testDevices = @[kGADSimulatorID];
    [adLoader loadRequest:request];
  }
}

-(void)setTextColor:(UIColor *)textColor {
  _textColor = textColor;
  
  [(UILabel *)[self.nativeAdView headlineView] setTextColor:textColor];
  [(UILabel *)[self.nativeAdView advertiserView] setTextColor:textColor];
  [(UILabel *)[self.nativeAdView bodyView] setTextColor:textColor];
  [(UILabel *)[self.nativeAdView priceView] setTextColor:textColor];
  [(UILabel *)[self.nativeAdView storeView] setTextColor:textColor];
}

-(void)setPrimaryTextColor:(UIColor *)primaryTextColor {
  _primaryTextColor = primaryTextColor;
  [(UIButton *)[self.nativeAdView callToActionView] setTintColor:primaryTextColor];
}

- (UIImage *)imageForStars:(NSDecimalNumber *)numberOfStars {
  double starRating = numberOfStars.doubleValue;
  if (starRating >= 5) {
    return [UIImage imageNamed:@"stars_5"];
  } else if (starRating >= 4.5) {
    return [UIImage imageNamed:@"stars_4_5"];
  } else if (starRating >= 4) {
    return [UIImage imageNamed:@"stars_4"];
  } else if (starRating >= 3.5) {
    return [UIImage imageNamed:@"stars_3_5"];
  } else {
    return nil;
  }
}

#pragma mark GADAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"%@ failed with error: %@", adLoader, error);
  //  self.refreshButton.enabled = YES;
}

#pragma mark GADUnifiedNativeAdLoaderDelegate implementation

- (void)adLoader:(GADAdLoader *)adLoader didReceiveUnifiedNativeAd:(GADUnifiedNativeAd *)nativeAd {
  //  self.refreshButton.enabled = YES;
  if (_onReceivedAd) {
    _onReceivedAd(nil);
  }
  
  GADUnifiedNativeAdView *nativeAdView = self.nativeAdView;
  //  GADUnifiedNativeAdView *nativeAdView = [self.bridge.uiManager viewForReactTag: reactTag];
  
  // Deactivate the height constraint that was set when the previous video ad loaded.
  //  self.heightConstraint.active = NO;
  
  nativeAdView.nativeAd = nativeAd;
  
  // Set ourselves as the ad delegate to be notified of native ad events.
  nativeAd.delegate = self;
  
  
  // Populate the native ad view with the native ad assets.
  // The headline and mediaContent are guaranteed to be present in every native ad.
  ((UILabel *)nativeAdView.headlineView).text = nativeAd.headline;
  nativeAdView.mediaView.mediaContent = nativeAd.mediaContent;
  
  // This app uses a fixed width for the GADMediaView and changes its height
  // to match the aspect ratio of the media content it displays.
  if (nativeAd.mediaContent.aspectRatio > 0) {
    //    self.heightConstraint =
    //    [NSLayoutConstraint constraintWithItem:nativeAdView.mediaView
    //                                 attribute:NSLayoutAttributeHeight
    //                                 relatedBy:NSLayoutRelationEqual
    //                                    toItem:nativeAdView.mediaView
    //                                 attribute:NSLayoutAttributeWidth
    //                                multiplier:(1 / nativeAd.mediaContent.aspectRatio)
    //                                  constant:0];
    //    self.heightConstraint.active = YES;
  }
  
  if (nativeAd.mediaContent.hasVideoContent) {
    // By acting as the delegate to the GADVideoController, this ViewController
    // receives messages about events in the video lifecycle.
    nativeAd.mediaContent.videoController.delegate = self;
    
    //    self.videoStatusLabel.text = @"Ad contains a video asset.";
  } else {
    //    self.videoStatusLabel.text = @"Ad does not contain a video.";
  }
  
  // These assets are not guaranteed to be present. Check that they are before
  // showing or hiding them.
  ((UILabel *)nativeAdView.bodyView).text = nativeAd.body;
  nativeAdView.bodyView.hidden = nativeAd.body ? NO : YES;
  
  [((UIButton *)nativeAdView.callToActionView) setTitle:nativeAd.callToAction
                                               forState:UIControlStateNormal];
  nativeAdView.callToActionView.hidden = nativeAd.callToAction ? NO : YES;
  
  ((UIImageView *)nativeAdView.iconView).image = nativeAd.icon.image;
  nativeAdView.iconView.hidden = nativeAd.icon ? NO : YES;
  
  ((UIImageView *)nativeAdView.starRatingView).image = [self imageForStars:nativeAd.starRating];
  nativeAdView.starRatingView.hidden = nativeAd.starRating ? NO : YES;
  
  ((UILabel *)nativeAdView.storeView).text = nativeAd.store;
  nativeAdView.storeView.hidden = nativeAd.store ? NO : YES;
  
  ((UILabel *)nativeAdView.priceView).text = nativeAd.price;
  nativeAdView.priceView.hidden = nativeAd.price ? NO : YES;
  
  ((UILabel *)nativeAdView.advertiserView).text = nativeAd.advertiser;
  nativeAdView.advertiserView.hidden = nativeAd.advertiser ? NO : YES;
  
  // In order for the SDK to process touch events properly, user interaction
  // should be disabled.
  nativeAdView.callToActionView.userInteractionEnabled = NO;
}

#pragma mark GADVideoControllerDelegate implementation

- (void)videoControllerDidEndVideoPlayback:(GADVideoController *)videoController {
  //  self.videoStatusLabel.text = @"Video playback has ended.";
}

#pragma mark GADUnifiedNativeAdDelegate

- (void)nativeAdDidRecordClick:(GADUnifiedNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidRecordImpression:(GADUnifiedNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillPresentScreen:(GADUnifiedNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillDismissScreen:(GADUnifiedNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdDidDismissScreen:(GADUnifiedNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)nativeAdWillLeaveApplication:(GADUnifiedNativeAd *)nativeAd {
  NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
