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
import Toggle from "react-toggle"

import Section from "./Section"
import { Columns, Column } from "./Columns"
import Select, { Option } from "./Select"
import { SliderAdjustment } from "./AdjustmentWidgets"
import Label from "./Label"
import Input from "./Input"
import Styles from "./Styles"
import Button, { ButtonMenu } from "./Button"
import {createShortUniqueValues, setElementStyleModified, clearElementStyleModified, onUpdateSetStateValue, onUpdateSetStateIndexValue, onEnterSetStateFloatValue} from "./Utilities"
import {createShortValuesFromNamespaces} from "./Utilities"

import NepiDeviceInfo from "./Nepi_IF_DeviceInfo"
import ImageViewer from "./Nepi_IF_ImageViewer"
import NepiIFSettings from "./Nepi_IF_Settings"
import NepiIFSaveData from "./Nepi_IF_SaveData"
import NepiIFConfig from "./Nepi_IF_Config"
import NepiSystemMessages from "./Nepi_IF_Messages"

import NepiIF3DTransform from "./Nepi_IF_3DTransform"
import NavPoseViewer from "./Nepi_IF_NavPoseViewer"
import {onChangeSwitchStateValue } from "./Utilities"

function round(value, decimals = 0) {
  return Number(value).toFixed(decimals)
  //return value && Number(Math.round(value + "e" + decimals) + "e-" + decimals)
}

@inject("ros")
@observer

// Component that contains the PTX controls
class NepiDevicePTX extends Component {
  constructor(props) {
    super(props)

    this.state = {
      showTransform: false,

      imageTopic: null,
      imageText: null,

      ptSerialNum: null,
      ptHwVersion: null,
      ptSwVersion: null,
      
      panPositionDeg: null,
      tiltPositionDeg: null,

      panGotoDeg: 0.0,
      tiltGotoDeg: 0.0,

      panHomePosEdited: null,
      panHomePosDeg: null,
      tiltHomePosEdited: null,
      tiltHomePosDeg: null,

      show_navpose: false,

      showLimits: false,

      panMaxHardstopDeg: null,
      panMaxHardstopEdited: null,
      tiltMaxHardstopDeg: null,
      tiltMaxHardstopEdited: null,

      panMinHardstopDeg: null,
      panMinHardstopEdited: null,
      tiltMinHardstopDeg: null,
      tiltMinHardstopEdited: null,
      
      panMaxSoftstopDeg: null,
      panMaxSoftstopEdited: null,
      tiltMaxSoftstopDeg: null,
      tiltMaxSoftstopEdited: null,

      panMinSoftstopDeg: null,
      panMinSoftstopEdited: null,
      tiltMinSoftstopDeg: null,
      tiltMinSoftstopEdited: null,



      panNowRatio: null,
      tiltNowRatio: null,
      panGoalRatio: null,
      tiltGoalRatio: null,
      panGoalRatioLast: null,
      tiltGoalRatioLast: null,
      panRatio: null,
      tiltRatio: null,
      speedRatio: null,

      reversePanEnabled: false,
      reverseTiltEnabled: false,

      autoPanEnabled: false,
      autoPanMin: -1,
      autoPanMax: 1,
      autoTiltEnabled: false,
      autoTiltMin: -1,
      autoTiltMax: 1,

      panScanMin: null,
      panScanMax: null,
      tiltScanMin: null,
      tiltScanMax: null,

      sinPanEnabled: false,
      sinTiltEnabled: false,

      speed_pan_dps: 0,
      speed_tilt_dps: 0,

      namespace : null,
      
      listener: null,
      disabled: true

    }

    //this.renderNavPose = this.renderNavPose.bind(this)
    //this.renderNavPoseInfo = this.renderNavPoseInfo.bind(this)

    this.onUpdateText = this.onUpdateText.bind(this)
    this.onKeyText = this.onKeyText.bind(this)
    this.createImageTopicsOptions = this.createImageTopicsOptions.bind(this)
    this.onImageTopicSelected = this.onImageTopicSelected.bind(this)
    this.onptxDeviceselected = this.onptxDeviceselected.bind(this)
    this.ptxStatusListener = this.ptxStatusListener.bind(this)
    this.renderControlPanel = this.renderControlPanel.bind(this)
    this.createPTXOptions = this.createPTXOptions.bind(this)
    this.onClickToggleShowLimits = this.onClickToggleShowLimits.bind(this)
    this.onClickToggleShowTransform = this.onClickToggleShowTransform.bind(this)
    this.getPanSpeed = this.getPanSpeed.bind(this)
    this.getTiltSpeed = this.getTiltSpeed.bind(this)

    this.onEnterSendScanRangeWindowValue = this.onEnterSendScanRangeWindowValue.bind(this)
  }

  onUpdateText(e) {
    var panElement = null
    var tiltElement = null
    var panMinElement = null
    var panMaxElement = null
    var tiltMinElement = null
    var tiltMaxElement = null
    if ((e.target.id === "PTXPanHomePos") || (e.target.id === "PTXTiltHomePos"))
    {
      panElement = document.getElementById("PTXPanHomePos")
      setElementStyleModified(panElement)
      
      tiltElement = document.getElementById("PTXTiltHomePos")
      setElementStyleModified(tiltElement)
      
      this.setState({panHomePosEdited: panElement.value,
                     tiltHomePosEdited: tiltElement.value})
    }
    else if ((e.target.id === "PTXPanSoftStopMin") || (e.target.id === "PTXPanSoftStopMax") ||
             (e.target.id === "PTXTiltSoftStopMin") || (e.target.id === "PTXTiltSoftStopMax"))
    {
      panMinElement = document.getElementById("PTXPanSoftStopMin")
      setElementStyleModified(panMinElement)

      panMaxElement = document.getElementById("PTXPanSoftStopMax")
      setElementStyleModified(panMaxElement)

      tiltMinElement = document.getElementById("PTXTiltSoftStopMin")
      setElementStyleModified(tiltMinElement)

      tiltMaxElement = document.getElementById("PTXTiltSoftStopMax")
      setElementStyleModified(tiltMaxElement)

      this.setState({panMinSoftstopEdited: panMinElement.value, panMaxSoftstopEdited: panMaxElement.value, 
                     tiltMinSoftstopEdited: tiltMinElement.value, tiltMaxSoftstopEdited: tiltMaxElement.value})
    }
    else if (e.target.id === "PTXPanGoto") 
      {
        panElement = document.getElementById("PTXPanGoto")
        setElementStyleModified(panElement)
             
        this.setState({panGotoDeg: panElement.value})
      }
        
    else if  (e.target.id === "PTXTiltGoto")
        {
          tiltElement = document.getElementById("PTXTiltGoto")
          setElementStyleModified(tiltElement)
               
          this.setState({tiltGotoDeg: tiltElement.value})                 
          
        }

  }

  onKeyText(e) {
    const {ptxDevices, onSetPTXGotoPos, onSetPTXGotoPanPos, onSetPTXGotoTiltPos, onSetPTXHomePos, onSetPTXSoftStopPos, onSetPTXHardStopPos} = this.props.ros
    const namespace = this.state.namespace

    const ptx_id = namespace? namespace.split('/').slice(-1) : "No Pan/Tilt Selected"
    const ptx_caps = ptxDevices[namespace]
    const has_sep_pan_tilt = ptx_caps && (ptx_caps.has_seperate_pan_tilt_control)
    var panElement = null
    var tiltElement = null
    var panMinElement = null
    var panMaxElement = null
    var tiltMinElement = null
    var tiltMaxElement = null
    if(e.key === 'Enter'){
      if ((e.target.id === "PTXPanHomePos") || (e.target.id === "PTXTiltHomePos"))
      {
        panElement = document.getElementById("PTXPanHomePos")
        clearElementStyleModified(panElement)
        
        tiltElement = document.getElementById("PTXTiltHomePos")
        clearElementStyleModified(tiltElement)
                
        onSetPTXHomePos(namespace, Number(panElement.value), Number(tiltElement.value))
        this.setState({panHomePosEdited:null, tiltHomePosEdited:null})
      }
      else if ((e.target.id === "PTXPanSoftStopMin") || (e.target.id === "PTXPanSoftStopMax") ||
               (e.target.id === "PTXTiltSoftStopMin") || (e.target.id === "PTXTiltSoftStopMax"))
      {
        panMinElement = document.getElementById("PTXPanSoftStopMin")
        clearElementStyleModified(panMinElement)

        panMaxElement = document.getElementById("PTXPanSoftStopMax")
        clearElementStyleModified(panMaxElement)

        tiltMinElement = document.getElementById("PTXTiltSoftStopMin")
        clearElementStyleModified(tiltMinElement)

        tiltMaxElement = document.getElementById("PTXTiltSoftStopMax")
        clearElementStyleModified(tiltMaxElement)

        onSetPTXSoftStopPos(namespace, Number(panMinElement.value), Number(panMaxElement.value), 
                            Number(tiltMinElement.value), Number(tiltMaxElement.value))
        this.setState({panMaxSoftstopEdited: null, panMinSoftstopEdited: null, tiltMaxSoftstopEdited: null, tiltMinSoftstopEdited: null})
      }
      else if (e.target.id === "PTXPanGoto") 
        {
          panElement = document.getElementById("PTXPanGoto")
          tiltElement = document.getElementById("PTXTiltGoto")
          clearElementStyleModified(panElement)
                        
          if (has_sep_pan_tilt === true){
            onSetPTXGotoPanPos(namespace, Number(panElement.value))
          }
          else {
            onSetPTXGotoPos(namespace, Number(panElement.value),Number(tiltElement.value))
          }
          
        }
        else if  (e.target.id === "PTXTiltGoto")
          {
            
            panElement = document.getElementById("PTXPanGoto")
            tiltElement = document.getElementById("PTXTiltGoto")
            clearElementStyleModified(tiltElement)
            if (has_sep_pan_tilt === true){
              onSetPTXGotoTiltPos(namespace, Number(tiltElement.value))
            }
            else {
              onSetPTXGotoPos(namespace, Number(panElement.value),Number(tiltElement.value))
            }                    
            
          }

    }
  }

  // Add the missing toggle method
  onClickToggleShowTransform() {
    this.setState({ showTransform: !this.state.showTransform })
  }

  // Function for creating image topic options.
  createImageTopicsOptions() {
    var items = []
    items.push(<Option>{"None"}</Option>) 
    const { imageTopics } = this.props.ros
    var imageTopicShortnames = createShortValuesFromNamespaces(imageTopics)
    for (var i = 0; i < imageTopics.length; i++) {
      items.push(<Option value={imageTopics[i]}>{imageTopicShortnames[i]}</Option>)
    }
    return items
  }

  // Handler for Image topic selection
  onImageTopicSelected(event) {
    var ind = event.nativeEvent.target.selectedIndex
    var text = event.nativeEvent.target[ind].text
    var value = event.target.value

    this.setState({
      imageTopic: value,
      imageText: text === "None" ? null : text,
    })
  }

  
  // Callback for handling ROS Status3DX messages
  ptxStatusListener(message) {
    const pan_min_ss = this.state.autoPanMin
    const pan_max_ss = this.state.autoPanMax
    const tilt_min_ss = this.state.autoTiltMin
    const tilt_max_ss = this.state.autoTiltMax
    const calculatedPanSpeed = this.getPanSpeed()
    const calculatedTiltSpeed = this.getTiltSpeed()

    this.setState({
      ptSerialNum: message.serial_num,
      ptHwVersion: message.hw_version,
      ptSwVersion: message.sw_version,
      panNowRatio: message.pan_now_ratio,
      tiltNowRatio: message.tilt_now_ratio,
      panGoalRatio: message.pan_goal_ratio,
      tiltGoalRatio: message.tilt_goal_ratio,
      speedRatio: message.speed_ratio,
      panPositionDeg: message.pan_now_deg,
      tiltPositionDeg: message.tilt_now_deg,
      panHomePosDeg: message.pan_home_pos_deg,
      tiltHomePosDeg: message.tilt_home_pos_deg,
      panMaxHardstopDeg: message.pan_max_hardstop_deg,
      tiltMaxHardstopDeg: message.tilt_max_hardstop_deg,
      panMinHardstopDeg: message.pan_min_hardstop_deg,
      tiltMinHardstopDeg: message.tilt_min_hardstop_deg,
      panMinSoftstopDeg: message.pan_min_softstop_deg,
      panMaxSoftstopDeg: message.pan_max_softstop_deg,
      tiltMinSoftstopDeg: message.tilt_min_softstop_deg,
      tiltMaxSoftstopDeg: message.tilt_max_softstop_deg,
      reversePanEnabled: message.reverse_pan_enabled,
      reverseTiltEnabled: message.reverse_tilt_enabled,
      autoPanEnabled: message.auto_pan_enabled,
      autoPanMin: message.auto_pan_range_window.start_range,
      autoPanMax: message.auto_pan_range_window.stop_range,
      autoTiltEnabled: message.auto_tilt_enabled,
      autoTiltMin: message.auto_tilt_range_window.start_range,
      autoTiltMax: message.auto_tilt_range_window.stop_range,
      sinPanEnabled: message.sin_pan_enabled,
      sinTiltEnabled: message.sin_tilt_enabled,
      speed_pan_dps: message.speed_pan_dps,
      speed_tilt_dps: message.speed_tilt_dps,
      calculatedPanSpeed: calculatedPanSpeed,
      calculatedTiltSpeed: calculatedTiltSpeed,

    })

    const scan_limits_changed = (pan_min_ss !== this.state.autoPanMin || pan_max_ss !== this.state.autoPanMax ||
                              tilt_min_ss !== this.state.autoTiltMin || tilt_max_ss !== this.state.autoTiltMax)
    if (scan_limits_changed === true){
      this.setState({panScanMin: message.auto_pan_range_window.start_range,
                     panScanMax: message.auto_pan_range_window.stop_range
      })
    }
    if (scan_limits_changed === true){
      this.setState({tiltScanMin: message.auto_tilt_range_window.start_range,
                     tiltScanMax: message.auto_tilt_range_window.stop_range
      })
    }
    
  }

  // Function for configuring and subscribing to ptx/status
  onptxDeviceselected(event) {
    if (this.state.listener) {
      this.state.listener.unsubscribe()
    }

    var ind = event.nativeEvent.target.selectedIndex
    var value = event.target.value

    // Handle the "None" option -- always index 0
    if (ind === 0) {
      this.setState({ disabled: true })
      return
    }

    this.setState({ namespace: value })

    var listener = this.props.ros.setupPTXStatusListener(
        value,
        this.ptxStatusListener
      )
      
    this.setState({ namespace: value, listener: listener, disabled: false })
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status3DX message
  componentWillUnmount() {
    if (this.state.listener) {
      this.state.listener.unsubscribe()
      this.setState({listener : null})
    }
  }

  // Function for creating topic options for Select input
  createPTXOptions(caps_dictionaries, filter) {
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
      device_name = filteredTopics[i].split('/ptx')[0].split('/').pop()
      items.push(<Option value={filteredTopics[i]}>{device_name}</Option>)
    }

    return items
  }


  onClickToggleShowLimits(){
    const currentVal = this.state.showLimits 
    this.setState({showLimits: !currentVal})
    this.render()
  }




onEnterSendScanRangeWindowValue(event, topicName, entryName, other_val) {
  const {publishRangeWindow} = this.props.ros
  const namespace = this.state.namespace

  const topic_namespace = namespace + topicName
  var min = -60
  var max = 60
  if(event.key === 'Enter'){
    const value = parseFloat(event.target.value)
    if (!isNaN(value)){
      if (entryName === "min"){
        min = value
        max = other_val
      }
      else if (entryName === "max"){
        min = other_val
        max = value
      }
      publishRangeWindow(topic_namespace,min,max,false)
    }
    document.getElementById(event.target.id).style.color = Styles.vars.colors.black
  }
}

getPanSpeed() {
  const panNow = Date.now();
  
  // Only calculate speed every 1000ms
  if (panNow - this.state.lastPanSpeedCalculation < 500) {
    return this.state.lastPanCalculatedSpeed || 0;
  }

  // Initialize on first call or if no previous data
  if (this.state.previousPanPosition === null || this.state.previousPanTimestamp === null) {
    this.setState({
      previousPanPosition: this.state.panPositionDeg,
      previousPanTimestamp: panNow,
      lastPanSpeedCalculation: panNow,
      lastPanCalculatedSpeed: 0
    });
    return 0; 
  }

  const currentPosition = this.state.panPositionDeg;
  
  // Calculate position difference and time difference
  const positionDiff = currentPosition - this.state.previousPanPosition;
  const timeDiff = (panNow - this.state.previousPanTimestamp) / 1000;
  
  // Calculate speed in degrees per second (only if time difference is reasonable)
  const panSpeed = (timeDiff > 0.01) ? positionDiff / timeDiff : 0;
  
  // Update state with new values for next calculation
  this.setState({
    previousPanPosition: currentPosition,
    previousPanTimestamp: panNow,
    lastPanSpeedCalculation: panNow,
    lastPanCalculatedSpeed: panSpeed
  });
  
  return panSpeed;
}

getTiltSpeed() {
  const now = Date.now();
  
  // Only calculate speed every 1000ms
  if (now - this.state.lastTiltSpeedCalculation < 500) {
    return this.state.lastTiltCalculatedSpeed || 0;
  }

  // Initialize on first call or if no previous data
  if (this.state.previousTiltPosition === null || this.state.previousTiltTimestamp === null) {
    this.setState({
      previousTiltPosition: this.state.tiltPositionDeg,
      previousTiltTimestamp: now,
      lastTiltSpeedCalculation: now,
      lastTiltCalculatedSpeed: 0
    });
    return 0; 
  }

  const currentPosition = this.state.tiltPositionDeg;
  
  // Calculate position difference and time difference
  const positionDiff = currentPosition - this.state.previousTiltPosition;
  const timeDiff = (now - this.state.previousTiltTimestamp) / 1000;
  
  // Calculate speed in degrees per second (only if time difference is reasonable)
  const speed = (timeDiff > 0.01) ? positionDiff / timeDiff : 0;
  
  // Update state with new values for next calculation
  this.setState({
    previousTiltPosition: currentPosition,
    previousTiltTimestamp: now,
    lastTiltSpeedCalculation: now,
    lastTiltCalculatedSpeed: speed
  });
  
  return speed;
}


  renderControlPanel() {
    const { ptxDevices, sendBoolMsg, onPTXGoHome, onPTXSetHomeHere } = this.props.ros
    
    const { ptSerialNum, ptHwVersion, ptSwVersion,
            panPositionDeg, tiltPositionDeg, panHomePosDeg, tiltHomePosDeg,
            panMaxHardstopDeg, tiltMaxHardstopDeg, panMinHardstopDeg, tiltMinHardstopDeg,
            panMinHardstopEdited, tiltMinHardstopEdited, panMaxHardstopEdited, tiltMaxHardstopEdited,
            panMaxSoftstopDeg, tiltMaxSoftstopDeg, panMinSoftstopDeg, tiltMinSoftstopDeg,
            panMinSoftstopEdited, tiltMinSoftstopEdited, panMaxSoftstopEdited, tiltMaxSoftstopEdited,
            speedRatio, panHomePosEdited, tiltHomePosEdited,
            reversePanEnabled, reverseTiltEnabled, autoPanEnabled, autoTiltEnabled,sinPanEnabled ,sinTiltEnabled, speed_pan_dps, speed_tilt_dps  } = this.state

    const namespace = this.state.namespace
    const ptx_id = namespace? namespace.split('/').slice(-1) : "No Pan/Tilt Selected"

    const panPositionDegClean = panPositionDeg + .001
    const tiltPositionDegClean = tiltPositionDeg + .001

    const ptx_caps = ptxDevices[namespace]
    const has_abs_pos = ptx_caps && (ptx_caps.has_absolute_positioning)
    const has_timed_pos = ptx_caps && (ptx_caps.has_timed_positioning)
    const has_sep_pan_tilt = ptx_caps && (ptx_caps.has_seperate_pan_tilt_control)
    const has_auto_pan = ptx_caps && (ptx_caps.has_auto_pan)
    const has_auto_tilt = ptx_caps && (ptx_caps.has_auto_tilt)
    const has_speed_control = ptx_caps && (ptx_caps.has_adjustable_speed)
    const has_homing = ptx_caps && (ptx_caps.has_homing)
    const has_set_home = ptx_caps && (ptx_caps.has_set_home)
    
    const panHomePos = (panHomePosEdited === null)? round(panHomePosDeg, 1) : panHomePosEdited
    const tiltHomePos = (tiltHomePosEdited === null)? round(tiltHomePosDeg, 1) : tiltHomePosEdited

    const panHardStopMin = (panMinHardstopEdited === null)? round(panMinHardstopDeg, 1) : panMinHardstopEdited
    const tiltHardStopMin = (tiltMinHardstopEdited === null)? round(tiltMinHardstopDeg, 1) : tiltMinHardstopEdited
    const panHardStopMax = (panMaxHardstopEdited === null)? round(panMaxHardstopDeg, 1) : panMaxHardstopEdited
    const tiltHardStopMax = (tiltMaxHardstopEdited === null)? round(tiltMaxHardstopDeg, 1) : tiltMaxHardstopEdited


    const panSoftStopMin = (panMinSoftstopEdited === null)? round(panMinSoftstopDeg, 1) : panMinSoftstopEdited
    const tiltSoftStopMin = (tiltMinSoftstopEdited === null)? round(tiltMinSoftstopDeg, 1) : tiltMinSoftstopEdited
    const panSoftStopMax = (panMaxSoftstopEdited === null)? round(panMaxSoftstopDeg, 1) : panMaxSoftstopEdited
    const tiltSoftStopMax = (tiltMaxSoftstopEdited === null)? round(tiltMaxSoftstopDeg, 1) : tiltMaxSoftstopEdited

    const hide_auto_pan = ((has_auto_pan === false || has_abs_pos === false) || (has_sep_pan_tilt === false && autoTiltEnabled == true))
    const hide_auto_tilt = ((has_auto_tilt === false || has_abs_pos === false) || (has_sep_pan_tilt === false && autoPanEnabled == true))
    const {sendTriggerMsg} = this.props.ros

    return (
      <Section title={ptx_id} >


        <Label title={"Serial Number"}>
          <Input disabled={true} value={ptSerialNum}/>
        </Label>
        <Label title={"H/W Rev."}>
          <Input disabled={true} value={ptHwVersion}/>
        </Label>
        <Label title={"S/W Rev."}>
          <Input disabled={true} value={ptSwVersion}/>
        </Label>
        
        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Angles in ENU frame (Tilt+:Down , Pan+:Left)"}
         </label>



        <Label title={""}>
          <div style={{ display: "inline-block", width: "45%", float: "left" }}>{"Pan"}</div>
          <div style={{ display: "inline-block", width: "45%", float: "left" }}>{"Tilt"}</div>
        </Label>

          <Label title={"Reverse Control"}>
            <div style={{ display: "inline-block", width: "45%", float: "left" }}>
              <Toggle style={{justifyContent: "flex-left"}} checked={reversePanEnabled} onClick={() => sendBoolMsg.bind(this)(namespace + "/set_reverse_pan_enable",!reversePanEnabled)} />
            </div>
            <div style={{ display: "inline-block", width: "45%", float: "right" }}>
              <Toggle style={{justifyContent: "flex-right"}} checked={reverseTiltEnabled} onClick={() => sendBoolMsg.bind(this)(namespace + "/set_reverse_tilt_enable",!reverseTiltEnabled)} />
            </div>
          </Label>



        <div hidden={(has_speed_control === false)}>

        <SliderAdjustment
          disabled={!has_speed_control}
          title={"Speed"}
          msgType={"std_msgs/Float32"}
          adjustment={speedRatio}
          topic={namespace + "/set_speed_ratio"}
          scaled={0.01}
          min={0}
          max={100}
          tooltip={"Speed as a percentage (0%=min, 100%=max)"}
          unit={"%"}
        />

        </div>

        <div hidden={(has_abs_pos === false)}>

        <Label title={"Present Position"}>
          <Input
            disabled
            style={{ width: "45%", float: "left" }}
            value={round(panPositionDegClean, 2)}
          />
          <Input
            disabled
            style={{ width: "45%" }}
            value={round(tiltPositionDegClean, 2)}
          />
        </Label>


        <Label title={"Current Speed (Deg/Sec)"}>
          <Input
            disabled
            style={{ width: "45%", float: "left" }}
            value={round(speed_pan_dps, 0)}
          />
          <Input
            disabled
            style={{ width: "45%" }}
            value={round(speed_tilt_dps, 0)}
          />
        </Label>

        <Label title={"Current Speed (Java)"}>
          <Input
            disabled
            style={{ width: "45%", float: "left" }}
            value={Math.abs(round(this.getPanSpeed()), 0)}
          />
          <Input
            disabled
            style={{ width: "45%" }}
            value={Math.abs(round(this.getTiltSpeed()), 0)}
          />
        </Label>

        <Label title={"GoTo Position"}>
          <Input
            disabled={!has_abs_pos}
            id={"PTXPanGoto"}
            style={{ width: "45%", float: "left" }}
            value={this.state.panGotoDeg}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
          <Input
            disabled={!has_abs_pos}
            id={"PTXTiltGoto"}
            style={{ width: "45%" }}
            value={this.state.tiltGotoDeg}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
        </Label>

        </div>

        <div hidden={(has_homing === false)}>

        <Label title={"Home Position"}>
          <Input
            disabled={!has_homing}
            id={"PTXPanHomePos"}
            style={{ width: "45%", float: "left" }}
            value={panHomePos}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
          <Input
            disabled={!has_homing}
            id={"PTXTiltHomePos"}
            style={{ width: "45%" }}
            value={tiltHomePos}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
        </Label>


        <ButtonMenu>
          <Button disabled={!has_homing} onClick={() => onPTXGoHome(namespace)}>{"Go Home"}</Button>
          <Button disabled={!has_homing} onClick={() => onPTXSetHomeHere(namespace)}>{"Set Home Here"}</Button>
        </ButtonMenu>

      </div>

        <div hidden={(hide_auto_pan === true)}>
        <div
          style={{
            borderTop: "1px solid #ffffff",
            marginTop: Styles.vars.spacing.medium,
            marginBottom: Styles.vars.spacing.xs,
          }}
        />
        </div>

        <Label title={""}>
          <div style={{ display: "inline-block", width: "45%", float: "left" }}>{"Pan"}</div>
          <div style={{ display: "inline-block", width: "45%", float: "left" }}>{"Tilt"}</div>
        </Label>
        <Label title={"Enable Auto Scan"}>
        <div hidden={(hide_auto_pan === true)}>
          <div style={{ display: "inline-block", width: "45%", float: "left" }}>
            <Toggle style={{justifyContent: "flex-left"}} checked={autoPanEnabled} onClick={() => sendBoolMsg.bind(this)(namespace + "/set_auto_pan_enable",!autoPanEnabled)} />
          </div>
          </div>

          <div hidden={(hide_auto_tilt === true)}>
          <div style={{ display: "inline-block", width: "45%", float: "right" }}>
            <Toggle style={{justifyContent: "flex-right"}} checked={autoTiltEnabled} onClick={() => sendBoolMsg.bind(this)(namespace + "/set_auto_tilt_enable",!autoTiltEnabled)} />
          </div>
          </div>
        </Label>

        <div hidden={(autoPanEnabled === false && autoTiltEnabled === false)}>
        <Label title={"Enable Sin Scan"}>

        <div hidden={(autoPanEnabled === false)}>
          <div style={{ display: "inline-block", width: "45%", float: "left" }}>
            <Toggle
              checked={this.state.sinPanEnabled}
              onClick={() => sendBoolMsg(namespace + "/set_auto_pan_sin_enable", !this.state.sinPanEnabled)
              }
            />
          </div>
        </div>

        <div hidden={(autoTiltEnabled === false)}>
          <div style={{ display: "inline-block", width: "45%", float: "right" }}>
            <Toggle
              checked={this.state.sinTiltEnabled}
              onClick={() => sendBoolMsg(namespace + "/set_auto_tilt_sin_enable", !this.state.sinTiltEnabled)
              }
            />
          </div>
        </div>
          </Label>
        </div>

        <Label title={"Min Scan Limits"}>

          <Input id="scan_pan_min" 
              value={this.state.panScanMin} 
              style={{ width: "45%", float: "left" }}
              onChange={(event) => onUpdateSetStateValue.bind(this)(event,"panScanMin")} 
              onKeyDown= {(event) => this.onEnterSendScanRangeWindowValue(event,"/set_auto_pan_window","min",Number(this.state.panScanMax))} />

          <Input id="scan_tilt_min" 
              value={this.state.tiltScanMin} 
              style={{ width: "45%" }}
              onChange={(event) => onUpdateSetStateValue.bind(this)(event,"tiltScanMin")} 
              onKeyDown= {(event) => this.onEnterSendScanRangeWindowValue(event,"/set_auto_tilt_window","min",Number(this.state.tiltScanMax))} />

          
        </Label>






        <Label title={"Max Scan Limits"}>

          <Input id="scan_pan_max" 
            value={this.state.panScanMax} 
            style={{ width: "45%", float: "left" }}
            onChange={(event) => onUpdateSetStateValue.bind(this)(event,"panScanMax")} 
            onKeyDown= {(event) => this.onEnterSendScanRangeWindowValue(event,"/set_auto_pan_window","max",Number(this.state.panScanMin))} />     


          <Input id="scan_tilt_max" 
              value={this.state.tiltScanMax} 
              style={{ width: "45%" }}
              onChange={(event) => onUpdateSetStateValue.bind(this)(event,"tiltScanMax")} 
              onKeyDown= {(event) => this.onEnterSendScanRangeWindowValue(event,"/set_auto_tilt_window","max",Number(this.state.tiltScanMin))} />                      
        </Label>
        <div hidden={(hide_auto_tilt === true)}>

        </div>


        <Columns>
          <Column>

            <Label title="Show Limits">
                    <Toggle
                      checked={this.state.showLimits===true}
                      onClick={this.onClickToggleShowLimits}>
                    </Toggle>
                  </Label>


             
          </Column>
          <Column>
 

          </Column>
        </Columns>


        <div hidden={(this.state.showLimits === false  || has_abs_pos === false)}>

        <Label title={"Hard Limit Min"}>
          <Input
            disabled={!has_abs_pos}
            id={"PTXPanHardStopMin"}
            style={{ width: "45%", float: "left" }}
            value={panHardStopMin}
          />
          <Input
            disabled={!has_abs_pos}
            id={"PTXTiltHardStopMin"}
            style={{ width: "45%" }}
            value={tiltHardStopMin}
          />
        </Label>

        <Label title={"Hard Limit Max"}>
          <Input
            disabled={!has_abs_pos}
            id={"PTXPanHardStopMax"}
            style={{ width: "45%", float: "left" }}
            value={panHardStopMax}
          />
          <Input
            disabled={!has_abs_pos}
            id={"PTXTiltHardStopMax"}
            style={{ width: "45%" }}
            value={tiltHardStopMax}
          />
        </Label>


        <Label title={"Soft Limit Min"}>
          <Input
            disabled={!has_abs_pos}
            id={"PTXPanSoftStopMin"}
            style={{ width: "45%", float: "left" }}
            value={panSoftStopMin}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
          <Input
            disabled={!has_abs_pos}
            id={"PTXTiltSoftStopMin"}
            style={{ width: "45%" }}
            value={tiltSoftStopMin}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
        </Label>
        <Label title={"Soft Limit Max"}>
          <Input
            disabled={!has_abs_pos}
            id={"PTXPanSoftStopMax"}
            style={{ width: "45%", float: "left" }}
            value={panSoftStopMax}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
          <Input
            disabled={!has_abs_pos}
            id={"PTXTiltSoftStopMax"}
            style={{ width: "45%" }}
            value={tiltSoftStopMax}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
        </Label>

        </div>

        <div
              style={{
                borderTop: "1px solid #ffffff",
                marginTop: Styles.vars.spacing.medium,
                marginBottom: Styles.vars.spacing.xs,
              }}
            />
            <Label title="Show 3D Transform">
              <Toggle
                checked={this.state.showTransform}
                onClick={this.onClickToggleShowTransform}>
              </Toggle>
            </Label>

            <div hidden={ this.state.showTransform === false}>

            <Columns>
              <Column>

                      <NepiIF3DTransform
                          namespace={namespace}
                          supports_updates={true}
                          title={"Nepi_IF_3DTransform"}
                      />

              </Column>
           </Columns>

            </div>



      </Section>
    )
  }


renderNavPose(){
  const show_navpose = this.state.show_navpose
  const namespace = this.state.namespace ? this.state.namespace : 'None'
  const make_section = this.props.make_section ? this.props.make_section : true
  //console.log("show navpose: " + show_navpose)
  //console.log("renderNavPose namespace : " + namespace)
  if (namespace == null || namespace === 'None'){
    return(
  
      <Columns>
      <Column>

      </Column>
      </Columns>
  
    )
  }
  else{
    return (

      <Section>
            <Columns>
            <Column>
                  <Label title="Show NavPose">
                      <Toggle
                        checked={this.state.show_navpose===true}
                        onClick={() => onChangeSwitchStateValue.bind(this)("show_navpose",this.state.show_navpose)}>
                      </Toggle>
                    </Label>            

                    </Column>
                    <Column>

                    </Column>
                    <Column>

                    </Column>
                    </Columns>
                    <div align={"left"} textAlign={"left"} hidden={!this.state.show_navpose}>

                  <NavPoseViewer
                    namespace={(show_navpose === true) ? namespace : null}
                    make_section={false}
                    title={"PTX NavPose Data"}
                  />
                  </div>

                </Section>
              )  
            }
          }




  render() {
    const { ptxDevices, onPTXJogPan, onPTXJogTilt, onPTXStop, sendTriggerMsg } = this.props.ros
    const { panNowRatio, panGoalRatio, tiltNowRatio, tiltGoalRatio} = this.state
    const namespace = this.state.namespace

    const ptxImageViewerElement = document.getElementById("ptxImageViewer")
    const tiltSliderHeight = (ptxImageViewerElement)? ptxImageViewerElement.offsetHeight : "100px"

    const ptx_caps = ptxDevices[namespace]
    const has_abs_pos = ptx_caps && (ptx_caps.has_absolute_positioning === true)
    const has_timed_pos = ptx_caps && (ptx_caps.has_timed_positioning === true)
    const show_navpose = this.state.show_navpose
    const device_selected = (this.state.namespace != null)

    console.log("render namespace : " + namespace)

    

    return (
      <React.Fragment>
        <Columns>
          <Column equalWidth = {false} >



                <div hidden={(namespace === null)}>
                      <NepiDeviceInfo
                            deviceNamespace={namespace}
                            status_topic={"/status"}
                            status_msg_type={"nepi_interfaces/DevicePTXStatus"}
                            name_update_topic={"/update_device_name"}
                            name_reset_topic={"/reset_device_name"}
                            title={"NepiSensorsImagingInfo"}
                        />
                </div>
                

                <div id="ptxImageViewer">
                  <ImageViewer
                    id="ptxImageViewer"
                    imageTopic={this.state.imageTopic}
                    title={this.state.imageText}
                    hideQualitySelector={false}
                  />
                </div>
                <SliderAdjustment
                  disabled={!has_abs_pos}
                  title={"Pan"}
                  msgType={"std_msgs/Float32"}
                  adjustment={panGoalRatio}
                  topic={namespace + "/goto_pan_ratio"}
                  scaled={0.01}
                  min={0}
                  max={100}
                  tooltip={"Pan as a percentage (0%=min, 100%=max)"}
                  unit={"%"}
                  noTextBox={true}
                  noLabel={true}
                />

              <div hidden={(has_timed_pos === false)}>

              <ButtonMenu>

                  <Button 
                    buttonDownAction={() => onPTXJogPan(namespace,  1)}
                    buttonUpAction={() => onPTXStop(namespace)}>
                    {'\u25C0'}
                    </Button>
                  <Button 
                    buttonDownAction={() => onPTXJogPan(namespace, - 1)}
                    buttonUpAction={() => onPTXStop(namespace)}>
                    {'\u25B6'}
                  </Button>
                  <Button 
                    buttonDownAction={() => onPTXJogTilt(namespace, 1)}
                    buttonUpAction={() => onPTXStop(namespace)}>
                    {'\u25B2'}
                  </Button>
                  <Button 
                    buttonDownAction={() => onPTXJogTilt(namespace, -1)}
                    buttonUpAction={() => onPTXStop(namespace)}>
                    {'\u25BC'}
                  </Button>

                </ButtonMenu>


                </div>



                <ButtonMenu>

                  <Button onClick={() => onPTXStop(namespace)}>{"STOP"}</Button>
                  
                </ButtonMenu>

                {this.renderNavPose()}

            <NepiSystemMessages
              messagesNamespace={namespace}
              title={"NepiSystemMessages"}
              />

          </Column>
          <Column style={{flex: 0.05}}>

          <div style={{ height: '155px' }}></div>

            <SliderAdjustment
              disabled={!has_abs_pos}
              title={"Tilt"}
              msgType={"std_msgs/Float32"}
              adjustment={tiltGoalRatio}
              topic={namespace + "/goto_tilt_ratio"}
              scaled={0.01}
              min={0}
              max={100}
              tooltip={"Tilt as a percentage (0%=min, 100%=max)"}
              unit={"%"}
              vertical={true}
              verticalHeight={tiltSliderHeight}
              noTextBox={true}
              noLabel={true}
            />
          </Column>
          <Column>
            <Label title={"Device"}>
              <Select
                onChange={this.onptxDeviceselected}
                value={namespace}
              >
                {this.createPTXOptions(ptxDevices)}
              </Select>
            </Label>
            <Label title={"Select Image"}>
              <Select
                id="ptxImageTopicSelect"
                onChange={this.onImageTopicSelected}
                value={this.state.imageTopic}
              >
              {this.createImageTopicsOptions()}
              </Select>
            </Label>


            <div align={"left"} textAlign={"left"} hidden={namespace == null}>
              
                  <NepiIFConfig
                        namespace={namespace}
                        title={"Nepi_IF_SaveConif"}
                  />

            </div>


            { namespace?
              this.renderControlPanel()
              : null
            }

            <div hidden={(namespace == null)}>
              <NepiIFSettings
                namespace={namespace}
                title={"Nepi_IF_Settings"}
              />
            </div>


          </Column>
        </Columns>
      </React.Fragment>
    )
  }
}

export default NepiDevicePTX
