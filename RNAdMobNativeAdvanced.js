import React from 'react';
import {requireNativeComponent, View, findNodeHandle, UIManager, StyleSheet, LayoutAnimation} from 'react-native';
import PropTypes from 'prop-types';

class NativeAdView extends React.Component {
  componentDidMount() {
    UIManager.dispatchViewManagerCommand(
      findNodeHandle(this),
      UIManager.getViewManagerConfig('RNTNativeAdView').Commands.refreshAds,
      []
    );
  }

  render() {
    return <RNTNativeAdView {...this.props} />;
  }
}

NativeAdView.propTypes = {
  adUnitId: PropTypes.string,
  textColor: PropTypes.any,
  primaryTextColor: PropTypes.any,
  onReceivedAd: PropTypes.func
};

NativeAdView.defaultProps = {
  textColor: 'white',
  primaryTextColor: 'blue',
};

const RNTNativeAdView = requireNativeComponent('RNTNativeAdView', NativeAdView);

class AdMobNativeAdvanced extends React.PureComponent{
  constructor(props) {
    super(props);
    this.state = {
      adLoaded: false
    };
    this.onReceivedAd = this.onReceivedAd.bind(this);
  }

  onReceivedAd(){
    LayoutAnimation.configureNext(LayoutAnimation.Presets.spring);
    this.setState({
      adLoaded: true
    })
  };

  render() {
    const { containerStyle, height, style, ...others} = this.props;
    return <View style={containerStyle}>
      <NativeAdView onReceivedAd={this.onReceivedAd} style={[styles.adStyle, style, {height}, !this.state.adLoaded && styles.hiddenStyle]} {...others}/>
    </View>
  }
}

AdMobNativeAdvanced.propTypes = {
  height: PropTypes.number.isRequired
};

AdMobNativeAdvanced.defaultProps = {
  height: 250
};

const styles = StyleSheet.create({
  adStyle: {
    flex: 1,
    width: '100%'
  },
  hiddenStyle: {
    height: 33,
    opacity: 0,
    overflow: 'hidden'
  }
});

export default AdMobNativeAdvanced;
