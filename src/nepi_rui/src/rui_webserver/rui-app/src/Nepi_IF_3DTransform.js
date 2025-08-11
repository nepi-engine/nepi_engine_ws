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
import Select, { Option } from "./Select"
import Styles from "./Styles"
import Button, { ButtonMenu } from "./Button"
import Input from "./Input"
import Toggle from "react-toggle"

import { round, convertStrToStrList, createShortValuesFromNamespaces, createMenuListFromStrList,
  onDropdownSelectedSendStr, onDropdownSelectedSetState, 
  onUpdateSetStateValue, onEnterSendFloatValue, onEnterSetStateFloatValue,
  doNothing} from "./Utilities"

import NepiIFConfig from "./Nepi_IF_Config"
import Nepi_IF_SaveData from "./Nepi_IF_SaveData"

@inject("ros")
@observer

// Frame 3D Transform window
class NepiIF3DTransform extends Component {
  constructor(props) {
    super(props)

    this.state = {

      transform_msg: null,
      source: '',
      end: '',

      transformTX: 0,
      transformTY: 0,
      transformTZ: 0,
      transformRX: 0,
      transformRY: 0,
      transformRZ: 0,
      transformHO: 0,
      needs_update: false,
      namespace: null

    }

    this.sendTransformUpdateMessage = this.sendTransformUpdateMessage.bind(this)
    this.sendTransformClearMessage = this.sendTransformClearMessage.bind(this)

    this.renderTransform = this.renderTransform.bind(this)

    this.updateListener = this.updateListener.bind(this)
    this.statusListener = this.statusListener.bind(this)
  }

  // Callback for handling ROS StatusIDX messages
  statusListener(message) {
    const last_msg = this.state.transform_msg
    this.setState({
      transform_msg: message,
      source: message.source_ref_description,
      end: message.end_ref_description
    })
    const update_msg = message.toString()
    if (update_msg !== last_msg.toString()) {
      this.setState({
        transformTX: message.translate_vector.x,
        transformTY: message.translate_vector.y,
        transformTZ: message.translate_vector.z,
        transformRX: message.rotate_vector.x,
        transformRY: message.rotate_vector.y,
        transformRZ: message.rotate_vector.z,
        transformHO: message.heading_offset,
      })
    }

  }

  // Function for configuring and subscribing to StatusIDX
  updateListener() {
    const namespace = this.props.namespace + '/frame_3d_transform'
    if (this.state.listener) {
      this.state.listener.unsubscribe()
    }
    this.setState({ namespace: namespace  })
    var listener = this.props.ros.setupFrame3DTransformListener(
      namespace,
      this.statusListener
    )
    this.setState({ listener: listener, disabled: false })

  }


  componentDidMount(){
    this.setState({needs_update: true})
  }


  componentDidMount(){
    this.setState({needs_update: true})
    
    // Always perform initial setup with the current namespace
    const { namespace } = this.props
    if (namespace !== null) {
      this.setState({namespace: namespace})
      this.updateListener()
    } else {
      this.setState({ disabled: true })
    }
  }

  // Lifecycle method called just before the component umounts.
  // Used to unsubscribe to StatusIDX message
  componentWillUnmount() {
    if (this.state.listener) {
      this.state.listener.unsubscribe()
    }
  }



  renderConfigs(){
    const { sendTriggerMsg } = this.props.ros
    const namespace = this.state.namespace
    return(
      <Columns>
      <Column>


          <NepiIFConfig
                        namespace={namespace}
                        title={"Nepi_IF_Config"}
          />

        </Column>
        </Columns>


    )

  }



  sendTransformUpdateMessage(){
    const {sendFrame3DTransformMsg} = this.props.ros
    const namespace = this.state.namespace + "/set_3d_transform"
    const TX = parseFloat(this.state.transformTX)
    const TY = parseFloat(this.state.transformTY)
    const TZ = parseFloat(this.state.transformTZ)
    const RX = parseFloat(this.state.transformRX)
    const RY = parseFloat(this.state.transformRY)
    const RZ = parseFloat(this.state.transformRZ)
    const HO = parseFloat(this.state.transformHO)
    const transformList = [TX,TY,TZ,RX,RY,RZ,HO]
    sendFrame3DTransformMsg(namespace,transformList)
  }


  sendTransformClearMessage(){
    const {sendTriggerMsg} = this.props.ros
    const namespace = this.state.namespace + "/clear_3d_transform"
    sendTriggerMsg(namespace)
  }

  renderTransform() {
    const { sendTriggerMsg } = this.props.ros
    const namespace = this.state.namespace ? this.state.namespace : "None"
    const has_transform = this.props.has_transform ? this.props.has_transform : true
    if (has_transform === false){
      const msg = ("\n\nData Transformed by Parent")

        return (
          <Columns>
          <Column>
          <Columns>
            <Column>
            <pre style={{ height: "200px", overflowY: "auto" }} align={"left"} textAlign={"left"}>
                      {msg}
                      </pre>

            </Column>
            </Columns>
          </Column>
        </Columns>
      )
    }
    else {
      const source = this.state.source
      const end = this.state.end
      const updates = this.props.supports_updates !== null ? this.props.supports_updates : true
      const updates_msg = updates ? "" : "Transform Set by Parent"

      const msg = ("\n\nSource: " + source + 
      "\n\nEnd: " + end + 
      "\n\n" + updates_msg)

      return (
        <div>

            <Columns>
            <Column>

            <Label title={"X (m)"}>
              <Input
                value={this.state.transformTX}
                id="XTranslation"
                disabled={!updates}
                onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"transformTX")}
                onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"transformTX")}
                style={{ width: "80%" }}
              />
            </Label>

            <Label title={"Y (m)"}>
              <Input
                value={this.state.transformTY}
                id="YTranslation"
                disabled={!updates}
                onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"transformTY")}
                onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"transformTY")}
                style={{ width: "80%" }}
              />
            </Label>

            <Label title={"Z (m)"}>
              <Input
                value={this.state.transformTZ}
                id="ZTranslation"
                disabled={!updates}
                onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"transformTZ")}
                onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"transformTZ")}
                style={{ width: "80%" }}
              />
            </Label>

            <div hidden={updates === false}>
            <ButtonMenu>
              <Button onClick={() => this.sendTransformUpdateMessage()}>{"Update Transform"}</Button>
            </ButtonMenu>
            </div>




          </Column>
          <Column>

            <Label title={"Roll (deg)"}>
              <Input
                value={this.state.transformRX}
                id="XRotation"
                disabled={!updates}
                onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"transformRX")}
                onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"transformRX")}
                style={{ width: "80%" }}
              />
            </Label>

            <Label title={"Pitch (deg)"}>
              <Input
                value={this.state.transformRY}
                id="YRotation"
                disabled={!updates}
                onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"transformRY")}
                onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"transformRY")}
                style={{ width: "80%" }}
              />
            </Label>

                <Label title={"Yaw (deg)"}>
                  <Input
                    value={this.state.transformRZ}
                    id="ZRotation"
                    disabled={!updates}
                    onChange= {(event) => onUpdateSetStateValue.bind(this)(event,"transformRZ")}
                    onKeyDown= {(event) => onEnterSetStateFloatValue.bind(this)(event,"transformRZ")}
                    style={{ width: "80%" }}
                  />
                </Label>

                <div hidden={updates === false}>
                    <ButtonMenu>
                        <Button onClick={() => sendTriggerMsg( namespace + "/clear_3d_transform")}>{"Clear Transform"}</Button>
                    </ButtonMenu>
                </div>


              </Column>
            </Columns>


            <Columns>
            <Column>

            {this.renderConfigs()}

            </Column>
            </Columns>
        </div>
      )
    }
  }

  render() {
    const make_section = this.props.make_section ? this.props.make_section : true
    const namespace = this.state.namespace ? this.state.namespace : 'None'


    if (namespace !== 'None' && make_section === true){
      return (
        <Columns>
          <Column>
          <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"3D Transforms"}
         </label>
          {this.renderTransform()}

          </Column>
        </Columns>
      )
    }
    else if (namespace !== 'None' && make_section === false) {
      return (
        <Section >
          <label style={{fontWeight: 'bold'}} align={"left"} textAlign={"left"}>
          {"3D Transforms"}
          </label>
          {this.renderTransform()}
        </Section>

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
  }


export default NepiIF3DTransform