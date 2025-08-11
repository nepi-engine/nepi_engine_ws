/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React, { Component } from "react"
import Toggle from "react-toggle"
import { observer, inject } from "mobx-react"

import Input from "./Input"
import Section from "./Section"
import Button, { ButtonMenu } from "./Button"
import { Columns, Column } from "./Columns"
import Label from "./Label"
import Styles from "./Styles"
import Select, { Option } from "./Select"
import {setElementStyleModified, clearElementStyleModified} from "./Utilities"

function round(value, decimals = 0) {
  return Number(value).toFixed(decimals)
  //return value && Number(Math.round(value + "e" + decimals) + "e-" + decimals)
}

@inject("ros")
@observer
class NepiIFNavPoseViewer extends Component {
  constructor(props) {
    super(props)

    this.state = {


      mgrName: "navpose_mgr",
      namespace: null,
      base_namespace: null,

      show_navpose: this.props.show_navpose ? this.props.show_navpose : true,

      message: null,

      listener: null,

      disabled: false,

      connected: false,
      statusListener: null,
      status_msg: null,

      navposeListener: null,
      navpose_msg: null,
      navpose_dict: null,

      needs_update: true,
      nav_needs_update: true  
    }


    this.renderNavPose = this.renderNavPose.bind(this)
    this.statusListener = this.statusListener.bind(this)
    this.navposeListener = this.navposeListener.bind(this)
    this.updateStatusListener = this.updateStatusListener.bind(this)
    this.updateNavposeListener = this.updateNavposeListener.bind(this)

  }

  // Callback for handling ROS StatusNPX messages
  statusListener(message) {
    console.log("=====statusListener called=====")
    console.log("statusListener msg: ", message);
    this.setState({
      status_msg: message, 
      connected: true
    })
  }

  navposeListener(message) {
    console.log("=====navposeListener called=====" + message)
    console.log("navposeListener msg: " + message)
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
  }

  updateStatusListener() {
      console.log("=====updateStatusListener called=====");
      const namespace = this.state.namespace + '/status'
      try {
        var statusListener = this.props.ros.setupStatusListener(
          namespace,
          "nepi_interfaces/NavPoseStatus",
          this.statusListener 
        );
        
        this.setState({ 
          statusListener: statusListener,
          needs_update: false 
        });
        console.log("Status listener setup successful");
      } catch (error) {
        console.error("Failed to setup status listener:", error);
      }
    }

  updateNavposeListener() {
    console.log("=====updateNavposeListener called=====")

    const namespace = this.state.namespace
    const navposeTopic = namespace
    
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
    const namespace = this.props.namespace  + "/navpose"
    if (prevState.namespace !== namespace){
      if (namespace != null) {
        this.setState({
          namespace: namespace,
        })
        this.updateStatusListener()
        this.updateNavposeListener()
      } else if (namespace == null){
        this.setState({ disabled: true })
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


  renderNavPose() {
    const navpose_data = this.state.navpose_data

    if (navpose_data == null) {

      return(
        <Columns>
          <Column>

          </Column>
        </Columns>
      )

    }
    else {
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
              <Columns>
                <Column>
                  <label style={{fontWeight: 'bold'}}>
                    {"Location"}
                  </label>
                  <Label title={"Latitude"}>
                    <Input
                      disabled
                      value={round(lat, 6)}
                      style={{ width: "80%" }}
                    />
                  </Label>
                  <Label title={"Longitude"}>
                    <Input
                      disabled
                      value={round(long, 6)}
                      style={{ width: "80%" }}
                    />
                  </Label>
                  <Label title={"Altitude " + frame_alt + " (m)"}>
                    <Input
                      disabled
                      value={round(alt, 2)}
                      style={{ width: "80%" }}
                    />
                  </Label>

                  <Label title={"Heading (deg)"}>
                    <Input
                      disabled
                      style={{ width: "80%" }}
                      value={round(head, 2)}
                    />
                  </Label>

                </Column>
                <Column>
                  <div style={{ display: "flex", marginLeft: Styles.vars.spacing.regular }}>
                    <label style={{fontWeight: 'bold', flex: 1, textAlign: "left"}}>
                    {"Orientation Frame " + frame_nav}
                    </label>
                  </div>
                  <Label title={"Roll Degs"}>
                    <Input
                      disabled
                      style={{ width: "45%", float: "left" }}
                      value={round(roll, 2)}
                    />
                  </Label>
                  <Label title={"Pitch Degs"}>
                    <Input
                      disabled
                      style={{ width: "45%", float: "left" }}
                      value={round(pitch, 2)}
                    />

                  </Label>
                  <Label title={"Yaw Degs"}>
                    <Input
                      disabled
                      style={{ width: "45%", float: "left" }}
                      value={round(yaw, 2)}
                    />
                  </Label>
      {/*
                  <Label title={"Ref. Frame"}>
                    <Input
                      disabled
                      style={{ width: "80%" }}
                      value={navPoseOrientationFrame}
                    />
                  </Label>
      */}
                  </Column>
                <Column>
                  <div style={{ display: "flex", marginLeft: Styles.vars.spacing.regular }}>
                    <label style={{fontWeight: 'bold', flex: 1, textAlign: "left"}}>
                    {"Position Frame " + frame_nav}
                    </label>
                  </div>
                  <Label title={"X Meters"}>
                    <Input
                      disabled
                      style={{ width: "45%", float: "left" }}
                      value={round(x_m, 2)}
                    />
                  </Label>
                  <Label title={"Y (North) Meters"}>
                    <Input
                      disabled
                      style={{ width: "45%", float: "left" }}
                      value={round(y_m, 2)}
                    />
                  </Label>
                  <Label title={"Z (Up) Meters"}>
                    <Input
                      disabled
                      style={{ width: "45%", float: "left" }}
                      value={round(z_m, 2)}
                    />
                  </Label>


                </Column>
              </Columns>

          )
        }
      }

      render() {
        const navpose_data = this.state.navpose_data
        const make_section = this.props.make_section !== undefined ? this.props.make_section : true;
        const view_title = this.props.title  ? this.props.title : "NavPose Data";
        
        if (navpose_data == null) {
    
          return(
            <Columns>
              <Column>
    
              </Column>
            </Columns>
          )
    
        }
        else if (make_section === true) {

              return (
                <Section>
                <Label title={view_title} />

                {this.renderNavPose()}
    
                </Section>
              )
            }
        else {
              
            return (
              <Columns>
              <Column>
              <Label title={view_title} />

              {this.renderNavPose()}
  
              </Column>
            </Columns>
            )
          }
      }


}
export default NepiIFNavPoseViewer
