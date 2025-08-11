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
import Select, { Option } from "./Select"

//import EnableAdjustment from "./EnableAdjustment"
import Styles from "./Styles"
import Button, { ButtonMenu } from "./Button"
import RangeAdjustment from "./RangeAdjustment"
import {RadioButtonAdjustment, SliderAdjustment} from "./AdjustmentWidgets"
import Toggle from "react-toggle"
import Label from "./Label"
import Input from "./Input"
import { Column, Columns } from "./Columns"
import { round, createShortUniqueValues, onUpdateSetStateValue, onEnterSetStateFloatValue, onChangeSwitchStateNestedValue } from "./Utilities"

import NepiDeviceInfo from "./Nepi_IF_DeviceInfo"
import NepiIFSettings from "./Nepi_IF_Settings"
import NepiIFSaveData from "./Nepi_IF_SaveData"
import NepiIFNavPoseViewer from "./Nepi_IF_NavPoseViewer"
import NepiIFConfig from "./Nepi_IF_Config"

import moment from "moment"


@inject("ros")
@observer

// NPX Application page
class MgrNavPose extends Component {
  constructor(props) {
    super(props)


    //const namespaces = Object.keys(props.ros.npxDevices)

    this.state = {


      mgrName: "navpose_mgr",
      namespace: null,
      base_namespace: null,

      message: null,

      listener: null,

      disabled: false,

      connected: false,
      statusListener: null,
      status_msg: null,

      navposeListener: null,
      navpose_msg: null,
/*
      fixedDict: {
        location: {
          fixed: false,
          npData: this.props.ros.blankNavPose
        },
        heading:  {
          fixed: false,
          npData: this.props.ros.blankNavPose
        },
        orientation:  {
          fixed: false,
          npData: this.props.ros.blankNavPose
        },
        position:  {
          fixed: false,
          npData: this.props.ros.blankNavPose
        },
        altitude:  {
          fixed: false,
          npData: this.props.ros.blankNavPose
        },
        depth:  {
          fixed: false,
          npData: this.props.ros.blankNavPose
        }
*/
  location_fixed: false,
  heading_fixed: false,
  orientation_mode: false,
  position_fixed: false,
  altitude_fixed: false,
  depth_fixed: false,
  
  fixed_npData_frame_3d: 'nepi_frame',
  fixed_npData_frame_nav: 'ENU',
  fixed_npData_frame_altitude: 'WGS84',
  fixed_npData_frame_depth: 'MSL',
  
  fixed_npData_geoid_height_meters: 0.0,
  
  fixed_npData_has_location: false,
  fixed_npData_time_location: moment.utc().unix(),
  fixed_npData_latitude: 0.0,
  fixed_npData_longitude: 0.0,
  
  fixed_npData_has_heading: false,
  fixed_npData_time_heading: moment.utc().unix(),
  fixed_npData_heading_deg: 0.0,
  
  fixed_npData_has_position: false,
  fixed_npData_time_position: moment.utc().unix(),
  fixed_npData_x_m: 0.0,
  fixed_npData_y_m: 0.0,
  fixed_npData_z_m: 0.0,
  
  fixed_npData_has_orientation: false,
  fixed_npData_time_orientation: moment.utc().unix(),
  fixed_npData_roll_deg: 0.0,
  fixed_npData_pitch_deg: 0.0,
  fixed_npData_yaw_deg: 0.0,
  
  fixed_npData_has_altitude: false,
  fixed_npData_time_altitude: moment.utc().unix(),
  fixed_npData_altitude_m: 0.0,
  
  fixed_npData_has_depth: false,
  fixed_npData_time_depth: moment.utc().unix(),
  fixed_npData_depth_m: 0.0,

      showTransformsDict: {
        location: false,
        heading: false,
        orientation: false,
        position: false,
        altitude: false,
        depth: false
      },


      transformsDict: {
        location: { 
          transfroms_msg: null,
          transformTX: 0,
          transformTY: 0,
          transformTZ: 0,
          transformRX: 0,
          transformRY: 0,
          transformRZ: 0,
          transformHO: 0
          },
        heading: { 
          transfroms_msg: null,
          transformTX: 0,
          transformTY: 0,
          transformTZ: 0,
          transformRX: 0,
          transformRY: 0,
          transformRZ: 0,
          transformHO: 0
          },
        orientation: { 
          transfroms_msg: null,
          transformTX: 0,
          transformTY: 0,
          transformTZ: 0,
          transformRX: 0,
          transformRY: 0,
          transformRZ: 0,
          transformHO: 0
          },
        position: { 
          transfroms_msg: null,
          transformTX: 0,
          transformTY: 0,
          transformTZ: 0,
          transformRX: 0,
          transformRY: 0,
          transformRZ: 0,
          transformHO: 0
          },
        altitude: { 
          transfroms_msg: null,
          transformTX: 0,
          transformTY: 0,
          transformTZ: 0,
          transformRX: 0,
          transformRY: 0,
          transformRZ: 0,
          transformHO: 0
          },
        depth: { 
          transfroms_msg: null,
          transformTX: 0,
          transformTY: 0,
          transformTZ: 0,
          transformRX: 0,
          transformRY: 0,
          transformRZ: 0,
          transformHO: 0
          }
      },
     

      needs_update: true,
      nav_needs_update: true  
    }


    this.getBaseNamespace = this.getBaseNamespace.bind(this)
    this.getMgrNamespace = this.getMgrNamespace.bind(this)

    this.renderMgrFixedControls = this.renderMgrFixedControls.bind(this)
    this.renderMgrTopicControls = this.renderMgrTopicControls.bind(this)

    /*
    this.getShowTransform = this.getShowTransform.bind(this)
    this.setShowTransform = this.setShowTransform.bind(this)
    */
    this.sendTransformUpdateMessage = this.sendTransformUpdateMessage.bind(this)
    this.sendTransformClearMessage = this.sendTransformClearMessage.bind(this)


    this.statusListener = this.statusListener.bind(this)
    this.navposeListener = this.navposeListener.bind(this)
    this.updateStatusListener = this.updateStatusListener.bind(this)
    this.updateNavposeListener = this.updateNavposeListener.bind(this)
    
  }

    
  getBaseNamespace(){
    //console.log("=====getBaseNamespace called=====")

    const { namespacePrefix, deviceId} = this.props.ros
    var baseNamespace = null
    if (namespacePrefix !== null && deviceId !== null){
      baseNamespace = "/" + namespacePrefix + "/" + deviceId 
    }
    //console.log("BaseNamespace: " + baseNamespace)

    return baseNamespace
  }


  getMgrNamespace(){
    const { namespacePrefix, deviceId} = this.props.ros
    var namespace = null
    if (namespacePrefix !== null && deviceId !== null){
      namespace = "/" + namespacePrefix + "/" + deviceId + "/" + this.state.mgrName
    }
    return namespace
  }





  // Callback for handling ROS StatusNPX messages
  statusListener(message) {
    //console.log("=====statusListener called=====")
    //console.log("statusListener msg: ", message);

    const last_status_msg = this.state.status_msg
    this.setState({
      status_msg: message, 
      connected: true
    })

    var has_changed = false
    const comp_infos = message.comp_infos
    const last_comp_infos = (last_status_msg != null) ?
                         last_status_msg.comp_infos : message.comp_infos
    for (var i = 0; i < comp_infos.length; i++) {
      const comp_info = comp_infos[i]
      const name = comp_info.name
      const last_comp_info = last_comp_infos[i]

      const fixed = comp_info.fixed
      const last_fixed = last_comp_info.fixed
      has_changed = (last_status_msg == null) ? true :
                            (last_fixed !== fixed)
      if (has_changed === true){
        this.setState({
          [name + '_fixed']: fixed
        })      }
      
      const transform_msg = comp_info.transform
      const last_transform_msg = last_comp_info.transform
      has_changed = (last_status_msg == null) ? true :
                           (last_transform_msg !== transform_msg)
      if (has_changed === true){
        this.state.transformsDict[name]['transform_msg'] = transform_msg,
        this.state.transformsDict[name]['transformTX'] = transform_msg.translate_vector.x,
        this.state.transformsDict[name]['transformTY'] = transform_msg.translate_vector.y,
        this.state.transformsDict[name]['transformTZ'] = transform_msg.translate_vector.z,
        this.state.transformsDict[name]['transformRX'] = transform_msg.rotate_vector.x,
        this.state.transformsDict[name]['transformRY'] = transform_msg.rotate_vector.y,
        this.state.transformsDict[name]['transformRZ'] = transform_msg.rotate_vector.z,
        this.state.transformsDict[name]['transformHO'] = transform_msg.heading_offset
      }
    }

  }

  navposeListener(message) {
    //console.log("=====navposeListener called=====" + message)
    //console.log("navposeListener msg: " + message)
    const last_navpose_msg = this.state.navpose_msg
    const navpose_data = {
      frame_3d: message.frame_3d,
      frame_nav: message.frame_nav,
      frame_alt: message.frame_alt,
      latitude: message.latitude,
      longitude: message.longitude,
      altitude: message.altitude_m,
      heading: message.heading_deg,
      roll: message.roll_deg,
      pitch: message.pitch_deg,
      yaw: message.yaw_deg,
      x_m: message.x_m,
      y_m: message.y_m,
      z_m: message.z_m
    }
        
    this.setState({
      navpose_msg: message,
      navpose_data: navpose_data, 
      connected: true
    })

    var name = ''
    var fixed = false
    var changed = false
    var navpose = null
    const navpose_msg = message

/*
    name = 'location'
    fixed = this.state[name + '_fixed']
    navpose = this.state.fixedDict[name]['npData']
    if (fixed === true){
      changed = last_navpose_msg == null ? true:
                ((navpose_msg.latitude !== last_navpose_msg.latitude) ||
                (navpose_msg.longitude !== last_navpose_msg.longitude))
      if (changed === true){
        this.setState({
          fixed_npData_latitude: navpose_msg.latitude
        })
      this.state.fixedDict[name]['npData']['longitude'] = navpose_msg.longitude
      }
    }

    name = 'heading'
    fixed = this.state[name + '_fixed']
    navpose = this.state.fixedDict[name]['npData']
    if (fixed === true){
      changed = last_navpose_msg == null ? true:
                ((navpose_msg.heading_deg !== last_navpose_msg.heading_deg))
      if (changed === true){
        this.state.fixedDict[name]['npData']['heading_deg'] = navpose_msg.heading_deg
      }
    }

    name = 'orientation'
    fixed = this.state[name + '_fixed']
    navpose = this.state.fixedDict[name]['npData']
    if (fixed === true){
      changed = last_navpose_msg == null ? true:
                ((navpose_msg.roll_deg !== last_navpose_msg.roll_deg) ||
                (navpose_msg.pitch_deg !== last_navpose_msg.pitch_deg)||
                (navpose_msg.yaw_deg !== last_navpose_msg.yaw_deg))
      if (changed === true){
        this.state.fixedDict[name]['npData']['roll_deg'] = navpose_msg.roll_deg
        this.state.fixedDict[name]['npData']['pitch_deg'] = navpose_msg.pitch_deg
        this.state.fixedDict[name]['npData']['yaw_deg'] = navpose_msg.yaw_deg
      }
    }

    name = 'position'
    fixed = this.state[name + '_fixed']
    navpose = this.state.fixedDict[name]['npData']
    if (fixed === true){
      changed = last_navpose_msg == null ? true:
                ((navpose_msg.x_m !== last_navpose_msg.x_m) ||
                (navpose_msg.y_m !== last_navpose_msg.y_m)||
                (navpose_msg.z_m !== last_navpose_msg.z_m))
      if (changed === true){
        this.state.fixedDict[name]['npData']['x_m'] = navpose_msg.x_m
        this.state.fixedDict[name]['npData']['y_m'] = navpose_msg.y_m
        this.state.fixedDict[name]['npData']['z_m'] = navpose_msg.z_m
      }
    }


      name = 'altitude'
      fixed = this.state[name + '_fixed']
      navpose = this.state.fixedDict[name]['npData']
      if (fixed === true){
        changed = last_navpose_msg == null ? true:
                 ((navpose_msg.altitude_m !== last_navpose_msg.altitude_m) )
        if (changed === true){
          this.state.fixedDict[name]['npData']['altitude_m'] = navpose_msg.altitude_m
        }
      }

      name = 'depth'
      fixed = this.state[name + '_fixed']
      navpose = this.state.fixedDict[name]['npData']
      if (fixed === true){
        changed = last_navpose_msg == null ? true:
                  ((navpose_msg.depth_m !== last_navpose_msg.depth_m) )
        if (changed === true){
          this.state.fixedDict[name]['npData']['depth_m'] = navpose_msg.depth_m
        }
      }

*/

  }

  updateStatusListener() {
    //console.log("=====updateStatusListener called=====");
    const namespace = this.state.base_namespace + "/" + this.state.mgrName;
    const topic = namespace + "/status";
    //console.log("Attempting to subscribe to:", topic);
    //console.log("Expected message type: nepi_interfaces/MgrNavPoseStatus");
    
    // Add error handling
    try {
      var statusListener = this.props.ros.setupStatusListener(
        topic,
        "nepi_interfaces/MgrNavPoseStatus",
        this.statusListener 
      );
      
      this.setState({ 
        statusListener: statusListener,
        needs_update: false 
      });
      //console.log("Status listener setup successful");
    } catch (error) {
      console.error("Failed to setup status listener:", error);
    }
  }

updateNavposeListener() {
  //console.log("=====updateNavposeListener called=====")

  const namespace = this.state.base_namespace
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
  componentDidUpdate(prevProps, prevState, snapshot) {
    const namespace = this.getMgrNamespace()
    const base_namespace = this.getBaseNamespace()
    if (prevState.namespace !== namespace){
      if (namespace != null) {
        this.setState({
          namespace: namespace,
          base_namespace: base_namespace
        })
        this.updateStatusListener()
        this.updateNavposeListener()
      } else if (namespace == null){
        this.setState({ disabled: true })
      }
    //console.log("Namespace check:", this.getMgrNamespace(), this.getBaseNamespace(), this.props.ros);

    }
  }

  componentDidMount() {
    //console.log("Component mounted, checking connection...");
    //console.log("namespacePrefix:", this.props.ros.namespacePrefix);
    //console.log("deviceId:", this.props.ros.deviceId);
    this.checkConnection();
  }
  
  
  async checkConnection() {
    const { namespacePrefix, deviceId } = this.props.ros;
    if (namespacePrefix != null && deviceId != null) {
      const namespace = this.getMgrNamespace();
      const base_namespace = this.getBaseNamespace();
  
      this.setState({
        namespace: namespace,
        base_namespace: base_namespace
      }, () => {
        this.updateStatusListener();
        this.updateNavposeListener();
      });
  
    } else {
      setTimeout(() => {
        this.checkConnection();
      }, 1000);
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
  createTopicOptions(name) {
    const namespace = this.state.namespace
    const status_msg = this.state.status_msg

    var items = []
    items.push(<Option value={'Fixed'}>{'Fixed'}</Option>)
    if (status_msg != null){
  
      const comp_names = status_msg.comp_names
      const comp_infos = status_msg.comp_infos
      const index = comp_names.indexOf(name)
    
      if (index !== -1){
        const infos = comp_infos[index]
        const topics = infos.available_topics
        for (var i = 0; i < topics.length; i++) {
          items.push(<Option value={topics[i]}>{topics[i]}</Option>)
        }
      }
    }

    return items
  }


  // Handler for IDX Sensor topic selection
  onTopicSelected(event) {
    const {updateNavPoseTopic} = this.props.ros
    const name = event.target.id
    const topic = event.target.value
    const apply_tf = false
    const namespace = this.state.namespace + "/set_topic"
    updateNavPoseTopic(namespace, name, topic, apply_tf)
  }






  sendTransformUpdateMessage(name){
    const {sendFrame3DTransformUpdateMsg} = this.props.ros
    const namespace = this.state.namespace + "/set_3d_transform"
    const TX = parseFloat(this.state.transformsDict[name]['transformTX'])
    const TY = parseFloat(this.state.transformsDict[name]['transformTY'])
    const TZ = parseFloat(this.state.transformsDict[name]['transformTZ'])
    const RX = parseFloat(this.state.transformsDict[name]['transformRX'])
    const RY = parseFloat(this.state.transformsDict[name]['transformRY'])
    const RZ = parseFloat(this.state.transformsDict[name]['transformRZ'])
    const HO = parseFloat(this.state.transformsDict[name]['transformHO'])
    const transformList = [TX,TY,TZ,RX,RY,RZ,HO]
    sendFrame3DTransformUpdateMsg(namespace, name, transformList)
  }


  sendTransformClearMessage(name){
    
    const {sendStringMsg} = this.props.ros
    const namespace = this.state.namespace + "/clear_3d_transform"
    sendStringMsg(namespace,name)
  }

  renderMgrControls() {

    const componentElements = []


    const {sendTriggerMsg, sendNavPoseMsg} = this.props.ros
    const namespace = this.state.namespace
    ////////////////
    const status_msg = this.state.status_msg
    //////////////// 
    if (status_msg == null){
      //console.log('status_msg is null in renderMgrControls')
    }

    if (status_msg == null){
      return (
            <Columns>
            <Column>
            

            </Column>
          </Columns>
      )
    }
    else {

      const comp_names = status_msg.comp_names
      const comp_infos = status_msg.comp_infos
      //console.log('=============renderMgrControls=================')
      //console.log('comp_names: ' + comp_names)
      //console.log('comp_infos: ' + comp_names)
      const componentElements = []

      for (var i = 0; i < comp_names.length; i++) {
        const comp_info = comp_infos[i]
        // Show for each
        const name = comp_info.name
        const name_state = this.state[name + '_fixed']
        const topics = comp_info.available_topics
        const msgs = comp_info.available_topic_msgs
        //console.log('name_state: ' + name_state)

        const name_text = name.toUpperCase()
        const fixed = comp_info.fixed
        //console.log('name: ' + name + ' fixed: ' + name_state)
        //console.log('name: ' + name + ' fixed: ' + fixed)

        const topic = (comp_info.topic !== '') ? comp_info.topic : 'None'
        //console.log('dropdown topic: ' + topic)

        componentElements.push(

       
          <Columns>
          <Column>


                <Columns>
                  <Column>

                      <label style={{fontWeight: 'bold'}}>
                            {name_text}
                          </label>

                          <Label title={"Select Source Topic"}>
                        <Select
                          id={name}
                          onChange={() => this.onTopicSelected(name)}
                          value={topic}
                          >
                          {namespace
                            ? this.createTopicOptions(name)
                            : <Option value={'None'}>{'None'}</Option>}
                        </Select>
                      </Label>

                    </Column>
                    <Column>

                    </Column>
                  </Columns>




                  <div align={"left"} textAlign={"left"} hidden={!fixed}>

                  {this.renderMgrFixedControls(name, comp_info)}

                  </div>

                  <div align={"left"} textAlign={"left"} hidden={fixed}>

                  {this.renderMgrTopicControls(name, comp_info)}

                  </div>

                  <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
              </Column>
            </Columns>
            
        )

      }    
      return (

        <React.Fragment>
        <NepiIFConfig
        namespace={namespace}
        title={"Nepi_IF_SaveConif"}
        />
        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
        {componentElements}
      </React.Fragment>
    )

    }
  }

  renderMgrFixedControls(name, comp_info) {
    const {sendTriggerMsg, sendNavPoseMsg} = this.props.ros
    const namespace = this.state.namespace
    // Remove the null assignment and early return
    const status_msg = this.state.status_msg
    
    const fixed = this.state[name + '_fixed']

    //console.log(this.state.fixed_npData_latitude)
    if (name === 'location'){
      return (
        <Columns>
        <Column>
              <Columns>
                <Column>
                <Label title={"Latitude"}>
                  <Input
                    value={this.state.fixed_npData_latitude}
                    id="latitude"
                    onChange={(event) =>
                      onUpdateSetStateValue.bind(this)(event, 'fixed_npData_latitude')
                    }
                    onKeyDown={(event) =>
                      onEnterSetStateFloatValue.bind(this)(event, 'fixed_npData_latitude')
                    }
                    style={{ width: '80%' }}
                  />
                </Label>

                  <Label title={"Longitude"}>
                        <Input
                          value={this.state.fixed_npData_longitude}
                          id="longitude"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_longitude')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_longitude')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                </Columns>
  
              <Columns>
              <Column>
                    <ButtonMenu>
                    <Button onClick={() => this.props.ros.sendNavPoseLocationMsg(
                      namespace,
                      this.state.fixed_npData_latitude,
                      this.state.fixed_npData_longitude,
                      false
                    )}>{"Update Fix"}</Button>
                    </ButtonMenu>
              </Column>
              <Column>
                    <ButtonMenu>
                    <Button onClick={() => this.props.ros.sendNavPoseLocationMsg(
                      namespace,
                      0.0,
                      0.0,
                      false
                    )}>{"Clear Fix"}</Button>
                    </ButtonMenu>                 
              </Column>
              </Columns>
        </Column>
        </Columns>
      )
    }
  
    else if (name === 'heading'){
      return (
        <Columns>
        <Column>
              <Columns>
                <Column>
                    <Label title={"Heading (Deg)"}>
                        <Input
                          value={this.state.fixed_npData_heading_deg}
                          id="heading"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_heading_deg')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_heading_deg')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                  <Column>
                  </Column>
                </Columns>
  
              <Columns>
              <Column>
                    <ButtonMenu>
                    <Button onClick={() => this.props.ros.sendNavPoseHeadingMsg(
                      namespace,
                      this.state.fixed_npData_heading_deg,
                      false
                    )}>{"Update Fix"}</Button>
                    </ButtonMenu>
              </Column>
              <Column>
                    <ButtonMenu>
                    <Button onClick={() => this.props.ros.sendNavPoseHeadingMsg(
                      namespace,
                      0.0,
                      false
                    )}>{"Clear Fix"}</Button>
                    </ButtonMenu>
              </Column>
              </Columns>
        </Column>
        </Columns>
      )
    }
  
    else if (name === 'orientation'){
      return (
        <Columns>
        <Column>
              <Columns>
                <Column>
                    <Label title={"Roll (Deg)"}>
                        <Input
                          value={this.state.fixed_npData_roll_deg}
                          id="roll"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_roll_deg')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_roll_deg')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                  <Column>
                  <Label title={"Pitch (Deg)"}>
                        <Input
                          value={this.state.fixed_npData_pitch_deg}
                          id="pitch"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_pitch_deg')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_pitch_deg')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                  <Column>
                  <Label title={"Yaw (Deg)"}>
                        <Input
                          value={this.state.fixed_npData_yaw_deg}
                          id="yaw"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_yaw_deg')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_yaw_deg')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                </Columns>
  
              <Columns>
              <Column>
              <ButtonMenu>
                    <Button onClick={() => this.props.ros.sendNavPoseOrientationMsg(
                      namespace,
                      this.state.fixed_npData_roll_deg,
                      this.state.fixed_npData_pitch_deg,
                      this.state.fixed_npData_yaw_deg,
                      false
                    )}>{"Update Fix"}</Button>
                    </ButtonMenu>
              </Column>
              <Column>
              <ButtonMenu>
                  <Button onClick={() => this.props.ros.sendNavPoseOrientationMsg(
                    namespace,
                    0,
                    0,
                    0,
                    false
                  )}>{"Update Fix"}</Button>
              </ButtonMenu>
              </Column>
              </Columns>
        </Column>
        </Columns>
      )
    }
  
    else if (name === 'position'){
      return (
        <Columns>
        <Column>
              <Columns>
                <Column>
                    <Label title={"X (Meters)"}>
                        <Input
                          value={this.state.fixed_npData_x_m}
                          id="x"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_x_m')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_x_m')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                  <Column>
                  <Label title={"Y (Meters)"}>
                        <Input
                          value={this.state.fixed_npData_y_m}
                          id="y"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_y_m')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_y_m')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                  <Column>
                  <Label title={"Z (Meters)"}>
                        <Input
                          value={this.state.fixed_npData_z_m}
                          id="z"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_z_m')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_z_m')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                </Columns>
  
              <Columns>
              <Column>
              <ButtonMenu>
                    <Button onClick={() => this.props.ros.sendNavPosePositionMsg(
                      namespace,
                      this.state.fixed_npData_x_m,
                      this.state.fixed_npData_y_m,
                      this.state.fixed_npData_z_m,
                      false
                    )}>{"Update Fix"}</Button>
                    </ButtonMenu>
              </Column>
              <Column>
                    <ButtonMenu>
                      <Button onClick={() => this.props.ros.sendNavPosePositionMsg(namespace,this.props.ros.blankNavPose)}>{"Clear Fix"}</Button>
                    </ButtonMenu>
              </Column>
              </Columns>
        </Column>
        </Columns>
      )
    }
  
    else if (name === 'altitude'){
      return (
        <Columns>
        <Column>
              <Columns>
                <Column>
                    <Label title={"Altitude (Meters)"}>
                        <Input
                          value={this.state.fixed_npData_altitude_m}
                          id="altitude"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_altitude_m')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_altitude_m')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                  <Column>
                  </Column>
                </Columns>
  
              <Columns>
              <Column>
              <ButtonMenu>
              <Button onClick={() => this.props.ros.sendNavPoseAltitudeMsg(
                      namespace,
                      this.state.fixed_npData_altitude_m,
                      false
                    )}>{"Update Fix"}</Button>
                    </ButtonMenu>
              </Column>
              <Column>
                    <ButtonMenu>
                      <Button onClick={() => this.props.ros.sendNavPoseAltitudeMsg(namespace,this.props.ros.blankNavPose)}>{"Clear Fix"}</Button>
                    </ButtonMenu>
              </Column>
              </Columns>
        </Column>
        </Columns>
      )
    }
  
    else if (name === 'depth'){
      return (
        <Columns>
        <Column>
              <Columns>
                <Column>
                    <Label title={"Depth (Meters)"}>
                        <Input
                          value={this.state.fixed_npData_depth_m}
                          id="depth"
                          onChange={(event) => onUpdateSetStateValue.bind(this)(event,'fixed_npData_depth_m')}
                          onKeyDown={(event) => onEnterSetStateFloatValue.bind(this)(event,'fixed_npData_depth_m')}
                          style={{ width: "80%" }}
                        />
                      </Label>
                  </Column>
                  <Column>
                  </Column>
                </Columns>
  
              <Columns>
              <Column>
              <ButtonMenu>
              <Button onClick={() => this.props.ros.sendNavPoseDepthMsg(
                      namespace,
                      this.state.fixed_npData_depth_m,
                      false
                    )}>{"Update Fix"}</Button>
                    </ButtonMenu>
              </Column>
              <Column>
                    <ButtonMenu>
                      <Button onClick={() => this.props.ros.sendNavPoseDepthMsg(namespace,this.props.ros.blankNavPose)}>{"Clear Fix"}</Button>
                    </ButtonMenu>
              </Column>
              </Columns>
        </Column>
        </Columns>
      )
    }
  
    else {
      return (
        <Columns>
          <Column>
          </Column>
        </Columns>
      )
    }
  }



  renderMgrTopicControls(name, comp_info) {
    const {sendTriggerMsg, sendNavPoseMsg} = this.props.ros
    const namespace = this.state.namespace
    ////////////////
    const status_msg = this.state.status_msg
    //////////////// 
    
    if (status_msg == null){
      return (
            <Columns>
            <Column>
            

            </Column>
          </Columns>
      )
    }
    else {
  
        const name = comp_info.name
        const name_text = name.toUpperCase()
        const topics = comp_info.available_topics
        const msgs = comp_info.available_topic_msgs
        // Show the rest if fixed === false
          const topic = (comp_info.topic !== '') ? comp_info.topic : 'None'
          // Show the rest if topic !== 'None'
            const msg = comp_info.topic_msg
            const con = comp_info.connected
            // Show the rest if connected
              const rate = comp_info.avg_rate
              const time = comp_info.last_time
              const fixed = this.state[name + '_fixed']
              const topic_selected = topic !== 'None' && topic !== ''
        const show_transform = this.state.showTransformsDict[name]
        const this_transform = this.state.transformsDict[name]
        return (
          <Columns>
          <Column>

                      <Label title={"Select Source Topic"}>
                        <Select
                          id={name}
                          onChange={() => this.onTopicSelected(name)}
                          value={topic}
                          >
                          {namespace
                            ? this.createTopicOptions(name)
                            : <Option value={'None'}>{'None'}</Option>}
                        </Select>
                      </Label>

                      <div align={"left"} textAlign={"left"} hidden={fixed === true || topic_selected === false}>

                            <Columns>
                              <Column>

                                  <pre style={{ height: "200px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
                                    {("\nReceive Rate: " + rate + 
                                        "\nLast Pub Time Sec: " + time)}
                                  </pre>


                                  <Label title="Show 3D Transform">
                                    <Toggle
                                      checked={show_transform === true}
                                      onClick={(event) => onUpdateSetStateValue.bind(this)('showTransformsDict.' + name)}>
                                    </Toggle>
                                  </Label>


                                </Column>
                              <Column>

                              </Column>
                              </Columns>

              



                              <div align={"left"} textAlign={"left"} hidden={fixed === true || topic_selected === false || show_transform === false}>


                                    <Columns>
                                      <Column>

                                      <Label title={"X (m)"}>
                                        <Input
                                          value={this_transform.transformTX}
                                          id="XTranslation"
                                          onChange= {(event) => onUpdateSetStateValue.bind(this)(event,'transformsDict.' + name + ".transformTX")}
                                          onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,'transformsDict.' + name + ".transformTX")}
                                          style={{ width: "80%" }}
                                        />
                                      </Label>

                                      <Label title={"Y (m)"}>
                                        <Input
                                          value={this_transform.transformTY}
                                          id="YTranslation"
                                          onChange= {(event) => onUpdateSetStateValue.bind(this)(event,'transformsDict.' + name + ".transformTY")}
                                          onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,'transformsDict.' + name + ".transformTY")}
                                          style={{ width: "80%" }}
                                        />
                                      </Label>

                                      <Label title={"Z (m)"}>
                                        <Input
                                          value={this_transform.transformTZ}
                                          id="ZTranslation"
                                          onChange= {(event) => onUpdateSetStateValue.bind(this)(event,'transformsDict.' + name + ".transformTZ")}
                                          onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,'transformsDict.' + name + ".transformTZ")}
                                          style={{ width: "80%" }}
                                        />
                                      </Label>

                                    </Column>
                                    <Column>

                                      <Label title={"Roll (deg)"}>
                                        <Input
                                          value={this_transform.transformRX}
                                          id="XRotation"
                                          onChange= {(event) => onUpdateSetStateValue.bind(this)(event,'transformsDict.' + name + ".transformRX")}
                                          onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,'transformsDict.' + name + ".transformRX")}
                                          style={{ width: "80%" }}
                                        />
                                      </Label>

                                      <Label title={"Pitch (deg)"}>
                                        <Input
                                          value={this_transform.transformRY}
                                          id="YRotation"
                                          onChange= {(event) => onUpdateSetStateValue.bind(this)(event,'transformsDict.' + name + ".transformRY")}
                                          onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,'transformsDict.' + name + ".transformRY")}
                                          style={{ width: "80%" }}
                                        />
                                      </Label>

                                          <Label title={"Yaw (deg)"}>
                                            <Input
                                              value={this_transform.transformRZ}
                                              id="ZRotation"
                                              onChange= {(event) => onUpdateSetStateValue.bind(this)(event,'transformsDict.' + name + ".transformRZ")}
                                              onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,'transformsDict.' + name + ".transformRZ")}
                                              style={{ width: "80%" }}
                                            />
                                          </Label>

                                        </Column>
                                      </Columns>




                                      <Columns>
                                          <Column>

                                            <ButtonMenu>
                                              <Button onClick={() => this.sendTransformUpdateMessage(name)}>{"Update Transform"}</Button>
                                            </ButtonMenu>

                                          </Column>
                                          <Column>

                                                  <ButtonMenu>
                                                      <Button onClick={() => this.sendTransformClearMessage(name)}>{"Clear Transform"}</Button>
                                                  </ButtonMenu>

                                            </Column>
                                      </Columns>
                      
                                </div>  


                      </div>


              </Column>
            </Columns>
        )

    }
  }


  renderMgrSettings() {
    const {sendTriggerMsg} = this.props.ros
    const NoneOption = <Option>None</Option>
    const connected = (this.state.namespace != null)
    const namespace = this.state.namespace
    const status_msg = this.state.status_msg

    // If status_msg !== null, show rate_control 


    return (
      <React.Fragment>
        <Columns>
          <Column>


            <Section title={"NavPose Solution Controls"}>


            {this.renderMgrControls()}

            <div align={"left"} textAlign={"left"} hidden={!connected}>

              <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

          </div>


            </Section>
          </Column>
        </Columns>
      </React.Fragment>
    )


  }

  render() {
    const namespace = this.state.namespace
    const navpose_data = this.state.navpose_data
    const status_msg = this.state.status_msg
    const connected = this.state.connected


    const frame_3d = navpose_data ? navpose_data.frame_3d : null
    const frame_nav = navpose_data ? navpose_data.frame_nav : null
    const frame_alt = navpose_data ? navpose_data.frame_alt : null
    const lat = navpose_data ? navpose_data.latitude : null
    const long = navpose_data ? navpose_data.longitude : null
    const alt = navpose_data ? navpose_data.altitude : null
    const head = navpose_data ? navpose_data.heading : null
    const x_m = navpose_data ? navpose_data.x_m : null
    const y_m = navpose_data ? navpose_data.y_m : null
    const z_m = navpose_data ? navpose_data.z_m : null
    const roll = navpose_data ? navpose_data.roll : null
    const pitch = navpose_data ? navpose_data.pitch : null
    const yaw = navpose_data ? navpose_data.yaw : null

    return (


    
      <div style={{ display: 'flex' }}>

          <div style={{ width: "65%" }}>

                    <NepiIFNavPoseViewer
                      namespace={namespace}
                      title={"NavPose Data"}
                    />


                    <div hidden={(!connected)}>

                      <NepiIFSaveData
                        namespace={namespace}
                        title={"Nepi_IF_SaveData"}
                      />
                    </div>


          </div>




          <div style={{ width: '5%' }}>
                {}
          </div>



          <div style={{ width: "30%"}}>


                    {this.renderMgrSettings()}


                    <div hidden={(!connected && this.state.show_settings)}>
                      <NepiIFSettings
                        namespace={namespace ? namespace + '/npx' : null}
                        title={"Nepi_IF_Settings"}
                      />
                    </div>

          </div>



    </div>



    )
  }
}

export default MgrNavPose
