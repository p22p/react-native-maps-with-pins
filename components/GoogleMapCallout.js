import React, { PropTypes } from 'react';
import {
  View,
  requireNativeComponent,
  StyleSheet,
} from 'react-native';

// eslint-disable-next-line react/prefer-es6-class
const GoogleMapCallout = React.createClass({
  propTypes: {
    ...View.propTypes,
    tooltip: PropTypes.bool,
    onPress: PropTypes.func,
  },

  getDefaultProps() {
    return {
      tooltip: false,
    };
  },

  render() {
    return <AIRGoogleMapCallout {...this.props} style={[styles.callout, this.props.style]} />;
  },
});

const styles = StyleSheet.create({
  callout: {
    position: 'absolute',
  },
});

const AIRGoogleMapCallout = requireNativeComponent('AIRGoogleMapCallout', GoogleMapCallout);

module.exports = GoogleMapCallout;
