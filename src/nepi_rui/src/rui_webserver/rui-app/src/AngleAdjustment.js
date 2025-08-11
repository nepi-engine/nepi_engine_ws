/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React, { Component } from "react"
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
    flex: 2.25,
    textAlign: "right"
  }
})

@inject("ros")
class AngleAdjustment extends Component {
  constructor(props) {
    super(props)

    const { offset, total } = this.props
    this.state = {
      // offset and total are used by the sliders for their values
      offset: offset * 3.5,
      total: total * 3.5,
      // scaled offset and total are used for communicating with ROS messages
      scaled_offset: offset,
      scaled_total: total,
      // input offset and total are used for the input box in the UI
      input_offset: Math.round(offset * 100),
      input_total: Math.round(total * 100)
    }

    this.onOffsetChange = this.onOffsetChange.bind(this)
    this.onTotalChange = this.onTotalChange.bind(this)
    this.onOffsetInputChange = this.onOffsetInputChange.bind(this)
    this.onTotalInputChange = this.onTotalInputChange.bind(this)
    this.onOffsetSliderChange = this.onOffsetSliderChange.bind(this)
    this.onTotalSliderChange = this.onTotalSliderChange.bind(this)
    this.sendOffsetUpdate = this.sendOffsetUpdate.bind(this)
    this.sendTotalUpdate = this.sendTotalUpdate.bind(this)
    this.sendUpdate = this.sendUpdate.bind(this)
  }

  // Lifecycle function called right after component updates.
  // The params of this component can be changed so we need to
  // react when that happens.
  componentDidUpdate(prevProps, prevState, snapshot) {
    // get various fields from the new props values
    const { offset, total, disabled } = this.props

    // this tests to see if a Status3DX message updated our
    // values through the props
    if (
      prevProps.offset !== offset ||
      prevProps.total !== total ||
      (!disabled && prevProps.disabled)
    ) {
      this.setState({
        offset: offset * 3.5,
        total: total * 3.5,
        scaled_offset: offset,
        scaled_total: total,
        input_offset: Math.round(offset * 100),
        input_total: Math.round(total * 100)
      })
    }

    // this zeros out values if we go from enabled to disabled
    // this prop is used when we aren't tracking a 3DX Sensor
    // disabled grays out all the inputs and makes them uneditable
    if (disabled && prevProps.disabled !== disabled) {
      this.setState({
        offset: 0,
        total: 0,
        scaled_offset: 0,
        scaled_total: 0,
        input_offset: 0,
        input_total: 0
      })
    }
  }

  // functions for updating state when values change
  onOffsetChange(value) {
    this.setState({
      offset: value,
      scaled_offset: value / 3.5,
      input_offset: Math.round(value)
    })
  }
  onTotalChange(value) {
    this.setState({
      total: value,
      scaled_total: value / 3.5,
      input_total: Math.round(value)
    })
  }

  // Handlers for when the slider changes value
  onOffsetSliderChange(value) {
    this.onOffsetChange(value)
    this.sendOffsetUpdate(value, true)
  }
  onTotalSliderChange(value) {
    this.onTotalChange(value)
    this.sendTotalUpdate(value, true)
  }

  // Handlers for when the input boxes changes value
  onOffsetInputChange(event) {
    this.onOffsetChange(event.target.value)
    this.sendOffsetUpdate(event.target.value)
  }
  onTotalInputChange(event) {
    this.onTotalChange(event.target.value)
    this.sendTotalUpdate(event.target.value)
  }

  // Functions for sending value changes through rosbridge
  sendOffsetUpdate(value, throttled = false) {
    this.sendUpdate(value / 3.5, this.state.scaled_total, throttled)
  }
  sendTotalUpdate(value, throttled = false) {
    this.sendUpdate(this.state.scaled_offset, value / 3.5, throttled)
  }
  sendUpdate(offset, total, throttled = false) {
    this.props.ros.publishAngle3DX(this.props.topic, offset, total, throttled)
  }

  render() {
    return (
      <div style={{ display: "flex", ...styles.root }}>
        <Tooltip placement="bottomRight" overlay={this.props.tooltip}>
          <label style={styles.label}>{`Angle`}</label>
        </Tooltip>
        <Tooltip placement="top" overlay="Offset">
          <Input
            style={styles.input}
            value={this.state.input_offset}
            onChange={this.onOffsetInputChange}
            disabled={this.props.disabled}
          />
        </Tooltip>
        <Slider
          style={styles.slider}
          value={this.state.offset}
          onChange={this.onOffsetSliderChange}
          onAfterChange={this.sendOffsetUpdate}
          disabled={this.props.disabled}
          min={0}
          max={100}
          step={1}
          handle={handle}
        />
        <Tooltip placement="top" overlay="Total">
          <Input
            style={styles.input}
            value={this.state.input_total}
            onChange={this.onTotalInputChange}
            disabled={this.props.disabled}
          />
        </Tooltip>
        <Slider
          style={styles.slider}
          value={this.state.total}
          onChange={this.onTotalSliderChange}
          onAfterChange={this.sendTotalUpdate}
          disabled={this.props.disabled}
          min={0}
          max={100}
          step={1}
          handle={handle}
        />
      </div>
    )
  }
}

export default AngleAdjustment
