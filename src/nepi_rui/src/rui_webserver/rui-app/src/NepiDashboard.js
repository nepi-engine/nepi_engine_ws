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

import Input from "./Input"
import Select, { Option } from "./Select"
import Toggle from "react-toggle"
import Section from "./Section"
import { Columns, Column } from "./Columns"
import Label from "./Label"
import Button, { ButtonMenu } from "./Button"
import BooleanIndicator from "./BooleanIndicator"
import Styles from "./Styles"
import {createShortUniqueValues} from "./Utilities"

import NepiMessagesSelector from "./NepiSelectorMessages"


// TODO: This is redundant with the one defined in APP.js
const IS_LOCAL = window.location.hostname === "localhost"

function roundWithSuffix(value, decimals, suffix) {
  return value && (value.toFixed(decimals) + " " + suffix)
}

@inject("ros")
@observer
class NepiDashboard extends Component {
  constructor(props) {
    super(props)

    this.state = {
      saveSettingsFilePrefix: "",
      currDeviceId: "",
      allowFileDeletion: false,
      saveFreq: this.props.ros.saveFreqHz,

      viewableMessages: false,
      selected_message: 'NONE',

      timezones_list_viewable: false
    }

  
    this.renderDeviceInfo = this.renderDeviceInfo.bind(this)
    this.renderSystemClock = this.renderSystemClock.bind(this)
    this.renderMgrSystemStatus = this.renderMgrSystemStatus.bind(this)

    this.toggleViewableMessages = this.toggleViewableMessages.bind(this)
    this.onToggleMessagesSelection = this.onToggleMessagesSelection.bind(this)

    this.onToggleTimezoneSelection = this.onToggleTimezoneSelection.bind(this)
    this.getTimezoneOptions = this.getTimezoneOptions.bind(this)
    this.toggleTimezonesListViewable = this.toggleTimezonesListViewable.bind(this)

  }

  getAllNamespace(){
    const { namespacePrefix, deviceId} = this.props.ros
    var allNamespace = null
    if (namespacePrefix !== null && deviceId !== null){
      allNamespace = "/" + namespacePrefix + "/" + deviceId + "/messages"
    }
    return allNamespace
  }

  createMessageOptions() {
    const allNamespace = this.getAllNamespace()
    var items = []
    //items.push(<Option value={"All"}>{"All"}</Option>)
    items.push(<Option value={"None"}>{"None"}</Option>)
    const Messages_topics = this.props.ros.messageTopics
    const shortnames = createShortUniqueValues(Messages_topics)
    var topic = ""
    for (var i = 0; i < Messages_topics.length; i++) {
      topic = Messages_topics[i]
      if (topic !== allNamespace && topic.indexOf("None") === -1) {
        items.push(<Option value={topic}>{shortnames[i]}</Option>)
      }
    }
    return items    
  }

  toggleViewableMessages() {
    const viewable = !this.state.viewableMessages
    this.setState({viewableMessages: viewable})
  }

  onToggleMessagesSelection(event){
    const selected_message = event.target.innerText
    this.setState({selected_message: selected_message})
  }

  renderSelectorMessages() {
    const messageTopics = this.createMessageOptions()
    const hide_messages_list = !this.state.viewableMessages && !this.state.connected
    return (
      <React.Fragment>
      <Columns>
      <Column>

      <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Select message Topic"}
         </label>

      <div onClick={this.toggleViewableMessages} style={{backgroundColor: Styles.vars.colors.grey0}}>
      <Select style={{width: "10px"}}/>
    </div>
    <div hidden={hide_messages_list}>
    {messageTopics.map((message) =>
    <div onClick={this.onToggleMessagesSelection}
      style={{
        textAlign: "center",
        padding: `${Styles.vars.spacing.xs}`,
        color: Styles.vars.colors.black,
        backgroundColor: (message.props.value === this.state.selected_message) ? Styles.vars.colors.blue : Styles.vars.colors.grey0,
        cursor: "pointer",
        }}>
        <body message-topic ={message} style={{color: Styles.vars.colors.black}}>{message}</body>
    </div>
    )}
    </div>

    </Column>
      </Columns>

    </React.Fragment>
    )
  }

  renderDeviceInfo() {
    const {
      deviceType,
      deviceId,
      deviceSerial,
      systemDefsFirmwareVersion,
    } = this.props.ros
    return (
      <Section title={"Device Info"}>
        <Label title={"Type"}>
          <Input disabled value={deviceType} />
        </Label>
        <Label title={"Device ID"}>
          <Input disabled value={deviceId} />
        </Label>
        <Label title={"Serial Number"}>
          <Input disabled value={deviceSerial} />
        </Label>
        <Label title={"Firmware"}>
          <Input disabled value={systemDefsFirmwareVersion} />
        </Label>

        <pre style={{ height: "71px", overflowY: "auto" }}>
            {""}
          </pre>

      </Section>
    )
  }

  renderdeviceInfo() {
    const {
      deviceConnected,
      deviceType,
      deviceFirmwareVersion,
      eggFirmwareVersion,
    } = this.props.ros
    return (
      <Section title={"device Info"}>
        <Label title={"Connected"}>
          <BooleanIndicator value={deviceConnected} />
        </Label>
        <Label title={"Type"}>
          <Input disabled value={deviceType} />
        </Label>
        <Label title={"Firmware"}>
          <Input disabled value={deviceFirmwareVersion} />
        </Label>
        <Label title={"Sensor Firmware"}>
          <Input disabled value={eggFirmwareVersion} />
        </Label>
        
      </Section>
    )
  }



  // Function for creating image topic options.
  getTimezoneOptions() {
    const {
      available_timezones
    } = this.props.ros
    var items = []

    if (available_timezones != null){
          for (var i = 0; i < available_timezones.length; i++) {
              if (available_timezones[i] !== 'None'){
                items.push(<Option value={available_timezones[i]}>{available_timezones[i]}</Option>)
              }
          }
    }
    return items
    }
  
  
    toggleTimezonesListViewable() {
      const set = !this.state.timezones_list_viewable
      this.setState({timezones_list_viewable: set})
    }
  
  
    onToggleTimezoneSelection(event){
      const {
        setTimezone,
        available_timezones,
        systemStatusTimezoneDesc
      } = this.props.ros
      const timezoneSelection = event.target.value
      if (timezoneSelection !== systemStatusTimezoneDesc){
        setTimezone(timezoneSelection)
      }
    }



  renderSystemClock() {
    const {
      systemInContainer,
      systemStatusTime,
      systemStatusTimeStr,
      systemStatusDateStr,
      clockUTCMode,
      clockTZ,
      onToggleClockUTCMode,
      systemStatusTimezone,
      systemStatusTimezoneDesc,
      syncTimezone,
      onToggleSyncTimezone,
      onSyncTimezone,
      setTimezoneUTC,
      clockNTP,
      syncTime2Device
    } = this.props.ros

    const timezoneOptions = this.getTimezoneOptions()


    var time_str = ""
    var date_str = ""
    var timezone = ""
    if (systemStatusTime){
      time_str = systemStatusTimeStr
      date_str = systemStatusDateStr

      timezone = systemStatusTimezoneDesc
      
      if (systemInContainer === false){
        if (systemStatusTimezoneDesc !== clockTZ && syncTimezone === true && clockNTP === false){
          onSyncTimezone()
        }
      }

    }
 
    
    return (
      <Section title={"System Clock"}>
        <Label title={"NTP"}>
          <BooleanIndicator value={clockNTP} />
        </Label>
        <Label title={"Time"}>
          <Input disabled value={time_str} />
        </Label>
        <Label title={"Date"}>
          <Input disabled value={date_str} />
        </Label>
        <Label title={"Timezone"}>
          <Input disabled value={timezone} />
        </Label>


        {(IS_LOCAL === false && systemInContainer === false) &&

            <Columns>
            <Column>


              <ButtonMenu>
                <Button onClick={syncTime2Device}>{"Sync Clocks"}</Button>
              </ButtonMenu>


            </Column >
            <Column>




              <Label title={"Auto Sync Timezone"}>
                <Toggle checked={syncTimezone} onClick={onToggleSyncTimezone} />
              </Label>

              <div hidden={syncTimezone === false}>

              <pre style={{ height: "31px", overflowY: "auto" }}>
            {""}
          </pre>

              </div>


                <div hidden={syncTimezone === true}>



                      <label align={"left"} textAlign={"left"}>
                          {"Select Timezone"}
                        </label>
                  


                          <div onClick={this.toggleTimezonesListViewable} style={{backgroundColor: Styles.vars.colors.grey0}}>
                                    <Select style={{width: "10px"}}/>
                                  </div>
                                  <div hidden={this.state.timezones_list_viewable === false}>
                                  {timezoneOptions.map( (Timezone) =>
                                  <div onClick={this.onToggleTimezoneSelection}
                                    style={{
                                      textAlign: "center",
                                      padding: `${Styles.vars.spacing.xs}`,
                                      color: Styles.vars.colors.black,
                                      backgroundColor: (timezone === Timezone.props.value)? Styles.vars.colors.blue : Styles.vars.colors.grey0,
                                      cursor: "pointer",
                                      }}>
                                      <body timezone_name ={Timezone} style={{color: Styles.vars.colors.black}}>{Timezone}</body>
                                  </div>
                                  )}
                            </div>

                        
                  </div>



                      </Column>
                      </Columns>




            }



      </Section>
    )
  }

  renderMgrSystemStatus() {
    const {
      heartbeat,
      systemStatusDiskUsageMB,
      systemStatusTempC,
      systemDefsDiskCapacityMB,
      diskUsagePercent
    } = this.props.ros

    const { wifi_query_response } = this.props.ros
    const internet_connected = (wifi_query_response !== null)? wifi_query_response.internet_connected : false
    
    const sys_debug = this.props.ros.systemDebugEnabled
    const debug_mode = sys_debug ? sys_debug : false
    return (
      <Section title={"System Status"}>
        <Label title={"Heartbeat"}>
          <BooleanIndicator value={heartbeat} />
        </Label>
        
        <Label title={"Temperature"}>
          <Input disabled value={roundWithSuffix(systemStatusTempC, 1, "\u00B0C")} />
        </Label>

        <Label title={"Storage"}>
          <Input disabled value={diskUsagePercent} />
        </Label>

        <Label title={"Capacity"}>
          <Input disabled value={roundWithSuffix(systemDefsDiskCapacityMB / 1000.0, 1, "GB")} />
        </Label>
        {/*
        <Label title={"Used"}>
          <Input disabled value={roundWithSuffix(systemStatusDiskUsageMB / 1000.0, 1, "GB")} />
        </Label>
      */}

        <Label title={"Internet Connected"}>
          <BooleanIndicator value={internet_connected} />
        </Label>

        <Label title={"Debug Mode Enabled"}>
          <BooleanIndicator value={debug_mode} />
        </Label>


        <pre style={{ height: "0px", overflowY: "auto" }}>
            {""}
          </pre>

      </Section>
    )
  }


  render() {
    return (
    <React.Fragment>

      <Columns>
        <Column>
          {this.renderDeviceInfo()}



        </Column>
        <Column>
          {this.renderMgrSystemStatus()}


        </Column>
        <Column>
        {this.renderSystemClock()}

        </Column>
      </Columns>

      <div style={{ marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

      <NepiMessagesSelector
        title={"NepiMessagesSelector.js"}
        />

    </React.Fragment>


    )
  }
}

export default NepiDashboard
