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

import Styles from "./Styles"
import Section from "./Section"
import { Columns, Column } from "./Columns"
import Select, { Option } from "./Select"

import { SliderAdjustment } from "./AdjustmentWidgets"
import Label from "./Label"
import Input from "./Input"
import Button, { ButtonMenu } from "./Button"
import Toggle from "react-toggle"

import NepiDeviceInfo from "./Nepi_IF_DeviceInfo"
import ImageViewer from "./Nepi_IF_ImageViewer"
import NepiIFSettings from "./Nepi_IF_Settings"
import NepiIFConfig from "./Nepi_IF_Config"
import NepiSystemMessages from "./Nepi_IF_Messages"

import NepiIF3DTransform from "./Nepi_IF_3DTransform"

import {createShortUniqueValues, onDropdownSelectedSendStr, createMenuListFromStrList} from "./Utilities"
import {createShortValuesFromNamespaces} from "./Utilities"

function round(value, decimals = 0) {
  return Number(value).toFixed(decimals)
  //return value && Number(Math.round(value + "e" + decimals) + "e-" + decimals)
}

@inject("ros")
@observer

// Component that contains the LSX controls
class NepiControlsLights extends Component {
  constructor(props) {
    super(props)

    this.state = {
		
	  lsxNamespace: null,
      imageTopic: null,
      imageText: null,

      lxsIdentifier: null,
      lsxSerialNum: null,
      lsxHwVersion: null,
      lsxSwVersion: null,
      lsxDeviceName: null,

      lxsUserName: null,
      
      lsxStandbyState: false,
      lsxOnOffState: false,
      lsxBlinkState: false,
      lsxStrobeState: false,


      lsxBlinkInterval: 1,
      lsxIntensityRatio: 0,


      lsxColorStr: "None",
      lsxKelvinVal: null,
      lsxTempC: null,
      lsxPowerW: null,


      listener: null,
      disabled: true,

      connected: false,

      currentIDXNamespace: null


    }

    this.createImageTopicsOptions = this.createImageTopicsOptions.bind(this)
    this.onImageTopicSelected = this.onImageTopicSelected.bind(this)
    this.onlsxDeviceselected = this.onlsxDeviceselected.bind(this)
    this.lsxStatusListener = this.lsxStatusListener.bind(this)
    this.renderControlPanel = this.renderControlPanel.bind(this)
    this.createLSXOptions = this.createLSXOptions.bind(this)
  }

  clearTopicLXSSelection() {
    this.setState({
      lsxNamespace: null,
      currentIDXNamespace: null,
      connected: false,
      disabled: true,
      imageTopic: null,
      imageText: null
    })
    if (this.state.listener) {
      this.state.listener.unsubscribe()
    }
  }

  // Function for creating image topic options.
  createImageTopicsOptions() {
    var items = []
    items.push(<Option>{"None"}</Option>) 
    const { imageTopics } = this.props.ros
    var imageTopicShortnames = createShortValuesFromNamespaces(imageTopics)
    if (!imageTopics) {
      return items
    }
    for (var i = 0; i < imageTopics.length; i++) {
      items.push(<Option value={imageTopics[i]}>{imageTopicShortnames[i]}</Option>)
    }
    return items
  }

  // Handler for Image topic selection
  onImageTopicSelected(event) {
    var idx = event.nativeEvent.target.selectedIndex
    var text = event.nativeEvent.target[idx].text
    var value = event.target.value

    this.setState({
      imageTopic: value,
      imageText: text === "None" ? null : text,
    })
  }

  
  // Callback for handling ROS Status3DX messages
  lsxStatusListener(message) {


    this.setState({
      lsxSerialNum: message.serial_num,
      lsxHwVersion: message.hw_version,
      lsxSwVersion: message.sw_version,

      lsxDeviceName: message.user_name ,
      
      lsxStandbyState: message.standby_state ,
      lsxOnOffState: message.on_off_state ,
      lsxIntensityRatio: message.intensity_ratio ,
      lsxBlinkState: message.blink_state ,
      lsxBlinkInterval: message.blink_interval ,
      lsxKelvinVal: message.kelvin_setting ,
      lsxStrobeState: message.strobe_state ,

      lsxColorStr: message.color_setting,
      lsxTempC: message.temp_c ,
      lsxPowerW: message.power_w ,

      lxsIdentifier: message.identifier,
      lxsUserName: message.user_name,

      connected: true
    })
  }

  // Function for configuring and subscribing to lsx/status
  onlsxDeviceselected(event) {
    if (this.state.listener) {
      this.state.listener.unsubscribe()
    }

    var idx = event.nativeEvent.target.selectedIndex
    //var text = event.nativeEvent.target[idx].text
    var value = event.target.value

    // Handle the "None" Option -- always index 0
    if (idx === 0) {
      this.setState({ disabled: true })
      return
    }

    this.setState({ lsxNamespace: value })

    var listener = this.props.ros.setupLSXStatusListener(
        value,
        this.lsxStatusListener
      )
      
    this.setState({ lsxNamespace: value, listener: listener, disabled: false })
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status3DX message
  componentWillUnmount() {
    if (this.state.listener) {
      this.state.listener.unsubscribe()
      this.setState({connected: false})
    }
  }

  // Function for creating topic Options for Select input
  createLSXOptions(caps_dictionaries, filter) {
    if (!caps_dictionaries) {
      return [<Option key="none">{"None"}</Option>]
    }
    const topics = Object.keys(caps_dictionaries)
    var filteredTopics = topics
    var i
    if (filter) {
      filteredTopics = []
      for (i = 0; i < topics.length; i++) {
        // includes does a substring search
        if (topics[i].includes(filter)) {
          filteredTopics.push(topics[i])
        }
      }
    }

    var items = []
    items.push(<Option>{""}</Option>)
    //var unique_names = createShortUniqueValues(filteredTopics)
    var device_name = ""
    for (i = 0; i < filteredTopics.length; i++) {
      device_name = filteredTopics[i].split('/lsx')[0].split('/').pop()
      items.push(<Option value={filteredTopics[i]}>{device_name}</Option>)
    }
    // Check that our current selection hasn't disappeard as an available Option
    const { lsxNamespace } = this.state
    if ((lsxNamespace != null) && (! filteredTopics.includes(lsxNamespace))) {
      this.clearTopicLXSSelection()
    }

    return items
  }

  
  renderControlPanel() {
    const { sendTriggerMsg } = this.props.ros
    const { lsxNamespace, lsxTempC } = this.state
    const { lsxDevices } = this.props.ros
    const lsx_id = lsxNamespace? lsxNamespace.split('/').slice(-1) : "No Light Selected"
    const namespace = this.state.lsxNamespace

    const lsx_caps = lsxDevices[lsxNamespace]
    const has_standby_mode = lsx_caps && (lsx_caps['has_standby_mode'] === true)
    const has_on_off_control = lsx_caps && (lsx_caps['has_on_off_control'] === true)
    const has_intensity_control = lsx_caps && (lsx_caps['has_intensity_control'] === true)
    const has_color_control = lsx_caps && (lsx_caps['has_color_control'] === true)
    const color_options_list = lsx_caps ?  lsx_caps['color_options_list'] : ["None"]
    const has_kelvin_control = lsx_caps && (lsx_caps['has_kelvin_control'] === true)
    const kelvin_min = lsx_caps ? lsx_caps['kelvin_min'] : 1000
    const kelvin_max = lsx_caps ? lsx_caps['kelvin_max'] : 3.5
    const has_blink_control = lsx_caps && (lsx_caps['has_blink_control'] === true)
    const has_hw_strobe = lsx_caps && (lsx_caps['has_hw_strobe'] === true)
    const reports_temperature = lsx_caps && (lsx_caps['reports_temperature'] === true)
    const reports_power = lsx_caps && (lsx_caps['reports_power'] === true)
    const NoneOption = <Option>None</Option>



    return (
      <Section title={lsx_id} >

            <div hidden={!has_on_off_control}>    
          <Label title="Set On_Off State">
                  <Toggle
                    checked={this.state.lsxOnOffState===true}
                    onClick={() => this.props.ros.sendBoolMsg(namespace + "/turn_on_off",!this.state.lsxOnOffState)}>
                  </Toggle>
            </Label>
            </div>

 
            <div hidden={!has_standby_mode}>      
          <Label title="Set Standby State">
                  <Toggle
                    checked={this.state.lsxStandbyState===true}
                    onClick={() => this.props.ros.sendBoolMsg(namespace + "/set_standby",!this.state.lsxStandbyState)}>
                  </Toggle>
            </Label>
            </div>



            <div hidden={!has_intensity_control || this.state.lsxOnOffState===false}>    
                <SliderAdjustment
                    title={"Intensity ratio"}
                    msgType={"std_msgs/Float32"}
                    adjustment={this.state.lsxIntensityRatio}
                    topic={lsxNamespace + "/set_intensity_ratio"}
                    scaled={.01}
                    min={0}
                    max={100}
                    tooltip={"Speed as a percentage (0%=min, 100%=max)"}
                    unit={"%"}
                  />
            </div>


            <div hidden={false}> 
            <div hidden={!has_color_control}>    
            <Label title={"Select Color"}>
                    <Select
                      id="select_color"
                        onChange={(event) => onDropdownSelectedSendStr.bind(this)(event,namespace + "/set_color")}
                        value={this.state.lsxColorStr}
                      >
                        {this.state.lsxColorStr
                          ? createMenuListFromStrList(color_options_list, false, [],[],[])
                          : NoneOption}
                      </Select>
                    </Label>
                    </div>

            <div hidden={!has_blink_control}>    

            <SliderAdjustment
                    title={"Blink Interval (ms)"}
                    msgType={"std_msgs/Float32"}
                    adjustment={this.state.lsxBlinkInterval}
                    topic={lsxNamespace + "/set_blink_interval"}
                    scaled={.01}
                    min={25}
                    max={200}
                    tooltip={""}
                    unit={"ms"}
                  />
            </div>
            

{/*
            <Label title={"Kelvin Setting"}>
                  <Input id="blink_interval" 
                    value={this.state.lsxKelvinVal} 
                    onChange={(event) => onUpdateSetStateValue.bind(this)(event,"lsxKelvinVal")} 
                    onKeyDown= {(event) => onEnterSendIntValue.bind(this)(event,namespace + "/set_kelvin")} />
                </Label>

                disabled={!has_intensity_control}
*/}                



            <div hidden={!has_kelvin_control}>    
                  <SliderAdjustment
                    title={"Kelvin Setting"}
                    msgType={"std_msgs/Int32"}
                    adjustment={this.state.lsxKelvinVal}
                    topic={lsxNamespace + "/set_kelvin"}
                    scaled={1}
                    min={kelvin_min}
                    max={kelvin_max}
                    tooltip={"Speed as a percentage (0%=min, 100%=max)"}
                    unit={"K"}
                  />
            </div>


            <div hidden={!reports_temperature}>    
                  <Label title={"Temperature C"}>
                    <Input
                      disabled
                      value={round(lsxTempC, 1)}  />
                  </Label>
                  </div>

                  <div hidden={!reports_power}>    
             <Label title={"Power"}>
                    <Input
                      disabled
                      value={round(this.state.lsxPowerW, 1)}  />
                  </Label>
                  </div>

          </div>

          <div hidden={!has_hw_strobe}>    
            <Label title="Set Strobe State">
                  <Toggle
                    checked={this.state.lsxStrobeState===true}
                    onClick={() => this.props.ros.sendBoolMsg(namespace + "/set_strobe_enable",!this.state.lsxStrobeState)}>
                  </Toggle>
            </Label>
            </div>

            <Columns>
                  <Column>

                          <NepiIF3DTransform
                              namespace={namespace}
                              supports_updates={true}
                              title={"Nepi_IF_3DTransform"}
                          />

                  </Column>
              </Columns>

               </Section>
    )
  }

  render() {
    const { sendTriggerMsg } = this.props.ros
    const { lsxDevices } = this.props.ros
    const { lsxNamespace } = this.state
    const connected = this.state.connected
    const namespace = this.state.lsxNamespace

    //const lsxImageViewerElement = document.getElementById("lsxImageViewer")

    //const lsx_caps = lsxDevices[lsxNamespace]
    return (
      <React.Fragment>

        <Columns>
          <Column equalWidth = {false} >

          <NepiDeviceInfo
                  deviceNamespace={namespace}
                  status_topic={"/status"}
                  status_msg_type={"nepi_interfaces/DeviceLSXStatus"}
                  name_update_topic={"/update_device_name"}
                  name_reset_topic={"/reset_device_name"}
                  title={"NepiSensorsImagingInfo"}
              />

                <div id="lsxImageViewer">
                  <ImageViewer
                    id="lsxImageViewer"
                    imageTopic={this.state.imageTopic}
                    title={this.state.imageText}
                    hideQualitySelector={false}
                  />
                </div>

                <NepiSystemMessages
                    messagesNamespace={namespace}
                    title={"NepiSystemMessages"}
                    />

          </Column>
          <Column>
          <Section title={"Selection"}>

            <Label title={"Device"}>
              <Select
                onChange={this.onlsxDeviceselected}
                value={namespace}
                >
                {this.createLSXOptions(lsxDevices)}
              </Select>
            </Label>
            <Label title={"Select Image"}>
              <Select
                id="lsxImageTopicSelect"
                onChange={this.onImageTopicSelected}
                value={this.state.imageTopic}
              >
              {this.createImageTopicsOptions()}
              </Select>
            </Label>

            <div hidden={namespace === null}>    

            <Label title={"Serial Number"}>
              <Input disabled={true} value={this.state.lsxSerialNum}/>
            </Label>
        
            <Label title={"H/W Rev."}>
              <Input disabled={true} value={this.state.lsxHwVersion}/>
            </Label>
        
            <Label title={"S/W Rev."}>
              <Input disabled={true} value={this.state.lsxSwVersion}/>
            </Label>
            </div>

            </Section>

          <div hidden={connected === false}>
                <NepiIFConfig
                        namespace={namespace}
                        title={"Nepi_IF_Conig"}
                  />


            {this.renderControlPanel()}
            

            <NepiIFSettings
            namespace={namespace + '/lxs'}
            title={"Nepi_IF_Settings"}
          />

        </div>




          </Column>
        </Columns>

      </React.Fragment>
    )
  }
}

export default NepiControlsLights
