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
import Button, { ButtonMenu } from "./Button"
import Input from "./Input"
import Toggle from "react-toggle"

import { round, convertStrToStrList, createShortValuesFromNamespaces, createMenuListFromStrList,
  onDropdownSelectedSendStr, onDropdownSelectedSetState, 
  onUpdateSetStateValue, onEnterSendFloatValue, onEnterSetStateFloatValue,
  doNothing} from "./Utilities"


import Nepi_IF_SaveData from "./Nepi_IF_SaveData"

@inject("ros")
@observer

// NavPose viewer window
class NavPoseViewer extends Component {
  constructor(props) {
    super(props)

    this.state = {
      show_nav_pose: false,
      appName: "nav_pose_publisher",
      appNamespace: null,
    
      latitude: null,
      longitude: null,
      altitude: null,

      heading: null,

      roll: null,
      pitch: null,
      yaw: null,

      x_m: null,
      y_m: null,
      z_m: null,

      connected: false,

      locListener: null.
      headListener: null,
      orienListener: null,
      posListener: null

    }

    this.updateNavPoseListeners = this.updateNavPoseListeners.bind(this)
    this.locationListener = this.locationListener.bind(this)
    this.headingListener = this.headingListener.bind(this)
    this.orientationListener = this.orientationListener.bind(this)
    this.positionListener = this.positionListener.bind(this)

  }

  getAppNamespace(){
    const { namespacePrefix, deviceId} = this.props.ros
    var appNamespace = null
    if (namespacePrefix !== null && deviceId !== null){
      appNamespace = "/" + namespacePrefix + "/" + deviceId + "/" + this.state.appName
    }
    return appNamespace
  }

  // Callback for handling ROS Status messages
  locationListener(message) {
    this.setState({
    latitude: message.x,
    longitude: message.y,
    altitude: message.z
    })
    this.setState({connected: true})
  }

  // Callback for handling ROS Status messages
  headingListener(message) {
    this.setState({
    heading: message.data
    })
  }

  orienationListener(message) {
    this.setState({
    roll: message.x,
    pitch: message.y,
    yaw: message.z
    })
  }

  orienationListener(message) {
    this.setState({
    x_m: message.x,
    y_m: message.y,
    z_m: message.z
    })
  }

  // Function for configuring and subscribing to Status
  updateNavPoseListeners() {
    const locNamespace = this.getAppNamespace() + '/location_wgs84_geo'
    if (this.state.locListener) {
      this.state.locListener.unsubscribe()
    }
    var locListener = this.props.ros.setupVector3Listener(
          locNamespace,
          this.locationListener
        )
    this.setState({ locListener: locListener})


    const headNamespace = this.getAppNamespace() + '/heading_deg'
    if (this.state.headListener) {
      this.state.headListener.unsubscribe()
    }
    var headListener = this.props.ros.setupVector3Listener(
          headNamespace,
          this.headingListener
        )
    this.setState({ headListener: headListener})


    const orienNamespace = this.getAppNamespace() + '/orientation_enu_degs'
    if (this.state.orienListener) {
      this.state.orienListener.unsubscribe()
    }
    var orienListener = this.props.ros.setupVector3Listener(
          orienNamespace,
          this.orientationListener
        )
    this.setState({ orienListener: orienListener})


    const posNamespace = this.getAppNamespace() + '/position_enu_m'
    if (this.state.posListener) {
      this.state.posListener.unsubscribe()
    }
    var posListener = this.props.ros.setupVector3Listener(
          posNamespace,
          this.posistionListener
        )
    this.setState({ posListener: posListener})
  }

  // Lifecycle method called when compnent updates.
  // Used to track changes in the topic
  componentDidUpdate(prevProps, prevState, snapshot) {
    const namespace = this.getAppNamespace()
    if (prevState.appNamespace !== namespace && namespace !== null) {
      if (namespace.indexOf('null') === -1) {
        this.setState({appNamespace: namespace})
        this.updateNavPoseListeners()
      } 
    }
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status message
  componentWillUnmount() {
    if (this.state.listener) {
      this.state.listener.unsubscribe()
    }
  }


  render() {

    return (
      <React.Fragment>

        <Section title={"Nav Pose"}>
          
        </Section>

      </React.Fragment>
    )
  }


}

export default NavPoseViewer
