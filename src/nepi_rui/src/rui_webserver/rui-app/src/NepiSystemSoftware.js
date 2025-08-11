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

import Input from "./Input"
import Section from "./Section"
import { Columns, Column } from "./Columns"
import Label from "./Label"
import Button, { ButtonMenu } from "./Button"
import Styles from "./Styles"

@inject("ros")
@observer
class NepiSystemSoftware extends Component {
    constructor(props) {
        super(props)
    
        this.renderSysSoftwareUpdate = this.renderSysSoftwareUpdate.bind(this)
    }

    renderSysPartitionSettings() {
      const {
        systemDefs,
        onSwitchActiveInactiveRootfs,
        systemStatus
      } = this.props.ros

      const active_device_str = systemDefs? systemDefs.active_rootfs_device + ": " + systemDefs.firmware_version : ""
      const inactive_device_str = systemDefs? systemDefs.inactive_rootfs_device + ": " + systemDefs.inactive_rootfs_fw_version : ""

      const stale_active_inactive = systemStatus && (systemStatus.warnings.flags[3] === true)
      var active_inactive_style = {width: '100%'}
      if (stale_active_inactive === true) {
        active_inactive_style["color"] = Styles.vars.colors.red
        active_inactive_style["fontWeight"] = "bold"
      }

      return (
        <Section title={"A/B Partition Settings"}>
          <Label title={"First-stage"}>
            <Input disabled value={systemDefs? systemDefs.first_stage_rootfs_device : ""} style={{width: '100%'}}/>
          </Label>
          <Label title={"Active"}>
            <Input disabled value={active_device_str} style={active_inactive_style}/>
          </Label>
          <Label title={"Inactive"}>
            <Input disabled value={inactive_device_str} style={active_inactive_style}/>
          </Label>
          <Label title={"Max Boot Fail Count"}>
            <Input disabled value={systemDefs? systemDefs.max_boot_fail_count : ""} style={{width: '100%'}}/>
          </Label>
          <ButtonMenu>
            <Button onClick={onSwitchActiveInactiveRootfs}>{"Switch Active/Inactive"}</Button>
          </ButtonMenu>                    
        </Section>
      )
    }

    renderSysSoftwareUpdate() {
      const {
          systemStatus,
          systemSoftwareStatus,
          callSystemSoftwareStatusQueryService,
          onInstallFullSysImg
      } = this.props.ros

      return (
        <Section title={"Full System Update"}>
          <Label title={"Source"}>
            <Input disabled value={systemSoftwareStatus? systemSoftwareStatus.new_sys_img_staging_device : ""} style={{width: '100%'}}/>
          </Label>
          <Label title={"Image Filename"}>
            <Input disabled value={systemSoftwareStatus? systemSoftwareStatus.new_sys_img : ""} style={{width: '100%'}}/>
          </Label>
          <Label title={"Image Version"}>
            <Input disabled value={systemSoftwareStatus? systemSoftwareStatus.new_sys_img_version : ""} style={{width: '100%'}}/>
          </Label>
          <Label title={"Image Size"}>
            <Input disabled value={systemSoftwareStatus? systemSoftwareStatus.new_sys_img_size_mb.toFixed(0) + "MB" : ""} style={{width: '100%'}}/>
          </Label>
          <Label title={"Status"}>
            <Input disabled value={systemStatus? systemStatus.sys_img_update_status : ""} style={{width: '100%'}}/> 
          </Label>
          <Label title={"Progress"}>
            <progress value={systemStatus? systemStatus.sys_img_update_progress : 0.0} style={{width: '100%'}}/>
          </Label>          
          <ButtonMenu>
            <Button onClick={callSystemSoftwareStatusQueryService}>{"Check"}</Button>
            {(systemSoftwareStatus && (systemSoftwareStatus.new_sys_img !== 'none detected')) &&
                <Button onClick={() => onInstallFullSysImg(systemSoftwareStatus.new_sys_img)}>{"Install"}</Button>
            }
          </ButtonMenu>
        </Section>
      )
    }

    renderSysArchive() {
      const {
        onStartSysBackup,
        systemSoftwareStatus,
        systemDefs,
        systemStatus
      } = this.props.ros

      const source_str = systemDefs? 
        systemDefs.inactive_rootfs_device + ":  (" + systemDefs.inactive_rootfs_size_mb.toFixed(0) + "MB)": 
        ""
      
      const dest_str = systemSoftwareStatus?
        systemSoftwareStatus.new_sys_img_staging_device + ":  (" + systemSoftwareStatus.new_sys_img_staging_device_free_mb.toFixed(0) + "MB free)":
        ""
      
        return (
        <Section title={"Full System Archive"}>
          <Label title={"Source"}>
            <Input disabled value={source_str} style={{width: '100%'}}/>
          </Label>
          <Label title={"Destination"}>
            <Input disabled value={dest_str} style={{width: '100%'}}/>
          </Label>
          <Label title={"Archive Filename"}>
            <Input disabled value={systemStatus? systemStatus.sys_img_archive_filename : ""} style={{width: '100%'}}/>
          </Label>
          <Label title={"Status"}>
            <Input disabled value={systemStatus? systemStatus.sys_img_archive_status : ""} style={{width: '100%'}}/> 
          </Label>
          <Label title={"Progress"}>
            <progress value={systemStatus? systemStatus.sys_img_archive_progress : 0.0} style={{width: '100%'}}/>
          </Label>
          <ButtonMenu>
            <Button onClick={() => onStartSysBackup()}>{"Archive"}</Button>
          </ButtonMenu>  
        </Section>
      )
    }

    render() {
      const {systemInContainer
      } = this.props.ros

      if (systemInContainer === true){
        return (

          <pre style={{ height: "88px", overflowY: "auto" }}>
            {"NEPI Running in Container Mode.  Software Update, Backup, and Cloning disabled"}
          </pre>
        )
      }
      else {
        return (

          <Columns>
          <Column>
            {this.renderSysPartitionSettings()}
            {this.renderSysArchive()}
          </Column>
          <Column>
            {this.renderSysSoftwareUpdate()}  
          </Column>
        </Columns>

            )

      }
    }
}

export default NepiSystemSoftware
