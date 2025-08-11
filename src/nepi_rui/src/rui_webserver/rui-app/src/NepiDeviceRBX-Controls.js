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
//import EnableAdjustment from "./EnableAdjustment"
import Button, { ButtonMenu } from "./Button"
import Label from "./Label"
import { Column, Columns } from "./Columns"
import Input from "./Input"
import Select, { Option } from "./Select"
import Styles from "./Styles"
import BooleanIndicator from "./BooleanIndicator"



import {convertStrToStrList, onEnterSetStateFloatValue, createMenuListFromStrList, onUpdateSetStateValue, onDropdownSelectedSetState} from "./Utilities"

@inject("ros")
@observer

// Component that contains RBX Controls
class NepiDeviceControls extends Component {
  constructor(props) {
    super(props)

    // these states track the values through  Status messages
    this.state = {
      show_process_controls: true,

      current_lat: null,
      current_long: null,
      current_altitude: null,
      current_heading: null,
      current_roll: null,
      current_pitch: null,
      current_yaw: null, 
      process_current: null,
      process_last: null,
      ready: null,
      battery: null,
      errors_current: [0,0,0,0,0,0,0],
      errors_prev: [0,0,0,0,0,0,0],
      cmd_success: null,
      manual_ready: null,
      autonomous_ready: null,
      last_cmd_str: null,
      last_error_message: null,

      rbx_capabilities: null,
      has_battery_feedback: null,
      has_motor_controls: null,
      has_autonomous_controls: null,
      has_set_home: null,
      has_go_home: null,
      has_go_stop: null,
      has_goto_pose: null,
      has_goto_position: null,
      has_goto_location: null,
      has_fake_gps: null,

      action_options: null,
      data_products: null,

      controls_type_list: null,
      controls_type_menu: null,
      selected_control_type: null,

      controls_auto_list: null,
      controls_auto_menu: null,
      selected_auto_control: null,
      actions_list: null,
      actions_menu: null,
      selected_go_action: null,
      selected_go_action_index: 0,
    
 
      controlsStatusListener : null,

      roll_deg: 0,
      pitch_deg: 0,
      yaw_deg_pose: 0,

      x_meters: 0,
      y_meters: 0,
      z_meters: 0,
      yaw_deg_position: 0,

      location_lat: 0,
      location_long: 0,
      altitude_meters: 0,
      yaw_deg_location: 0,

    }


    this.updateControlsStatusListener = this.updateControlsStatusListener.bind(this)
    this.controlsStatusListener = this.controlsStatusListener.bind(this)

    this.onDropdownSelectedAction = this.onDropdownSelectedAction.bind(this)
    this.sendGoActionIndex = this.sendGoActionIndex.bind(this)
    this.setLocationToCurrent = this.setLocationToCurrent.bind(this)
  }



  // Callback for handling ROS Status messages
  controlsStatusListener(message) {
    const {rbxDevices} = this.props.ros
    this.setState({
      current_lat: message.current_lat ,
      current_long: message.current_long ,
      current_altitude: message.current_altitude ,
      current_heading: message.current_heading ,
      current_roll: message.current_roll ,
      current_pitch: message.current_pitch ,
      current_yaw: message.current_yaw , 
      process_current: message.process_current ,
      process_last: message.process_last ,
      ready: message.ready ,
      battery: message.battery ,
      errors_current_x:[message.errors_current.x_m],
      errors_current_y:[message.errors_current.y_m],
      errors_current_z:[message.errors_current.z_m],
      errors_current_heading_deg:[message.errors_current.heading_deg],
      errors_current_roll_deg:[message.errors_current.roll_deg],
      errors_current_pitch_deg:[message.errors_current.pitch_deg],
      errors_current_yaw_deg: [message.errors_current.yaw_deg],
      errors_prev: [message.errors_prev.x_m ,message.errors_prev.x_m, message.errors_prev.x_m, message.errors_prev.heading_deg, message.errors_prev.roll_deg, message.errors_prev.pitch_deg, message.errors_prev.yaw_deg],
      cmd_success: message.cmd_success ,
      manual_ready: message.manual_motor_control_mode_ready ,
      autonomous_ready: message.autonomous_control_mode_ready ,

      last_cmd_str: message.last_cmd_string ,
      last_error_message: message.last_error_message 
    })
    if (this.state.rbx_capabilities === null){
      const capabilities = rbxDevices[this.props.rbxNamespace]
      if (capabilities){
        const actions=convertStrToStrList(capabilities.action_options)
        const actions_menu_options=createMenuListFromStrList(actions,false,[],[],[])
        
        this.setState({ 
          rbx_capabilities: capabilities,
          has_battery_feedback: capabilities.has_battery_feedback,
          has_motor_controls: capabilities.has_motor_controls,
          has_autonomous_controls: capabilities.has_autonomous_controls,
          has_set_home: capabilities.has_set_home,
          has_go_home: capabilities.has_go_home,
          has_go_stop: capabilities.has_go_stop,
          has_goto_pose: capabilities.has_goto_pose,
          has_goto_position: capabilities.has_goto_position,
          has_goto_location: capabilities.has_goto_location,
          has_fake_gps: capabilities.has_fake_gps,
          action_options: capabilities.go_action_options,
          actions_list: actions,
          actions_menu: actions_menu_options,

          data_products: capabilities.data_products,
        })
        var controls_type_list = ["None"]
        if (this.state.has_motor_controls){
          controls_type_list.push("Manual")
        }
        if (this.state.has_autonomous_controls){
          controls_type_list.push("Autonomous")
        }
        const controls_type_menu = createMenuListFromStrList(controls_type_list,false,[],[],[])
        this.setState({
          controls_type_list: controls_type_list,
          controls_type_menu: controls_type_menu
        })
      }

      var controls_auto_list = ["None"]
      if (this.state.actions_list.length > 0){
         controls_auto_list.push("Action")
      }
      if (this.state.has_goto_pose){
        controls_auto_list.push("Pose")
      }
      if (this.state.has_goto_position){
        controls_auto_list.push("Position")
      }
      if (this.state.has_goto_location){
        controls_auto_list.push("Location")
      }
      const controls_auto_menu = createMenuListFromStrList(controls_auto_list,false,[],[],[])
      this.setState({
        controls_auto_list: controls_auto_list,
        controls_auto_menu: controls_auto_menu
      })

    }
  }

  // Function for configuring and subscribing to Status
  updateControlsStatusListener() {
    const namespace = this.props.rbxNamespace
    if (this.state.controlsStatusListener ) {
      this.state.controlsStatusListener.unsubscribe()
    }
    var listener = this.props.ros.setupStatusListener(
          namespace + "/status",
          "nepi_interfaces/DeviceRBXStatus",
          this.controlsStatusListener
        )
    this.setState({ controlsStatusListener : listener})
  }

  // Lifecycle method called when compnent updates.
  // Used to track changes in the topic
  componentDidUpdate(prevProps, prevState, snapshot) {
    const { rbxNamespace } = this.props
    if (prevProps.rbxNamespace !== rbxNamespace && rbxNamespace !== null) {
      if (rbxNamespace.indexOf('null') === -1){
        this.updateControlsStatusListener()
        this.render()
      } 
    }
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status message
  componentWillUnmount() {
    if (this.state.controlsStatusListener ) {
      this.state.controlsStatusListener.unsubscribe()
    }
  }

  
  sendGoActionIndex(){
  const {sendIntMsg} = this.props.ros
  const namespace = this.props.rbxNamespace + "/go_action"
  if (this.state.selected_go_action_index !== null) {
      sendIntMsg(namespace,this.state.selected_go_action_index)
    }
  }

  onDropdownSelectedAction(event) {
    this.setState({
      selected_go_action: event.target.value,
      selected_go_action_index: event.target.selectedIndex
    })
  }

  setLocationToCurrent(event) {
    this.setState({
      location_lat: this.state.current_lat,
      location_long: this.state.current_long,
      altitude_meters: this.state.current_altitude,
      yaw_deg_location: this.state.current_yaw,
    })
  }


  render() {
    const {  sendTriggerMsg, sendFloatGotoPoseMsg, sendFloatGotoPositionMsg, sendFloatGotoLocationMsg } = this.props.ros
    const NoneOption = <Option>None</Option>
    const namespace = this.props.rbxNamespace
    return (
      <Section title={"Process Controls"}>

{/*
          <Columns>
          <Column>
                  <Label title="Show Process Controls">
                    <Toggle
                      checked={this.state.show_process_controls===true}
                      onClick={() => onChangeSwitchStateValue.bind(this)("show_process_controls",this.state.show_process_controls)}>
                    </Toggle>
                  </Label>

            </Column>
            <Column>

            </Column>
            </Columns>
*/}
        <div hidden={!this.state.show_process_controls}>

       <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>


            <Columns>
            <Column>

            <Label title={"System Ready"}>
              <BooleanIndicator value={(this.state.ready !== null)? this.state.ready : false} />
            </Label>

            <Label title={"Select Control Type"}>
                    <Select
                      id="selected_control_type"
                      onChange={(event) => onDropdownSelectedSetState.bind(this)(event,"selected_control_type")}
                      value={this.state.selected_control_type}
                    >
                      {this.state.controls_type_list ? this.state.controls_type_menu : NoneOption}
                    </Select>
                    </Label>


            </Column>
            <Column>

            <Label title={"Current Process"}>
              <Input
                disabled value={this.state.process_current}
                id="current_process"
              />
            </Label>

            <Label title={"Last Process"}>
              <Input
                disabled value={this.state.process_last}
                id="last_process"
              />
            </Label>

            <Label title={"Last Process Success"}>
              <BooleanIndicator value={(this.state.cmd_success !== null)? this.state.cmd_success : false} />
            </Label>


            </Column>
            </Columns>

            <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>


            <div hidden={(this.state.selected_control_type!=="Autonomous")}>
            <Columns>
            <Column>


            <div hidden={(this.state.selected_control_type!=="Autonomous")}>
            <Label title={"Autonomous Ready"}>
              <BooleanIndicator value={(this.state.autonomous_ready !== null)? this.state.autonomous_ready : false} />
            </Label>
            </div>

            </Column>
            <Column>

            <ButtonMenu>
                <Button onClick={() => sendTriggerMsg(namespace + "/go_stop")}>{"stop"}</Button>
            </ButtonMenu>

            </Column>
            <Column>

            <div hidden={(!this.state.has_go_home)}>
            <ButtonMenu>
                <Button onClick={() =>  this.state.autonomous_ready ? 
                  sendTriggerMsg(namespace + "/go_home"):
                  this.doNothing()
                }>{"Go Home"}</Button>
              </ButtonMenu>
              </div>

            </Column>
            </Columns>
            </div>

            <Columns>
            <Column>

            <div hidden={(this.state.selected_control_type!=="Manual")}>
            <Label title={"Manual Ready"}>
              <BooleanIndicator value={(this.state.manual_ready !== null)? this.state.manual_ready : false} />
            </Label>
            </div>

            <Label title={""}></Label>

            </Column>
            </Columns>

            <Label title={""}></Label>

            <div hidden={(this.state.selected_control_type!=="Autonomous")}>
            <Columns>
            <Column>

            <Label title={"Select Goto Type"}>
              <Select
                id="selected_auto_control"
                onChange={(event) => onDropdownSelectedSetState.bind(this)(event,"selected_auto_control")}
                value={this.state.selected_auto_control}
              >
                {this.state.controls_auto_list ? this.state.controls_auto_menu : NoneOption}
              </Select>
              </Label>


            <div hidden={(this.state.selected_auto_control!=="Pose")}>

            <label style={{fontWeight: 'bold'}}>
                {"GoTo Pose (Body)"}
              </label>


            <Label title={"Roll Deg"}>
                <Input
                  value={this.state.roll_deg}
                  id="roll_deg"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"roll_deg")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"roll_deg")}
                  style={{ width: "80%" }}
                />
              </Label>

            <Label title={"Pitch Deg"}>
                <Input
                  value={this.state.pitch_deg}
                  id="pitch_deg"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"pitch_deg")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"pitch_deg")}
                  style={{ width: "80%" }}
                />
              </Label>

            <Label title={"Yaw Deg"}>
                <Input
                  value={this.state.yaw_deg_pose}
                  id="yaw_deg_pose"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"yaw_deg_pose")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"yaw_deg_pose")}
                  style={{ width: "80%" }}
                />
              </Label>

              <ButtonMenu>
                <Button onClick={() => this.state.autonomous_ready ? 
                  sendFloatGotoPoseMsg(namespace + "/goto_pose", this.state.roll_deg, this.state.pitch_deg, this.state.yaw_deg_pose ) :
                  this.doNothing()
                  }>{"Send"}</Button>
              </ButtonMenu>
            </div>

            <div hidden={(this.state.selected_auto_control!=="Position")}>
            <label style={{fontWeight: 'bold'}}>
                {"GoTo Position (Body)"}
              </label>
      

            <Label title={"Forward -> X (m)"}>
                <Input
                  value={this.state.x_meters}
                  id="x_meters"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"x_meters")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"x_meters")}
                  style={{ width: "80%" }}
                />
              </Label>

            <Label title={"Left -> Y (m)"}>
                <Input
                  value={this.state.y_meters}
                  id="y_meters"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"y_meters")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"y_meters")}
                  style={{ width: "80%" }}
                />
              </Label>

            <Label title={"Up -> Z (m)"}>
                <Input
                  value={this.state.z_meters}
                  id="z_meters"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"z_meters")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"z_meters")}
                  style={{ width: "80%" }}
                />
              </Label>

              <Label title={"Yaw Deg"}>
                <Input
                  value={this.state.yaw_deg_position}
                  id="yaw_deg_position"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"yaw_deg_position")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"yaw_deg_position")}
                  style={{ width: "80%" }}
                />
              </Label>

              <ButtonMenu>
                <Button onClick={() =>  this.state.autonomous_ready ? 
                  sendFloatGotoPositionMsg(namespace + "/goto_position", this.state.x_meters, this.state.y_meters, this.state.z_meters, this.state.yaw_deg_position ):
                  this.doNothing()
                  }>{"Send"}</Button>
              </ButtonMenu>

              </div>

              <div hidden={(this.state.selected_auto_control!=="Location")}>
            <label style={{fontWeight: 'bold'}}>
                {"GoTo Location (Geo WSG84)"}
              </label>

              <ButtonMenu>
                <Button onClick={() => this.setLocationToCurrent()}>{"Set to Current"}</Button>
              </ButtonMenu>


            <Label title={"Latitude"}>
                <Input
                  value={this.state.location_lat}
                  id="location_lat"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"location_lat")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"location_lat")}
                  style={{ width: "80%" }}
                />
              </Label>


            <Label title={"Longitude"}>
                <Input
                  value={this.state.location_long}
                  id="location_long"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"location_long")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"location_long")}
                  style={{ width: "80%" }}
                />
              </Label>

            <Label title={"Altitude (m)"}>
                <Input
                  value={this.state.altitude_meters}
                  id="altitude_meters"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"altitude_meters")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"altitude_meters")}
                  style={{ width: "80%" }}
                />
              </Label>

              <Label title={"Yaw Deg"}>
                <Input
                  value={this.state.yaw_deg_location}
                  id="yaw_deg_location"
                  onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"yaw_deg_location")}
                  onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"yaw_deg_location")}
                  style={{ width: "80%" }}
                />
              </Label>



              <ButtonMenu>
                <Button onClick={() =>  this.state.autonomous_ready ? 
                  sendFloatGotoLocationMsg(namespace + "/goto_location", this.state.location_lat, this.state.location_long, this.state.altitude_meters, this.state.yaw_deg_location ):
                  this.doNothing()
                }>{"Send"}</Button>
              </ButtonMenu>

              </div>


              <div hidden={(this.state.selected_auto_control!=="Action")}>
              <Label title={""}></Label>
              <Label title={""}></Label>

              <Label title={"Select Action"}>
                    <Select
                      id="selected_go_action"
                      onChange={(event) => onDropdownSelectedSetState.bind(this)(event,"selected_go_action")}
                      value={this.state.selected_go_action}
                    >
                      {this.state.actions_list ? this.state.actions_menu : NoneOption}
                    </Select>
                    </Label>

            <ButtonMenu>
              <Button onClick={() =>  this.state.autonomous_ready ? 
                this.sendGoActionIndex():
                this.doNothing()
              }>{"Send Action"}</Button>
            </ButtonMenu>
            </div>

            </Column>
            <Column>

            <label>
                {"Current Errors"}
              </label>

            <Label title={"x (m)"}>
              <Input
                disabled value={this.state.errors_current_x}
                id="x_error"
              />

            </Label>

            <Label title={"y (m)"}>
              <Input
                disabled value={this.state.errors_current_y}
                id="y_error"
              />

            </Label>

            <Label title={"z (m)"}>
              <Input
                disabled value={this.state.errors_current_z}
                id="z_error"
              />

            </Label>

            <Label title={"Roll"}>
              <Input
                disabled value={this.state.errors_current_roll_deg}
                id="roll_error"
              />

            </Label>

            <Label title={"Pitch"}>
              <Input
                disabled value={this.state.errors_current_pitch_deg}
                id="pitch_error"
              />

            </Label>

            <Label title={"Yaw"}>
              <Input
                disabled value={this.state.errors_current_yaw_deg}
                id="yaw_error"
              />

            </Label>

            <Label title={"Heading"}>
              <Input
                disabled value={this.state.errors_current_heading_deg}
                id="heading_error"
              />

            </Label>

            </Column>
            </Columns>
           



            

            <Label title={"Last Command"} ></Label>
            

              <Input
                disabled value={this.state.last_cmd_str}
                id="last_command"
              />



            </div>



        </div>

      </Section>
    )
  }

}
export default NepiDeviceControls
