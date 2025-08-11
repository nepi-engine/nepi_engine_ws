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
import PropTypes from "prop-types"
import Toggle from "react-toggle"

import Styles from "./Styles"
import Input from "./Input"
import Select, {Option} from "./Select"
import {Column, Columns} from "./Columns"
import Label from "./Label"

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
  rootTight: {
    marginTop: 0
  },
  label: {
    flex: 1,
    textAlign: "left"
  },
  input: {
    flex: 0.5,
    textAlign: "left",
    width: "4em",
    marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.small,
    backgroundColor: Styles.vars.colors.white
  },
  slider: {
    flex: 1.5,
    marginTop: Styles.vars.spacing.xs,
    marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.small,
    textAlign: "right",
  },
  disabled_slider: {
    flex: 1.5,
    marginTop: Styles.vars.spacing.xs,
    marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.small,
    textAlign: "right",
    backgroundColor: Styles.vars.colors.default_dark    
  },
  vertical_slider: {
    flex: 0.2,
    marginTop: Styles.vars.spacing.xs,
    marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.small,
    textAlign: "right",    
  },
  invisible_slider_input: {
    flex: 1,
    textAlign: "left",
    width: "5em",
    //marginRight: Styles.vars.spacing.small,
    marginLeft: Styles.vars.spacing.small,
  },    
  invisible_slider: {
    marginTop: Styles.vars.spacing.xs,
    marginRight: Styles.vars.spacing.none,
    marginLeft: Styles.vars.spacing.none,
    flex: 0.05, // Must give it some horizontal extent or it always jumps to zero on selection
    textAlign: "left",
  },
  drop_down: {
    flex: 1,
    textAlign: "center"
  },
  drop_down_narrow:
  {
    flex: 0.88,
    textAlign: "center"
  }

})

// Function for sending updated state through rosbridge
function sendUpdate(props, new_value, throttle) {
  const noPrefix = (props.topic.startsWith('/'))
  const comp_name = props.comp_name ? props.comp_name : null
  if (comp_name != null) {
    props.ros.sendUpdateRatioMsg(props.topic,props.comp_name,new_value)
  }
  else {
    props.ros.publishValue(
      props.topic,
      props.msgType,
      new_value,
      throttle,
      noPrefix
    )
}
}

// Following constants control the SliderAdjustment acceleration. The logic is
// that each time at least THRESHOLD_COUNT adjustments are made within ACCEL_PERIOD_MS
// the step size is increased by a STEP_ACCEL_INCR incrementing factor. Everything is reset is after a quiescent
// period of ACCEL_PERIOD_MS or if the direction of update changes
const STEP_ACCEL_PERIOD_MS = 500 // 1/2 sec.
const STEP_ACCEL_THRESHOLD_COUNT = 10
const STEP_ACCEL_INCR = 1

@inject("ros")
class SliderAdjustment extends Component {
  propTypes = {
    // Component name if sending an UpdateRatioMsg
    comp_name: PropTypes.string,
    // Topic on which changes are published
    topic: PropTypes.string.isRequired,

    // Message type for adjustments
    msgType: PropTypes.string.isRequired,

    // View value for the adjustment component.
    adjustment: PropTypes.Number,

    // Specifies a mapping between displayed values and underlying data values
    stepMapping: PropTypes.objectOf(PropTypes.arrayOf(PropTypes.Number)), 

    // Indicates a multiplier value for the underlying data value before publishing the adjustement. Helpful for int-to-float conversions, etc.
    scaled: PropTypes.Number,

    // Min value of slider bar. Automaticly set to 0 if stepMapping is defined
    min: PropTypes.Number, 

    // Max value of slider bar. Automatically set to stepMapping.length - 1 if stepMapping is defined
    max: PropTypes.Number, 

    // Indicates whether discrete steps should be marked on slider bar
    markSteps: PropTypes.Bool, 

    // Indicates discrete step size for slider bar. Automatically set to 1 if stepMapping is defined
    step: PropTypes.Number,
    
    // Makes the slider invisible for keyboard/joystick controlled incrementers
    invisibleSlider: PropTypes.Bool,

    // Provides a suffix for the text box
    unit: PropTypes.string,

    // Reverse the direction of the slider, so that right/up decreases value
    reverse: PropTypes.Bool
  }
  
  defaultProps = {
    step: 1,
    markSteps: false,
    invisibleSlider: false,
    scaled: 1,
    unit: " ",
    reverse: false
  }

  constructor(props) {
    super(props)

    this.state = {
      step_accel: 0,
      step_accel_count: 0,
      last_update: new Date(),
      last_step_positive: true
    }


    const title = this.props.title
    
    this.name = (title)? title.toLowerCase() : "none"
    this.onSliderValueChange = this.onSliderValueChange.bind(this)
    this.marksFromStepMapping = this.marksFromStepMapping.bind(this)

    // Create an input reference for autofocus, etc. The parent can supply this as a prop 
    this.focusReference = this.props.autoFocusRef? this.props.autoFocusRef : React.createRef()
  }

  // Handler for slider value changes
  onSliderValueChange(new_value) {
    if (this.props.onSliderChangeOverride)
    {
      return this.props.onSliderChangeOverride(new_value)
    }
    
    var value_to_publish = (this.props.reverse === true)? ((this.props.max - new_value) * this.props.scaled) : (new_value * this.props.scaled)
    if (this.props.stepMapping)
    {
      if (this.props.publishStepIndex)
      {
        value_to_publish = new_value
      }
      else
      {
        value_to_publish = this.props.stepMapping[new_value]
      }
    }
    else if (this.props.acceleratingSlider)
    {
      // Need to handle acceleration here
      var now = new Date()
      var accelerator
      var accel_count             

      const roundingVal = (this.props.displayDecimals)? 10**this.props.displayDecimals : 1
      const prev_val = Math.round((this.props.adjustment/this.props.scaled) * roundingVal) / roundingVal
      
      const new_step_positive = (new_value > prev_val)
      const changed_direction = (this.state.last_step_positive !== new_step_positive)
     
      if ((now - this.state.last_update > STEP_ACCEL_PERIOD_MS) ||
          (changed_direction === true)){
        accelerator = 0
        accel_count = 0
      }
      else {
        if (this.state.step_accel_count > STEP_ACCEL_THRESHOLD_COUNT) {
          const incr = (new_step_positive === true)? STEP_ACCEL_INCR : -STEP_ACCEL_INCR
          accelerator = this.state.step_accel + incr // Increment/Decrement
          accel_count = 0 // Reset to track for the next increment/decrement
        }
        else {
          accelerator = this.state.step_accel
          accel_count = this.state.step_accel_count + 1          
        }
      }

      // Update state
      this.setState({step_accel: accelerator, 
                     step_accel_count: accel_count, 
                     last_update: now,
                     last_step_positive: new_step_positive})

      const scaled_accelerated_val = (new_value + accelerator) * this.props.scaled
      const scaled_max = this.props.max * this.props.scaled
      const scaled_min = this.props.min * this.props.scaled
      value_to_publish = Math.min(Math.max(scaled_accelerated_val, scaled_min), scaled_max) // Apply bounds
    }
    //sendUpdate(this.props, value_to_publish, true)
    sendUpdate(this.props, value_to_publish, false)
  }

  marksFromStepMapping() {
    var marks={}
    this.props.stepMapping.forEach((x,i) => marks[i] = "")
    return marks
  }

  render() {
    const { noMargin, displayDecimals } = this.props
    var roundingVal = (displayDecimals)? 10**displayDecimals : 1
    var marginStyle = (noMargin? {marginTop: 0} : null )
    var newSliderVal = this.props.stepMapping? 
      this.props.adjustment : Math.round((this.props.adjustment/this.props.scaled) * roundingVal) / roundingVal
    if (this.props.reverse === true) {
      newSliderVal = this.props.max - newSliderVal
    }

    var newInputVal = this.props.stepMapping?
      this.props.stepMapping[newSliderVal] : newSliderVal
    if (this.props.unit) {
      newInputVal = newInputVal.toString() + this.props.unit
    }

    var sliderStyle = styles.slider 
    var handleStyle = {} // Default
    var trackStyle = {} // Default
    var railStyle = {} // Default
    
    if (this.props.invisibleSlider) {
      sliderStyle = styles.invisible_slider
      handleStyle = {backgroundColor: Styles.vars.colors.default_dark, borderWidth: "0px"}
      trackStyle = {backgroundColor: Styles.vars.colors.default_dark, borderWidth: "0px"}
      railStyle = {backgroundColor: Styles.vars.colors.default_dark, borderWidth: "0px"}
    }
    else if (this.props.vertical) {
      sliderStyle = { ...styles.vertical_slider, height: this.props.verticalHeight }
    }
    else if (this.props.disabled) {
      handleStyle = {backgroundColor: Styles.vars.colors.default_dark}
      sliderStyle = styles.disabled_slider
    }

    return (
      <div style={{ display: "flex", ...styles.root, ...marginStyle}}>
        {(this.props.noLabel)?
          null :
          <Tooltip placement="bottomRight" overlay={this.props.tooltip}>
            <label style={styles.label}>{this.props.title}</label>
          </Tooltip>
        }
        <Slider
          ref={this.focusReference}
          style={sliderStyle}
          disabled={this.props.disabled}
          value={newSliderVal}
          onChange={this.onSliderValueChange}
          min={this.props.stepMapping? 0 : this.props.min}
          max={this.props.stepMapping? this.props.stepMapping.length - 1 : this.props.max}
          marks={(this.props.stepMapping && this.props.markSteps)? this.marksFromStepMapping() : this.props.marks}
          step={this.props.stepMapping? 1 : this.props.step}
          handle={(this.props.invisibleSlider === true)? undefined : handle}
          handleStyle={handleStyle}
          trackStyle= {trackStyle}
          railStyle={railStyle}
          vertical={this.props.vertical}
        />
        {(this.props.noTextBox)?
          null :
          <Input
            style={(this.props.invisibleSlider === true)? styles.invisible_slider_input : styles.input}
            disabled={true}
            value={newInputVal}
          />
        }
      </div>
    )
  }
}

@inject("ros")
class DropdownAdjustment extends Component {
  propTypes = {
    // Topic on which changes are published
    topic: PropTypes.string.isRequired,

    // Message type for adjustments
    msgType: PropTypes.string.isRequired,

    // View value for the adjustment component.
    adjustment: PropTypes.Number,
    
    // Text values for drop-down options: Indexed/Ordered by value to transmit on selection
    entries: PropTypes.array.isRequired
  }

  constructor(props) {
    super(props)

    this.name = this.props.title.toLowerCase()

    this.onSelectionChange = this.onSelectionChange.bind(this)
    this.createOptions = this.createOptions.bind(this)

    // Create an input reference for autofocus, etc. The parent can supply this as a prop 
    this.focusReference = this.props.autoFocusRef? this.props.autoFocusRef : React.createRef()
  }

  onSelectionChange(event) {
    sendUpdate(this.props, event.nativeEvent.target.selectedIndex, false)
  }

  // Function for creating topic options for Select input
  createOptions(option_text_array) {
    var items = []
    for (var option_text of option_text_array) {
      items.push(<Option>{option_text}</Option>)
    }
    return items
  }

  render() {
    const { noMargin } = this.props
    var marginStyle = (noMargin? {marginTop: 0} : null )
    return (
      <div style={{ display: "flex", ...styles.root, ...marginStyle}}>
        <Tooltip placement="bottomRight" overlay={this.props.tooltip}>
          <label style={styles.label}>{this.props.title}</label>
        </Tooltip>
        <Select
          ref={this.focusReference}
          id="topicSelect_0"
          onChange={this.onSelectionChange}
          value={this.props.entries[this.props.adjustment]}
          style={this.props.narrow? styles.drop_down_narrow : styles.drop_down}
        >
          {this.createOptions(this.props.entries)}
        </Select>
      </div>
    )
  }
}

@inject("ros")
class RadioButtonAdjustment extends Component {
  propTypes = {
    // Topic on which changes are published
    topic: PropTypes.string.isRequired,

    // Message type for adjustments
    msgType: PropTypes.string.isRequired,

    // View value for the adjustment component.
    adjustment: PropTypes.Number,
    
    // Text values for drop-down options: Indexed/Ordered by value to transmit on selection
    entries: PropTypes.array.isRequired
  }
    
  constructor(props) {
    super(props)
    this.generateRadioButton = this.generateRadioButton.bind(this)
  }

  generateRadioButton(i) {
    return (
      <Column>
      <div align={"left"} textAlign={"left"}>
        <Label title={this.props.entries[i]}/>
        <Toggle checked={this.props.adjustment === i} disabled={this.props.disabled} onClick={() => {sendUpdate(this.props, i, false)}}/>
      </div>
      </Column>      
    )
  }

  render() {
    var entry_radio_buttons = []
    for (var i = 0; i < this.props.entries.length; ++i) {
      entry_radio_buttons.push(this.generateRadioButton(i))
    }
    
    return (
        <Columns>
          <Column>
          <div align={"left"} textAlign={"left"}>
            <Label title={this.props.title}/>
          </div>
          </Column>
          {entry_radio_buttons}
        </Columns>
    )
  }
}

export {SliderAdjustment, DropdownAdjustment, RadioButtonAdjustment}

