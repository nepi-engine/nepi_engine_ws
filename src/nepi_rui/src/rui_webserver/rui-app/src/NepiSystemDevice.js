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
import {Link} from "react-router-dom"
import Toggle from "react-toggle"
import { displayNameFromNodeName, nodeNameFromDisplayName } from "./Store"
import Input from "./Input"
import Section from "./Section"
import { Columns, Column } from "./Columns"
import Label from "./Label"
import Button, { ButtonMenu } from "./Button"
import Select, { Option } from "./Select"
import Styles from "./Styles"
import BooleanIndicator from "./BooleanIndicator"

function round(value, decimals = 0) {
  return value && Number(Math.round(value + "e" + decimals) + "e-" + decimals)
}

function styleTextEdited(text_box_element) {
  text_box_element.style.color = Styles.vars.colors.red
  text_box_element.style.fontWeight = "bold"
}

function styleTextUnedited(text_box_element) {
  text_box_element.style.color = Styles.vars.colors.black
  text_box_element.style.fontWeight = "normal"
}

const styles = Styles.Create({
  link_style: {
    color: Styles.vars.colors.blue,
    fontSize: Styles.vars.fontSize.medium,
    //lineHeight: Styles.vars.lineHeights.xl 
  }
})

@inject("ros")
@observer
class NepiSystemDevice extends Component {
  constructor(props) {
    super(props)

    this.state = {
      mgrName: "network_mgr",
      mgrNamespace: null,

      autoRate: this.props.ros.triggerAutoRateHz,
      autoRateUserEditing: false,
      ipAddrVal: "0.0.0.0/24",
      configSubsys: "All",
      advancedConfigEnabled: false,
      updatedDeviceId: "",
      selectedWifiNetwork: "",
      wifiClientSSID: "",
      wifiClientPassphrase: "",
      wifiAPSSIDEdited: false,
      wifiAPSSID: "",
      wifiAPPassphrase: "",
      tx_bandwidth_limit: (this.props.ros.bandwidth_usage_query_response !== null)? this.props.ros.bandwidth_usage_query_response.tx_limit_mbps : -1,
      tx_bandwidth_user_editing: false,
      

      netStatus: null,
      last_netStatus: null,
      connected: true,
      netListener: null

    }

    this.onUpdateAutoRateText = this.onUpdateAutoRateText.bind(this)
    this.onKeyAutoRateText = this.onKeyAutoRateText.bind(this)
    this.onUpdateTXRateLimitText = this.onUpdateTXRateLimitText.bind(this)
    this.onKeyTXRateLimitText = this.onKeyTXRateLimitText.bind(this)

    this.onIPAddrValChange = this.onIPAddrValChange.bind(this)
    this.onAddButtonPressed = this.onAddButtonPressed.bind(this)
    this.onRemoveButtonPressed = this.onRemoveButtonPressed.bind(this)
    this.onSaveCfg = this.onSaveCfg.bind(this)
    this.onUserReset = this.onUserReset.bind(this)
    this.onFactoryReset = this.onFactoryReset.bind(this)
    this.onConfigSubsysSelected = this.onConfigSubsysSelected.bind(this)
    this.onToggleAdvancedConfig = this.onToggleAdvancedConfig.bind(this)
    this.createConfigSubsysOptions = this.createConfigSubsysOptions.bind(this)
    this.onConnectClientWifiButton = this.onConnectClientWifiButton.bind(this)
    this.createWifiNetworkOptions = this.createWifiNetworkOptions.bind(this)
    this.onWifiNetworkSelected = this.onWifiNetworkSelected.bind(this)
    this.onUpdateClientPassphraseText = this.onUpdateClientPassphraseText.bind(this)
    this.onKeyClientWifiPassphrase = this.onKeyClientWifiPassphrase.bind(this)
    this.onUpdateAPSSIDText = this.onUpdateAPSSIDText.bind(this)
    this.onUpdateAPPassphraseText = this.onUpdateAPPassphraseText.bind(this)
    this.onKeyAPWifi = this.onKeyAPWifi.bind(this)


    this.onDeviceIdChange = this.onDeviceIdChange.bind(this)
    this.onDeviceIdKey = this.onDeviceIdKey.bind(this)

    this.renderDeviceConfiguration = this.renderDeviceConfiguration.bind(this)
    this.renderLicense = this.renderLicense.bind(this)
    this.renderLicenseRequestInfo = this.renderLicenseRequestInfo.bind(this)
    this.renderLicenseInfo = this.renderLicenseInfo.bind(this)
    this.renderNetworkInfo = this.renderNetworkInfo.bind(this)
    this.renderTriggerSettings = this.renderTriggerSettings.bind(this)

    this.updateMgrNetStatusListener = this.updateMgrNetStatusListener.bind(this)
    this.netStatusListener = this.netStatusListener.bind(this)
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
  netStatusListener(message) {
    this.setState({
      netStatus: message,
      connected: true
    })    
  }

  // Function for configuring and subscribing to Status
  updateMgrNetStatusListener() {
    const statusNamespace = this.getMgrNamespace() + '/status'
    if (this.state.netListener) {
      this.state.netListener.unsubscribe()
    }
    var netListener = this.props.ros.setupStatusListener(
          statusNamespace,
          "nepi_interfaces/MgrNetworkStatus",
          this.netStatusListener
        )
    this.setState({ netListener: netListener,
      needs_update: false})
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
        this.updateMgrNetStatusListener()
      } 
    }
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status message
  componentWillUnmount() {
    if (this.state.netListener) {
      this.state.netListener.unsubscribe()
      this.state.appListener.unsubscribe()
    }
  }




  async onDeviceIdChange(e) {
    this.setState({ updatedDeviceId: e.target.value })
    var device_id_textbox = document.getElementById(e.target.id)
    styleTextEdited(device_id_textbox)
  }

  async onDeviceIdKey(e) {
    const {setDeviceID} = this.props.ros
    if(e.key === 'Enter'){
      setDeviceID({newDeviceID: this.state.updatedDeviceId})
      var device_id_textbox = document.getElementById(e.target.id)
      styleTextUnedited(device_id_textbox)
    }
  }

  renderDeviceConfiguration() {
    const { resetTopics, onUserCfgRestore, onFactoryCfgRestore } = this.props.ros
    const { advancedConfigEnabled, configSubsys } = this.state
    const {deviceId} = this.props.ros
    const sys_debug = this.props.ros.systemDebugEnabled
    const debug_mode = sys_debug ? sys_debug : false
    if (this.state.advancedConfigEnabled === false && deviceId !== this.state.updatedDeviceId){
      this.setState({updatedDeviceId:deviceId})
    }
    const updatedDeviceId = this.state.updatedDeviceId
      
    return (

      <Section title={"System Settings"}>




              <Columns>
              <Column>

                    <Label title={"Device ID"}>
                    <Input
                      id={"device_id_update_text"}
                      value={deviceId }
                      disabled={!advancedConfigEnabled}
                      onChange={this.onDeviceIdChange}
                      onKeyDown={this.onDeviceIdKey}
                    />
                  </Label>



                  </Column>
                  <Column>
 
                  <Label title={"Show Advanced Settings"}>
                    <Toggle
                      onClick={this.onToggleAdvancedConfig}>
                    </Toggle>
                  </Label>


                </Column>
                  </Columns>






                    <div hidden={!advancedConfigEnabled}>

                    <Columns>
                    <Column>

                          <Label title="System Debug Mode">
                                <Toggle
                                checked={debug_mode}
                                onClick={() => this.props.ros.sendBoolMsg("debug_mode_enable", !debug_mode)}>
                              </Toggle>
                          </Label>
                                  

                          <Label title={"Save/Reset Options"}>
                            <Select
                              onChange={this.onConfigSubsysSelected}
                              value={configSubsys}
                            >
                              {this.createConfigSubsysOptions(resetTopics)}
                            </Select>
                          </Label>




                            <ButtonMenu>
                              <Button onClick={this.onSaveCfg}>{"Save"}</Button>
                              <Button onClick={this.onUserReset}>{"Reset"}</Button>
                              <Button onClick={this.onFactoryReset}>{"Factory Reset"}</Button>
                              {/*
                              <Button onClick={this.onSoftwareReset}>{"Software Reset"}</Button>
                              <Button onClick={this.onHardwareReset}>{"Hardware Reset"}</Button>
                            */}
                            </ButtonMenu>


                            <ButtonMenu>
                              <Button onClick={this.onFactoryCfgRestore}>{"Full Factory Restore"}</Button>
                              <Button onClick={onUserCfgRestore}>{"Full User Restore"}</Button>
                            </ButtonMenu>

     

                  </Column>
                  <Column>


                          <Label title="System Debug Mode">
                              <Toggle
                              checked={debug_mode}
                              onClick={() => this.props.ros.sendBoolMsg("debug_mode_enable", !debug_mode)}>
                            </Toggle>
                        </Label>
                            
   
                </Column>
                  </Columns>
              
              </div>





      </Section>
    )
  }

  renderLicense() {
    const {license_info} = this.props.ros

    const license_info_valid = license_info && ("licensed_components" in license_info) && ("nepi_base" in license_info["licensed_components"]) &&
      "commercial_license_type" in license_info["licensed_components"]["nepi_base"]

    const license_issue_date = license_info_valid && "issued_date" in license_info["licensed_components"]["nepi_base"]?
    license_info["licensed_components"]["nepi_base"]["issued_date"] : ""

    const license_issue_version = license_info_valid && "issued_version" in license_info["licensed_components"]["nepi_base"]?
      license_info["licensed_components"]["nepi_base"]["issued_version"] : ""

    const license_expiration_date = license_info_valid && "expiration_date" in license_info["licensed_components"]["nepi_base"]?
      license_info["licensed_components"]["nepi_base"]["expiration_date"] : null

    const license_expiration_version = license_info_valid && "expiration_version" in license_info["licensed_components"]["nepi_base"]?
      license_info["licensed_components"]["nepi_base"]["expiration_version"] : null
    
    return (
      <div>
        <Label title={"Issue Date"}>
          <Input value={license_issue_date} disabled={true}/>
        </Label>
        {/*
        <Label title={"Issue Version"}>
          <Input value={license_issue_version} disabled={true}/>
        </Label>
        {license_expiration_date?
          <Label title={"Expiration Date"}>
            <Input value={license_expiration_date} disabled={true}/>
          </Label>
          : null
        }
        {license_expiration_version?
          <Label title={"Expiration Version"}>
            <Input value={license_expiration_version} disabled={true}/>
          </Label>
          : null
        }
      */}
      </div>
    )
  }

  renderLicenseRequestInfo() {
    const { license_request_info } = this.props.ros

    const license_request_info_valid = license_request_info && ('license_request' in license_request_info)
    const license_hw_key = (license_request_info_valid && ('hardware_key' in license_request_info['license_request']))?
      license_request_info['license_request']['hardware_key'] : 'Unknown'
    const license_request_date = (license_request_info_valid && ('date' in license_request_info['license_request']))?
      license_request_info['license_request']['date'] : 'Unknown'    
    const license_request_version = (license_request_info_valid && ('version' in license_request_info['license_request']))?
      license_request_info['license_request']['version'] : 'Unknown'    

    return (
      // TODO: A QR code or automatic API link would be nicer here.
      <div>
        <Label title={"H/W Key"}>
          <Input value={license_hw_key} disabled={true}/>
        </Label>
        <Label title={"Date"}>
          <Input value={license_request_date} disabled={true}/>
        </Label>
        <Label title={"Version"}>
          <Input value={license_request_version} disabled={true}/>
        </Label>
      </div>
    )
  }

  renderLicenseInfo() {
    const {license_info, commercial_licensed, license_request_mode, onGenerateLicenseRequest} = this.props.ros

    const license_info_valid = license_info && ("licensed_components" in license_info) && ("nepi_base" in license_info["licensed_components"]) &&
                               "commercial_license_type" in license_info["licensed_components"]["nepi_base"] &&
                               "status" in license_info["licensed_components"]["nepi_base"]
    
    var license_type = license_info_valid? license_info["licensed_components"]["nepi_base"]["commercial_license_type"] : "Unlicensed"
    var license_status = license_info_valid? license_info["licensed_components"]["nepi_base"]["status"] : ""
    if (license_request_mode === true) {
      license_type = "Request"
      license_status = "Pending"
    }

    return (
      <Section title={"NEPI License"}>
        <Label title={"Type"}>
          <Input value={license_type} disabled={true}/>
        </Label>

        <div hidden={license_type !== "Unlicensed"}> 
        <pre style={{ height: "25px", overflowY: "auto" }}>
            {"No Commercial License Found. Valid for development purposes only"}
          </pre>
        </div>

        {license_info_valid?
          <Label title={"Status"} >
            <Input value={license_status} disabled={true}/>
          </Label>
          : null
        }

        {license_info_valid && license_request_mode?
          this.renderLicenseRequestInfo() : null
        }

        {license_info_valid && !license_request_mode?
          this.renderLicense() : null
        }
                         
        {(license_info_valid && !commercial_licensed)?
          <ButtonMenu>
            <Button onClick={onGenerateLicenseRequest}>{"License Request"}</Button>
          </ButtonMenu>
          : null
        }
                  
        {(license_info_valid && !commercial_licensed)?
            <div style={{textAlign: "center"}}>
              <Link to={{ pathname: "commercial_license_request_instructions.html" }} target="_blank" style={styles.link_style}>
                Open license request instructions
              </Link>
            </div>
            : null
        }
      </Section>
    )
  }

  renderTriggerSettings() {
    const {
      //triggerMask,
      onPressManualTrigger,
      //onToggleHWTriggerOutputEnabled,
      //onToggleHWTriggerInputEnabled,
      triggerAutoRateHz
    } = this.props.ros

    return (
      <Section title={"Trigger Settings"}>
        <Label title={"Auto Rate (Hz)"}>
          <Input
            id="autoRateInput"
            value={(this.state.autoRateUserEditing === true)? this.state.autoRate : triggerAutoRateHz}
            onChange={this.onUpdateAutoRateText} onKeyDown={this.onKeyAutoRateText}
          />
        </Label>
        <ButtonMenu>
          <Button onClick={onPressManualTrigger}>{"Manual Trigger"}</Button>
        </ButtonMenu>
        {/*
        <Label title={"Hardware Trigger Input Enable"}>
          <Toggle
            checked={false}
            disabled={true}
          />
        </Label>
        <Label title={"Hardware Trigger Output Enable"}>
          <Toggle
            checked={true}
            disabled={true}
          />
        </Label>
        */}
      </Section>
    )
  }



  createWifiNetworkOptions(wifiNetworks) {
    var network_options = []
    network_options.push(<Option>{"None"}</Option>)
    for (var i = 0; i < wifiNetworks.length; i++) {
      network_options.push(<Option>{wifiNetworks[i]}</Option>)
    }

    return network_options
  }


  onUpdateAutoRateText(e) {
    this.setState({autoRate: e.target.value});
    this.setState({autoRateUserEditing: true});
    styleTextEdited(document.getElementById(e.target.id))
  }

  onKeyAutoRateText(e) {
    const {onChangeTriggerRate, } = this.props.ros
    if(e.key === 'Enter'){
      this.setState({autoRateUserEditing: false});
      onChangeTriggerRate(this.state.autoRate)
      styleTextUnedited(document.getElementById(e.target.id))
    }
  }

  onUpdateTXRateLimitText(e) {
    this.setState({tx_bandwidth_limit: e.target.value});
    this.setState({tx_bandwidth_user_editing: true});
    var rate_limit_textbox = document.getElementById(e.target.id)
    styleTextEdited(rate_limit_textbox)
  }

  onKeyTXRateLimitText(e) {
    const {onChangeTXRateLimit} = this.props.ros
    if(e.key === 'Enter'){
      this.setState({tx_bandwidth_user_editing: false});
      onChangeTXRateLimit(this.state.tx_bandwidth_limit)
      var rate_limit_textbox = document.getElementById(e.target.id)
      styleTextUnedited(rate_limit_textbox)
    }
  }

  async onIPAddrValChange(e) {
    await this.setState({ipAddrVal: e.target.value})
  }

  async onAddButtonPressed() {
    const { addIPAddr } = this.props.ros
    const { ipAddrVal } = this.state

    addIPAddr(ipAddrVal)
  }

  async onRemoveButtonPressed() {
    const { removeIPAddr } = this.props.ros
    const { ipAddrVal } = this.state

    removeIPAddr(ipAddrVal)
  }


  renderNetworkInfo() {
    const { systemInContainer, sendTriggerMsg, onToggleDHCPEnabled, bandwidth_usage_query_response } = this.props.ros
    const { ipAddrVal } = this.state
    const netStatus = this.state.netStatus
    const dhcp_enabled = (netStatus !== null)? netStatus.dhcp_enabled : false
    const primary_addr = (netStatus !== null)? netStatus.primary_ip_addr : ''
    const managed_addrs = (netStatus !== null)? netStatus.managed_ip_addrs : []
    const dhcp_addr = (netStatus !== null)? netStatus.dhcp_ip_addr : ''
    const internet_connected = dhcp_enabled ? ((netStatus !== null)? netStatus.internet_connected : false):false
    const clock_skewed = (netStatus !== null)? netStatus.clock_skewed : false
    const message = clock_skewed == false ? "" : "Clock out of date. Sync Clock to use DHCP"
    
    return (
      <Section title={"Ethernet"}>

          <Columns>
            <Column>


              <div hidden={systemInContainer === false}> 

                      <pre style={{ height: "88px", overflowY: "auto" }}>
                        {"NEPI Running in Container Mode.  Ethernet configuration set by host system"}
                      </pre>
            </div>

             <div hidden={systemInContainer === true}>  





                    <Label title={"Add/Remove IP Alias"}>
                      <Input value={ipAddrVal} onChange={ this.onIPAddrValChange} />
                    </Label>
                    <ButtonMenu>
                      <Button onClick={this.onAddButtonPressed}>{"Add"}</Button>
                      <Button onClick={this.onRemoveButtonPressed}>{"Remove"}</Button>
                    </ButtonMenu>


                    <Label title={"Device IP Addresses"}>
                      <pre style={{ height: "75px", overflowY: "auto" }}>
                        {primary_addr + '\n' + managed_addrs.join('\n')}
                      </pre>
                    </Label>




                    <Columns>
                  <Column>

                  <div hidden={clock_skewed === false}> 

                        <pre style={{ height: "25px", overflowY: "auto" , color: Styles.vars.colors.red }}>
                            {message}
                          </pre>

                   </div>

                      </Column>
                  </Columns>

                      <Label title={"DHCP Enable"}>
                            <Toggle
                              checked={dhcp_enabled}
                              onClick= {onToggleDHCPEnabled}
                            />
                          </Label>


                        <div hidden={dhcp_enabled === false}>

                            <Label title={"DHCP IP Addresses"}>
                              <pre style={{ height: "25px", overflowY: "auto" }}>
                                {dhcp_addr}
                              </pre>
                            </Label>


                            <Label title={"Wired Internet Connected"}>
                              <BooleanIndicator value={internet_connected} />
                            </Label>
                        </div>



                </div>


            </Column>
              <Column>



              <Label title={"TX Data Rate (Mbps)"}>
                      <Input disabled value={(bandwidth_usage_query_response !== null)? round(bandwidth_usage_query_response.tx_rate_mbps, 2) : -1.0} />
                    </Label>
                    <Label title={"RX Data Rate (Mbps)"}>
                      <Input disabled value={(bandwidth_usage_query_response !== null)? round(bandwidth_usage_query_response.rx_rate_mbps, 2) : -1.0} />
                    </Label>
                    <Label title={"TX Rate Limit (Mbps)"}>
                      <Input
                        id="txRateLimit"
                        value={((this.state.tx_bandwidth_user_editing === true) || (bandwidth_usage_query_response === null))?
                          this.state.tx_bandwidth_limit : bandwidth_usage_query_response.tx_limit_mbps}
                        onChange={this.onUpdateTXRateLimitText}
                        onKeyDown={this.onKeyTXRateLimitText}
                      />
                    </Label>


            </Column>
            </Columns>
      </Section>
    )
  }


  onWifiNetworkSelected(e) {
    var passphrase_textbox = document.getElementById("wifi_client_passphrase_textbox")
    if (e.target.value !== "" && e.target.value !== "None") {
      passphrase_textbox.style.color = Styles.vars.colors.red
      passphrase_textbox.style.fontWeight = "bold"
    }
    else {
      passphrase_textbox.style.color = Styles.vars.colors.black
      passphrase_textbox.style.fontWeight = "normal"  
    }

    this.setState({
      selectedWifiNetwork: e.target.value,
      wifiClientSSID: e.target.value, 
      wifiClientPassphrase: ""
    })
  }



  onConnectClientWifiButton() {
      const ssid = this.state.wifiClientSSID
      const passphrase = this.state.wifiClientPassphrase
      this.props.ros.onUpdateWifiClientCredentials(ssid, passphrase)
  }


  onUpdateClientPassphraseText(e) {
    this.setState({wifiClientPassphrase: e.target.value});
    var client_passphrase_textbox = document.getElementById("wifi_client_passphrase_textbox")
    styleTextEdited(client_passphrase_textbox)
  }

  onKeyClientWifiPassphrase(e) {
    if(e.key === 'Enter'){
      var client_passphrase_textbox = document.getElementById("wifi_client_passphrase_textbox")
      styleTextUnedited(client_passphrase_textbox)
      this.setState({ wifiClientPassphrase: e.target.value })
    }
  }




  onUpdateAPSSIDText(e) {
    this.setState({wifiAPSSID: e.target.value, wifiAPSSIDEdited: true});
    var ap_ssid_textbox = document.getElementById("wifi_ap_ssid_textbox")
    styleTextEdited(ap_ssid_textbox)
    var ap_passphrase_textbox = document.getElementById("wifi_ap_passphrase_textbox")
    styleTextEdited(ap_passphrase_textbox)
  }

  onUpdateAPPassphraseText(e) {
    this.setState({wifiAPPassphrase: e.target.value, wifiAPSSIDEdited: true});
    var ap_ssid_textbox = document.getElementById("wifi_ap_ssid_textbox")
    styleTextEdited(ap_ssid_textbox)
    var ap_passphrase_textbox = document.getElementById("wifi_ap_passphrase_textbox")
    styleTextEdited(ap_passphrase_textbox)
  }

  onKeyAPWifi(e) {
    const {onUpdateWifiAPCredentials} = this.props.ros
    if(e.key === 'Enter'){
      this.setState({wifiAPSSIDEdited: false})
      onUpdateWifiAPCredentials(this.state.wifiAPSSID, this.state.wifiAPPassphrase)
      // Reset style
      var ap_ssid_textbox = document.getElementById("wifi_ap_ssid_textbox")
      styleTextUnedited(ap_ssid_textbox)
      var ap_passphrase_textbox = document.getElementById("wifi_ap_passphrase_textbox")
      styleTextUnedited(ap_passphrase_textbox)
    }
  }





  renderWifiInfo() {
    const { systemInContainer, onToggleWifiAPEnabled, onToggleWifiClientEnabled, onRefreshWifiNetworks } = this.props.ros
    const { wifiClientSSID, wifiClientPassphrase,
            wifiAPSSIDEdited, wifiAPSSID, wifiAPPassphrase } = this.state
    const netStatus = this.state.netStatus
    const wifi_enabled = (netStatus !== null)? netStatus.wifi_client_enabled : false
    const wifi_client_ssid = (netStatus !== null)? netStatus.wifi_client_ssid : ""
    const wifi_client_passphrase = (netStatus !== null)? netStatus.wifi_client_passphrase : ""
    const ap_ssid = (netStatus !== null)? netStatus.wifi_ap_ssid : ""
    const ap_passphrase = (netStatus !== null)? netStatus.wifi_ap_passphrase : ""
    const available_networks = (netStatus !== null)? netStatus.available_networks : []

    const clock_skewed = (netStatus !== null)? netStatus.clock_skewed : false
    const message = clock_skewed == false ? "" : "Clock out of date. Sync Clock to Connect to Internet"
    const connected = (netStatus !== null)? netStatus.wifi_client_connected : false
    const connecting = (netStatus !== null)? netStatus.wifi_client_connecting : false
    const internet_connected = connected ? ((netStatus !== null)? netStatus.internet_connected : false) : false

    
    const connect_text = (connected === true) ? "WiFi Connected" : (connecting === true ? "WiFi Connecting" : "WiFi Connected")
    const connect_value = (connected === true) ? true : connecting
    

    // Update on User Change
    var sel_wifi_ssid = 'None'
    var sel_passphrase = ''
    if (wifiClientSSID !== ''){
      if (available_networks.indexOf(wifiClientSSID) === -1){
        this.setState({wifiClientSSID:"",wifiClientPassphrase:""})
      }
      else {
        sel_wifi_ssid = wifiClientSSID 
        sel_passphrase = wifiClientPassphrase
      }
    }


    // Update On Manager Change
    if (netStatus !== null) {
      const last_response = this.state.last_netStatus
      if (last_response == null){
        this.setState({wifiClientSSID:wifi_client_ssid,wifiClientPassphrase:wifi_client_passphrase})
        this.setState({last_netStatus: netStatus})
      }
      else{
        if (last_response.wifi_client_ssid !== netStatus.wifi_client_ssid){
          sel_wifi_ssid = wifi_client_ssid
          this.setState({wifiClientSSID:wifi_client_ssid})
        }
        if (last_response.wifi_client_passphrase !== netStatus.wifi_client_passphrase){
          this.setState({wifiClientSSID:wifi_client_ssid,wifiClientPassphrase:wifi_client_passphrase})
        }
        if (last_response !== netStatus){
          this.setState({last_netStatus: netStatus})
        }
      }
    }

    

    
    return (
      <Section title={"WiFi"}>
        <div hidden={systemInContainer === false}> 

        <pre style={{ height: "50px", overflowY: "auto" }}>
          {"NEPI Running in Container Mode.  WiFi configuration set by host system"}
        </pre>
      </div>

      <div hidden={systemInContainer === true}> 

      <Columns>
          <Column>
          <div hidden={clock_skewed === false && wifi_enabled === true}> 

            <pre style={{ height: "25px", overflowY: "auto" , color: Styles.vars.colors.red }}>
                {message}
              </pre>

          </div>
          </Column>
        </Columns>


        <Columns>
          <Column>
            <Label title={"WiFi Enable"}>
              <Toggle
                checked={wifi_enabled}
                onClick= {onToggleWifiClientEnabled}
              />
            </Label>

          </Column>
          <Column>
    
  
          </Column>
        </Columns>



        <div hidden={!wifi_enabled}>

          <Columns>
            <Column>

              <Label title={"Selected Network"} >
                <Select
                  onChange={this.onWifiNetworkSelected}
                  value={sel_wifi_ssid}
                >
                  {this.createWifiNetworkOptions(available_networks)}
                </Select>
              </Label>

              <ButtonMenu>
                <Button onClick={onRefreshWifiNetworks}>{"Refresh"}</Button>
              </ButtonMenu>


            </Column>
            <Column>

              <Label title={"Passphrase"} >
                <Input 
                  id={"wifi_client_passphrase_textbox"}
                  type={"password"}
                  value={sel_passphrase}
                  onChange={this.onUpdateClientPassphraseText} onKeyDown={this.onKeyClientWifiPassphrase}
                />
              </Label>

              <ButtonMenu>
              <Button onClick={this.onConnectClientWifiButton}>{"Connect"}</Button>
              </ButtonMenu>


              <Label title={connect_text}>
              <BooleanIndicator value={connect_value} />
            </Label>


              <Label title={"WiFi Internet Connected"}>
                            <BooleanIndicator value={internet_connected} />
                          </Label>
   
             </Column>
          </Columns>
 

        </div>

        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
        <Columns>
          <Column>
            <Label title={"Access Point Enable"} >
              <Toggle
                checked={(netStatus !== null)? netStatus.wifi_ap_enabled : false}
                onClick= {onToggleWifiAPEnabled}
              />
            </Label>
          </Column>
          <Column/>
        </Columns>
        <Columns>
          <Column>
            <Label title={"Access Point"} >
              <Input
                id={"wifi_ap_ssid_textbox"} 
                value={(wifiAPSSIDEdited === true)? wifiAPSSID : ap_ssid}
                onChange={this.onUpdateAPSSIDText} onKeyDown={this.onKeyAPWifi}
              />
            </Label>
          </Column>
          <Column>
            <Label title={"Passphrase"} >
              <Input
              id={"wifi_ap_passphrase_textbox"}                 
                value={(wifiAPSSIDEdited === true)? wifiAPPassphrase : ap_passphrase}
                onChange={this.onUpdateAPPassphraseText} onKeyDown={this.onKeyAPWifi}
              />
            </Label>
          </Column>
        </Columns>
        </div>

      </Section>
    )
  }

  async onSaveCfg() {
    const { saveCfg } = this.props.ros
    var node_name = this.state.configSubsys
    if (node_name !== 'UNKNOWN_NODE') {
      saveCfg({baseTopic: node_name})
    }
  }

  async onUserReset() {
    const { systemReset } = this.props.ros
    var node_name = this.state.configSubsys
    if (node_name !== 'UNKNOWN_NODE') {
      systemReset(node_name, 0) // Value 1 per Reset.msg
    }
  }

  async onFactoryReset() {
    const { systemReset } = this.props.ros
    var node_name = this.state.configSubsys
    if (node_name !== 'UNKNOWN_NODE') {
      systemReset(node_name, 1) // Value 1 per Reset.msg
    }
  }

  async onSoftwareReset() {
    const { systemReset } = this.props.ros
    var node_name = this.state.configSubsys
    if (node_name !== 'UNKNOWN_NODE') {
      systemReset(node_name, 2) // Value 1 per Reset.msg
    }
  }

  async onHardwareReset() {
    const { systemReset } = this.props.ros
    var node_name = this.state.configSubsys
    if (node_name !== 'UNKNOWN_NODE') {
      systemReset(node_name, 3) // Value 1 per Reset.msg
    }
  }

  async onConfigSubsysSelected(e) {
    await this.setState({configSubsys: e.target.value})
  }

  async onToggleAdvancedConfig() {
    var enabled = this.state.advancedConfigEnabled
    this.setState({advancedConfigEnabled: !enabled})
  }

  createConfigSubsysOptions(resetTopics) {
    var subsys_options = []
    subsys_options.push(<Option value={resetTopics[0]}>{'All'}</Option>)
    for (var i = 1; i < resetTopics.length; i++) { // Skip the first one -- it is global /numurus/dev_3dx/<s/n>
      var node_name = resetTopics[i].split("/").pop()
      subsys_options.push(<Option value={resetTopics[i]}>{node_name}</Option>)
    }
    return subsys_options
  }




  render() {
    const netStatus = this.state.netStatus
    const has_wifi = netStatus? netStatus.has_wifi : false
    const internet_connected = (netStatus !== null)? netStatus.wifi_client_connected : false
    return (
      <Columns>
        <Column>
          {this.renderDeviceConfiguration()}
          {this.renderLicenseInfo()}
          {/*this.renderTriggerSettings()*/}

        </Column>
        <Column>


          {this.renderNetworkInfo()}
          {has_wifi? this.renderWifiInfo(): null}

        </Column>
      </Columns>
    )
  }
}
export default NepiSystemDevice
