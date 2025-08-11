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

import { Columns, Column } from "./Columns"

import OnvifMgr from "./NepiAppOnvifMgr"
import AiTargetingApp from "./NepiAppAiTargeting"
import AiAlertsApp from "./NepiAppAiAlerts"
import AiPtTrackerApp from "./NepiAppAiPtTracker"
import FilePubImgApp from "./NepiAppFilePubImg"
import FilePubVidApp from "./NepiAppFilePubVid"
import FilePubPcdApp from "./NepiAppFilePubPcd"
import PointcloudViewerApp from "./NepiAppPointcloudViewer"
import ImageViewerApp from "./NepiAppImageViewer"


const appsClassMap = new Map([
  ["OnvifMgr", OnvifMgr],
  ["AiTargetingApp", AiTargetingApp],
  ["AiAlertsApp", AiAlertsApp],
  ["AiPtTrackerApp", AiPtTrackerApp],
  ["FilePubImgApp", FilePubImgApp],
  ["FilePubVidApp", FilePubVidApp],
  ["FilePubPcdApp", FilePubPcdApp],
  ["PointcloudViewerApp", PointcloudViewerApp],
  ["ImageViewerApp", ImageViewerApp]
]);


@inject("ros")
@observer

// Pointcloud Application page
class AppRender extends Component {
  constructor(props) {
    super(props)

    this.state = {
      dummy: null
    }

  }

  render() {
    const sel_app = this.props.sel_app
    const {appNameList, appStatusList} = this.props.ros
    const appInd = appNameList.indexOf(sel_app)
    var appStatusMsg = null
    if (appInd !== -1){
      appStatusMsg =appStatusList[appInd]
    }
    var rui_main_class = ""
    var rui_menu_name = ""
    if (appStatusMsg !== null){
      rui_main_class = appStatusMsg.rui_main_class
      rui_menu_name = appStatusMsg.rui_menu_name
    }
  
    if (appNameList.indexOf(sel_app) !== -1){
      const AppToRender = appsClassMap.get(rui_main_class);
      return (
        <div>
            <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
            {rui_menu_name}
            </label>

          {AppToRender && <AppToRender />} 
        </div>
      );
    }
    else {
      return (
        <React.Fragment>
            <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
            {sel_app + " NOT AVAILABLE"}
          </label>

          <Columns>
          <Column>

          </Column>
          </Columns> 
        </React.Fragment>
      )
    }


  }

}

export default AppRender
