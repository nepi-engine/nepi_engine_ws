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
import Input from "./Input"
import Section from "./Section"
import { Columns, Column } from "./Columns"
import Label from "./Label"
import Button, { ButtonMenu } from "./Button"
import BooleanIndicator from "./BooleanIndicator"
import Select from "./Select"
import Styles from "./Styles"
import {createShortUniqueValues, setElementStyleModified, clearElementStyleModified} from "./Utilities"
//var qr = require("qrcode")

// const reorder = (list, startIndex, endIndex) => {
//   const result = Array.from(list);
//   const [removed] = result.splice(startIndex, 1);
//   result.splice(endIndex, 0, removed);

//   return result;
// };

@inject("ros")
@observer
class NepiSystemConnect extends Component {
  constructor(props) {
    super(props)

    this.state = {
      viewableTopics: false,
      viewableOrder: false,
      autoRateEdited: null,
      dataSetsPerHourEdited: null,
      showPublicSSHKey: false
    }
    this.renderNEPIConnect = this.renderNEPIConnect.bind(this)
    this.renderLBInformation = this.renderLBInformation.bind(this)
    this.renderHBInformation = this.renderHBInformation.bind(this)
    this.renderConnectionSettings = this.renderConnectionSettings.bind(this)
    this.renderLBSettings = this.renderLBSettings.bind(this)
    //this.renderQR = this.renderQR.bind(this)
    this.onDragEnd = this.onDragEnd.bind(this)
    this.toggleViewableTopics = this.toggleViewableTopics.bind(this)
    this.toggleViewableOrder = this.toggleViewableOrder.bind(this)
    this.onUpdateText = this.onUpdateText.bind(this)
    this.onKeyText = this.onKeyText.bind(this)
  }
  onDragEnd(result) {
    // // commented out to prevent movement of comms order list.
    // if (!result.destination) {
    //   return;
    // }

    // const items = reorder(
    //   this.state.items,
    //   result.source.index,
    //   result.destination.index
    // );

    // this.setState({
    //   items
    // });
  }

  onUpdateText(e) {
    if (e.target.id === "autoRate")
    {
      var autoRateElement = document.getElementById("autoRate")
      setElementStyleModified(autoRateElement)
      this.setState({autoRateEdited: autoRateElement.value})
    }
    else if (e.target.id === "dataSetsPerHour")
    {
      var dataSetsPerHourElement = document.getElementById("dataSetsPerHour")
      setElementStyleModified(dataSetsPerHourElement)
      this.setState({dataSetsPerHourEdited: dataSetsPerHourElement.value})
    }
  }

  onKeyText(e) {
    const {onChangeNEPIConnect} = this.props.ros
    if(e.key === 'Enter'){
      onChangeNEPIConnect(e.target.dataset.topic, e.target.value)
      // Clear red formatting and revert to using the feedback from device for value
      if (e.target.id === "autoRate")
      {
        var autoRateElement = document.getElementById("autoRate")
        clearElementStyleModified(autoRateElement)
        this.setState({autoRateEdited : null})
      }
      else if (e.target.id === "dataSetsPerHour")
      {
        var dataSetsPerHourElement = document.getElementById("dataSetsPerHour")
        clearElementStyleModified(dataSetsPerHourElement)
        this.setState({dataSetsPerHourEdited : null})
      }
    }
  }

  toggleViewableTopics() {
    const set = !this.state.viewableTopics
    this.setState({viewableTopics: set})
  }
  toggleViewableOrder() {
    const set = !this.state.viewableOrder
    this.setState({viewableOrder: set})
  }

  renderNEPIConnect() {
    const { NUID, alias, ssh_public_key, log_storage_enabled, onToggleLogStorage } = this.props.ros
    return(
      <Section title={"NEPI Connect"}>
        <Label title="NEPI UID">
          <Input
            disabled value= {NUID}
          />
        </Label>
        <Label title="NEPI Device Alias">
          <Input
            disabled value= {alias}
          />
        </Label>
        <Label title={"Show Public SSH Key"}>
          <Toggle
            checked={this.state.showPublicSSHKey}
            onClick={() => this.setState({showPublicSSHKey: !(this.state.showPublicSSHKey)})}
          />
        </Label>
        <div hidden={!(this.state.showPublicSSHKey)}>
          <Label title={"Public SSH Key"}/>
          <pre style={{ height: "100px", overflowX: "auto", overflowY: "auto", overflowWrap: "anywhere", whiteSpace: "normal"}}>
            {ssh_public_key}
          </pre>
        </div>
        <Label title="Save Connection Logs">
          <Toggle
            checked={log_storage_enabled}
            onClick= {onToggleLogStorage}
          />
        </Label>
        {/*
        <Label title="">
          <canvas id="qrcode"></canvas>
        </Label>
        */}
      </Section>
    )
  }

  /*
  renderQR() {
    const { NUID } = this.props.ros
    qr.toCanvas(document.getElementById("qrcode"), NUID)
  }
  */

  renderLBInformation() {
    const { lb_last_connection_time, lb_do_msg_count, lb_dt_msg_count } = this.props.ros
    if((lb_last_connection_time !== null) && (lb_last_connection_time.unix() !== 0)) {
      var last = lb_last_connection_time.format("l h:mm:ss a")
    } else {
      last = "---"
    }
    return(
      <Section title={"Messaging Status"}>
        <Label title="Last Connection">
          <Input
            disabled value= {last}
          />
        </Label>
        <Label title="Transmitted Messages">
          <Input
            disabled value= {lb_do_msg_count}
          />
        </Label>
        <Label title="Received Messages">
          <Input
            disabled value= {lb_dt_msg_count}
          />
        </Label>
      </Section>
    )
  }

  renderHBInformation() {
    const { hb_last_connection_time, hb_do_transfered_mb, hb_dt_transfered_mb, hb_data_queue_size_mb } = this.props.ros
    if ((hb_last_connection_time !== null) && (hb_last_connection_time.unix() !== 0)) {
      var last = hb_last_connection_time.format("l h:mm:ss a")
    } else {
      last = "---"
    }
    return(
      <Section title={"File Transfer Status"}>
        <Label title="Last Connection">
          <Input
            disabled value= {last}
          />
        </Label>
        <Label title="Transmitted Data (MB)">
          <Input
            disabled value= {hb_do_transfered_mb != null ? hb_do_transfered_mb.toFixed(2) : "0.00"}
          />
        </Label>
        <Label title="Received Data (MB)">
          <Input
            disabled value= {hb_dt_transfered_mb != null ? hb_dt_transfered_mb.toFixed(2) : "0.00"}
          />
        </Label>
        <Label title="Data to Transmit (MB)">
          <Input
            disabled value= {hb_data_queue_size_mb != null ? hb_data_queue_size_mb.toFixed(2) : "0.00"}
          />
        </Label>
      </Section>
    )
  }

  renderConnectionSettings() {
    const { bot_running, lb_enabled, hb_enabled, hb_auto_data_offloading_enabled, onNEPIConnectConnectNow,
            auto_attempts_per_hour, onToggleHB, onToggleAutoOffloading, onToggleLB, 
            nepiHbLinkAutoDataOffloadingCheckboxVisible} = this.props.ros
    const { autoRateEdited } = this.state
    
    const displayedAutoRate = (autoRateEdited === null)? auto_attempts_per_hour : autoRateEdited
    
    return(
      <Section title={"Connection Settings"}>
        <Label title={"Connection in Progress"}>
          <BooleanIndicator value={bot_running} />
        </Label>
        <ButtonMenu>
          <Button onClick={onNEPIConnectConnectNow}>{"Connect Now"}</Button>
        </ButtonMenu>
        <Label title="Connection Attempts Per Hour">
          <Input
            id="autoRate"
            data-topic="nepi_link_ros_bridge/set_auto_attempts_per_hour"
            value= {displayedAutoRate}
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
        </Label>
        <Label title="Enable Messaging">
          <Toggle
            checked={lb_enabled}
            onClick={onToggleLB}>
          </Toggle>
        </Label>
        <Label title="Enable File Transfer">
          <Toggle
            checked={hb_enabled}
            onClick={onToggleHB}>
          </Toggle>
        </Label>
        <div hidden={!nepiHbLinkAutoDataOffloadingCheckboxVisible}>
          <Label title="Enable Stored Data Auto Offloading">
            <Toggle
              checked={hb_auto_data_offloading_enabled}
              onClick={onToggleAutoOffloading}>
            </Toggle>
          </Label>
        </div>
      </Section>
    )
  }

  renderLBSettings() {
    const { lb_selected_data_sources, lb_available_data_sources, lb_comms_types, lb_data_queue_size_kb, lb_data_sets_per_hour,
            onNEPIConnectDataSetNow, onToggleTopic } = this.props.ros
    const { viewableTopics, viewableOrder, dataSetsPerHourEdited } = this.state
    var sources = []
    //var selected_sources = []
    var i;

    if (lb_available_data_sources != null) {
      const shortSources = createShortUniqueValues(lb_available_data_sources)
      for(i = 0; i < lb_available_data_sources.length; i++) {
        sources[i] = {
          long:lb_available_data_sources[i],
          short:shortSources[i]
        }
      }
    }

    const displayedDataSetsPerHour = (dataSetsPerHourEdited === null)? lb_data_sets_per_hour : dataSetsPerHourEdited
    
    return (
      <Section title={"Messaging Config"}>
        <ButtonMenu>
          <Button onClick={onNEPIConnectDataSetNow}>{"Create Messages Now"}</Button>
        </ButtonMenu>
        <Label title="Message Sets per Hour">
          <Input
            value={displayedDataSetsPerHour}
            id="dataSetsPerHour"
            data-topic="nepi_link_ros_bridge/lb/set_data_sets_per_hour"
            onChange= {this.onUpdateText}
            onKeyDown= {this.onKeyText}
          />
        </Label>
        <Label title="Queued Message Data (KB)">
          <Input
            value={lb_data_queue_size_kb !== null ? lb_data_queue_size_kb.toFixed(2) : "0.00"}
            onChange={this.LBQueueMaxSizeUp}
            disabled="true"
          />
        </Label>
        <Label title="Comms Attempt Order">
          {/* <div>
            <DragList list={items} width="225px" callback={this.onDragEnd}>
            </DragList>
          </div> */}
          <div onClick={this.toggleViewableOrder} style={{backgroundColor: Styles.vars.colors.orange}}>
            <Select style={{backgroundColor: Styles.vars.colors.orange, width: "10px"}}/>
          </div>
          <div hidden={!viewableOrder}>
          {lb_comms_types !== null ? lb_comms_types.map((item, index) =>
          <div
            style={{
              textAlign: "center",
              padding: `${Styles.vars.spacing.xs}`,
              color: Styles.vars.colors.black,
              backgroundColor: Styles.vars.colors.orange,
              cursor: "pointer",
              }}>
              <body style={{color: Styles.vars.colors.black}}>{item}</body>
          </div>
          ) : <div></div>}
          </div>
        </Label>
        <Label title="Selected Message Topics">
          <div onClick={this.toggleViewableTopics} style={{backgroundColor: Styles.vars.colors.grey0}}>
            <Select style={{width: "10px"}}/>
          </div>
          <div hidden={!viewableTopics}>
          {sources.map((topic) =>
          <div onClick={onToggleTopic}
            style={{
              textAlign: "center",
              padding: `${Styles.vars.spacing.xs}`,
              color: Styles.vars.colors.black,
              backgroundColor: (lb_selected_data_sources && lb_selected_data_sources.includes(topic.long))? Styles.vars.colors.blue : Styles.vars.colors.grey0,
              cursor: "pointer",
              }}>
              <body data-topic={topic.long} style={{color: Styles.vars.colors.black}}>{topic.short}</body>
          </div>
          )}
          </div>

        </Label>
      </Section>
    )
  } 

  render() {
    const { NEPIConnectenabled, onToggleNEPIConnectComms, lb_enabled } = this.props.ros
    return (
      <div>
        <Columns>
          <Column equalWidth={false}/>
          <Column>
            <Label title={"Enable NEPI CONNECT Communications"} alignRight={true}>
              <Toggle
                checked={NEPIConnectenabled}
                onClick={onToggleNEPIConnectComms}>
              </Toggle>
            </Label>
          </Column>
        </Columns>
        <Columns>
          <Column>
              <div hidden={!NEPIConnectenabled}>
              {this.renderNEPIConnect()}
              {this.renderConnectionSettings()}
              </div>
          </Column>
          <Column>
            <div hidden={!NEPIConnectenabled}>
            {this.renderLBInformation()}
            {this.renderHBInformation()}
            </div>
            <div hidden={!lb_enabled || !NEPIConnectenabled}>
            {this.renderLBSettings()}
            </div>
          </Column>
        </Columns>
      </div>
    )
  }

  /*
  componentDidMount() {
    this.renderQR();
  }
  */
}
export default NepiSystemConnect
