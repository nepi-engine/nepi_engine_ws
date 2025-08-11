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
import Styles from "./Styles"

import NepiSystemMessages from "./Nepi_IF_Messages"


import { createShortUniqueValues} from "./Utilities"

@inject("ros")
@observer

class NepiMessagesSelector extends Component {
  constructor(props) {
    super(props)

    this.state = {
      
      selected_topic: "Connecting",
    }

    this.onChangeMessageSelection = this.onChangeMessageSelection.bind(this)

    
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
    const sel_topic = this.state.selected_topic
    var items = []
    const msgTopics = this.props.ros.messageTopics
    const msgTopicsSorted = msgTopics.sort()
    //items.push(<Option value={"All"}>{"All"}</Option>)
    if (msgTopics.length > 0 && msgTopics.indexOf(allNamespace) !== -1 ){
      items.push(<Option value={"All"}>{"All"}</Option>)
      if (sel_topic === "Connecting"){
        this.setState({selected_topic: "All"})
      }
      const shortnames = createShortUniqueValues(msgTopics)
      var topic = ""
      for (var i = 0; i < msgTopicsSorted.length; i++) {
        topic = msgTopicsSorted[i]
        if (topic !== allNamespace && topic.indexOf("None") === -1) {
          items.push(<Option value={topic}>{shortnames[i].replace("/messages","")}</Option>)
        }
      }
    }
    else{
      items.push(<Option value={"Connecting"}>{"Connecting"}</Option>)
    }
    return items    
  }

  onChangeMessageSelection(event){
    var selected_topic = event.target.value
    this.setState({selected_topic: selected_topic})
  }

  renderSelection() {
    const messageTopics = this.createMessageOptions()

    return (
      <React.Fragment>

      <Columns>
        <Column>

        <label style={{fontWeight: 'bold'}}>
            {"Select System Messages"}
          </label>

          <div style={{ marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>


            <Select onChange={this.onChangeMessageSelection}
            id="MsgSelector"
            value={this.state.selected_topic}>
            {messageTopics}
            </Select>
         

      </Column>
      </Columns>

      </React.Fragment>
    )
  }


  renderApplication() {
    const msg_namespace = this.state.selected_topic

    return (
      <React.Fragment>

      <Columns>
        <Column>

        <NepiSystemMessages
        messagesNamespace={msg_namespace}
        hide_control={true}
        title={"NepiSystemMessages"}
        />

      </Column>
      </Columns>

      </React.Fragment>
    )
  }



  render() {
    const msg_namespace = this.state.selected_topic
    const hide_app = this.state.selected_topic === "Connecting"
    return (


      <div style={{ display: 'flex' }}>
        <div style={{ width: '20%' }}>
          {this.renderSelection()}
        </div>

        <div style={{ width: '5%' }}>
          {}
        </div>

        <div hidden={hide_app} style={{ width: '75%' }}>
          <label style={{fontWeight: 'bold'}}>
            {msg_namespace}
          </label>
          {this.renderApplication()}
        </div>
      </div>

    )
  }

}

export default NepiMessagesSelector
