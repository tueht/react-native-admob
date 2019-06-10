//
//  RNTNativeAdView.h
//  PeriodicTable
//
//  Created by Hoang Trong Tue on 6/9/19.
//  Copyright © 2019 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <React/RCTView.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNTNativeAdView : UIView

@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) UIColor *textColor;
@property (nonatomic, copy) UIColor *primaryTextColor;

@property (nonatomic, copy) RCTDirectEventBlock onReceivedAd;

-(void)refreshAd;

@end

NS_ASSUME_NONNULL_END
