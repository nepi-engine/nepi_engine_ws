/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React, { Component } from "react"
import { observer, inject } from "mobx-react"

import Section from "./Section"
import Button, { ButtonMenu } from "./Button"
import RangeAdjustment from "./RangeAdjustment"
import {RadioButtonAdjustment, SliderAdjustment} from "./AdjustmentWidgets"
import Toggle from "react-toggle"
import Label from "./Label"
import Input from "./Input"
import { Column, Columns } from "./Columns"
import Styles from "./Styles"


import { round, onUpdateSetStateValue, onEnterSetStateFloatValue,  } from "./Utilities"


import NepiIF3DTransform from "./Nepi_IF_3DTransform"

@inject("ros")
@observer

// Component that contains the NPX Device controls
class NepiDeviceNPXControls extends Component {
  constructor(props) {
    super(props)

    // these states track the values through NPX Status messages
    this.state = {
      frame3D: null,
      age_filter_s: null
    }


  }


  renderControls() {
    const { npxDevices, sendBoolMsg, sendTriggerMsg, setIdxControlsEnable, setIdxAutoAdjust, setFrame3D } = this.props.ros
    const namespace = this.props.namespace ? this.props.namespace : null
    const message = this.props.status_msg ? this.props.status_msg : null
    const capabilities = npxDevices[namespace] ? npxDevices[namespace] : null


    if (namespace != null && capabilities != null && message != null){
      const update_rate = message.update_rate
      const frame_3d = message.frame_3d
      const frame_nav = message.frame_nav
      const frame_altitude = message.frame_altitude
      const frame_depth = message.frame_depth
      const has_loc = message.has_location
      const has_head = message.has_heading
      const has_orien = message.has_orientation
      const has_pos = message.has_position
      const has_alt = message.has_altitude
      const has_depth = message.has_depth

      const has_transform = message.has_transform
      const updates = message.supports_updates
    
      return (
        <Section title={"NavPose Controls"}>
          
          <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Set System NavPose Source"}
         </label>

          <Columns equalWidth={true}>
            <Column>
                <div hidden={!has_loc}>    
                <ButtonMenu>   
                  <Button onClick={() => sendTriggerMsg(namespace + "/set_as_location_source")}>{"Location "}</Button>
                </ButtonMenu>
                </div>
                <div hidden={!has_pos}>  
                <ButtonMenu>   
                  <Button onClick={() => sendTriggerMsg(namespace + "/set_as_position_source")}>{"Position"}</Button>
                </ButtonMenu>
                </div>

                </Column>
                <Column>

                <div hidden={!has_head}>    
                <ButtonMenu>   
                  <Button onClick={() => sendTriggerMsg(namespace + "/set_as_heading_source")}>{"Heading"}</Button>
                </ButtonMenu>
                </div>

                <div hidden={!has_alt}>    
                <ButtonMenu>   
                  <Button onClick={() => sendTriggerMsg(namespace + "/set_as_altitude_source")}>{"Altitude"}</Button>
                </ButtonMenu>
                </div>

                </Column>
                <Column>

                <div hidden={!has_orien}>    
                <ButtonMenu>   
                  <Button onClick={() => sendTriggerMsg(namespace + "/set_as_orientation_source")}>{"Orientation"}</Button>
                </ButtonMenu>
                </div>

                <div hidden={!has_depth}>    
                <ButtonMenu>   
                  <Button onClick={() => sendTriggerMsg(namespace + "/set_as_depth_source")}>{"Depth"}</Button>
                </ButtonMenu>
                </div>

                </Column>
                </Columns>


          <Columns>
                  <Column>

                          <NepiIF3DTransform
                              namespace={namespace}
                              has_transform={has_transform}
                              supports_updates={updates}
                              title={"Nepi_IF_3DTransform"}
                          />

                  </Column>
            </Columns>



        </Section>
      )
    }
  }

  render() {
    return (
      <Columns>
        <Column>
          {this.renderControls()}
        </Column>
      </Columns>
    )
  }
}

export default NepiDeviceNPXControls