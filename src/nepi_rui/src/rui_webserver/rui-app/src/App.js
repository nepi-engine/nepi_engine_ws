/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React, { Component } from "react"
import { Route, Switch, withRouter } from "react-router-dom"
import { observer, inject } from "mobx-react"

import Page from "./Page"
import Nav from "./Nav"
import HorizontalDivider from "./HorizontalDivider"
//import PageLock from "./PageLock"


import Dashboard from "./NepiDashboard"

import DevicesSelector from "./NepiSelectorDevices"
import AutoSelector from "./NepiSelectorAuto"
import DataSelector from "./NepiSelectorData"
import NavPoseSelector from "./NepiSelectorNavPose"
import AiSelector from "./NepiSelectorAI"
import SystemSelector from "./NepiSelectorSystem"





//const IS_LOCAL = window.location.hostname === "localhost"

@inject("ros")
@withRouter
@observer
class App extends Component {

  componentDidMount() {
    this.props.ros.checkROSConnection()
  }

  render() {
    const { license_valid, license_server, license_type } = this.props.ros
    const unlicensed = (license_server !== null) && 
      (license_server.readyState === 1) && 
      (license_valid === false) 
      return (
      <Page>
        <Nav
          unlicensed={unlicensed}
          license_type={license_type}
          pages={[
            { path: "/", label: "Dashboard" },
            { path: "/devices_selector", label: "Devices"},
            { path: "/data_selector", label: "Data"},
            { path: "/navpose_selector", label: "NavPose"},
            { path: "/ai_selector", label: "AI_System"},
            { path: "/auto_selector", label: "Automation"},
            { path: "/system_selector", label: "System"},
            {
              path: "/help",
              label: "Help",
              subItems: [
                { path: "/docs", label: "Docs" },
                { path: "/tuts", label: "Tutorials" },
                { path: "/vids", label: "Videos" },
              ]
            }
          ]}
        />
        <HorizontalDivider />
        <Switch>
          <Route exact path="/" component={Dashboard} />

          <Route path="/devices_selector" component={DevicesSelector} />      
          <Route path="/navpose_selector" component={NavPoseSelector} />
          <Route path="/data_selector" component={DataSelector} /> 
          <Route path="/ai_selector" component={AiSelector} />
          <Route path="/auto_selector" component={AutoSelector} />
          <Route path="/system_selector" component={SystemSelector} />
          

          <Route path='/docs' component={() => {
             window.location.href = 'https://nepi.com/documentation/';
             return null;
            }}/>
          <Route path='/tuts' component={() => {
             window.location.href = 'https://nepi.com/tutorials/';
             return null;
            }}/>
          <Route path='/vids' component={() => {
             window.location.href = 'https://nepi.com/videos/';
             return null;
            }}/>
          
        </Switch>
      </Page>
    )
  }
}

export default App
