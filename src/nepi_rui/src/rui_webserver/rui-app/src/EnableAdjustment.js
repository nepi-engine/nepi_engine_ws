/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React, { Component } from "react"
import Toggle from "react-toggle"
import { inject } from "mobx-react"
import Slider from "rc-slider"
import Tooltip from "rc-tooltip"

import Styles from "./Styles"
import Input from "./Input"

// This "handle" is for adding a tooltip to the slider
import "rc-slider/assets/index.css"
import "rc-tooltip/assets/bootstrap.css"
const handle = props => {
  const { value, dragging, index, ...restProps } = props
  return (
    <Tooltip
      prefixCls="rc-slider-tooltip"
      overlay={value}
      visible={dragging}
      placement="top"
      key={index}
    >
      <Handle value={value} {...restProps} />
    </Tooltip>
  )
}
const Handle = Slider.Handle

const styles = Styles.Create({
  root: {
    marginTop: Styles.vars.spacing.regular
  },
  label: {
    flex: 1,
    textAlign: "left"
  },
  toggle: {
    marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.small,
    flex: 0.2,
    textAlign: "right"
  },
  input: {
    flex: 0.25,
    textAlign: "right",
    width: "2em",
    marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.small
  },
  slider: {
    marginTop: Styles.vars.spacing.xs,
    marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.small,
    flex: 3.3,
    textAlign: "right"
  }
})

@inject("ros")
class EnableAdjustment extends Component {
  constructor(props) {
    super(props)

    this.name = this.props.title.toLowerCase()

    this.state = {
      // state of the checkbox
      // props name enabled corresponds to the field in the
      // ros message
      checked: this.props.enabled,
      // value used by the input field and the slider
      value: Math.round(this.props.adjustment * 3.5),
      // scaled is for sending updates to the ROS message
      // adjustment is the field name in the ROS message
      scaled: this.props.adjustment
    }

    this.onToggle = this.onToggle.bind(this)
    this.onValueChange = this.onValueChange.bind(this)
    this.onSliderValueChange = this.onSliderValueChange.bind(this)
    this.onValueInputChange = this.onValueInputChange.bind(this)
    this.onValueAfterChange = this.onValueAfterChange.bind(this)
    this.sendUpdate = this.sendUpdate.bind(this)
  }

  // Lifecycle function called right after component updates.
  // The params of this component can be changed so we need to
  // react when that happens.
  componentDidUpdate(prevProps, prevState, snapshot) {
    // make various props variables local constants
    const { enabled, adjustment, disabled } = this.props

    // this tests to see if a Status3DX message updated our
    // values through the props
    if (
      this.state.checked !== enabled ||
      prevProps.enabled !== enabled ||
      prevProps.adjustment !== adjustment ||
      (!disabled && prevProps.disabled)
    ) {
      this.setState({
        checked: enabled,
        value: Math.round(adjustment * 3.5),
        scaled: adjustment
      })
    }

    // this zeros out values if we go from enabled to disabled
    // this prop is used when we aren't tracking a 3DX Sensor
    // disabled grays out all the inputs and makes them uneditable
    if (disabled && prevProps.disabled !== disabled) {
      this.setState({
        checked: false,
        value: 0,
        scaled: 0
      })
    }
  }

  // Handler for toggle switch changes
  onToggle(event) {
    // only do actions if we are not disabled
    if (!this.props.disabled) {
      // udpate the state
      this.setState({
        checked: event.target.checked
      })
      // send and update through ROS
      this.sendUpdate(event.target.checked, this.state.scaled)
    } else {
      // if whole element is disabled, toggle can't be checked
      this.setState({
        checked: false
      })
    }
  }

  // Handler for slider value changes
  onSliderValueChange(value) {
    this.onValueChange(value)
    this.sendUpdate(this.state.checked, value / 3.5, true)
  }

  // Function for updating state to new value
  onValueChange(value) {
    this.setState({
      value: Math.round(value),
      scaled: value / 3.5
    })
  }

  // Handler function for value changes through text input box
  onValueInputChange(event) {
    this.onValueChange(event.target.value)
    this.onValueAfterChange(event.target.value)
  }

  // Handler function called when user releases mouse on slider
  onValueAfterChange(value) {
    this.sendUpdate(this.state.checked, value / 3.5)
  }

  // Function for sending updated state through rosbridge
  sendUpdate(checked, value, throttle = false) {
    this.props.ros.publishAutoManualSelection3DX(
      this.props.topic,
      this.name,
      checked,
      value,
      throttle
    )
  }

  render() {
    return (
      <div style={{ display: "flex", ...styles.root }}>
        <Tooltip placement="bottomRight" overlay={this.props.tooltip}>
          <label style={styles.label}>{this.props.title}</label>
        </Tooltip>
        <Toggle
          style={styles.toggle}
          onClick={this.onToggle}
          checked={!this.props.disabled && this.state.checked}
          disabled={this.props.disabled}
        />
        <Input
          style={styles.input}
          disabled={this.props.disabled || !this.state.checked}
          value={this.state.value}
          onChange={this.onValueInputChange}
        />
        <Slider
          style={styles.slider}
          disabled={this.props.disabled || !this.state.checked}
          value={this.state.value}
          onChange={this.onSliderValueChange}
          onAfterChange={this.onValueAfterChange}
          min={0}
          max={100}
          step={1}
          handle={handle}
        />
      </div>
    )
  }
}

export default EnableAdjustment
