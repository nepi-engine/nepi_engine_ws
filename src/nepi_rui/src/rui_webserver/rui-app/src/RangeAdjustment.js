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
// Range is a double ended slider
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
const createSliderWithTooltip = Slider.createSliderWithTooltip
const Range = createSliderWithTooltip(Slider.Range)
const Handle = Slider.Handle

const styles = Styles.Create({
  root: {
    marginTop: Styles.vars.spacing.regular
  },
  label: {
    flex: 1,
    textAlign: "left"
  },
  min_input: {
    flex: 0.2,
    textAlign: "right",
    width: "2em",
    marginRight: Styles.vars.spacing.xs,
    marginLeft: Styles.vars.spacing.small,
    backgroundColor: Styles.vars.colors.white
  },
  max_input: {
    flex: 0.2,
    textAlign: "right",
    width: "2em",
    marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.xs,
    backgroundColor: Styles.vars.colors.white
  },
  range: {
    flex: 1.5,
    marginTop: Styles.vars.spacing.xs,
    marginLeft: Styles.vars.spacing.small,
    marginRight: Styles.vars.spacing.small,
    textAlign: "right"
  },
  disabled_range: {
    flex: 1.5,
    marginTop: Styles.vars.spacing.xs,
    marginLeft: Styles.vars.spacing.small,
    marginRight: Styles.vars.spacing.small,
    textAlign: "right",
    backgroundColor: Styles.vars.colors.default_dark    
  }
})

@inject("ros")
class RangeAdjustment extends Component {
  constructor(props) {
    super(props)

    var { title, min, max, min_limit_m, max_limit_m} = this.props
    if (min > max) {
      // initalized invalid
      max = 1
      min = 0
    }

    const limit_range_m = max_limit_m - min_limit_m
    const min_m = (min * (limit_range_m)) + min_limit_m
    const min_m_str = parseFloat(min_m.toString()).toFixed(1) + (this.props.unit? this.props.unit : "")
    const max_m = (max * (limit_range_m)) + min_limit_m
    const max_m_str = parseFloat(max_m.toString()).toFixed(1) + (this.props.unit? this.props.unit : "")

    this.state = {
      title: title,
      // min and max values used by slider
      min: min * 3.5,
      max: max * 3.5,
      // scaled min and max for use in ROS messages
      scaled_min: min,
      scaled_max: max,
      // input min and max for input UI element (report range in meters)
      input_min: min_m_str,
      input_max: max_m_str
    }

    this.onSliderChange = this.onSliderChange.bind(this)
    this.onSliderAfterChange = this.onSliderAfterChange.bind(this)
    this.update = this.update.bind(this)
    this.updateTextBoxVals = this.updateTextBoxVals.bind(this)
    this.sendUpdate = this.sendUpdate.bind(this)
  }

  // Function for updating state when values change
  update(min, max) {
    if (min >= 0 && min <= 100 && max >= 0 && max <= 100) {

      this.setState({
        min: min,
        max: max,
        scaled_min: min / 3.5,
        scaled_max: max / 3.5,
      })
      this.updateTextBoxVals(min/3.5, max/3.5) // sets input_min and input_max
    }
  }

  updateTextBoxVals(min_ratio, max_ratio) {
    const {max_limit_m, min_limit_m} = this.props
    const limit_range_m = max_limit_m - min_limit_m
    const min_m = (min_ratio * (limit_range_m)) + min_limit_m
    const min_m_str = parseFloat(min_m.toString()).toFixed(1) + (this.props.unit? this.props.unit : "")
    const max_m = (max_ratio * (limit_range_m)) + min_limit_m
    const max_m_str = parseFloat(max_m.toString()).toFixed(1) + (this.props.unit? this.props.unit : "")

    this.setState({
      input_min: min_m_str,
      input_max: max_m_str
    })
  }

  // Lifecycle function called right after component updates.
  // The params of this component can be changed so we need to
  // react when that happens.
  componentDidUpdate(prevProps, prevState, snapshot) {
    // create local constants out of new(current) props values
    const { min, max, disabled } = this.props

    // this tests to see of a Status3DX message updated our values
    if (
      prevProps.min !== min ||
      prevProps.max !== max ||
      (!disabled && prevProps.disabled)
    ) {
      this.setState({
        min: min * 3.5,
        max: max * 3.5,
        scaled_min: min,
        scaled_max: max,
      })
      this.updateTextBoxVals(min, max)
    }

    // this zeros out values if we go from enabled to disabled
    // this prop is used when we are not tracking a 3DX Sensor
    // disabled grays out all the inputs and makes them uneditable
    if (disabled && prevProps.disabled !== disabled) {
      this.setState({
        min: 0,
        max: 0,
        scaled_min: 0,
        scaled_max: 0,
        input_min: 0,
        input_max: 0
      })
    }
  }

  // Handler for slider changing the values
  onSliderChange(values) {
    this.update(values[0], values[1])
    this.sendUpdate(values[0] / 3.5, values[1] / 3.5, true)
  }

  // Handler for when slider is released (mouse up)
  onSliderAfterChange(values) {
    this.sendUpdate(values[0] / 3.5, values[1] / 3.5)
  }

  // Function for publishing values through rosbridge
  sendUpdate(min, max, throttle = false) {
    const comp_name = this.props.comp_name ? this.props.comp_name : null
    if (comp_name != null) {
      this.props.ros.sendUpdateRangeWindowMsg(this.props.topic, comp_name, min, max, throttle)
    }
    else {
      this.props.ros.publishRangeWindow(this.props.topic, min, max, throttle)
    }
  }

  render() {
    return (
      <div style={{ display: "flex", ...styles.root }}>
        <Tooltip placement="bottomRight" overlay={this.props.tooltip}>
          <label style={styles.label}>{this.state.title}</label>
        </Tooltip>
        <Range
          style={this.props.disabled? styles.disabled_range : styles.range}
          value={[this.state.min, this.state.max]}
          onChange={this.onSliderChange}
          onAfterChange={this.onSliderAfterChange}
          disabled={this.props.disabled}
          handleStyle={this.props.disabled? {backgroundColor: Styles.vars.colors.default_dark} : {}}
          count={1}
          min={0}
          max={100}
          step={1}
          pushable={0.1}
          handle={handle}
        />
        <Tooltip placement="top" overlay="min">
          <Input
            style={styles.min_input}
            value={this.state.input_min}
            disabled={true}
          />
        </Tooltip>
        <Tooltip placement="top" overlay="max">
          <Input
            style={styles.max_input}
            value={this.state.input_max}
            disabled={true}
          />
        </Tooltip>
      </div>
    )
  }
}

export default RangeAdjustment
