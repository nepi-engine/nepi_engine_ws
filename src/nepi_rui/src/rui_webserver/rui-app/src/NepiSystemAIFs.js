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


@inject("ros")
@observer

class AisMgr extends Component {
  constructor(props) {
    super(props)

    this.state = {

      mgrName: "ai_model_mgr",
      mgrNamespace: null,

      viewable_frameworks: false,

      frameworks_list: [],
      last_frameworks_list: [],
      active_frameworks: [],
      active_frameworks_folders: [],
      selected_framework: 'None',
    
      viewable_models: false, 

      models_list: [],
      models_types: [],
      models_aifs: [],
      models_states: [],
      
      active_models_list: [],
      active_models_types: [],
      active_models_nodes: [],
      active_models_namespaces: [],



      model_active_state: false,
      selected_model: 'None',

      connected: false,

      aiMgrListener: null,
      needs_update: false

    }

    this.checkConnection = this.checkConnection.bind(this)
    this.getMgrNamespace = this.getMgrNamespace.bind(this)


    this.toggleViewableFrameworks = this.toggleViewableFrameworks.bind(this)
    this.getFrameworkOptions = this.getFrameworkOptions.bind(this)
    this.onToggleFrameworkSelection = this.onToggleFrameworkSelection.bind(this)
    this.getInactiveFrameworkStr = this.getInactiveFrameworkStr.bind(this)
    this.getActiveFrameworkStr = this.getActiveFrameworkStr.bind(this)

    this.toggleViewableModels = this.toggleViewableModels.bind(this)
    this.getModelOptions = this.getModelOptions.bind(this)
    this.onToggleModelSelection = this.onToggleModelSelection.bind(this)
    this.getDisabledModelStr = this.getDisabledModelStr.bind(this)
    this.getActiveModelStr = this.getActiveModelStr.bind(this)
    this.getModelInfo = this.getModelInfo.bind(this)


    this.updateAiMgrStatusListener = this.updateAiMgrStatusListener.bind(this)
    this.aiMgrStatusListener = this.aiMgrStatusListener.bind(this)



  
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
  aiMgrStatusListener(message) {
    this.setState({
      frameworks_list: message.ai_frameworks,

      models_list: message.ai_models,
      models_aifs: message.ai_models_frameworks,
      models_types: message.ai_models_types,
      models_states: message.ai_models_states,

      active_frameworks: message.active_ai_frameworks,
      active_frameworks_folders: message.active_ai_frameworks_folders,

      active_models_list: message.active_ai_models,
      active_models_types: message.active_ai_models_types,
      active_mdoels_nodes: message.active_ai_models_nodes,
      active_models_namespaces: message.active_ai_models_namespaces,

      connected: true
    })    

  }



  // Function for configuring and subscribing to Status
  updateAiMgrStatusListener() {
    const statusNamespace = this.getMgrNamespace() + '/status'
    if (this.state.aiMgrListener) {
      this.state.aiMgrListener.unsubscribe()
    }
    var aiMgrListener = this.props.ros.setupStatusListener(
          statusNamespace,
          "nepi_interfaces/MgrAiModelsStatus",
          this.aiMgrStatusListener
        )
    this.setState({ aiMgrListener: aiMgrListener,
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
    const needs_update = (this.state.needs_update && namespace !== null)
    if (namespace_updated || needs_update) {
      if (namespace.indexOf('null') === -1){
        this.setState({
          mgrNamespace: namespace
        })
        this.updateAiMgrStatusListener()
      } 
    }
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status message
  componentWillUnmount() {
    if (this.state.aiMgrListener) {
      this.state.aiMgrListener.unsubscribe()
    }
  }

  toggleViewableFrameworks() {
    const set = !this.state.viewable_frameworks
    this.setState({viewable_frameworks: set})
  }

  // Function for creating image topic options.
  getFrameworkOptions() {
    const frameworksList = this.state.frameworks_list  
    var items = []
    items.push(<Option value={'None'}>{'None'}</Option>)
    if (frameworksList.length > 0){
      for (var i = 0; i < frameworksList.length; i++) {
          items.push(<Option value={frameworksList[i]}>{frameworksList[i]}</Option>)
     }
    }

    return items
  }


  onToggleFrameworkSelection(event){
    const framework_name = event.target.value
    this.setState({selected_framework: framework_name})
  }

  getActiveFrameworkStr(){
    const active_aifs =  this.state.active_frameworks
    var active_str_list = []
    for (var i = 0; i < active_aifs.length; i++) {
        active_str_list.push(active_aifs[i])
        active_str_list.push("\n")
    }
    const inactive_str =active_str_list.join("")
    return inactive_str
  }

  
  getInactiveFrameworkStr(){
    const aif_list = this.state.frameworks_list
    const active_aifs =  this.state.active_frameworks
    var inactive_str_list = []
    for (var i = 0; i < aif_list.length; i++) {
      if (active_aifs.indexOf(aif_list[i]) === -1){
        inactive_str_list.push(aif_list[i])
        inactive_str_list.push("\n")
      }
    }
    const inactive_str =inactive_str_list.join("")
    return inactive_str
  }

 


  renderFrameworkConfig() {
    const viewable_frameworks = this.state.viewable_frameworks
    const framework_options = this.getFrameworkOptions()
    const selected_framework = this.state.selected_framework
    const active_frameworks = this.state.active_frameworks
    const framework_state = (active_frameworks.indexOf(selected_framework) !== -1)
    return (

      <Columns equalWidth={true}>
      <Column>

      <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Select AI Framework"}
         </label>

          <div onClick={this.toggleViewableFrameworks} style={{backgroundColor: Styles.vars.colors.grey0}}>
            <Select style={{width: "10px"}}/>
          </div>
          <div hidden={!viewable_frameworks}>
          {framework_options.map((framework) =>
          <div onClick={this.onToggleFrameworkSelection}
            style={{
              textAlign: "center",
              padding: `${Styles.vars.spacing.xs}`,
              color: Styles.vars.colors.black,
              backgroundColor: (framework.props.value === selected_framework) ?
                Styles.vars.colors.green :
                (active_frameworks.indexOf(framework.props.value) !== -1) ? Styles.vars.colors.blue : Styles.vars.colors.grey0,
              cursor: "pointer",
              }}>
              <body framework-topic ={framework} style={{color: Styles.vars.colors.black}}>{framework}</body>
          </div>
          )}
          </div>

        </Column>
        <Column>



        <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {this.state.selected_framework}
          </label>

          <div hidden={(this.state.selected_framework === "None")}>

        <Label title="Enable AI Framework"> 
          <Toggle
            checked={framework_state }
            onClick={() => this.props.ros.sendUpdateStateMsg(this.state.mgrNamespace + "/update_framework_state", this.state.selected_framework, !framework_state)}>
        </Toggle>
        </Label>

          </div>

          <ButtonMenu>
        <Button onClick={() => this.props.ros.sendTriggerMsg(this.state.mgrNamespace + "/enable_all_frameworks")}>{"Enable All"}</Button>
        </ButtonMenu>

        <ButtonMenu>
        <Button onClick={() => this.props.ros.sendTriggerMsg(this.state.mgrNamespace + "/disable_all_frameworks")}>{"Disable All"}</Button>
        </ButtonMenu>



        </Column>
        <Column>

        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
        <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Active AI Frameworks"}
          </label>

        <pre style={{ height: "20px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
        {this.getActiveFrameworkStr()}
        </pre>

        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
        <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"Disabled AI Frameworks"}
          </label>

        <pre style={{ height: "200px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
        {this.getInactiveFrameworkStr()}
        </pre>

        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        </Column>
        </Columns> 

    )
  }


  toggleViewableModels() {
    const set = !this.state.viewable_models
    this.setState({viewable_models: set})
  }

  // Function for creating image topic options.
  getModelOptions() {
    const models_list = this.state.models_list  
    const models_aifs = this.state.models_aifs
    const sel_aif = this.state.selected_framework

    var items = []
    items.push(<Option>{"None"}</Option>) 
    if (models_list.length > 0){
      for (var i = 0; i < models_list.length; i++) {
          if (models_aifs[i] === sel_aif){
            items.push(<Option value={models_list[i]}>{models_list[i]}</Option>)
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


  onToggleModelSelection(event){
    const model_name = event.target.value
    this.setState({selected_model: model_name})
  }

  getModelInfo(model_name){
    const model_names = this.state.models_list
    const model_types = this.state.models_types
    const model_states = this.state.models_states
    var model_type = 'Unknown'
    var model_state = false
    const ind = model_names.indexOf(model_name)
    if (ind !== -1){
      model_type = model_types[ind]
      model_state = model_states[ind]
    }
    return [model_type,model_state]
}

  getActiveModelStr(){
    const models_list = this.state.models_list  
    const models_aifs = this.state.models_aifs
    const models_states= this.state.models_states
    const sel_aif = this.state.selected_framework
    var active_str_list = []
    var model_name = ""
    var model_aif = ""
    var model_state = false
    for (var i = 0; i < models_list.length; i++) {
      model_name = models_list[i]
      model_aif = models_aifs[i]
      model_state = models_states[i]
      if (model_aif === sel_aif && model_state === true){
        active_str_list.push(model_name)
        active_str_list.push("\n")
      }
    }
    const active_str =active_str_list.join("")
    return active_str
  }

  
  getDisabledModelStr(){
    const models_list = this.state.models_list  
    const models_aifs = this.state.models_aifs
    const models_states= this.state.models_states
    const sel_aif = this.state.selected_framework
    var active_str_list = []
    var model_name = ""
    var model_aif = ""
    var model_state = false
    for (var i = 0; i < models_list.length; i++) {
      model_name = models_list[i]
      model_aif = models_aifs[i]
      model_state = models_states[i]
      if (model_aif === sel_aif && model_state === false){
        active_str_list.push(model_name)
        active_str_list.push("\n")
      }
    }
    const active_str =active_str_list.join("")
    return active_str
  }

 


  renderModelConfig() {
    const active_frameworks = this.state.active_frameworks
    const active_frameworks_folders = this.state.active_frameworks_folders
    const sel_framework = this.state.selected_framework
    const active_ind = active_frameworks.indexOf(sel_framework)
    const aif_active = (active_ind !== -1)
    const sel_framework_folder = (aif_active === true) ? active_frameworks_folders[active_ind] : "None"
    const selected_model = this.state.selected_model
    const [selected_type, selected_state] = this.getModelInfo(selected_model)
    const viewable_models = this.state.viewable_models
    const model_options = this.getModelOptions()
    const has_models = (model_options.length > 1)
    const active_model_list = this.state.active_models_list



    if (sel_framework === "None"){
      return(
        <Columns>
        <Column>

        </Column>
          </Columns> 
      )
    }

    else if (has_models === false){

      <Columns>
      <Column>

      <pre style={{ height: "200px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
      {"No models found for selected framework: " + sel_framework + '.' +
       "\nAdd models to the ai_modols/" + sel_framework_folder + " folder on the NEPI user storage drive"
      }
      </pre>

      </Column>
        </Columns> 


    }

    else {
      return (

        <Columns equalWidth={true}>
        <Column>

        <div hidden={(aif_active === true)}>


                  <pre style={{fontWeight: 'bold', height: "200px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
                   {"FRAMEWORK NOT ENABLED"}
                   </pre>

         </div>


        <div hidden={(aif_active === false)}>



                <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
                    {"Select AI Model"}
                  </label>

                    <div onClick={this.toggleViewableModels} style={{backgroundColor: Styles.vars.colors.grey0}}>
                      <Select style={{width: "10px"}}/>
                    </div>
                    <div hidden={!viewable_models}>
                    {model_options.map((model) =>
                    <div onClick={this.onToggleModelSelection}
                      style={{
                        textAlign: "center",
                        padding: `${Styles.vars.spacing.xs}`,
                        color: Styles.vars.colors.black,
                        backgroundColor: (model.props.value === selected_model) ?
                          Styles.vars.colors.green :
                          (active_model_list.includes(model.props.value)) ? Styles.vars.colors.blue : Styles.vars.colors.grey0,
                        cursor: "pointer",
                        }}>
                        <body model-topic ={model} style={{color: Styles.vars.colors.black}}>{model}</body>
                    </div>
                    )}
                    </div>


          </div>


          </Column>
          <Column>


            <div hidden={(aif_active === false)}>

                <div hidden={(this.state.selected_model === "None")}>

                    <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
                      {selected_model + ' : ' + selected_type}
                      </label>


                    <Label title="Enable"> 
                      <Toggle
                        checked={selected_state===true}
                        onClick={() => this.props.ros.sendUpdateStateMsg(this.state.mgrNamespace + "/update_model_state", this.state.selected_model, !selected_state)}>
                    </Toggle>
                    </Label>

                   </div>

                    <ButtonMenu>
                    <Button onClick={() => this.props.ros.sendUpdateStateMsg(this.state.mgrNamespace + "/enable_all_models", sel_framework, true)}>{"Enable All"}</Button>
                    </ButtonMenu>

                    <ButtonMenu>
                    <Button onClick={() => this.props.ros.sendUpdateStateMsg(this.state.mgrNamespace + "/disable_all_models", sel_framework, false)}>{"Disable All"}</Button>
                    </ButtonMenu>

            </div>
          </Column>
          <Column>

          <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
          <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
            {"Active Models "}
            </label>

          <pre style={{ height: "200px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
          {this.getActiveModelStr()}
          </pre>

          <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
          <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
            {"Disabled Models "}
            </label>

          <pre style={{ height: "200px", overflowY: "auto" }} align={"center"} textAlign={"center"}>
          {this.getDisabledModelStr()}
          </pre>

          <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

          </Column>
          </Columns> 

      )
    }
  }



render() {
  const selected_framework = this.state.selected_framework
  const active_frameworks = this.state.active_frameworks
  const framework_state = (active_frameworks.indexOf(selected_framework) !== -1 && selected_framework !== "None")
    return (

    <Section title={"AI Framework and Model Settings"}>
       
       <Columns>
      <Column>

       <ButtonMenu>
        <Button onClick={() => this.props.ros.sendTriggerMsg(this.state.mgrNamespace + "/refresh_frameworks")}>{"Refresh"}</Button>
        </ButtonMenu>

        </Column>
        <Column>

        <ButtonMenu>
        <Button onClick={() => this.props.ros.sendTriggerMsg(this.state.mgrNamespace + "/factory_reset")}>{"Factory Reset"}</Button>
        </ButtonMenu>

        </Column>
     </Columns>

 
     <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

      <Columns>
      <Column>

      {this.renderFrameworkConfig()}
      <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>
      </Column>
        <Column>

      {this.renderModelConfig()}
      <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>


       </Column>
     </Columns>
         
    </Section>
          

    )
  }

}


export default AisMgr
