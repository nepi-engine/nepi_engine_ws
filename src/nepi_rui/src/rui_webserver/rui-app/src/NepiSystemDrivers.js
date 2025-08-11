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
import Toggle from "react-toggle"
import Select, { Option } from "./Select"
import Styles from "./Styles"
import Button, { ButtonMenu } from "./Button"
import Input from "./Input"
import BooleanIndicator from "./BooleanIndicator"

import NepiIFSettings from "./Nepi_IF_Settings"

import { onChangeSwitchStateValue,createMenuListFromStrList, onDropdownSelectedSetState } from "./Utilities"

  @inject("ros")
  @observer
  

  class DriversMgr extends Component {
    constructor(props) {
      super(props)
  
      this.state = {
        show_delete_driver: false,
        mgrName: "drivers_mgr",
        mgrNamespace: null,

      viewableDrivers: false,
      viewabletypes: false,

      drivers_pkg_list: [],
      last_drivers_pkg_list: [],
      drivers_name_list: [],
      drivers_type_list: [],
      drivers_active_pkg_list: [],
      drivers_active_name_list: [],
      drivers_active_namespace_list: [],
      drivers_install_path: null,
      drivers_install_list: [],
      backup_removed_drivers: true,
      selected_driver: null,

      settings_namespace: 'None',
      driver_pkg: 'None',
      driver_display_name: 'None',
      driver_description: null,
      driver_type: null,
      driver_type_name: "None",
      driver_group_id: null,
      driver_interfaces: null, 
      driver_active_state: null,
      driver_order: 0,
      driver_msg_str: "",
      
      retry_enabled: false,

      connected: false,

      driversListener: null,
      driverListener: null,
      selected_driver_install_pkg: null,
      type_list: ['IDX','LSX','PTX','RBX','NPX'],
      type_names: ['Imaging','Lights','PanTilts','Robots','NavPose'],
      selected_type: "All",
      
      needs_update: false
    }
    this.checkConnection = this.checkConnection.bind(this)

    this.getMgrNamespace = this.getMgrNamespace.bind(this)

    this.sendDriverUpdateOrder = this.sendDriverUpdateOrder.bind(this)
    this.toggleViewableDrivers = this.toggleViewableDrivers.bind(this)
    this.toggleViewabletypes = this.toggleViewabletypes.bind(this)
    this.getDriverOptions = this.getDriverOptions.bind(this)
    this.getInstallOptions = this.getInstallOptions.bind(this)
    this.gettypeOptions = this.gettypeOptions.bind(this)
    this.onChangetypeSelection = this.onChangetypeSelection.bind(this)
    this.onToggleDriverSelection = this.onToggleDriverSelection.bind(this)

    this.updateMgrDriversStatusListener = this.updateMgrDriversStatusListener.bind(this)
    this.driversStatusListener = this.driversStatusListener.bind(this)

    this.updateDriverStatusListener = this.updateDriverStatusListener.bind(this)
    this.statusDriverListener = this.statusDriverListener.bind(this)
    this.statusDriverListener = this.statusDriverListener.bind(this)
    this.convertDriverStrInstallToStrList = this.convertDriverStrInstallToStrList.bind(this)

    this.getDisabledStr = this.getDisabledStr.bind(this)
    this.getActiveStr = this.getActiveStr.bind(this)
    this.getInstallStr = this.getInstallStr.bind(this)

    this.getSettingsNamespace = this.getSettingsNamespace.bind(this)

    
  
    this.onDropdownSelectedSendDriverOption = this.onDropdownSelectedSendDriverOption.bind(this)
  
  
  }

  getMgrNamespace(){
    const { namespacePrefix, deviceId} = this.props.ros
    var mgrNamespace = null
    if (namespacePrefix !== null && deviceId !== null){
      mgrNamespace = "/" + namespacePrefix + "/" + deviceId + "/" + this.state.mgrName
    }
    return mgrNamespace
  }

  // Callback for handling ROS Status messages
  driversStatusListener(message) {
    this.setState({
      drivers_pkg_list: message.pkg_list,
      drivers_name_list: message.name_list,
      drivers_type_list: message.type_list,
      drivers_active_pkg_list: message.active_pkg_list,
      drivers_active_name_list: message.active_name_list,
      drivers_active_namespace_list: message.active_namespace_list,
      drivers_install_path: message.install_path,
      drivers_install_list: message.install_list,
      backup_removed_drivers: message.backup_removed_drivers,
      selected_driver: message.selected_driver,
      retry_enabled: message.retry_enabled,
      connected: true
    })    

  }

  // Function for configuring and subscribing to Status
  updateMgrDriversStatusListener() {
    const statusNamespace = this.getMgrNamespace() + '/status'
    if (this.state.driversListener) {
      this.state.driversListener.unsubscribe()
    }
    var driversListener = this.props.ros.setupStatusListener(
          statusNamespace,
          "nepi_interfaces/MgrDriversStatus",
          this.driversStatusListener
        )
    this.setState({ driversListener: driversListener})
  }


  statusDriverListener(message) {
    this.setState({
  
      driver_pkg: message.pkg_name,
      driver_display_name: message.display_name,
      driver_description: message.description,
      driver_type: message.type,
      driver_group_id: message.group_id,
      driver_active_state: message.active_state,
      driver_order: message.order,
      driver_msg_str: message.msg_str
    })
    const types = this.state.type_list
    const type_index = types.indexOf(message.type)
    const type_names = this.state.type_names
    if ( type_index !== -1){
      this.state.driver_type_name = type_names[type_index]
    }
  }

    // Function for configuring and subscribing to Status
    updateDriverStatusListener() {
      const namespace = this.getMgrNamespace()
      const statusNamespace = namespace + '/status_driver'
      if (this.state.driverListener) {
        this.state.driverListener.unsubscribe()
      }
      var driverListener = this.props.ros.setupStatusListener(
            statusNamespace,
            "nepi_interfaces/DriverStatus",
            this.statusDriverListener
          )
      this.setState({ driverListener: driverListener})
    }

    async checkConnection() {
      const { namespacePrefix, deviceId} = this.props.ros
      if (namespacePrefix != null && deviceId != null) {
        this.setState({needs_update: true})
      }
      else {
        setTimeout(async () => {
          await this.checkConnection()
        }, 1000)
      }
    }
  
    componentDidMount(){
      this.checkConnection()
    }

    
  // Lifecycle method called when compnent updates.
  // Used to track changes in the topic
  componentDidUpdate(prevProps, prevState, snapshot) {
    const namespace = this.getMgrNamespace()
    const namespace_updated = (prevState.mgrNamespace !== namespace && namespace !== null)
    if (namespace_updated) {
      if (namespace.indexOf('null') === -1){
        this.setState({
          mgrNamespace: namespace
        })
        this.updateMgrDriversStatusListener()
        this.updateDriverStatusListener()
      } 
    }
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status message
  componentWillUnmount() {
    if (this.state.driversListener) {
      this.state.driversListener.unsubscribe()
      this.state.driverListener.unsubscribe()
    }
  }

  toggleViewableDrivers() {
    const set = !this.state.viewableDrivers
    this.setState({viewableDrivers: set})
  }

  toggleViewabletypes() {
    const set = !this.state.viewabletypes
    this.setState({viewabletypes: set})
  }

  // Function for creating image topic options.
  getDriverOptions() {
    const driversList = this.state.drivers_pkg_list  
    const namesList = this.state.drivers_name_list
    const typesList = this.state.drivers_type_list
    const sel_type = this.state.selected_type
    var items = []
    if (driversList.length > 0){
      for (var i = 0; i < driversList.length; i++) {
          if (sel_type === "All" || typesList[i] === sel_type){
            items.push(<Option value={driversList[i]}>{namesList[i]}</Option>)
          }
     }
    }
    else{
      items.push(<Option value={'None'}>{'None'}</Option>)
      //items.push(<Option value={'TEST1'}>{'TEST1'}</Option>)
      //items.push(<Option value={'TEST2'}>{'TEST2'}</Option>)
    }
    return items
  }

  // Function for creating type topic options.
  gettypeOptions() { 
    const types = this.state.drivers_type_list
    const typeIds = this.state.type_list
    const typeNames = this.state.type_names
    var items = []
    items.push(<Option value={'None'}>{'None'}</Option>)
    items.push(<Option value={'All'}>{'All'}</Option>)
    if (types.length > 0){
      for (var i = 0; i < typeIds.length; i++) {
        if (types.indexOf(typeIds[i]) !== -1){
          items.push(<Option value={typeIds[i]}>{typeNames[i]}</Option>)
        }
      }
    }
    return items
  }
  


  onToggleDriverSelection(event){
    const {sendStringMsg} = this.props.ros
    const driver_pkg = event.target.value
    const selectNamespace = this.state.mgrNamespace + "/select_driver"
    sendStringMsg(selectNamespace,driver_pkg)
  }


  sendDriverUpdateOrder(){
    const {sendUpdateOrderMsg} = this.props.ros
    var namespace = this.state.mgrNamespace
    var driver_pkg = this.state.driver_pkg
    var move_cmd = this.state.move_cmd
    sendUpdateOrderMsg(namespace,driver_pkg,move_cmd)
  }
  convertDriverStrInstallToStrList(inputStr) {
    var strList = []
    if (inputStr != null){
      inputStr = inputStr.replaceAll("[","")
      inputStr = inputStr.replaceAll("]","")
      inputStr = inputStr.replaceAll(" '","")
      inputStr = inputStr.replaceAll("'","")
      strList = inputStr.split(",")
      
    }
    return strList
  }

  // Function for creating image topic options.
  getInstallOptions() {
    const driversList = this.state.drivers_install_list
    var items = []
    const connected = this.state.connected
    if (connected !== true){
      items.push(<Option value={'Connecting'}>{'Connecting'}</Option>)
    }
    else{
      if (driversList.length > 0){
        for (var i = 0; i < driversList.length; i++) {
            items.push(<Option value={driversList[i]}>{driversList[i]}</Option>)
        }
      }
      else{
        items.push(<Option value={'None'}>{'None'}</Option>)
        //items.push(<Option value={'TEST1'}>{'TEST1'}</Option>)
        //items.push(<Option value={'TEST2'}>{'TEST2'}</Option>)
      }
    }
    return items
  }


  onDropdownSelectedSendDriverOption(event) {
    const {sendUpdateOptionMsg} = this.props.ros
    const topic = event.target.id
    const namespace = this.state.mgrNamespace + "/" + topic
    const driver_pkg = this.state.driver_pkg
    const option_str = event.target.value
    sendUpdateOptionMsg(namespace, driver_pkg, option_str)
  }


  getSettingsNamespace(){
    const active_drivers = this.state.drivers_active_pkg_list
    const active_topics = this.state.drivers_active_namespace_list
    const sel_drv = this.state.driver_pkg
    const set_namespace = this.state.settings_namespace
    const ind = active_drivers.indexOf(sel_drv)
    var cur_namespace = 'None'
    if (ind !== -1){
      cur_namespace = active_topics[ind]
      if (set_namespace !== cur_namespace){  
        this.props.ros.callSettingsCapabilitiesQueryService(cur_namespace)
        this.setState({ settings_namespace: cur_namespace})
      }
    }
    return cur_namespace
  }

  renderDriverConfigure() {
    const { sendStringMsg, sendUpdateOrderMsg, sendUpdateStateMsg, } = this.props.ros
    const NoneOption = <Option>None</Option>
    const namespace = this.getSettingsNamespace()
    const check_topic = namespace + "/settings_status"
    const {topicNames} = this.props.ros
    const topic_publishing = topicNames ? topicNames.indexOf(check_topic) !== -1 : false
    const settings_namespace = topic_publishing ? namespace : ""


    return (
      <React.Fragment>

        <Section title={this.state.driver_display_name}>

        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        <div hidden={(this.state.driver_pkg === 'None')}>

          <label style={{}} align={"left"} textAlign={"left"}>
            {this.state.driver_display_name}
          </label>
    

          <pre style={{ height: "50px", overflowY: "auto" }}>
          {this.state.driver_description}
          </pre>


      <Columns equalWidth={true}>
      <Column>

        <Label title="Enable/Disable Driver">
          <Toggle
            checked={this.state.driver_active_state===true}
            onClick={() => sendUpdateStateMsg(this.state.mgrNamespace + "/update_state", this.state.driver_pkg, !this.state.driver_active_state)}>
          </Toggle>
          </Label>


      </Column>
      <Column>

      <Label title={"Driver Enabled"}>
          <BooleanIndicator value={(this.state.driver_active_state !== null)? this.state.driver_active_state : false} />
        </Label>
        
      </Column>
      <Column>

      <pre style={{ height: "50px", overflowY: "auto" }}>
          {"Subtype: " + this.state.driver_group_id}
          </pre>

      </Column>
      </Columns>


        <Columns equalWidth={true}>
          <Column>


      <Label title={"Type"}>
        <Input disabled value={this.state.driver_type} />
      </Label>
      <Label title={"Group ID"}>
        <Input disabled value={this.state.driver_group_id} />
      </Label>

      </Column>
      <Column>

      <Label title={"Package"}>
        <Input disabled value={this.state.driver_pkg} />
      </Label>



      </Column>
      <Column>


        <Label title={"Driver Start Order"}>
          <Input disabled value={this.state.driver_order} />
        </Label>


        <ButtonMenu>
        <Button onClick={() => sendUpdateOrderMsg(this.state.mgrNamespace + "/update_order", this.state.driver_pkg, "top")}>{"Move to Top"}</Button>
        </ButtonMenu>

        <ButtonMenu>
        <Button onClick={() => sendUpdateOrderMsg(this.state.mgrNamespace + "/update_order", this.state.driver_pkg, "up")}>{"Move    Up"}</Button>
        </ButtonMenu>

        <ButtonMenu>
          <Button onClick={() => sendUpdateOrderMsg(this.state.mgrNamespace + "/update_order", this.state.driver_pkg, "down")}>{"Move Down"}</Button>
        </ButtonMenu>

        <ButtonMenu>
          <Button onClick={() => sendUpdateOrderMsg(this.state.mgrNamespace + "/update_order", this.state.driver_pkg, "bottom")}>{"Move to Bottom"}</Button>
        </ButtonMenu>
        </Column>
        </Columns>

        <div hidden={settings_namespace === 'None'}>
        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        <label style={{fontWeight: 'bold'}}>
            {"Discovery Options Settings"}
          </label>


          <NepiIFSettings
            namespace={settings_namespace}
            make_section={false}
            title={"Nepi_IF_Settings"}
          />

          </div>
          <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        <Columns equalWidth={true}>
          <Column>


          <Label title="Show Remove Driver">
                <Toggle
                checked={this.state.show_delete_driver===true}
                onClick={() => onChangeSwitchStateValue.bind(this)("show_delete_driver",this.state.show_delete_driver)}>
                </Toggle>
          </Label>


      </Column>
      <Column>


      </Column>
      <Column>

      </Column>
      <Column>

        </Column>
        </Columns>


      <div hidden={!this.state.show_delete_driver}>

        <Columns equalWidth={true}>
          <Column>


        <Label title="Backup on Remove">
                <Toggle
                checked={this.state.backup_removed_drivers===true}
                onClick={() => this.props.ros.sendBoolMsg(this.state.mgrNamespace + "/backup_on_remeove", this.state.backup_removed_drivers===false)}>
                </Toggle>
        </Label>


      </Column>
      <Column>

      <ButtonMenu>
        <Button onClick={() => sendStringMsg(this.state.mgrNamespace + "/remove_driver", this.state.selected_driver)}>{"Remove Driver"}</Button>
      </ButtonMenu>

      </Column>
      <Column>

        </Column>
        </Columns>

        </div>

        </div>

        </Section>
      
      </React.Fragment>
    )
  }

  
 
  renderDriverInstall() {
    const selected_install_pkg = this.state.selected_driver_install_pkg ? this.state.selected_driver_install_pkg : "None"
    const install_options = this.getInstallOptions()
    const {sendStringMsg} = this.props.ros
    return (
      <React.Fragment>

        <Section title={"Install/Update Drivers"}>

        <Label title="Install"> 
        <Select
          id="select_target"
          onChange={(event) => onDropdownSelectedSetState.bind(this)(event, "selected_driver_install_pkg")}
          value={this.state.selected_driver_install_pkg}
          >
          {install_options}
        </Select>
        </Label>

        <Label title="Show Install Driver">
                <Toggle
                checked={this.state.show_install_driver===true}
                onClick={() => onChangeSwitchStateValue.bind(this)("show_install_driver",this.state.show_install_driver)}>
                </Toggle>
          </Label>

          <div hidden={!this.state.show_install_driver}>
      <ButtonMenu>
        <Button onClick={() => sendStringMsg(this.state.mgrNamespace + "/install_driver_pkg", selected_install_pkg)}>{"Install Driver"}</Button>
      </ButtonMenu>
      </div>

          <Label title={"Install Folder"} >
          </Label>

          <pre style={{ height: "20Spx", overflowY: "auto" }}>
            {this.state.drivers_install_path}
          </pre>



        </Section>
        
      </React.Fragment>
    )
  }



  getActiveStr(){
    const active_names =  this.state.drivers_active_name_list
    var config_str_list = []
    for (var i = 0; i < active_names.length; i++) {
      config_str_list.push(active_names[i])
      config_str_list.push("\n")
    }
    const config_str =config_str_list.join("")
    return config_str
  }

  
  getDisabledStr(){
    const installed = this.state.drivers_pkg_list
    const active_names =  this.state.drivers_active_name_list
    var config_str_list = []
    for (var i = 0; i < installed.length; i++) {
      if (active_names.indexOf(installed[i]) === -1){
        config_str_list.push(installed[i])
        config_str_list.push("\n")
      }
    }
    const config_str =config_str_list.join("")
    return config_str
  }


  getInstallStr(){
    const install_list = this.state.drivers_install_list
    var config_str_list = []
    for (var i = 0; i < install_list.length; i++) {
      config_str_list.push(install_list[i])
      config_str_list.push("\n")
    }
    const config_str =config_str_list.join("")
    return config_str
  }

  onChangetypeSelection(event){
    var selected_type = event.target.value
    this.setState({selected_type: selected_type})
  }

  render() {
    if (this.state.needs_update === true){
      this.setState({needs_update: false})
    }
    const selected_driver = this.state.selected_driver
    const driver_options = this.getDriverOptions()
    const active_driver_list = this.state.drivers_active_pkg_list
    const hide_driver_list = !this.state.viewableDrivers && !this.state.connected
    const drv_type_options = this.gettypeOptions()
    return (


    <Columns>
      <Column>
      <Label title={"Turn off unused drivers for faster startup times"}> </Label>

      <Columns equalWidth={true}>
        <Column>
        <div style={{ marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        <label style={{fontWeight: 'bold'}}>
            {"Filter Driver List"}
          </label>

          <div style={{ marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>


            <Select onChange={this.onChangetypeSelection}
            id="DrvtypeSelector"
            value={this.state.selected_type}>
            {drv_type_options}
            </Select>

            <div style={{ marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Select Driver"}
         </label>

         <div style={{ marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

          <div onClick={this.toggleViewableDrivers} style={{backgroundColor: Styles.vars.colors.grey0}}>
            <Select style={{width: "10px"}}/>
          </div>
          <div hidden={hide_driver_list}>
          {driver_options.map((driver) =>
          <div onClick={this.onToggleDriverSelection}
            style={{
              textAlign: "center",
              padding: `${Styles.vars.spacing.xs}`,
              color: Styles.vars.colors.black,
              backgroundColor: (driver.props.value === selected_driver) ?
                Styles.vars.colors.green :
                (active_driver_list.includes(driver.props.value)) ? Styles.vars.colors.blue : Styles.vars.colors.grey0,
              cursor: "pointer",
              }}>
              <body driver-topic ={driver} style={{color: Styles.vars.colors.black}}>{driver}</body>
          </div>
          )}
          </div>

      </Column>
      <Column>

      
      <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
      <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Active Drivers List "}
          </label>

      <pre style={{ height: "200px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
        {this.getActiveStr()}
        </pre>

        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
      <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Disabled Drivers List "}
          </label>

        <pre style={{ height: "200px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
        {this.getDisabledStr()}
        </pre>

        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
      <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Install Drivers List "}
          </label>

        <pre style={{ height: "200px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
        {this.getInstallStr()}
        </pre>

        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

      </Column>
      <Column>

      <ButtonMenu>
        <Button onClick={() => this.props.ros.sendTriggerMsg(this.state.mgrNamespace + "/enable_all_drivers")}>{"Enable All"}</Button>
      </ButtonMenu>

      <ButtonMenu>
        <Button onClick={() => this.props.ros.sendTriggerMsg(this.state.mgrNamespace + "/disable_all_drivers")}>{"Disable All"}</Button>
      </ButtonMenu>

      <ButtonMenu>
        <Button onClick={() => this.props.ros.sendTriggerMsg(this.state.mgrNamespace + "/refresh_drivers")}>{"Refresh"}</Button>
      </ButtonMenu>

        <ButtonMenu>
        <Button onClick={() => this.props.ros.sendTriggerMsg(this.state.mgrNamespace + "/factory_reset")}>{"Factory Reset"}</Button>
      </ButtonMenu>

      <Label title="Allow Discovery Retry">
          <Toggle
            checked={this.state.retry_enabled}
            onClick={() => this.props.ros.sendBoolMsg(this.state.mgrNamespace + "/enable_retry", !this.state.retry_enabled)}>
          </Toggle>
          </Label>

        </Column>
      </Columns>


      </Column>
      <Column>
      
      <div hidden={this.state.driver_pkg === 'None'}>

        {this.renderDriverConfigure()}

      </div>

      {this.renderDriverInstall()}

       </Column>
     </Columns>
         

          

    )
  }

}

export default DriversMgr
