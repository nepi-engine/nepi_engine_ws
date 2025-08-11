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
import { Columns, Column } from "./Columns"
import Label from "./Label"
import Select, { Option } from "./Select"
import Styles from "./Styles"

import NepiDeviceNPXControls from "./NepiDeviceNPX-Controls"

import NepiDeviceInfo from "./Nepi_IF_DeviceInfo"
import NepiIFSettings from "./Nepi_IF_Settings"
import NepiIFSaveData from "./Nepi_IF_SaveData"
import NepiIFNavPoseViewer from "./Nepi_IF_NavPoseViewer"
import NepiIFConfig from "./Nepi_IF_Config"
import NepiSystemMessages from "./Nepi_IF_Messages"

import {createShortUniqueValues} from "./Utilities"

@inject("ros")
@observer

// NPX Application page
class NepiDeviceNPX extends Component {
  constructor(props) {
    super(props)


    //const namespaces = Object.keys(props.ros.npxDevices)

    this.state = {

      show_controls: true,
      show_settings: true,
      show_save_data: true,
      
      // NPX Device topic to subscribe to and update
      namespace: null,

      listener: null,

      disabled: false,

      connected: false,
      statusListener: null,
      navposeListener: null,
      needs_update: true,
      nav_needs_update: true
    }


    this.ondeviceSelected = this.ondeviceSelected.bind(this)
    this.clearDeviceSelection = this.clearDeviceSelection.bind(this)
    this.createDeviceOptions = this.createDeviceOptions.bind(this)
    this.statusListener = this.statusListener.bind(this)
    this.navposeListener = this.navposeListener.bind(this)
    this.updateStatusListener = this.updateStatusListener.bind(this)
    this.updateNavposeListener = this.updateNavposeListener.bind(this)


  }


  // Callback for handling ROS StatusNPX messages
  statusListener(message) {
  console.log('Status message received:', message);

    this.setState({
      status_msg: message, 
      connected: true
    })

  }

  navposeListener(message) {
    
    const navpose_data = {
      latitude: message.latitude,
      longitude: message.longitude,
      altitude: message.altitude_m,
      heading: message.heading_deg,
      roll: message.roll_deg,
      pitch: message.pitch_deg,
      yaw: message.yaw_deg,
      x_m: message.x_m,
      y_m: message.y_m,
      z_m: message.z_m,
      frame_3d: message.frame_3d,
      frame_id: message.frame_id
    }
        
    this.setState({
      navpose_data: navpose_data, 
      connected: true
    })
  }

updateStatusListener() {
  const namespace = this.state.namespace
  const statusTopic = namespace + "/status"
  var statusListener = this.props.ros.setupStatusListener(
    namespace + "/status",
    "nepi_interfaces/DeviceNPXStatus",
    this.statusListener 
  )
  
  this.setState({ 
    statusListener: statusListener,
    needs_update: false 
  })
}

updateNavposeListener() {
  const namespace = this.state.namespace
  const navposeTopic = namespace + "/navpose"
  if (this.state.navposeListener) {
    this.state.navposeListener.unsubscribe()
  }
  
  var navposeListener = this.props.ros.setupStatusListener(
    navposeTopic,
    "nepi_interfaces/NavPose",
    this.navposeListener 
  )
  
  this.setState({ 
    navposeListener: navposeListener,
    nav_needs_update: false 
  })
}

  // Lifecycle method called when compnent updates.
  // Used to track changes in the topic
  componentDidUpdate(prevProps, prevState) {
    if (prevState.namespace !== this.state.namespace) {
      const namespace = this.state.namespace;  
      if (namespace) {
        this.updateStatusListener();
        this.updateNavposeListener();
      } else {
        this.setState({ disabled: true });
      }
    }
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to StatusNPX message
  componentWillUnmount() {
    if (this.state.statusListener) {
      this.state.statusListener.unsubscribe()
    }
    if (this.state.navposeListener) {
      this.state.navposeListener.unsubscribe()
    }
  }


    // Function for creating topic options for Select input
    createDeviceOptions(topics) {

      var items = []
      items.push(<Option>{"None"}</Option>)
      //var unique_names = createShortUniqueValues(topics)
      var device_name = ""
      for (var i = 0; i < topics.length; i++) {
        device_name = topics[i].split('/npx')[0].split('/').pop()
        items.push(<Option value={topics[i]}>{device_name}</Option>)
      }
      // Check that our current selection hasn't disappeard as an available option
      const { namespace } = this.state
      if ((namespace != null) && (! topics.includes(namespace))) {
        this.clearDeviceSelection()
      }
  
      return items
    }
  
  
    clearDeviceSelection() {
      this.setState({
        namespace: null,
        namespaceText: "No sensor selected",
      })
    }
  
    // Handler for IDX Sensor topic selection
    ondeviceSelected(event) {
      var index = event.nativeEvent.target.selectedIndex
      var text = event.nativeEvent.target[index].text
      var value = event.target.value
  
      // Handle the "None" option -- always index 0
      if (index === 0) {
        this.clearDeviceSelection()
        return
      }
      else{
        var autoSelectedImgTopic = null
        var autoSelectedImgTopicText = null
        const capabilities = this.props.ros.npxDevices[value]
        
  
        this.setState({
          namespace: value,
          namespaceText: text,
        })
      }
    }


  renderDeviceSelection() {
    const { npxDevices, sendTriggerMsg, saveConfigTriggered  } = this.props.ros
    const NoneOption = <Option>None</Option>
    const deviceSelected = (this.state.namespace != null)
    const namespace = this.state.namespace
    
    return (
      <React.Fragment>
        <Columns>
          <Column>
            <Section title={"Selection"}>

              <Columns>
              <Column>
              
                <Label title={"Device"}>
                  <Select
                    onChange={this.ondeviceSelected}
                    value={namespace}
                  >
                    {this.createDeviceOptions(Object.keys(npxDevices))}
                  </Select>
                </Label>
               
 

              </Column>
              <Column>
 
              </Column>
            </Columns>

            <div align={"left"} textAlign={"left"} hidden={!deviceSelected}>
            <NepiIFConfig
                        namespace={namespace}
                        title={"Nepi_IF_Conig"}
                  />


          </div>


            </Section>
          </Column>
        </Columns>
      </React.Fragment>
    )
  }

  render() {
    const deviceSelected = (this.state.namespace != null)
    const namespace = this.state.namespace
    const navpose_data = this.state.navpose_data
    const status_msg = this.state.status_msg
    const connected = this.state.connected

    return (
      
      <div style={{ display: 'flex' }}>

          <div style={{ width: "65%" }}>

                    <div hidden={(!deviceSelected)}>
                      <NepiDeviceInfo
                            deviceNamespace={namespace}
                            status_topic={"npx/status"}
                            status_msg_type={"nepi_interfaces/DeviceNPXStatus"}
                            name_update_topic={"/update_device_name"}
                            name_reset_topic={"/reset_device_name"}
                            title={"NepiDeviceNPXInfo"}
                        />

                    </div>

                    <NepiIFNavPoseViewer
                      namespace={namespace}
                      title={"NavPose Data"}
                    />


                    <div hidden={(!deviceSelected)}>

                      <NepiIFSaveData
                        namespace={namespace}
                        title={"Nepi_IF_SaveData"}
                      />

                    <NepiSystemMessages
                    messagesNamespace={namespace}
                    title={"NepiSystemMessages"}
                    />


                    </div>


          </div>




          <div style={{ width: '5%' }}>
                {}
          </div>



          <div style={{ width: "30%"}}>


                    {this.renderDeviceSelection()}


                    <div hidden={(!deviceSelected)}>
                      <NepiDeviceNPXControls
                          namespace={namespace}
                          status_msg={status_msg}
                          title={"NepiDeviceNPXControls"}
                      />
                    </div>


                    <div hidden={(!deviceSelected && this.state.show_settings)}>
                      <NepiIFSettings
                        namespace={namespace}
                        title={"Nepi_IF_Settings"}
                      />
                    </div>

          </div>



    </div>



    )
  }
}

export default NepiDeviceNPX
