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
import Button, { ButtonMenu } from "./Button"
import Styles from "./Styles"

import NepiDeviceIDXControls from "./NepiDeviceIDX-Controls"

import NepiDeviceInfo from "./Nepi_IF_DeviceInfo"
import ImageViewer from "./Nepi_IF_ImageViewer"
import NepiIFSettings from "./Nepi_IF_Settings"
import NepiIFSaveData from "./Nepi_IF_SaveData"
import NepiIFConfig from "./Nepi_IF_Config"

import NepiSystemMessages from "./Nepi_IF_Messages"


import {createShortUniqueValues} from "./Utilities"

@inject("ros")
@observer

// IDX Application page
class NepiDeviceIDX extends Component {
  constructor(props) {
    super(props)


    
    this.state = {

      show_controls: true,
      show_settings: true,
      show_save_data: true,

      data_topic: null,
      data_product: 'None',
      imageTopic: 'None',
      imageText: 'None',      
      
      // IDX Sensor topic to subscribe to and update
      namespace: null,
      namespaceText: "No sensor selected"
    }

    this.onDeviceSelected = this.onDeviceSelected.bind(this)
    this.clearDeviceSelection = this.clearDeviceSelection.bind(this)
    this.createDeviceOptions = this.createDeviceOptions.bind(this)

    this.createDataProductOptions = this.createDataProductOptions.bind(this)
    this.onDataProductSelected = this.onDataProductSelected.bind(this)

    //const namespaces = Object.keys(props.ros.idxDevices)

  }


  // Function for creating topic options for Select input
  createDeviceOptions(topics) {

    var items = []
    items.push(<Option value={'None'}>{'None'}</Option>)
    //var unique_names = createShortUniqueValues(topics)
    var device_name = ""
    for (var i = 0; i < topics.length; i++) {
      device_name = topics[i].split('/idx')[0].split('/').pop()
      items.push(<Option value={topics[i]}>{device_name}</Option>)
    }
    // Check that our current selection hasn't disappeard as an available option
    const { namespace } = this.state
    if ((namespace != null) && (! topics.includes(namespace))) {
      this.clearDeviceSelection()
    }

    return items
  }


  clearDeviceSelection() {
    this.setState({
      namespace: null,
      namespaceText: "No sensor selected",
      imageTopic: "None",
      imageText: "None"        
    })
  }

  // Handler for IDX Sensor topic selection
  onDeviceSelected(event) {
    var index = event.nativeEvent.target.selectedIndex
    var text = event.nativeEvent.target[index].text
    var value = event.target.value

    // Handle the "None" option -- always index 0
    if (index === 0) {
      this.clearDeviceSelection()
      return
    }
    else{
      var autoSelectedImgTopic = null
      var autoSelectedImgTopicText = null
      const capabilities = this.props.ros.idxDevices[value]
      if (capabilities.has_color_image) {
        autoSelectedImgTopic = value + '/color_image'
        autoSelectedImgTopicText = 'color_image'
      }

      this.setState({
        namespace: value,
        namespaceText: text,
        data_topic: autoSelectedImgTopic,
        data_product: autoSelectedImgTopicText,
        imageTopic: autoSelectedImgTopic,
        imageText: autoSelectedImgTopicText
      })
    }
  }


  createDataProductOptions(namespace) {
    const capabilities = this.props.ros.idxDevices[namespace]
    const data_products = capabilities ? capabilities.data_products : []

    var items = []
    items.push(<Option value={"None"}>{"None"}</Option>)
    var data_product
    var data_topic

    for (var i = 0; i < data_products.length; i++) {
      data_product = data_products[i]
      data_topic = namespace + '/' + data_product
      items.push(<Option value={data_topic}>{data_product}</Option>)
    }
    return items    
  }


  // Handler for Image topic selection
  onDataProductSelected(event) {
    var index = event.nativeEvent.target.selectedIndex
    var text = event.nativeEvent.target[index].text
    var value = event.target.value

    var img_topic = null
    var img_text = 'None'
    if (text !== 'None') {
      img_topic = value
      img_text = text
    }

    if (img_topic != null && text.indexOf('image') === -1){
      img_topic = img_topic + '/' + text + '_image'
      img_text = text + '_image'
    }

    this.setState({
      data_topic: value,
      data_product: text,
      imageTopic: img_topic,
      imageText: img_text
    })
  }

  renderDeviceSelection() {
    const { idxDevices, sendTriggerMsg  } = this.props.ros
    const NoneOption = <Option>None</Option>
    const device_selected = (this.state.namespace != null)
    const data_topic = this.state.data_topic
    const namespace = this.state.namespace ? this.state.namespace : "None"

    return (
      <React.Fragment>
        <Columns>
          <Column>
            <Section title={"Selection"}>

              <Columns>
              <Column>
              
                <Label title={"Device"}>
                  <Select
                    onChange={this.onDeviceSelected}
                    value={namespace}
                  >
                    {this.createDeviceOptions(Object.keys(idxDevices))}
                  </Select>
                </Label>
               
                <div align={"left"} textAlign={"left"} hidden={!device_selected}>
                  <Label title={"Data Product"}>
                    <Select
                      id="topicSelect"
                      onChange={this.onDataProductSelected}
                      value={data_topic}
                    >
                      {namespace
                        ? this.createDataProductOptions(namespace)
                        : NoneOption}
                    </Select>
                  </Label>
                </div>

              </Column>
              <Column>
 
              </Column>
            </Columns>

            <div align={"left"} textAlign={"left"} hidden={!device_selected}>
              
                    <NepiIFConfig
                        namespace={namespace}
                        title={"Nepi_IF_Conig"}
                  />
          </div>


            </Section>
          </Column>
        </Columns>
      </React.Fragment>
    )
  }

  renderImageViewer() {
    const image_topic = this.state.imageTopic
    const image_text = this.state.imageText
    return (
      <React.Fragment>
        <Columns>
          <Column equalWidth={false}>

          {image_topic && image_topic !== 'None' &&

            <ImageViewer
              imageTopic={image_topic}
              title={image_text}
              hideQualitySelector={false}
            />
          }

          </Column>
        </Columns>
      </React.Fragment>
    )
  }


  render() {
    const device_selected = (this.state.namespace != null)
    const namespace = this.state.namespace
    const data_product = this.state.data_product

    
    return (

      <Columns>
      <Column>


    
      <div style={{ display: 'flex' }}>

          <div style={{ width: "68%" }}>

                    <div hidden={(!device_selected)}>
                      <NepiDeviceInfo
                            deviceNamespace={namespace}
                            status_topic={"/status"}
                            status_msg_type={"nepi_interfaces/DeviceIDXStatus"}
                            name_update_topic={"/update_device_name"}
                            name_reset_topic={"/reset_device_name"}
                            title={"NepiDeviceIDXInfo"}
                        />

                    </div>


                        {this.renderImageViewer()}

                    <div hidden={(!device_selected)}>

                      <NepiIFSaveData
                          namespace={namespace}
                          title={"Nepi_IF_SaveData"}
                      />


                    <NepiSystemMessages
                    messagesNamespace={namespace}
                    title={"NepiSystemMessages"}
                    />

                    </div>


          </div>


          <div style={{ width: '2%' }}>
                {}
          </div>



          <div style={{ width: "30%"}}>

                {this.renderDeviceSelection()}



                <div hidden={(!device_selected && this.state.show_controls)}>
                      <NepiDeviceIDXControls
                          namespace={namespace}
                          dataProduct={data_product}
                          title={"NepiDeviceIDXControls"}
                      />
                </div>


                <div hidden={(!device_selected && this.state.show_settings)}>
                      <NepiIFSettings
                        namespace={namespace}
                        title={"Nepi_IF_Settings"}
                      />
                </div>

          </div>

    </div>


      </Column>
    </Columns>

    )
  }


}

export default NepiDeviceIDX
