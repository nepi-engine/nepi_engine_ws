/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React, { Component } from "react"
//import moment from "moment"
import { observer, inject } from "mobx-react"

//import { TransformWrapper, TransformComponent } from "react-zoom-pan-pinch";

import Section from "./Section"
//import EnableAdjustment from "./EnableAdjustment"
import Button, { ButtonMenu } from "./Button"
import Toggle from "react-toggle"
import Label from "./Label"
import RangeAdjustment from "./RangeAdjustment"
import {RadioButtonAdjustment, SliderAdjustment} from "./AdjustmentWidgets"
import { Column, Columns } from "./Columns"
import Styles from "./Styles"
import Select from "./Select"
import Input from "./Input"

import NepiIFConfig from "./Nepi_IF_Config"
import NavPoseViewer from "./Nepi_IF_NavPoseViewer"

import { createMenuListFromStrList, onChangeSwitchStateValue, onEnterSendFloatValue } from "./Utilities"

function round(value, decimals = 0) {
  return Number(value).toFixed(decimals)
  //return value && Number(Math.round(value + "e" + decimals) + "e-" + decimals)
}


const styles = Styles.Create({

  
  canvas: {
    width: "100%",
    height: "auto",
    transform: "scale(1)"
  }
})

const COMPRESSION_HIGH_QUALITY = 95
const COMPRESSION_MED_QUALITY = 50
const COMPRESSION_LOW_QUALITY = 10

const PORT = 9091
const ROS_WEBCAM_URL_BASE = `http://${
  window.location.hostname
}:${PORT}/stream?topic=`

@inject("ros")
@observer
class ImageViewer extends Component {
  constructor(props) {
    super(props)

    this.state = {
      has_status: false,
      show_status: false,
      has_controls: false,
      controls_namespace: null,
      show_controls: false,
      has_overlay: false,
      has_navpose: false,
      show_navpose: false,
      hasInitialized: false,
      shouldUpdate: true,
      streamWidth: null,
      streamHeight: null,
      streamSize: 0,
      currentStreamingImageQuality: COMPRESSION_HIGH_QUALITY,
      status_listenter: null,
      status_msg: null,

      enhance_list_viewable: false,

      connected: false
    }
    this.updateFrame = this.updateFrame.bind(this)
    this.onCanvasRef = this.onCanvasRef.bind(this)
    this.updateImageSource = this.updateImageSource.bind(this)
    this.onChangeImageQuality = this.onChangeImageQuality.bind(this)
    this.renderControls = this.renderControls.bind(this)
    this.renderOverlays = this.renderOverlays.bind(this)
    this.renderStats = this.renderStats.bind(this)
    this.getImgStatsText = this.getImgStatsText.bind(this)


    //this.ZoomViewer = this.ZoomViewer.bind(this)

    this.statusListener = this.statusListener.bind(this)
    this.updateStatusListener = this.updateStatusListener.bind(this)

  }

  updateFrame() {
    const square_canvas = this.props.squareCanvas ? this.props.squareCanvas : false
    const shouldUpdate = this.state.shouldUpdate
    const hasInitialized = this.state.hasInitialized
    const connected = this.state.connected

    if (shouldUpdate === true && hasInitialized === true && this.canvas) {

      // Firset check for image size change
      const { width, height } = this.image
      const streamWidth = this.state.streamWidth
      const streamHeight = this.state.streamHeight

      const width_changed = width !== streamWidth
      const height_changed = height  !== streamHeight
      const size_changed = (width_changed === true || height_changed === true)
      if (size_changed === true || connected === false) {
        this.setState({
            hasInitialized: true,
            streamWidth: width,
            streamHeight: height,
            streamSize: width * height,
            connected: true
            })

        if (square_canvas === true){
          var size = 0
          if (width > height){
            size = width
          }
          else {
            size = height
          }
          this.canvas.width = size
          this.canvas.height = size

        }
        else {
          this.canvas.width = width
          this.canvas.height = height
        }
      }

      // Then update
      const context = this.canvas.getContext("2d")
      context.fillStyle = "red"
      context.textAlign = "center"
      context.font = "50px Arial"
      context.clearRect(0, 0, streamWidth, streamHeight)
      context.drawImage(this.image, 0, 0, streamWidth, streamHeight)
      //this.setState({ clockTime: moment() })
      requestAnimationFrame(this.updateFrame)
      

    }
  }
  

  onCanvasRef(ref) {
    this.canvas = ref
    //this.updateImageSource()
  }

  // Callback for handling ROS Status messages
  statusListener(message) {
    this.setState({
      status_msg: message
    })    

  }

  // Function for configuring and subscribing to Status
  updateStatusListener() {
    const namespace = this.props.status_namespace ? this.props.status_namespace : this.props.imageTopic
    const statusNamespace = namespace + '/status'
    if (this.state.statusListener) {
      this.state.statusListener.unsubscribe()
      this.setState({status_msg: null})

    }
    var status_listenter = this.props.ros.setupStatusListener(
          statusNamespace,
          "nepi_interfaces/ImageStatus",
          this.statusListener
        )
    this.setState({ status_listenter: status_listenter,
                    controls_namespace: namespace
    })
  }


  updateImageSource() {
    if (this.props.imageTopic) {
      if (!this.image) {
        this.image = new Image() // EXPERIMENT -- Only create a new Image when strictly required
      }
      this.image.crossOrigin = "Anonymous"
      this.image.onload = () => {
        const { width, height } = this.image
        this.setState(
          {
            hasInitialized: true,
            connected: false,
            streamWidth: width,
            streamHeight: height,
            streamSize: width * height
          },
          () => {
            requestAnimationFrame(this.updateFrame)
          }
        )
      }
    }
    if (this.image) {
      const { streamingImageQuality } = this.props.ros
      this.image.src = ROS_WEBCAM_URL_BASE + this.props.imageTopic + '&quality=' + streamingImageQuality
    }
  }

  // Lifecycle method called when the props change.
  // Used to track changes in the image topic value
  componentDidUpdate(prevProps, prevState, snapshot) {
    const { imageTopic } = this.props
    const size = this.state.streamSize
    const width = (this.image) ? this.image.width : 0
    const height = (this.image) ? this.image.height : 0
    const got_size = width * height
    const size_changed = (size !== got_size)
    if (prevProps.imageTopic !== imageTopic || size_changed === true || prevState.currentStreamingImageQuality !== this.state.currentStreamingImageQuality){
      this.updateImageSource()
      if (prevProps.imageTopic !== imageTopic) {
        this.updateStatusListener()
      }
    }
  }

  componentWillUnmount() {
    this.setState({ shouldUpdate: false })
    if (this.image) {
      this.image.src = null
    }
  }

  componentDidMount() {
    this.updateImageSource()
  }

  onChangeImageQuality(quality) {
    this.props.ros.onChangeStreamingImageQuality(quality)
    this.setState({currentStreamingImageQuality: quality})
    this.updateImageSource()

  }




  getImgInfoText(){
    const status_msg = this.state.status_msg
    var msg = ""
    if (status_msg != null){
      const frame_3d = status_msg.frame_3d
      const encoding = status_msg.encoding
      const width_px = round(status_msg.width_px, 0)
      const height_px = round(status_msg.height_px, 0)
      const width_deg = round(status_msg.width_deg, 0)
      const height_deg = round(status_msg.height_deg, 0)
      const perspective = status_msg.perspective

      msg = ("\n\n3D Frame: " + frame_3d + 
      "\n\nEncoding: " + encoding + 
      "\n\nWidth/Height (Pixals): " + width_px.replace('.','') + ':' + height_px.replace('.','') +
      "\n\nWidth/Height (Deg): " + width_deg.replace('.','') + ':' + height_deg.replace('.','') +
      "\nPerspective: " + perspective )
    }
    else {
      msg = "No Stats Available"

    }
    return msg
  }


  renderInfo() {
   
    if (this.state.status_msg != null){
      const msg = this.getImgInfoText()
      return (
        <Columns>
        <Column>
         <pre style={{ height: "200px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
                  {msg}
                  </pre>
    
        </Column>
        </Columns>

      )
    }
    else {
      return (
        <Columns>
        <Column>

        </Column>
        </Columns>
      )

    }

  }



  getImgStatsText(){
    const status_msg = this.state.status_msg
    const has_status = this.props.has_status ? this.props.has_status : true
    var msg = ""
    if (status_msg != null && has_status === true){
      const get_lat = round(status_msg.get_latency_time, 3)
      const pub_lat = round(status_msg.pub_latency_time, 3)
      const proc_time = round(status_msg.process_time, 3)
      const avg_fps = round(status_msg.avg_pub_rate, 3)
      msg = ("\n\nGet Latency: " + get_lat + 
      "\n\nPublish Latency: " + pub_lat + 
      "\n\nProcess Times (Image): " + proc_time +
      "\n\nAvg FPS: " + avg_fps )
    }
    else {
      msg = "No Stats Available"

    }
    return msg
  }

  renderStats() {
    const status_msg = this.state.status_msg
    const has_status = this.props.has_status ? this.props.has_status : true
    if (status_msg != null && has_status === true){
      const msg = this.getImgStatsText()
      return (
        <Columns>
        <Column>
         <pre style={{ height: "200px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
                  {msg}
                  </pre>
    
        </Column>
        </Columns>

      )
    }
    else {
      return (
        <Columns>
        <Column>

        </Column>
        </Columns>
      )

    }

  }

  renderEnhances(namespace, enhance_options, enhance_states, enhance_ratios) {
    if (enhance_options.length > 0){
      var enhance_name = ""
      var enhance_enabled = false
      var enhance_ratio = 0.0

      for (var i = 0; i < enhance_options.length; i++) {
        enhance_name = enhance_options[i]
        enhance_enabled = enhance_states[i]
        enhance_ratio = enhance_ratios[i]
        return (
           
          <Columns>
          <Column>

          <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

          



                        <Label title={'Filter: ' + enhance_name.toUpperCase()}>
         
                    
                            <Toggle
                              checked={enhance_enabled === true}
                              onClick={() => this.props.ros.sendUpdateStateMsg(namespace + "/set_enhance_enable",enhance_name,!enhance_enabled)}>
                            </Toggle>
                      
                      </Label>


                  <div hidden={(enhance_enabled !== true)}>
                            <SliderAdjustment
                                title={"Enhance Sensitivity"}
                                msgType={"std_msgs/Float32"}
                                adjustment={enhance_ratio}
                                comp_name={enhance_name}
                                topic={namespace + "/set_enhance_ratio"}
                                scaled={0.01}
                                min={0}
                                max={100}
                                tooltip={"Adjustable enhancement sensitivity"}
                                unit={"%"}
                            />

                  </div>



                </Column>
                </Columns>

                )
      }
    }
    else {
      return (
        <Columns>
        <Column>

        </Column>
        </Columns>
      )
    }
  }

  renderControls() {

    const namespace = this.state.controls_namespace
    const has_controls = this.props.has_controls ? this.props.has_controls : true

    const { imageCaps, sendTriggerMsg, sendBoolMsg, sendUpdateStateMsg, sendUpdateRatioMsg } = this.props.ros
    const capabilities = (imageCaps != null) ? (imageCaps[namespace] != null ? imageCaps[namespace] : null) : null

   
    if (has_controls === true && this.state.status_msg != null && namespace != null && capabilities != null){
      const has_auto_adjust = (capabilities && capabilities.has_auto_adjust && !this.state.disabled)
      const has_contrast = (capabilities && capabilities.has_contrast && !this.state.disabled)
      const has_brightness = (capabilities && capabilities.has_brightness && !this.state.disabled)
      const has_threshold = (capabilities && capabilities.has_threshold && !this.state.disabled)
      const has_resolution = (capabilities && capabilities.has_resolution && !this.state.disabled)
      const has_framerate = (capabilities && capabilities.has_framerate && !this.state.disabled)
      const has_range = (capabilities && capabilities.has_range && !this.state.disabled)
      const has_zoom = (capabilities && capabilities.has_zoom && !this.state.disabled)
      const has_pan = (capabilities && capabilities.has_pan && !this.state.disabled)
      const has_window = (capabilities && capabilities.has_window && !this.state.disabled)
      const has_rotate = (capabilities && capabilities.has_rotate && !this.state.disabled)
      const has_tilt = (capabilities && capabilities.has_tilt && !this.state.disabled)
      const has_enhances = (capabilities && capabilities.has_enhances && !this.state.disabled)

      const message = this.state.status_msg
      const auto_adjust_enabled = message.auto_adjust_enabled
      const auto_adjust_ratio = message.auto_adjust_ratio
      const auto_adjust_controls = message.auto_adjust_controls
      const resolution_ratio = message.resolution_ratio
      const resolution_str = message.resolution_current
      const brightness_ratio = message.brightness_ratio
      const contrast_ratio = message.contrast_ratio
      const threshold_ratio = message.threshold_ratio
      const range_start_ratio = message.range_ratios.start_range
      const range_stop_ratio = message.range_ratios.stop_range
      const zoom_ratio = message.zoom_ratio
      const pan_lr_ratio = message.pan_left_right_ratio
      const pan_ud_ratio = message.pan_up_down_ratio
      const window_ratios = message.window_ratios
      const rotate_ratio = message.rotate_ratio
      const tilt_ratio = message.tilt_ratio

      const auto_controls = auto_adjust_enabled ? auto_adjust_controls : []
      const hide_framerate = (!has_framerate || auto_controls.indexOf('framerate') != -1)
      const hide_resolution = (!has_resolution || auto_controls.indexOf('resolution') != -1)
      const hide_brightness = (!has_brightness || auto_controls.indexOf('brightness') != -1)
      const hide_contrast = (!has_contrast || auto_controls.indexOf('contrast') != -1)
      const hide_threshold = (!has_threshold || auto_controls.indexOf('threshold') != -1)
      const hide_range = (!has_range || auto_controls.indexOf('range') != -1)



      const enhance_options = message.enhance_options
      const enhance_states = message.enhance_states
      const enhance_ratios = message.enhance_ratios




      return (

        <Columns>
        <Column>
 
 
        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

              <div hidden={(hide_resolution)}>



                            <SliderAdjustment
                                  title={"Resolution"}
                                  msgType={"std_msgs/Float32"}
                                  adjustment={resolution_ratio}
                                  topic={namespace + '/set_resolution_ratio'}
                                  scaled={0.01}
                                  min={0}
                                  max={100}
                                  tooltip={"Adjustable Resolution"}
                                  unit={"%"}
                              />

              </div>

                          <Columns>
                          <Column>

                          </Column>
                          <Column>

                          <Label title={"Current Resolution"}>
                        <Input
                          value={resolution_str}
                          id="cur_res"
                          style={{ width: "100%" }}
                          disabled={true}
                        />
                      </Label>

                          </Column>
                        </Columns>             




            {this.renderEnhances(namespace, enhance_options, enhance_states, enhance_ratios)}


            <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

            <div hidden={(has_auto_adjust !== true )}>
            
                    <Columns>
                    <Column>

                            <Label title={"Auto Adjust"}>
                              <Toggle
                                checked={auto_adjust_enabled===true}
                                onClick={() => sendBoolMsg(namespace + "/set_auto_adjust_enable",!auto_adjust_enabled)}>
                              </Toggle>
                            </Label>


                        </Column>
                        <Column>

                        </Column>
                      </Columns>

                </div>


            <div hidden={(has_auto_adjust !== true || auto_adjust_enabled !== true )}>
                      <SliderAdjustment
                          title={"Auto Adjust Sensitivity"}
                          msgType={"std_msgs/Float32"}
                          adjustment={auto_adjust_ratio}
                          topic={namespace + "/set_auto_adjust_ratio"}
                          scaled={0.01}
                          min={0}
                          max={100}
                          tooltip={"Adjustable Adjust"}
                          unit={"%"}
                      />

            </div>


          <div hidden={(hide_brightness)}>
                      <SliderAdjustment
                          title={"Brightness"}
                          msgType={"std_msgs/Float32"}
                          adjustment={brightness_ratio}
                          topic={namespace + "/set_brightness_ratio"}
                          scaled={0.01}
                          min={0}
                          max={100}
                          tooltip={"Adjustable brightness"}
                          unit={"%"}
                      />

            </div>


            <div hidden={(hide_contrast)}>
                      <SliderAdjustment
                        title={"Contrast"}
                        msgType={"std_msgs/Float32"}
                        adjustment={contrast_ratio}
                        topic={namespace + "/set_contrast_ratio"}
                        scaled={0.01}
                        min={0}
                        max={100}
                        tooltip={"Adjustable contrast"}
                        unit={"%"}
                      />

            </div>

            <div hidden={(hide_threshold)}>
                      <SliderAdjustment
                          title={"Thresholding"}
                          msgType={"std_msgs/Float32"}
                          adjustment={threshold_ratio}
                          topic={namespace + "/set_threshold_ratio"}
                          scaled={0.01}
                          min={0}
                          max={100}
                          tooltip={"Adjustable threshold"}
                          unit={"%"}
                      />
              </div>




            <div hidden={(hide_range)}>
                    <RangeAdjustment
                      title="Range Clip"
                      min={range_start_ratio}
                      max={range_stop_ratio}
                      min_limit_m={0.2}
                      max_limit_m={1.0}
                      topic={namespace + "/set_range_ratios"}
                      tooltip={"Adjustable range ratio"}
                      unit={"%"}
                    />
          </div>


          <div hidden={(has_zoom !== true )}>

                      <SliderAdjustment
                            title={"Zoom"}
                            msgType={"std_msgs/Float32"}
                            adjustment={zoom_ratio}
                            topic={namespace + "/set_zoom_ratio"}
                            scaled={0.01}
                            min={0}
                            max={100}
                            disabled={false}
                            tooltip={"Zoom controls"}
                            unit={"%"}
                        />
          </div>

          <div hidden={(has_pan !== true )}>

                      <SliderAdjustment
                            title={"Pan Left-Right"}
                            msgType={"std_msgs/Float32"}
                            adjustment={pan_lr_ratio}
                            topic={namespace + "/set_pan_lr_ratio"}
                            scaled={0.01}
                            min={0}
                            max={100}
                            disabled={false}
                            tooltip={"Pan left-right controls"}
                            unit={"%"}
                        />

                      <SliderAdjustment
                            title={"Pan Up-Down"}
                            msgType={"std_msgs/Float32"}
                            adjustment={pan_ud_ratio}
                            topic={namespace + "/set_pan_up_ratio"}
                            scaled={0.01}
                            min={0}
                            max={100}
                            disabled={false}
                            tooltip={"Pan up-down controls"}
                            unit={"%"}
                        />

          </div>

          <div hidden={(has_rotate !== true )}>

                      <SliderAdjustment
                            title={"Rotate"}
                            msgType={"std_msgs/Float32"}
                            adjustment={rotate_ratio}
                            topic={namespace + "/set_rotate_ratio"}
                            scaled={0.01}
                            min={0}
                            max={100}
                            disabled={false}
                            tooltip={"Rotate controls"}
                            unit={"%"}
                        />

          </div>

          <div hidden={(has_tilt !== true )}>

                        <SliderAdjustment
                            title={"Tilt"}
                            msgType={"std_msgs/Float32"}
                            adjustment={tilt_ratio}
                            topic={namespace + "/set_tilt_ratio"}
                            scaled={0.01}
                            min={0}
                            max={100}
                            disabled={false}
                            tooltip={"Tilt controls"}
                            unit={"%"}
                        />
          </div>



          <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/> 


          <ButtonMenu>
            <Button onClick={() => sendTriggerMsg( namespace + "/reset_controls")}>{"Reset Controls"}</Button>
          </ButtonMenu>


      </Column>
      </Columns>
      )
    }
    else {
      return (
        <Columns>
        <Column>

        </Column>
        </Columns>
      )

    }

  }

  renderOverlays() {
    const { sendTriggerMsg, sendBoolMsg } = this.props.ros
    const namespace = this.state.controls_namespace
    const has_overlays = this.props.has_overlays ? this.props.has_overlays : true
   
    if (has_overlays === true && this.state.status_msg != null && namespace != null){
      const message = this.state.status_msg
      const size_ratio = message.overlay_size_ratio
      const name = message.overlay_img_name
      const date = message.overlay_date_time
      const nav = message.overlay_nav
      const pose = message.overlay_pose


      return (

        <Columns>
        <Column>


        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

            <Columns>
            <Column>
                  <Label title={"Source Name"}>
                      <Toggle
                        checked={name}
                        onClick={() => sendBoolMsg(namespace + '/set_overlay_source_name',!name)}
                      /> 
                    </Label>

                    <Label title={"Date Time"}>
                      <Toggle
                        checked={date}
                        onClick={() => sendBoolMsg(namespace + '/set_overlay_date_time',!date)}
                      /> 
                    </Label>

                    <Label title={"Location"}>
                      <Toggle
                        checked={nav}
                        onClick={() => sendBoolMsg(namespace + '/set_overlay_nav',!nav)}
                      /> 
                    </Label>

                    <Label title={"Pose"}>
                      <Toggle
                        checked={pose}
                        onClick={() => sendBoolMsg(namespace + '/set_overlay_pose',!pose)}
                      /> 
                    </Label>


                </Column>
                <Column>

                </Column>
              </Columns>



              <SliderAdjustment
                            title={"Overlay Size"}
                            msgType={"std_msgs/Float32"}
                            adjustment={size_ratio}
                            topic={namespace + "/set_overlay_size_ratio"}
                            scaled={0.01}
                            min={0}
                            max={100}
                            disabled={false}
                            tooltip={"Overlay size controls"}
                            unit={"%"}
                        />



              <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/> 

          <ButtonMenu>
            <Button onClick={() => sendTriggerMsg( namespace + "/reset_overlays")}>{"Reset Overlays"}</Button>
          </ButtonMenu>

      </Column>
      </Columns>
      )
    }
    else {
      return (
        <Columns>
        <Column>

        </Column>
        </Columns>
      )

    }

  }


  renderCompression(){
    const {
      streamingImageQuality
    } = this.props.ros
    const hideQualitySelector = this.props.hideQualitySelector ? this.props.hideQualitySelector: false


    if (streamingImageQuality !== this.state.currentStreamingImageQuality)
    {
      this.setState({currentStreamingImageQuality: streamingImageQuality})
    }

    

    return(
          <Columns>
          <Column>
          <div align={"left"} textAlign={"left"}>
            { hideQualitySelector ?
              null :
              <Label title={"Compression Level"} />
            }
          </div>
          </Column>
          <Column>
          <div align={"left"} textAlign={"left"}>
            { hideQualitySelector ?
              null :
              <div>
                <Label title={"Low"} />
                <Toggle
                  checked={streamingImageQuality >= COMPRESSION_HIGH_QUALITY}
                  onClick={() => {this.onChangeImageQuality(COMPRESSION_HIGH_QUALITY)}}
                />
              </div>
            }
          </div>
          </Column>
          <Column>
          <div align={"left"} textAlign={"left"}>
            { hideQualitySelector ?
              null :
              <div>
                <Label title={"Medium"} />
                <Toggle
                  checked={streamingImageQuality >= COMPRESSION_MED_QUALITY && streamingImageQuality < COMPRESSION_HIGH_QUALITY}
                  onClick={() => {this.onChangeImageQuality(COMPRESSION_MED_QUALITY)}}
                />
              </div>
            }
          </div>
          </Column>
          <Column>
          <div align={"left"} textAlign={"left"}>
            { hideQualitySelector ?
              null :
              <div>
                <Label title={"High"} />
                <Toggle
                  checked={streamingImageQuality <= COMPRESSION_LOW_QUALITY}
                  onClick={() => {this.onChangeImageQuality(COMPRESSION_LOW_QUALITY)}}
                />
              </div>
            }
          </div>
          </Column>
        </Columns>

    )

  }

  /*
  ZoomViewer(){
    return (
  
      <TransformWrapper>
        <TransformComponent>
          <canvas style={styles.canvas} ref={this.onCanvasRef} />
          </TransformComponent>
      </TransformWrapper>
  
    )
  
  }
*/

  render() {

    const namespace = this.props.imageTopic ? this.props.imageTopic : 'None'
    const show_status = this.state.show_status
    const show_controls = this.state.show_controls
    const show_navpose = this.state.show_navpose 
    const navpose_namespace = this.props.navpose_namespace ? this.props.navpose_namespace : namespace

    
    return (
      <Section title={this.props.title}>

          <canvas style={styles.canvas} ref={this.onCanvasRef} />

        <div style={{ display: 'flex' }}>
                <div style={{ width: '20%' }}>
                      <Label title="Show Controls">
                        <Toggle
                          checked={this.state.show_controls===true}
                          onClick={() => onChangeSwitchStateValue.bind(this)("show_controls",this.state.show_controls)}>
                        </Toggle>
                    </Label>
                </div>
                <div style={{ width: '10%' }}>
                </div>

                <div style={{ width: '20%' }}>
                    <Label title="Show Info">
                        <Toggle
                          checked={this.state.show_status===true}
                          onClick={() => onChangeSwitchStateValue.bind(this)("show_status",this.state.show_status)}>
                        </Toggle>
                      </Label>
                </div>
                <div style={{ width: '10%' }}>
                </div>

                <div style={{ width: '20%' }}>
                     <Label title="Show NavPose">
                        <Toggle
                          checked={this.state.show_navpose===true}
                          onClick={() => onChangeSwitchStateValue.bind(this)("show_navpose",this.state.show_navpose)}>
                        </Toggle>
                      </Label>
                </div>
                <div style={{ width: '20%' }}>
                </div>

              </div>


        <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

              <div style={{ display: 'flex' }}>
                <div style={{ width: '20%' }}>







                </div>

                <div style={{ width: '80%' }}>

                </div>
              </div>


        <div align={"left"} textAlign={"left"} hidden={(show_status !== true || namespace === 'None')}>


              <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>


              <div style={{ display: 'flex' }}>
                <div style={{ width: '40%' }}>


                <Label title={"Info"} />
                    {this.renderInfo()}


                </div>

                <div style={{ width: '20%' }}>
                  {}
                </div>

                <div style={{ width: '40%' }}>


                <Label title={"Stats"} />
                    {this.renderStats()}


                </div>
              </div>




        </div>

       


        <div align={"left"} textAlign={"left"} hidden={(show_controls !== true || namespace === 'None')}>

                <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

                <div style={{ display: 'flex' }}>
                      <div style={{ width: '40%' }}>


                          <Label title={"OVERLAYS"} />
                                        {this.renderOverlays()}


                      </div>

                      <div style={{ width: '20%' }}>
                        {}
                      </div>

                      <div style={{ width: '40%' }}>

                          <Label title={"CONROLS"} />
                                        {this.renderControls()}
                      </div>
      
                </div>

                <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>      

                  {this.renderCompression()}

                  <NepiIFConfig
                      namespace={namespace}
                      title={"Nepi_IF_Config"}
                  />

          </div>

          <div align={"left"} textAlign={"left"} hidden={(show_navpose !== true || namespace === 'None')}>          

                      <NavPoseViewer
                        namespace={(show_navpose === true)? navpose_namespace : null}
                        make_section={false}
                        title={"IDX NavPose Data"}
                      />

</div>

             
      </Section>

    )
  }
}

ImageViewer.defaultProps = {
  imageRecognitions: [
    // {
    //   label: "foobar",
    //   roi: { x_offset: 500, y_offset: 100, width: 300, height: 400 }
    // }
  ]
}

export default ImageViewer
