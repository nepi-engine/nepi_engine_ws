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
//import EnableAdjustment from "./EnableAdjustment"
import Button, { ButtonMenu } from "./Button"
import BooleanIndicator from "./BooleanIndicator"
import Toggle from "react-toggle"
import Label from "./Label"
import { Column, Columns } from "./Columns"
import Styles from "./Styles"
import Select, { Option } from "./Select"
import Input from "./Input"


import NepiIFConfig from "./Nepi_IF_Config"

function roundWithSuffix(value, decimals, suffix) {
  return value && (value.toFixed(decimals) + " " + suffix)
}

@inject("ros")
@observer

// Component that contains the Save Data Controls
class NepiIFSaveData extends Component {
  constructor(props) {
    super(props)

    // these states track the values through the components Save Data Status messages
    this.state = {
      namespace: 'None',
      capabilities: null,
      saveRatesMsg: "",
      saveDataPrefix: "",
      saveUtcTz: false,
      exp_filename: "",
      saveDataEnabled: false,
      saveDataRate: "1.0",
      saveNamesList: [],
      saveRatesList: [],
      selectedDataProducts: [],

      showControls: this.props.showControls ? this.props.showControls : false,

      needs_update: true,
      saveStatusListener: null
    }


    this.updateSaveStatusListener = this.updateSaveStatusListener.bind(this)
    this.saveStatusListener = this.saveStatusListener.bind(this)

    this.updateSaveLists = this.updateSaveLists.bind(this)
    this.getSaveNamesList = this.getSaveNamesList.bind(this)
    this.getSaveRatesList = this.getSaveRatesList.bind(this)
    this.getSaveConfigString = this.getSaveConfigString.bind(this)
    this.getSaveRateValue = this.getSaveRateValue.bind(this)
    this.getSaveRateData = this.getSaveRateData.bind(this)
    this.onClickToggleShowSettings = this.onClickToggleShowSettings.bind(this)


    this.getSaveDataValue = this.getSaveDataValue.bind(this)
    this.onChangeBoolSaveDataValue = this.onChangeBoolSaveDataValue.bind(this)
    this.onChangeBoolUtcTzValue = this.onChangeBoolUtcTzValue.bind(this)
    this.onUpdateInputSaveDataRateValue = this.onUpdateInputSaveDataRateValue.bind(this)
    this.onKeySaveInputSaveDataRateValue = this.onKeySaveInputSaveDataRateValue.bind(this)
    this.onUpdateInputSaveDataPrefixValue = this.onUpdateInputSaveDataPrefixValue.bind(this)
    this.onKeySaveInputSaveDataPrefixValue = this.onKeySaveInputSaveDataPrefixValue.bind(this)
    this.onToggleDataProductSelection = this.onToggleDataProductSelection.bind(this)
    this.sendSaveRateUpdate = this.sendSaveRateUpdate.bind(this)
    
    this.updateSelectedDataProducts = this.updateSelectedDataProducts.bind(this)
    this.getSelectedDataProducts = this.getSelectedDataProducts.bind(this)
    this.getDiskUsageRate = this.getDiskUsageRate.bind(this)

    this.updateCapabilities = this.updateCapabilities.bind(this)

    this.convertStrListToMenuList = this.convertStrListToMenuList.bind(this)
    
    this.doNothing = this.doNothing.bind(this)

    this.onSnapshotTriggered = this.onSnapshotTriggered.bind(this)

  }

  // CAllback for handling ROS Status messages
  saveStatusListener(message) {
    const saveDataRates = message.save_data_rates
    const saveDirPrefix = message.current_subfolder
    const saveNamePrefix = message.current_filename_prefix
    const saveUtcTz = message.save_data_utc
    const saveData = message.save_data_enabled
    const exp_filename = message.example_filename
    var saveDataPrefix = ""
    if (saveDirPrefix === ""){
      saveDataPrefix = saveNamePrefix
    } else {
      saveDataPrefix = saveDirPrefix + "/" + saveNamePrefix
    }
    this.setState({
      saveRatesMsg: saveDataRates,
      saveDataPrefix: saveDataPrefix,
      saveUtcTz: saveUtcTz,
      exp_filename: exp_filename,
      saveDataEnabled: saveData
    })
    this.updateSaveLists()
    this.updateSelectedDataProducts()
  }

  // Function for configuring and subscribing to Status
  updateSaveStatusListener() {
    const namespace = this.props.namespace + '/save_data'
    if (this.state.saveStatusListener) {
      this.state.saveStatusListener.unsubscribe()
    }
    if (namespace != 'None'){
      var saveStatusListener = this.props.ros.setupSaveDataStatusListener(
            namespace,
            this.saveStatusListener
          )
      this.setState({ namespace: namespace})
      this.setState({ saveStatusListener: saveStatusListener,
        needs_update: false})
    }
  }

  // Lifecycle method cAlled when compnent updates.
  // Used to track changes in the topic
  componentDidUpdate(prevProps, prevState, snapshot) {
    const namespace = this.props.namespace ? this.props.namespace : 'None'
    const namespace_updated = (prevProps.namespace !== namespace && namespace !== 'None')
  
    if ((namespace_updated) && !namespace.includes("null")) {
      this.updateSaveStatusListener()
    }
  }

  // Lifecycle method cAlled just before the component umounts.
  // Used to unsubscribe to Status message
  componentWillUnmount() {
    if (this.state.saveStatusListener) {
      this.state.saveStatusListener.unsubscribe()
    }
  }



  // Function for creating settings options list from capabilities
  updateCapabilities() {
    const {saveDataCaps} = this.props.ros
    const cur_namespace = this.props.namespace
    const set_namespace = this.state.namespace.replace('/save_data','')
    var capabilities = null
    if (saveDataCaps){
      capabilities = saveDataCaps[set_namespace]
    }    
    if (capabilities != null && set_namespace !== cur_namespace){
      this.setState({
        capabilities: capabilities,
      })
    }
    else if (capabilities == null) {
      this.setState({
        capabilities: null,
      })
    }
    const new_namespace = this.state.namespace + '/save_data'
    this.setState({namespace:  new_namespace})
  }


  // Function for creating configs options list from capabilities
  updateSaveLists() {
    var saveRatesMsg = this.state.saveRatesMsg
    var NamesList = []
    var RatesList = []
    var name = ""
    var rate_int = 0
    var rate_str = ""
    var saveRateMsg = null
    // add None and All options to lists
    NamesList.push("None")
    RatesList.push("0.0")
    NamesList.push("All")
    RatesList.push(this.state.saveDataRate)
    for (let ind = 0; ind < saveRatesMsg.length; ind++){
        saveRateMsg =saveRatesMsg[ind]
        name = saveRateMsg.data_product
        rate_int = saveRateMsg.save_rate_hz
        rate_str = rate_int.toFixed(2)
        NamesList.push(name)
        RatesList.push(rate_str)
    }
    this.setState({saveNamesList:NamesList})
    this.setState({saveRatesList:RatesList})
  }

  onClickToggleShowSettings(){
    const currentVal = this.state.showControls 
    this.setState({showControls: !currentVal})
    this.render()
  }


  getSaveNamesList(){
    const list = this.state.saveNamesList
    return list
  }

  getSaveRatesList(){
    const list = this.state.saveRatesList
    return list
  }


  getSaveConfigString() {
    const namesList = this.state.saveNamesList
    const ratesList = this.state.saveRatesList
    var configsStr = ""
    var entryStr
    var configsStrList = [""]
    for (let ind = 0; ind < namesList.length; ind++) {
      if (namesList[ind] !== "None" && namesList[ind] !== "All" ){
        entryStr = namesList[ind] + " : " + ratesList[ind] +  " Hz\n"
        configsStrList.push(entryStr)
      }
    }
    configsStr = configsStrList.join("")
    return configsStr
  }

  getSaveRateValue(dataName) {
    const configsStrList = this.getsaveRatesAsList()
    const configInd = configsStrList.indexOf(dataName)
    return configsStrList[configInd + 1]
  }

  getSaveRateData(dataName) {
    const configValue = this.getSaveRateValue(dataName)
    return parseFloat(configValue)
  }

  sendSaveRateUpdate(data_product,rate) {
    const {updateSaveDataRate}  = this.props.ros
    if (isNaN(rate) === false){
      updateSaveDataRate(this.state.namespace,data_product,rate)
    }
  }

  updateSelectedDataProducts() {
    const NamesList = this.state.saveNamesList
    const RatesList = this.state.saveRatesList
    var selectedList = []
    var name = ""
    for (let ind = 0; ind < NamesList.length; ind++){
      name = NamesList[ind]
      if (name !== "None" && name !== "All"){
        if (parseFloat(RatesList[ind]) > 0) {
          selectedList.push(NamesList[ind])
        }
      }
    }
    this.setState({selectedDataProducts:selectedList})
  }

  getSelectedDataProducts(){
    const list =  this.state.selectedDataProducts
    return list
  }

  doNothing(){
    var ret = false
    return ret
  }
 
  onToggleDataProductSelection(event){
    const data_product = event.target.getAttribute("data-product")
    var selectedList = this.getSelectedDataProducts()
    const saveDataRate = this.state.saveDataRate
    const rate = parseFloat(saveDataRate)
    const ind = selectedList.indexOf(data_product)
    if ( ind !== -1 ){
      delete selectedList[ind]
      this.sendSaveRateUpdate(data_product,0.0)
    } else {
      selectedList.push(data_product)
      this.sendSaveRateUpdate(data_product,rate)
    }
  }

  getSaveDataValue(){
    const saveData = (this.state.saveDataEnabled === true)
    return saveData
  }


  onChangeBoolSaveDataValue(){
    const {sendBoolMsg}  = this.props.ros
    const enabled = (this.state.saveDataEnabled === false)
    const saveDataRate = this.state.saveDataRate
    const rate = parseFloat(saveDataRate)
    this.sendSaveRateUpdate('Active',rate)
    sendBoolMsg(this.state.namespace + '/save_data_enable',enabled)

  }

  onChangeBoolUtcTzValue(e){
    const {sendBoolMsg}  = this.props.ros
    const enabled = e.target.checked
    sendBoolMsg(this.state.namespace + '/save_data_utc',enabled)
  }


  onUpdateInputSaveDataRateValue(event) {
    this.setState({ saveDataRate: event.target.value })
    document.getElementById("input_rate").style.color = Styles.vars.colors.red
    this.render()
  }

  onKeySaveInputSaveDataRateValue(event) {
    const saveDataRate = this.state.saveDataRate
    const rate = parseFloat(saveDataRate)
    if(event.key === 'Enter'){
      const rate = parseFloat(event.target.value)
      if (!isNaN(rate)){
        this.setState({saveDataRate: event.target.value })
        this.sendSaveRateUpdate('Active',rate)
      }
      document.getElementById("input_rate").style.color = Styles.vars.colors.black
    }
  }



  onUpdateInputSaveDataPrefixValue(event) {
    this.setState({ saveDataPrefix: event.target.value })
    document.getElementById("input_prefix").style.color = Styles.vars.colors.red
    this.render()
  }

  onKeySaveInputSaveDataPrefixValue(event) {
    const { updateSaveDataPrefix} = this.props.ros
    const key = event.key
    const value = event.target.value
    if(key === 'Enter'){
      document.getElementById("input_prefix").style.color = Styles.vars.colors.black
    }
  }
  

  convertStrListToMenuList(strList){
    var menuList = []
    for (let ind = 0; ind < strList.length; ind++){
      menuList.push(<Option>{strList[ind]}</Option>)
    } 
    return menuList
  }

  getDiskUsageRate(){
    const {systemStatusDiskRate} = this.props.ros
    return systemStatusDiskRate
  }


  onSnapshotTriggered(){
    const { sendTriggerMsg} = this.props.ros
    sendTriggerMsg(this.state.namespace + '/snapshot_trigger')
  }

  render() {
    const { sendTriggerMsg} = this.props.ros
    const saveDataEnabled = this.getSaveDataValue()
    const dataProdcutSources = this.getSaveNamesList()
    const selectedDataProducts = this.getSelectedDataProducts()
    const diskUsage = this.getDiskUsageRate()
    const saveUtcTz = this.state.saveUtcTz
    const namespace = this.state.namespace ? this.state.namespace : 'None'

    
    return (
      <Section title={"Save Data"}>

            <Columns>
            <Column>

                    <ButtonMenu >
                        <Button onClick={this.onSnapshotTriggered}>{"Take Snapshot"}</Button>
                      </ButtonMenu>

                      <Label title={"Save Data"}>
                      <Toggle
                        checked={ (saveDataEnabled === true) }
                        onClick={() => {this.onChangeBoolSaveDataValue()}}
                      />
                    </Label>

                      <Label title="Show Controls">
                        <Toggle
                          checked={this.state.showControls===true}
                          onClick={this.onClickToggleShowSettings}>
                        </Toggle>
                      </Label>

              </Column>
              <Column>

              </Column>
              <Column>


            </Column>
            </Columns>


            <div align={"left"} textAlign={"left"} hidden={this.state.showControls === false}>

                  <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
              
                <Columns>
                  <Column>

                        <Label title={"Use UTC Time"}>
                            <Toggle
                              checked={ (saveUtcTz) }
                              onClick={this.onChangeBoolUtcTzValue}
                            />
                          </Label>

                          <Label title={"Set Save Rate (Hz)"}>
                            <Input id="input_rate" 
                                value={this.state.saveDataRate} 
                                onChange={this.onUpdateInputSaveDataRateValue} 
                                onKeyDown= {this.onKeySaveInputSaveDataRateValue} />
                        </Label>

                        <Label title={"Set Save Prefix"}>
                          <Input id="input_prefix" 
                              value={this.state.saveDataPrefix} 
                              onChange={this.onUpdateInputSaveDataPrefixValue} 
                              onKeyDown= {this.onKeySaveInputSaveDataPrefixValue} />
                        </Label>



                        <Label title={"Selected Message Topics"}>
                          <div onClick={this.doNothing} style={{backgroundColor: Styles.vars.colors.grey0}}>
                            <Select style={{width: "10px"}}/>
                          </div>

                            {dataProdcutSources.map((data_product) =>
                            <div onClick={this.onToggleDataProductSelection}
                                style={{
                                    textAlign: "center",
                                    padding: `${Styles.vars.spacing.xs}`,
                                    color: Styles.vars.colors.black,
                                    backgroundColor: (selectedDataProducts.includes(data_product))? Styles.vars.colors.blue : Styles.vars.colors.grey0,
                                    cursor: "pointer",
                                  }}>
                                  <body data-product={data_product} style={{color: Styles.vars.colors.black}}>{data_product}</body>
                            </div>
                            )}
                        </Label>

      

                  </Column>
                  <Column>

                        <Label title={""}>
                        </Label>
                        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

                        <Label title={"Saving"}>
                          <BooleanIndicator value={(this.getSaveDataValue() === true)} />
                        </Label>

                        <Label title={"Data Save Rate"}>
                          <Input disabled value={roundWithSuffix(diskUsage, 3, "MB/s")} />
                        </Label>

                        <Label title={"Example Filename"}>
                        </Label>

                        <pre style={{ height: "100px", overflowY: "auto" }}>
                          {this.state.exp_filename}
                        </pre>

                        <Label title={"Data Product Save Settings"}>
                        </Label>

                        <pre style={{ height: "400px", overflowY: "auto" }}>
                          {this.getSaveConfigString()}
                        </pre>

                  </Column>
                </Columns>
        
          </div>


          <div align={"left"} textAlign={"left"} hidden={namespace === 'None'}>

                  <NepiIFConfig
                        namespace={namespace}
                        title={"Nepi_IF_Config"}
                  />

          </div>


      </Section>
    )
  }

}
export default NepiIFSaveData
