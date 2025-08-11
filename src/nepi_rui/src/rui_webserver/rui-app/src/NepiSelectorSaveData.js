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
import Select, { Option } from "./Select"

import NepiIFSaveData from "./Nepi_IF_SaveData"


import { createShortUniqueValues} from "./Utilities"

@inject("ros")
@observer

class SaveDataSelector extends Component {
  constructor(props) {
    super(props)

    this.state = {
      selected_topic: "None",

      connected: false,
      

    }

    this.onChangeSaveSelection = this.onChangeSaveSelection.bind(this)

    
  }

  getAllNamespace(){
    const { namespacePrefix, deviceId} = this.props.ros
    var allNamespace = null
    if (namespacePrefix !== null && deviceId !== null){
      allNamespace = "/" + namespacePrefix + "/" + deviceId
    }
    return allNamespace
  }

  createSaveOptions() {
    const allNamespace = this.getAllNamespace()
    var items = []
    //items.push(<Option value={"All"}>{"All"}</Option>)
    items.push(<Option value={"None"}>{"None"}</Option>)
    const saveData_topics = this.props.ros.saveDataNamespaces
    const shortnames = createShortUniqueValues(saveData_topics)
    var topic = ""
    for (var i = 0; i < saveData_topics.length; i++) {
      topic = saveData_topics[i]
      if (topic !== allNamespace && topic.indexOf("None") === -1) {
        items.push(<Option value={topic}>{shortnames[i]}</Option>)
      }
    }
    return items    
  }


  onChangeSaveSelection(event){
    const selected_topic = event.target.value
    this.setState({selected_topic: selected_topic})
  }

  renderSelection() {
    const saveTopics = this.createSaveOptions()

    return (
      <React.Fragment>

      <Columns>
        <Column>

        <label style={{fontWeight: 'bold'}}>
            {"Configure System Saving"}
          </label>


            <Select onChange={this.onChangeSaveSelection}
            id="MsgSelector"
            value={this.state.selected_topic}>
              {saveTopics}
            </Select>

      </Column>
      </Columns>

      </React.Fragment>
    )
  }


  renderApplication() {
    const node_namespace = this.state.selected_topic.replace("/save_data/status", "")

    return (
      <React.Fragment>

      <Columns>
        <Column>

        <NepiIFSaveData
        saveNamespace={node_namespace}
        showSettings = {true}
        title={"NepiIFSaveData.js"}
        />

      </Column>
      </Columns>

      </React.Fragment>
    )
  }



  render() {
    const node_namespace = this.state.selected_topic.replace("/save_data_status", "")
    const hide_app = this.state.selected_topic === "None"
    return (


      <div style={{ display: 'flex' }}>
        <div style={{ width: '15%' }}>
          {this.renderSelection()}
        </div>

        <div style={{ width: '10%' }}>
          {}
        </div>

        <div hidden={hide_app}  style={{ width: '75%' }}>

          <label style={{fontWeight: 'bold'}}>
            {node_namespace}
          </label>
          {this.renderApplication()}
        </div>
      </div>

    )
  }

}

export default SaveDataSelector
