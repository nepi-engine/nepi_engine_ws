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
import Label from "./Label"
import { Column, Columns } from "./Columns"
import Input from "./Input"
import Select, { Option } from "./Select"
import Styles from "./Styles"
import Toggle from "react-toggle"
import BooleanIndicator from "./BooleanIndicator"
import {SliderAdjustment} from "./AdjustmentWidgets"

import ImageViewer from "./Nepi_IF_ImageViewer"
import NepiIFSaveData from "./Nepi_IF_SaveData"
import NepiIFConfig from "./Nepi_IF_Config"

import {filterStrList, createShortImagesFromNamespaces,onChangeSwitchStateValue} from "./Utilities"

function round(value, decimals = 0) {
  return Number(value).toFixed(decimals)
  //return value && Number(Math.round(value + "e" + decimals) + "e-" + decimals)
}

@inject("ros")
@observer


class AiDetectorMgr extends Component {
  detector_info = []
  constructor(props) {
    super(props)

    this.state = {

      mgrName: "ai_model_mgr",
      mgrNamespace: null,

      modelMgrListener: null,

      model_mgr_connected: false,

      frameworks_list: [],
      active_framework: "None",

      models_list: [],
      models_frameworks: [],
      models_types: [],

      active_models_list: [],
      active_models_types: [],
      active_models_nodes: [],
      active_models_namespaces: [],

      all_namespace: null,

      detectorMgrListener: null,
      detector_mgr_connected: false,
      det_mgr_status_msg: null,

      detectorListener: null,
      detector_connected: false,
      det_status_msg: null,

      selected_detector: "None",
      last_selected_detector: "None",
      selected_detector_namespace: "None",
      detector_info_resp: null,


      img_list_viewable: false,
      img_filter_str_list: ['detection_image','targeting_image','alert_image','tracking_image'],
      selected_img_topic: "",
      selected_img_text: "",

      classes_list_viewable: false,
      availableClassesList: [],
      selectedClassesList:[],

      showSettingsControl: this.props.showSettingsControl ? this.props.showSettingsControl : false,      
      showSettings: false,

      needs_update: false


    }

    this.getBaseNamespace = this.getBaseNamespace.bind(this)
    this.getMgrNamespace = this.getMgrNamespace.bind(this)

    this.updateModelMgrStatusListener = this.updateModelMgrStatusListener.bind(this)
    this.modelMgrStatusListener = this.modelMgrStatusListener.bind(this)

    this.updateDetectorStatusListeners = this.updateDetectorStatusListeners.bind(this)
    this.detectorMgrStatusListener = this.detectorMgrStatusListener.bind(this)
    this.detectorStatusListener = this.detectorStatusListener.bind(this)

    this.getDetectorOptions = this.getDetectorOptions.bind(this)
    this.onDetectorSelected = this.onDetectorSelected.bind(this)

    this.createImageTopicsOptions = this.createImageTopicsOptions.bind(this)

    this.toggleImagesListViewable = this.toggleImagesListViewable.bind(this)
    this.onImagesTopicSelected = this.onImagesTopicSelected.bind(this)


    this.onToggleClassSelection = this.onToggleClassSelection.bind(this)
    this.getClassOptions = this.getClassOptions.bind(this)
    this.toggleClassesListViewable = this.toggleClassesListViewable.bind(this)

    this.getDisplayImgOptions = this.getDisplayImgOptions.bind(this)
    this.onDisplayImgSelected = this.onDisplayImgSelected.bind(this)
    this.getSaveNamespace = this.getSaveNamespace.bind(this)

  }
  
  getBaseNamespace(){
    const { namespacePrefix, deviceId} = this.props.ros
    var baseNamespace = null
    if (namespacePrefix !== null && deviceId !== null){
      baseNamespace = "/" + namespacePrefix + "/" + deviceId 
    }
    return baseNamespace
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
  modelMgrStatusListener(message) {

    this.setState({
      frameworks_list: message.ai_frameworks,
      active_framework: message.active_ai_framework,

      models_list: message.ai_models,
      models_frameworks: message.ai_models_frameworks,
      models_types: message.ai_models_types,

      active_models_list: message.active_ai_models,
      active_models_types: message.active_ai_models_types,
      active_mdoels_nodes: message.active_ai_models_nodes,
      active_models_namespaces: message.active_ai_models_namespaces,

   
      all_namespace: message.all_namespace,
      model_mgr_connected: true
    })    


  }

  // Function for configuring and subscribing to Status
  updateModelMgrStatusListener() {
    const statusNamespace = this.getMgrNamespace() + '/status'
    if (this.state.modelMgrListener) {
      this.state.modelMgrListener.unsubscribe()
      this.setState({det_status_msg: null, det_mgr_status_msg: null})
    }
    var modelMgrListener = this.props.ros.setupStatusListener(
          statusNamespace,
          "nepi_interfaces/MgrAiModelsStatus",
          this.modelMgrStatusListener
        )
    this.setState({ modelMgrListener: modelMgrListener,
      needs_update: false})
  }



  // Callback for handling ROS Status messages
  detectorMgrStatusListener(message) {
    const sel_detector = this.state.selected_detector
    const got_detector = message.name

    if (sel_detector === got_detector){
      this.setState({
      det_mgr_status_msg: message,
      detector_mgr_connected: true
      })
    }

  }

  // Callback for handling ROS Status messages
  detectorStatusListener(message) {
    const sel_detector = this.state.selected_detector
    const got_detector = message.name

    if (sel_detector === got_detector){
      this.setState({
      det_status_msg: message,
      detector_connected: true
      })
    }

  }

  // Function for configuring and subscribing to Status
  updateDetectorStatusListeners() {
    if (this.state.detectorMgrListener) {
      this.state.detectorMgrListener.unsubscribe()
      this.setState({detector_namespace: null, 
        det_mgr_status_msg: null,
        detector_mgr_connected: false})
    }

    if (this.state.detectorListener) {
      this.state.detectorListener.unsubscribe()
      this.setState({detector_namespace: null, 
        det_status_msg: null,
        detector_connected: false})
    }
    const models = this.state.active_models_list
    const active_models_namespaces = this.state.active_models_namespaces
    const selected_detector = this.state.selected_detector
    const detector_ind = models.indexOf(selected_detector)
    if (detector_ind !== -1){
      const detector_namespace = active_models_namespaces[detector_ind]

      const statusNamespace = detector_namespace + '/status'
      var detectorMgrListener = this.props.ros.setupStatusListener(
        statusNamespace,
        "nepi_interfaces/MgrAiDetectorStatus",
        this.detectorMgrStatusListener
      )
      this.setState({ 
        detectorMgrListener: detectorMgrListener,
        detector_namespace: detector_namespace
      })

      const detStatusNamespace = detector_namespace + '/detector_status'
      var detectorListener = this.props.ros.setupStatusListener(
        detStatusNamespace,
        "nepi_interfaces/AiDetectorStatus",
        this.detectorStatusListener
      )
      this.setState({ 
        detectorListener: detectorListener,
        detector_namespace: detector_namespace
      })
    }

  }


  componentDidMount(){
    this.setState({
      selected_detector: "None",
      last_selected_detector: "None", 
      selected_detector_namespace: "None",
      det_mgr_status_msg: null,
      detector_mgr_connected: false,
      det_status_msg: null,
      detector_connected: false
    })
  }

  // Lifecycle method called when compnent updates.
  // Used to track changes in the topic
  componentDidUpdate(prevProps, prevState, snapshot) {
    // First update manager status
    const model_mgr_namespace = this.getMgrNamespace()
    const cur_namespace = this.state.mgrNamespace
    const namespace_updated = (cur_namespace !== model_mgr_namespace && model_mgr_namespace !== null)
    const needs_update = (this.state.needs_update && model_mgr_namespace !== null)
    if (namespace_updated || needs_update) {
      if (model_mgr_namespace.indexOf('null') === -1){
        this.setState({
          mgrNamespace: model_mgr_namespace
        })
        this.updateModelMgrStatusListener()
      } 
    }

    // Once manager is connected update Model status on change
    if (this.state.model_mgr_connected === true){
      const selected_detector = this.state.selected_detector
      const last_detector = this.state.last_selected_detector

      if (last_detector !== selected_detector) {
          this.setState({      
            det_status_msg: null,
            last_selected_detector: selected_detector
          })  
          this.updateDetectorStatusListeners()

      }
    }
     
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to Status message
  componentWillUnmount() {
    if (this.state.modelMgrListener) {
      this.state.modelMgrListener.unsubscribe()
    }
  }





  // Function for creating image topic options.
  getDetectorOptions() {
    const active_models_list = this.state.active_models_list
    const active_models_types = this.state.active_models_types
    var items = []
    var check_type = 'detection'
    var type = 'Unknown'
    items.push(<Option value={'None'}>{'None'}</Option>)
    for (var i = 0; i < active_models_list.length; i++) {
        type = active_models_types[i]
        if (type === check_type ){
          items.push(<Option value={active_models_list[i]}>{active_models_list[i]}</Option>)
        }
    }
    return items
  }

  onDetectorSelected(event){
    const detector = event.target.value
    this.setState({selected_detector: detector})
  }

  renderAiDetector() {
    const {sendTriggerMsg} = this.props.ros
    const model_mgr_namespace = this.getMgrNamespace()
    const model_mgr_connected = this.state.model_mgr_connected == true

    const has_framework = this.active_framework !== "None"

    const detector_options = this.getDetectorOptions()
    const has_models = detector_options.length > 1

    const selected_detector = this.state.selected_detector
    const detector_selected = (selected_detector !== "None")

    const det_msg = this.state.det_status_msg
    const detector_name = det_msg == null? "None" : det_msg.name
    const detector_loading = (detector_name === selected_detector && selected_detector !== "None")? this.state.detector_connected === false : selected_detector !== "None"
    const detector_connected = (detector_name === selected_detector)? (this.state.detector_connected === true && detector_name === selected_detector):false

    const Spacer = ({ size }) => <div style={{ height: size, width: size }}></div>;

    if (model_mgr_connected === false){
      return(
        <Columns>
        <Column>

        <pre style={{ height: "50px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
                  {"LOADING..."}
                  </pre>
   
        </Column>
        </Columns>
      )
    }

    else if (has_framework === false){
      return(
        <Columns>
        <Column>

        <pre style={{ height: "50px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
                  {"NO AI FRAMEWORK FOUND.  Enable frameworks on the AI Model Manager page"}
                  </pre>
   
        </Column>
        </Columns>
      )
    }

    else if (has_models === false){
      return(
        <Columns>
        <Column>

        <pre style={{ height: "50px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
                  {"No AI MODELS FOUND.  Enable models on the AI Model Manager page"}
                  </pre>
   
        </Column>
        </Columns>
      )
    }

    else{
      return (


        <Section title={"AI Detection Manager"}>

          <Columns>
          <Column>

             <Label title="Select Detector">
                  <Select id="DetectorSelect" onChange={this.onDetectorSelected} 
                      value={selected_detector}
                      disabled={false}>
                    {detector_options}
                  </Select>
              </Label>
    

              <div hidden={detector_loading === false}>

                  <pre style={{ height: "50px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
                  {"Loading..."}
                  </pre>

              </div>

          </Column>
          </Columns>

          <div hidden={detector_connected === false}>
   
                        {this.renderDetectorSettings()}

          </div>

  
          </Section>

      )
    }

  }



  // Function for creating image topic options.
  createImageTopicsOptions() {
    const filter_str_list = this.state.img_filter_str_list
    const { imageTopics } = this.props.ros
    const img_options = filterStrList(imageTopics,filter_str_list)
    const baseNamespace = this.getBaseNamespace()
    var imageTopicShortnames = createShortImagesFromNamespaces(baseNamespace, img_options)
    var items = []
    items.push(<Option value={'None'}>{'None'}</Option>)
    items.push(<Option value={'All'}>{'All'}</Option>)
    var img_text = ""
    const sel_det = this.state.selected_detector
    for (var i = 0; i < img_options.length; i++) {
      if (img_options[i].indexOf(sel_det) === -1){
       items.push(<Option value={img_options[i]}>{imageTopicShortnames[i]}</Option>)
      }
    }
    return items
  }

  toggleImagesListViewable() {
    const set = !this.state.img_list_viewable
    this.setState({img_list_viewable: set})
  }


  onImagesTopicSelected(event){
    const {imageTopics, sendStringMsg, sendStringArrayMsg} = this.props.ros
    const detector_namespace = this.state.detector_namespace
    const add_img_namespace = detector_namespace + "/add_img_topic"
    const add_imgs_namespace = detector_namespace + "/add_img_topics"
    const remove_img_namespace = detector_namespace + "/remove_img_topic"
    const remove_imgs_namespace = detector_namespace + "/remove_img_topics"
    const filter_str_list = this.state.img_filter_str_list
    const img_options = filterStrList(imageTopics,filter_str_list)
    const det_img_topics = this.state.det_status_msg.selected_img_topics
    const img_topic = event.target.value
    //this.setState({selected_img_topic: img_topic})

    if (img_topic === "None"){
        sendStringArrayMsg(remove_imgs_namespace,img_options)
    }
    else if (img_topic === "All"){
        sendStringArrayMsg(add_imgs_namespace,img_options)
    }
    else if (det_img_topics.indexOf(img_topic) === -1){
      sendStringMsg(add_img_namespace,img_topic)
    }
    else {
      sendStringMsg(remove_img_namespace,img_topic)
    }
  }


  // Function for creating image topic options.
  getClassOptions() {

    var items = []
    items.push(<Option>{"None"}</Option>)

    const selected_detector = this.state.selected_detector
    const det_msg = this.state.det_status_msg
    if (det_msg != null){
      const detector_name = det_msg.name 
      if (selected_detector === detector_name){
        const availableClassesList = det_msg.available_classes

        items.push(<Option>{"All"}</Option>)
        if (availableClassesList.length > 0 ){
          for (var i = 0; i < availableClassesList.length; i++) {
              if (availableClassesList[i] !== 'None'){
                items.push(<Option value={availableClassesList[i]}>{availableClassesList[i]}</Option>)
              }
          }
        }
      }
    }
    return items
    }
  
  
    toggleClassesListViewable() {
      const set = !this.state.classes_list_viewable
      this.setState({classes_list_viewable: set})
    }
  
  
    onToggleClassSelection(event){
      const {sendTriggerMsg, sendStringMsg} = this.props.ros

      const selected_detector = this.state.selected_detector
      const det_msg = this.state.det_status_msg
      if (det_msg != null){
        const detector_name = det_msg.name 
        if (selected_detector === detector_name){
          const detector_namespace = det_msg.namespace
          const classSelection = event.target.value
          const availableClassesList = det_msg.available_classes
          const selectedClassesList = det_msg.selected_classes
          const addAllNamespace = detector_namespace + "/add_all_classes"
          const removeAllNamespace = detector_namespace + "/remove_all_classes"
          const addNamespace = detector_namespace + "/add_class"
          const removeNamespace = detector_namespace + "/remove_class"
          if (detector_namespace){
            if (classSelection === "None"){
                sendTriggerMsg(removeAllNamespace)
            }
            else if (classSelection === "All"){
              sendTriggerMsg(addAllNamespace)
          }
            else if (selectedClassesList.indexOf(classSelection) !== -1){
              sendStringMsg(removeNamespace,classSelection)
            }
            else {
              sendStringMsg(addNamespace,classSelection)
            }
          }
        }
      }
    }


renderDetectorSettings() {
  const { sendTriggerMsg, sendBoolMsg } = this.props.ros


  const sel_img = this.state.selected_img_topic

  const classOptions = this.getClassOptions()
  const selectedClasses = this.state.selectedClassesList
  const classes_sel = selectedClasses[0] !== "" && selectedClasses[0] !== "None"

  const selected_detector = this.state.selected_detector
  const det_mgr_msg = this.state.det_mgr_status_msg
  const det_msg = this.state.det_status_msg
  if (det_mgr_msg != null && det_msg != null){
    const detector_name = det_msg.name 
    if (selected_detector === detector_name){
      const detector_namespace = det_msg.namespace


      const has_tiling = det_mgr_msg.has_tiling
      const is_tiling = det_mgr_msg.img_tiling

      const has_sleep = det_mgr_msg.has_sleep
      const sleep_enabled = det_mgr_msg.sleep_enabled
      const sleep_suspend_sec = det_mgr_msg.sleep_suspend_sec
      const sleep_run_sec = det_mgr_msg.sleep_run_sec
      const sleep_state = det_mgr_msg.msg





      const availableClassesList = det_msg.available_classes
      const selectedClassesList = det_msg.selected_classes
      const classes_selected = (selectedClassesList.length > 0)

      const detector_enabled = det_msg.enabled
      const detector_state = det_msg.state
      const detection_state = det_msg.detection_state
      const det_running = (detector_state === "Running")

      const overlay_labels = det_msg.overlay_labels
      const overlay_detector_name = det_msg.overlay_clf_name
      const overlay_img_name = det_msg.overlay_img_name

      const threshold = det_msg.threshold_filter
      const max_det_rate = det_msg.max_proc_rate_hz 
      const max_img_rate = det_msg.max_img_rate_hz
      const use_last_image = det_msg.use_last_image

      const det_img_topics = det_msg.selected_img_topics

      const img_selected = det_msg.image_selected
      const img_connected = det_msg.image_connected

      const img_latency = round(det_msg.image_latency_time, 3)
      const det_latency = round(det_msg.detect_latency_time, 3)
      const pre_time = round(det_msg.preprocess_time, 3)
      const det_time = round(det_msg.detect_time, 3)
      const rate_hz = round(det_msg.avg_rate_hz, 3)
      const img_options = this.createImageTopicsOptions()

      const img_list_viewable = this.state.img_list_viewable

      const detector_display_name = detector_name.toUpperCase()

      return (

      <Columns>
      <Column>

      <Label title={"DETECTOR"}></Label>

        <Columns>
        <Column>

        <Label title="Enable">
              <Toggle
              checked={detector_enabled===true}
              onClick={() => sendBoolMsg(detector_namespace + "/enable",!detector_enabled)}>
              </Toggle>
        </Label>

        </Column>
        <Column>
        <Label title={"Running"}>
                        <BooleanIndicator value={det_running} />
                      </Label>
        </Column>
        </Columns>



        <Label title={"IMAGE"}></Label>

        <div style={{ display: 'flex' }}>
                      <div style={{ width: '40%' }}>

                      <Label title={"Selected"}>
                    <BooleanIndicator value={img_selected} />
                    </Label>


                      </div>

                      <div style={{ width: '20%' }}>
                        {}
                      </div>

                      <div style={{ width: '40%' }}>
                       
                          <Label title={"Connected"}>
                            <BooleanIndicator value={img_connected} />
                          </Label>
                      </div>
              </div>


    

          <Label title={"CLASSES"}></Label>

          <div style={{ display: 'flex' }}>
                      <div style={{ width: '40%' }}>

                      <Label title={"Selected"}>
                        <BooleanIndicator value={classes_selected} />
                      </Label>

                      </div>

                      <div style={{ width: '20%' }}>
                        {}
                      </div>

                      <div style={{ width: '40%' }}>
                       
                      <Label title={"Detected"}>
                        <BooleanIndicator value={detection_state} />
                      </Label>

                      </div>
                    </div>



        <pre style={{ height: "100px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
        {"\n Avg Detect Latency: " + det_time +
        "\n Avg Detect Rate Hz: " + rate_hz}
        
        </pre>


        <NepiIFConfig
                        namespace={detector_namespace}
                        title={"Nepi_IF_Conig"}
        />



        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        <Columns>
        <Column>

        <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
            {"Detector Settings"}
          </label>

          </Column>
          </Columns>

          <Columns>
        <Column>



          </Column>
          </Columns>


          <Columns>
        <Column>

        <label align={"left"} textAlign={"left"}>
            {"Select Classes"}
          </label>


            </Column>
          <Column>

                <div style={{ marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

                <div onClick={this.toggleClassesListViewable} style={{backgroundColor: Styles.vars.colors.grey0}}>
                      <Select style={{width: "10px"}}/>
                    </div>
                    <div hidden={this.state.classes_list_viewable === false}>
                    {classOptions.map((Class) =>
                    <div onClick={this.onToggleClassSelection}
                      style={{
                        textAlign: "center",
                        padding: `${Styles.vars.spacing.xs}`,
                        color: Styles.vars.colors.black,
                        backgroundColor: (selectedClassesList.includes(Class.props.value))? Styles.vars.colors.blue : Styles.vars.colors.grey0,
                        cursor: "pointer",
                        }}>
                        <body class_name ={Class} style={{color: Styles.vars.colors.black}}>{Class}</body>
                    </div>
                    )}
                    </div>

          </Column>
          </Columns>





          <Columns>
        <Column>

        <label align={"left"} textAlign={"left"}>
            {"Select Images"}
          </label>


            </Column>
          <Column>

                <div style={{ marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

        <div onClick={this.toggleImagesListViewable} style={{backgroundColor: Styles.vars.colors.grey0}}>
          <Select style={{width: "10px"}}/>
        </div>
        <div hidden={this.state.img_list_viewable === false}>
        {img_options.map((image) =>
        <div onClick={this.onImagesTopicSelected}
          style={{
            textAlign: "center",
            padding: `${Styles.vars.spacing.xs}`,
            color: Styles.vars.colors.black,
            backgroundColor: (image.props.value === sel_img) ?
              Styles.vars.colors.green :
              (det_img_topics.indexOf(image.props.value) !== -1 ) ? Styles.vars.colors.blue : Styles.vars.colors.grey0,
            cursor: "pointer",
            }}>
            <body image-topic ={image} style={{color: Styles.vars.colors.black}}>{image}</body>
        </div>
        )}
        </div>

          </Column>
          </Columns>




          

          <SliderAdjustment
                    title={"Threshold"}
                    msgType={"std_msgs/Float32"}
                    adjustment={threshold}
                    topic={detector_namespace + "/set_threshold"}
                    scaled={0.01}
                    min={0}
                    max={100}
                    disabled={false}
                    tooltip={"Sets detection confidence threshold"}
                    unit={"%"}
                  />
                  
          <SliderAdjustment
                  title={"Max Detection Rate"}
                  msgType={"std_msgs/Float32"}
                  adjustment={max_det_rate}
                  topic={detector_namespace + "/set_max_proc_rate"}
                  scaled={1.0}
                  min={1}
                  max={20}
                  disabled={false}
                  tooltip={"Sets detection max rate in hz"}
                  unit={"Hz"}
            />

          <SliderAdjustment
                  title={"Max Image Publish Rate"}
                  msgType={"std_msgs/Float32"}
                  adjustment={max_img_rate}
                  topic={detector_namespace + "/set_max_img_rate"}
                  scaled={1.0}
                  min={1}
                  max={20}
                  disabled={false}
                  tooltip={"Sets detection max rate in hz"}
                  unit={"Hz"}
            />




            <Columns>
            <Column>

                <Label title="Use Last Image">
                  <Toggle
                  checked={use_last_image===true}
                  onClick={() => this.props.ros.sendBoolMsg(detector_namespace + "/set_use_last_image", use_last_image===false)}>
                  </Toggle>
                  </Label>

                <Label title="Overlay Labels">
                  <Toggle
                  checked={overlay_labels===true}
                  onClick={() => this.props.ros.sendBoolMsg(detector_namespace + "/set_overlay_labels", overlay_labels===false)}>
                  </Toggle>
                </Label>

                <Label title="Overlay Image Name">
                  <Toggle
                  checked={overlay_img_name===true}
                  onClick={() => this.props.ros.sendBoolMsg(detector_namespace + "/set_overlay_img_name", overlay_img_name===false)}>
                  </Toggle>
                  </Label>


                  <Label title="Overlay Classifier">
                  <Toggle
                  checked={overlay_detector_name===true}
                  onClick={() => this.props.ros.sendBoolMsg(detector_namespace + "/set_overlay_clf_name", overlay_detector_name===false)}>
                  </Toggle>
                  </Label>


              </Column>
              <Column>

                 

          {/*
            <div hidden={has_tiling === false}>           
                <Label title="Enable Image Tiling">
                  <Toggle
                  checked={is_tiling===true}
                  onClick={() => this.props.ros.sendBoolMsg(detector_namespace + "/set_img_tiling", is_tiling===false)}>
                  </Toggle>
                  </Label>

                  </div>
          */}


            </Column>
            </Columns>



    </Column>
    </Columns>


        )
      }
    }
  }





  onDisplayImgSelected(event){
    const img_topic = event.target.value
    const det_msg = this.state.det_status_msg
    var detector_name = 'None'
    var img_name = 'None'
    if (det_msg != null){
      detector_name = det_msg.name 
      img_name = detector_name + img_topic.split(detector_name)[1]
    }
    this.setState({selected_img_topic: img_topic,
                   selected_img_text: img_name
    })
  }   



    // Function for creating image topic for a selected detector.
    getDisplayImgOptions() {

      var items = []
      const det_msg = this.state.det_status_msg
      const selected_detector = this.state.selected_detector
      const sel_img = this.state.selected_img_topic


      var img_topic = "None"
      var img_text = "None"
      var img_ns = "None"

        if (det_msg != null){

              const detector_ns = this.state.detector_namespace
              const detector_enabled = det_msg.enabled
              const det_img_nns = det_msg.image_detector_namespaces
              if (detector_enabled === false) {
                  img_topic === "Detector Not Enabled"
                  img_text = "Detector Not Enabled"
                  items.push(<Option value={img_topic}>{img_text}</Option>)
              }
              else if (detector_ns){
                const det_img_topic = detector_ns + "/detection_image"
                img_text = "All"
                items.push(<Option value={det_img_topic}>{img_text}</Option>)
                if (sel_img === ""){
                  this.setState({selected_img_topic: det_img_topic })
                }
                for (var i = 0; i < det_img_nns.length; i++) {
                    img_topic = det_img_nns[i] + '/detection_image'
                    img_text = img_topic.replace(detector_ns + '/','')
                    items.push(<Option value={img_topic}>{img_text}</Option>)
                }
              }
              else  {
                items.push(<Option value={"None"}>{"None"}</Option>)
              }
      }
      else  {
        items.push(<Option value={"None"}>{"None"}</Option>)
      }
      return items
    }






    // Function for creating image topic options.
    getSaveNamespace() {
      const detector_namespace = this.state.detector_namespace
      var saveNamespace = "None"
      if (detector_namespace){
        saveNamespace = detector_namespace
      }
      return saveNamespace
    }





  render() {
    const {topicNames} = this.props.ros
    const img_options = this.getDisplayImgOptions()
    const sel_img_topic = this.state.selected_img_topic
    const img_publishing = topicNames.indexOf(sel_img_topic) !== -1
    const sel_img = img_publishing? sel_img_topic : ""
    const sel_img_text = img_publishing?  this.state.selected_img_text : 'Waiting for image to publish'

    const saveNamespace = this.getSaveNamespace()


    return (



      <Columns>
      <Column equalWidth={false}>


          <Columns>
          <Column>

                  <Label title="Select Detector Image Stream">
                      <Select id="ImgSelect" onChange={this.onDisplayImgSelected} 
                      value={sel_img}
                      disabled={false}>
                        {img_options}
                    </Select>
                    </Label>
          </Column>
          <Column>

          </Column>
          </Columns>


      <ImageViewer
        imageTopic={sel_img}
        title={sel_img_text}
        hideQualitySelector={false}
      />

      <div hidden={saveNamespace === 'None'}>
        <NepiIFSaveData
              saveNamespace={saveNamespace}
              title={"Nepi_IF_SaveData"}
          />
      </div>

      </Column>
      <Column>


      {this.renderAiDetector()}
      


      </Column>
      </Columns>



      )
    }

  

}

export default AiDetectorMgr
