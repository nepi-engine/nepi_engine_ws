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
import Toggle from "react-toggle"
import Label from "./Label"
import { Column, Columns } from "./Columns"
import Input from "./Input"
import Styles from "./Styles"




import { onChangeSwitchStateValue, convertStrToStrList} from "./Utilities"
import {Queue} from "./Utilities"



@inject("ros")
@observer

// Component that contains RBX Controls
class NepiRBXMessages extends Component {
  constructor(props) {
    super(props)

    // these states track the values through  Status messages
    this.state = {
      show_messages: false,

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
      errors_current: null,
      errors_prev: null,
      cmd_success: null,
      manual_ready: null,
      autonomous_ready: null,
      last_cmd_str: null,
      last_error_message: null,
      msg_queue_size: 50,
      status_msg: null,

      has_battery_feedback: null,

      MessagesStatusListener : null,
      MessagesStatusMsgListener : null,
      MessagesStatusStrListener: null,

      status_str_list: null
    }

    this.msg_queue = new Queue()

    this.updateMessagesStatusListener = this.updateMessagesStatusListener.bind(this)
    this.updateMessagesStatusMsgListener = this.updateMessagesStatusMsgListener.bind(this)


    this.MessagesStatusListener = this.MessagesStatusListener.bind(this)
    this.MessagesStatusMsgListener = this.MessagesStatusMsgListener.bind(this)
    this.MessagesStatusStrListener = this.MessagesStatusStrListener.bind(this)
    this.convertMsgListToStr = this.convertMsgListToStr.bind(this)
    this.convertStrListToJoinedStr = this.convertStrListToJoinedStr.bind(this)
    

    this.onEnterMessagesQueueVar = this.onEnterMessagesQueueVar.bind(this)
    this.onUpdateMessagesInputBoxValue = this.onUpdateMessagesInputBoxValue.bind(this)

  }



  // Callback for handling ROS Status messages
  MessagesStatusListener(message) {
    this.setState({
      current_lat: message.current_lat ,      
      current_long: message.current_long ,
      current_altitude: message.current_altitude ,
      current_heading: message.current_heading ,
      current_roll: message.current_roll ,
      current_pitch: message.current_pitch ,
      current_yaw: message.current_yaw , 
      process_current: message.rocess_current ,
      process_last: message.process_last ,
      ready: message.ready ,
      battery: message.battery ,
      status_message: message.s,

      errors_current: [message.errors_current.x_m ,message.errors_current.x_m, message.errors_current.x_m, message.errors_current.heading_deg, message.errors_current.roll_deg, message.errors_current.pitch_deg, message.errors_current.yaw_deg],
      errors_prev: [message.errors_prev.x_m ,message.errors_prev.x_m, message.errors_prev.x_m, message.errors_prev.heading_deg, message.errors_prev.roll_deg, message.errors_prev.pitch_deg, message.errors_prev.yaw_deg],
      cmd_success: message.cmd_success ,
      manual_ready: message.manual_motor_control_mode_ready ,
      autonomous_ready: message.autonomous_control_mode_ready ,
      last_cmd_str: message.last_cmd_string ,
      last_error_message: message.last_error_message 
    })

  
  }

  MessagesStatusMsgListener(message) {
    const msg_str = message.data + "\n"
    this.msg_queue.pushItem(msg_str)
    var q_len = this.msg_queue.getLength()
    while (q_len > this.state.msg_queue_size){
      q_len = this.msg_queue.getLength()
      this.msg_queue.pullItem()
    }
    const msg_list = this.msg_queue.getItemsReversed()
    const msg_str_join = msg_list.join("")
    this.setState({status_msg : msg_str_join})
  }

  MessagesStatusStrListener(message) {
    const status_str = message.data
    const status_str_list = convertStrToStrList(status_str)
    this.setState({status_str_list: status_str_list})
  }
  

  // Function for configuring and subscribing to Status
  updateMessagesStatusListener() {
    const Namespace = this.props.rbxNamespace
    if (this.state.MessagesStatusListener ) {
      this.state.MessagesStatusListener.unsubscribe()
    }
    var listener = this.props.ros.setupStatusListener(
          Namespace + "/status",
          "nepi_interfaces/RBXStatus",
          this.MessagesStatusListener
        )
    this.setState({ MessagesStatusListener : listener})
      }


    updateMessagesStatusMsgListener() {
      const Namespace = this.props.rbxNamespace
    if (this.state.MessagesStatusMsgListener ) {
      this.state.MessagesStatusMsgListener.unsubscribe()
    }
    var msglistener = this.props.ros.setupStringListener(
          Namespace + "/status_msg",
          this.MessagesStatusMsgListener
        )
    this.setState({ MessagesStatusMsgListener : msglistener})
     }
    
     updateMessagesStatusStrListener() {
      const Namespace = this.props.rbxNamespace
    if (this.state.MessagesStatusStrListener ) {
      this.state.MessagesStatusStrListener.unsubscribe()
    }
    var statuslistener = this.props.ros.setupStringListener(
          Namespace + "/status_str",
          this.MessagesStatusStrListener
        )
    this.setState({ MessagesStatusStrListener : statuslistener})
     }
  

  // Lifecycle method called when compnent updates.
  // Used to track changes in the topic
  componentDidUpdate(prevProps, prevState, snapshot) {
    const { rbxNamespace } = this.props
    if (prevProps.rbxNamespace !== rbxNamespace && rbxNamespace !== null) {
      if (rbxNamespace.indexOf('null') === -1){
        this.updateMessagesStatusMsgListener()
        this.updateMessagesStatusListener()
        this.updateMessagesStatusStrListener()
        this.msg_queue = new Queue()
        this.render()
      } 
    }
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status message
  componentWillUnmount() {
    if (this.state.MessagesStatusListener ) {
      this.state.MessagesStatusListener.unsubscribe()
    }
  }


  onUpdateMessagesInputBoxValue(event,stateVarStr) {
    var key = stateVarStr
    var value = event.target.value
    var obj  = {}
    obj[key] = value
    this.setState(obj)
    document.getElementById(event.target.id).style.color = Styles.vars.colors.red
    this.render()
  }

  onEnterMessagesQueueVar(event) {
    if(event.key === 'Enter'){
      var value = parseInt(event.target.value, 10)
      if (!isNaN(value)){
        if (value <10){
          value=10
        }
        else if (value > 100){
          value=100
        }
        this.setState({msg_queue_size: value})
      }
      document.getElementById(event.target.id).style.color = Styles.vars.colors.black
    }
  }

  convertMsgListToStr(){
    const msg_list = this.msg_queue.getItems()
    const msg_str = msg_list.join("")
    return msg_str
  }

  convertStrListToJoinedStr(str_list) {
    var mod_str_list = []
    for (var i = 0; i < str_list.length; ++i) {
      mod_str_list.push(str_list[i]+"\n")
    }
    const joined_str = mod_str_list.join("")
    return joined_str

  }

  
  render() {
    return (
      <Section title={"System Informaion"}>

            <Columns>
            <Column>

            <Label title={"Current Battery"}>
              <Input 
              disabled value={this.state.battery}
                id="current_battery"
              />
            </Label>

            </Column>
            <Column>

            </Column>
            </Columns>

            <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

            <label style={{fontWeight: 'bold'}}>
              {"Nave Pose"}
            </label>

            <Columns>
            <Column>
          
            <Label title={"Latitude"}>
              <Input
                disabled value={this.state.current_lat}
                id="InitLatitude"
              />
            </Label>

            <Label title={"Longitude"}>
              <Input
                disabled value={this.state.current_long}
                id="InitLongitude"
              />
            </Label>

            <Label title={"Altitude (m)"}>
              <Input
                disabled value={this.state.current_altitude}
                id="InitAltitude"
              />
            </Label>

            </Column>
            <Column>

            <Label title={"Roll (deg)"}>
              <Input
                disabled value={this.state.current_roll}
                id="InitRoll"
              />

              </Label>
              <Label title={"Pitch (deg)"}>
                <Input
                  disabled value={this.state.current_pitch}
                  id="InitPitch"
                />

              </Label>
              <Label title={"Yaw (deg)"}>
                <Input
                  disabled value={this.state.current_yaw}
                  id="InitYaw"
                />
              </Label>

              </Column>
              </Columns>

            <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

            <Columns>
            <Column>
            
            <Label title="Show System Messages">
                    <Toggle
                      checked={this.state.show_messages===true}
                      onClick={() => onChangeSwitchStateValue.bind(this)("show_messages",this.state.show_messages)}>
                    </Toggle>
              </Label>

            </Column>
            <Column>
            </Column>
            </Columns>


          <div hidden={!this.state.show_messages}>

            <Label title={"Last Command"} >
          </Label>
          <pre style={{ height: "25px", overflowY: "auto" }}>
            {this.state.last_cmd_str}
          </pre>

          <Label title={"Last Error"} >
          </Label>
          <pre style={{ height: "25px", overflowY: "auto" }}>
            {this.state.last_error_message}
          </pre>


            <div align={"left"} textAlign={"left"}> 
        <label style={{fontWeight: 'bold'}}>
          {"RBX Status"}
        </label>
          <pre style={{ height: "600px", overflowY: "auto" }}>
            {this.state.status_str_list ? this.convertStrListToJoinedStr(this.state.status_str_list) : ""}
          </pre>
          </div>


              </div>
      </Section>
    )
  }

}
export default NepiRBXMessages
