/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import { observable, action } from "mobx"
import moment from "moment"
import ROS from "roslib"
import cannon from "cannon"
import yaml from "js-yaml"

const ROS_WS_URL = `ws://${window.location.hostname}:9090`
//const FLASK_URL = `http://${window.location.hostname}:5003`
const LICENSE_SERVER_WS_URL = `ws://${window.location.hostname}:9092`

const TRIGGER_MASKS = {
  OUTPUT_ENABLED: 0xffffffff,
  DEFAULT: 0x7fffffff
}

const EULER_ORDER_FOR_CANNON = "YZX" // Only supported angle ordering for Cannon library quaternion.toEuler() function

// TODO: Would be better to query the display_name property of all nodes to generate
// this dictionary... requires a new SDKNode service to do so
const NODE_DISPLAY_NAMES = {
  config_mgr: "Config Manager",
  nav_pose_mgr: "Nav./Pose/GPS",
  network_mgr: "Network",
  ai_detector_mgr: "Classifier",
  system_mgr: "System",
  time_sync_mgr: "Time Sync",
  trigger_mgr: "Triggering",
  nepi_link_ros_bridge: "NEPI Connect",
  gpsd_ros_client: "GPSD Client",
  illumination_mgr: "Illumination",
  automation_mgr: "Automation",
  app_image_sequencer: "Sequencer"
}

const UPDATE_PERIOD = 100 // ms between sending updates

function displayNameFromNodeName(node_name) {
  var display_name = NODE_DISPLAY_NAMES[node_name]
  if (display_name) {
    return display_name
  }
  return node_name
}

function nodeNameFromDisplayName(display_name) {
  for( var node_name in NODE_DISPLAY_NAMES ) {
    if (NODE_DISPLAY_NAMES[node_name] === display_name) {
      return node_name
    }
  }
  // Don't return anything if we don't find the display name -- callers can check for undefined
}

export { TRIGGER_MASKS, displayNameFromNodeName, nodeNameFromDisplayName }

/*
async function apiCall(endpoint) {
  try {
    const r = await fetch(`${FLASK_URL}/api/${endpoint}`, {
      method: "GET"
    })
    const json = await r.json()
    return json
  } catch (err) {
    console.error(err)
  }
}
*/

/*
// gets a file through the flask api and parses it as Json
async function getFileJson(filename) {
  try {
    const r = await fetch(`${FLASK_URL}/files/${filename}`, {
      method: "GET"
    })
    const json = await r.json()
    return json
  } catch (err) {
    console.error(err)
    return null
  }
}
*/

function getLocalTZ() {
  return Intl.DateTimeFormat().resolvedOptions().timeZone
}

//////////////////////////////////////////////////////////////
// from: https://stackoverflow.com/questions/7837456/how-to-compare-arrays-in-javascript
// Warn if overriding existing method
if (Array.prototype.equals)
  console.warn(
    "Overriding existing Array.prototype.equals. Possible causes: New API defines the method, there's a framework conflict or you've got double inclusions in your code."
  )
// attach the .equals method to Array's prototype to call it on any array
// eslint-disable-next-line no-extend-native
Array.prototype.equals = function(array) {
  // if the other array is a falsy value, return
  if (!array) return false

  // compare lengths - can save a lot of time
  if (this.length !== array.length) return false

  for (var i = 0, l = this.length; i < l; i++) {
    // Check if we have nested arrays
    if (this[i] instanceof Array && array[i] instanceof Array) {
      // recurse into the nested arrays
      if (!this[i].equals(array[i])) return false
    } else if (this[i] !== array[i]) {
      // Warning - two different object instances will never be equal: {x:20} != {x:20}
      return false
    }
  }
  return true
}
// Hide method from for-in loops
// eslint-disable-next-line no-extend-native
Object.defineProperty(Array.prototype, "equals", { enumerable: false })
//////////////////////////////////////////////////////////////

class ROSConnectionStore {
  @observable rosCheckDelay = 1000
  @observable rosCheckStarted = false
  @observable connectedToROS = false
  @observable rosAutoReconnect = true
  @observable messageLog = ""
  rosListeners = []

  @observable namespacePrefix = null
  @observable deviceType = null
  @observable deviceId = null
  @observable deviceSerial = null
  @observable deviceInWater = false

  @observable systemDefs = null
  @observable systemDefsFirmwareVersion = null
  @observable systemDefsDiskCapacityMB = null

  @observable systemSoftwareStatus = null

  @observable systemStatus = null
  @observable systemDebugEnabled = false
  @observable heartbeat = false
  @observable systemInContainer = false
  @observable systemStatusDiskUsageMB = null
  @observable systemStatusDiskRate = null
  @observable systemStatusTempC = null
  @observable systemStatusWarnings = []
  @observable diskUsagePercent = null

  @observable systemStatusTime = null
  @observable systemStatusTimeStr = null
  @observable systemStatusDateStr = null
  @observable clockUTCMode = false
  @observable available_timezones = []
  @observable syncTimezone = true
  @observable systemStatusTimezone = null
  @observable clockTZ = this.get_timezone_desc()
  @observable clockNTP = false
  @observable clockPPS = false

  @observable blankNavPose = {
      frame_3d: 'nepi_frame',
      frame_nav: 'ENU',
      frame_altitude: 'WGS84',
      frame_depth: 'MSL',
  
      geoid_height_meters: 0.0,
  
      has_location: false,
      time_location: moment.utc().unix(),
      // Location Lat,Long
      latitude: 0.0,
      longitude: 0.0,
  
      has_heading: false,
      time_heading: moment.utc().unix(),
      // Heading should be provided in Degrees True North
      heading_deg: 0.0,
  
      has_position: false,
      time_position: moment.utc().unix(),
      // Position should be provided in Meters in specified 3d frame (x,y,z) with x forward, y right/left, and z up/down
      x_m: 0.0,
      y_m: 0.0,
      z_m: 0.0,
  
      has_orientation: false,
      time_orientation: moment.utc().unix(),
      // Orientation should be provided in Degrees in specified 3d frame
      roll_deg: 0.0,
      pitch_deg: 0.0,
      yaw_deg: 0.0,
  
      has_altitude: false,
      time_altitude: moment.utc().unix(),
      // Altitude should be provided in postivie meters in specified alt frame
      altitude_m: 0.0,
  
      has_depth: false,
      time_depth: moment.utc().unix(),
      // Depth should be provided in positive meters
      depth_m: 0.0
  }
  

  @observable gpsClockSyncEnabled = false

    
  @observable imageRecognitions = []

  @observable triggerStatus = null
  @observable triggerAutoRateHz = 0
  @observable triggerMask = TRIGGER_MASKS.DEFAULT

  @observable saveFreqHz = 1.0

  @observable topicQueryLock = false
  @observable topicNames = null
  @observable topicTypes = null
  @observable appNames = []
  @observable appNamesLast = []
  @observable appNameList = []
  @observable appStatusList = []
  @observable navPoseTopics = []
  @observable navPoseCaps = {}
  @observable imageTopics = []
  @observable imageCaps = {}
  @observable imageDetectionTopics = []
  @observable depthMapTopics = []
  @observable depthMapCaps = {}
  @observable pointcloudTopics = []
  @observable pointcloudCaps = {}
  @observable settingCaps = {}
  @observable saveDataNamespaces = []
  @observable saveDataCaps = {}
  @observable idxDevices = {}
  @observable ptxDevices = {}
  @observable lsxDevices = {}
  @observable rbxDevices = {}
  @observable npxDevices = {}
  @observable resetTopics = []
  @observable navSatFixTopics = []
  @observable orientationTopics = []
  @observable headingTopics = []
  @observable messageTopics = []

  @observable imageFilterDetection = null
  @observable imageFilterSequencer = null
  @observable imageFilterPTX = null
  
  @observable lastUpdate = new Date()

  @observable targLocalizerImgTopic = null

  @observable ip_query_response = null
  @observable bandwidth_usage_query_response = null
  @observable wifi_query_response = null
  /*
  @observable NUID = "INVALID"
  @observable NEPIConnectStatus = null
  @observable alias = ""
  @observable ssh_public_key = ""
  @observable bot_running = null
  @observable lb_last_connection_time = null
  @observable hb_last_connection_time = null
  @observable lb_do_msg_count = "1"
  @observable lb_dt_msg_count = null
  @observable hb_do_transfered_mb = null
  @observable hb_dt_transfered_mb = null
  @observable lb_data_sets_per_hour = null
  @observable lb_enabled = null
  @observable hb_enabled = null
  @observable lb_available_data_sources = null
  @observable lb_selected_data_sources = null
  @observable lb_comms_types = null
  @observable auto_attempts_per_hour = null
  @observable lb_data_queue_size_kb = null
  @observable hb_data_queue_size_mb = null
  @observable hb_auto_data_offloading_enabled = null
  @observable log_storage_enabled = null
  */

  @observable streamingImageQuality = 95
  @observable nepiLinkHbAutoDataOffloadingCheckboxVisible = false

  @observable scripts = []
  @observable running_scripts = []
  @observable launchScript = false
  @observable stopScript = false
  @observable systemStats = null
  @observable scriptForPolledStats = null

  @observable imgMuxSequences = null
  @observable drivers_list_query

  @observable license_server = null
  @observable license_valid = true // Default to true to avoid initial DEVELOPER message]
  @observable license_type = 'Unlicensed'
  @observable license_info = null
  @observable license_request_info = null
  @observable license_request_mode = false



  async checkLicense() {
    var retry_delay_ms = 3000
    if (!this.license_server) {
      try {
        this.license_server = new WebSocket(LICENSE_SERVER_WS_URL)

        this.license_server.onmessage = (event) => {
          var response_dict = yaml.load(event.data)         
          
          if ('licensed_components' in response_dict)
          {
            this.license_info = yaml.load(event.data)
            this.license_type = this.license_info['licensed_components']['nepi_base']['commercial_license_type']
            if ( this.license_type === 'Unlicensed') {
              this.license_valid = false
            }
            else {
              if (this.license_request_mode && !this.license_valid) {
                this.license_request_mode = false
              }
              this.license_valid = true
            }
          }

          else if ('license_request' in response_dict)
          {
            this.license_request_info = yaml.load(event.data)
          }
        }

        retry_delay_ms = 250 // Fast to avoid a lot of latency while connecting
      } catch (e) {
        // Note: Failure to contact the server does not result in this exception, instead
        // an event is dispatched, so we don't get into this block just because the
        // server isn't present: 
        // https://stackoverflow.com/questions/31002592/javascript-doesnt-catch-error-in-websocket-instantiation
        //console.error(e)
        console.error("License server not running")
        this.license_server = null
        this.license_yaml = null
        this.license_valid = false 
        this.license_info = null
        this.license_request_info = null
        this.license_request_mode = false
      }
    }

    else if (this.license_server.readyState === 1) { // READY
      // Check for license updates
      this.license_server.send("license_check") 
      retry_delay_ms = 5000 // Slow down the updates now that we are connected
    }

    else if (this.license_server.readyState === 3) { // CLOSED
      this.license_server = null
      this.license_valid = false
      this.license_info = null
      this.license_request_info = null
      this.license_request_mode = false
    }

    setTimeout(async () => {
      await this.checkLicense()
    }, retry_delay_ms)
  }

  async checkROSConnection() {
    this.rosCheckStarted = true
    if (!this.connectedToROS) {
      try {
        // setup rosbridge connection
        if (!this.ros || !this.connectedToROS) {
          this.ros = new ROS.Ros({
            url: ROS_WS_URL
          })
          this.ros.on("connection", this.onConnectedToROS)
          this.ros.on("error", this.onErrorConnectingToROS)
          this.ros.on("close", this.onDisconnectedToROS)
        } else {
          this.ros.connect(ROS_WS_URL)
        }
        //update the topics periodically
        this.updateTopics()
      } catch (e) {
        console.error(e)
      }
    }

    if (this.rosAutoReconnect) {
      setTimeout(async () => {
        await this.checkROSConnection()
      }, this.rosCheckDelay)
    }
  }

  @action.bound
  async updateTopics() {
    // topicQueryLock is used so we don't call getTopics many times
    // while witing for it to return.  With many topics on a slow
    // target it takes a few seconds to retrun.
    //if (this.ros && !this.connectedToROS && !this.rosCheckStarted){
    //  this.checkROSConnection()
    //}
    //else if (this.ros && !this.topicQueryLock && this.connectedToROS) {
    if (this.ros && !this.topicQueryLock && this.connectedToROS) {
      this.topicQueryLock = true
      this.ros.getTopics(result => {
        this.topicNames = result.topics
        this.topicTypes = result.types
        var newPrefix = this.updatePrefix()
        var newResetTopics = this.updateResetTopics()
        var newSaveDataNamespaces = this.updateSaveDataNamespaces()
        var newImageTopics = this.updateImageTopics()
        var newMessageTopics = this.updateMessageTopics()
        var newPointcloudTopics = this.updatePointcloudTopics()
        this.updateAppStatusList()
        this.updateIDXDevices()
        this.updatePTXDevices()
		    this.updateLXSDevices()
        this.updateRBXDevices()
        this.updateNPXDevices()

        if (newPrefix || newResetTopics || newSaveDataNamespaces || newMessageTopics || newImageTopics || newPointcloudTopics) {
          this.initalizeListeners()
        }
        this.topicQueryLock = false
      })
    }

    setTimeout(async () => {
      await this.updateTopics()
    }, 2000)

  }

  validPrefix() {
    return this.namespacePrefix && this.deviceId
  }

  @action.bound
  updatePrefix() {
    // Function for testing if we need to update the device prefix variables.
    // It loops though the topics and uses the testTopicForPrefix to test and
    // perform the update.  If it updates we are done, break.

    // we return true if the prefix was updated
    var ret = false
    for (var i = 0; i < this.topicNames.length; i++) {
      var topic_name_parts = this.topicNames[i].split("/")
      if (
        topic_name_parts[topic_name_parts.length - 1] === "system_status" &&
        this.topicTypes[i] === "nepi_interfaces/MgrSystemStatus"
      ) {
        if (
          this.namespacePrefix !== topic_name_parts[1] &&
          this.deviceId !== topic_name_parts[2]
        ) {
          this.namespacePrefix = topic_name_parts[1]
          this.deviceId = topic_name_parts[2]
          if (this.validPrefix()) {
            ret = true
            this.rosLog(
              `Fetched device info ${this.namespacePrefix}/${this.deviceId}`
            )
          }
        }
      }
    }
    return ret
  }



  @action.bound
  updateSaveDataNamespaces() {
    // Function for updating image topics list
    var newSaveDataNamespaces = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicTypes[i] === "nepi_interfaces/SaveDataStatus"){
        newSaveDataNamespaces.push(this.topicNames[i].replace('/save_data/status',''))
      }
    }

    // sort the save topics for comparison to work
    newSaveDataNamespaces.sort()    

    if (!this.saveDataNamespaces.equals(newSaveDataNamespaces)) {
      this.saveDataNamespaces = newSaveDataNamespaces
      for (var i = 0; i < this.saveDataNamespaces.length; i++) {
            this.callSaveDataCapabilitiesQueryService(this.saveDataNamespaces[i])
          }
      return true
    } else {
      return false
    }
  }


  @action.bound
  updateMessageTopics() {
    // Function for updating image topics list
    var newMessageTopics = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicTypes[i] === "nepi_interfaces/Message") {
        newMessageTopics.push(this.topicNames[i])
      }
    }

    // sort the image topics for comparison to work
    newMessageTopics.sort()

    if (!this.messageTopics.equals(newMessageTopics)) {
      this.messageTopics = newMessageTopics
      return true
    } else {
      return false
    }
  }


  @action.bound
  updateNavPoseTopics() {
    // Function for updating image topics list
    var newNavPoseTopics = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicTypes[i] === "nepi_interfaces/NavPose" && this.topicNames[i].indexOf("zed_node") === -1) {
        newNavPoseTopics.push(this.topicNames[i])
      }
    }

    // sort the image topics for comparison to work
    newNavPoseTopics.sort()    

    if (!this.navposeTopic.equals(newNavPoseTopics)) {
      this.navposeTopics = newNavPoseTopics
      for (var i = 0; i < this.navposeTopics.length; i++) {
            this.callNavPoseCapabilitiesQueryService(this.NavPoseTopics[i])
          }
      return true
    } else {
      return false
    }
  }

  @action.bound
  updateImageTopics() {
    // Function for updating image topics list
    var newImageTopics = []
    var newImageDetectionTopics = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicTypes[i] === "sensor_msgs/Image" && this.topicNames[i].indexOf("zed_node") === -1) {
        newImageTopics.push(this.topicNames[i])
        if (this.topicNames[i].indexOf('detection_image') !== -1){
          newImageDetectionTopics.push(this.topicNames[i])
        }
      }
    }

    // sort the image topics for comparison to work
    newImageTopics.sort()    

    if (!this.imageTopics.equals(newImageTopics)) {
      this.imageTopics = newImageTopics
      this.imageDetectionTopics = newImageDetectionTopics
      for (var i = 0; i < this.imageTopics.length; i++) {
            this.callImageCapabilitiesQueryService(this.imageTopics[i])
          }
      return true
    } else {
      return false
    }
  }



  @action.bound
  updatePointcloudTopics() {
    // Function for updating image topics list
    var newPointcloudTopics = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicTypes[i] === "sensor_msgs/PointCloud2") {
        newPointcloudTopics.push(this.topicNames[i])
      }
    }

    // sort the image topics for comparison to work
    newPointcloudTopics.sort()

    if (!this.pointcloudTopics.equals(newPointcloudTopics)) {
      this.pointcloudTopics = newPointcloudTopics
      return true
    } else {
      return false
    }
  }

  @action.bound
  updateAppStatusList() {
    const appNames = this.appNames
    const appNamesLast = this.appNamesLast
    if (appNames.length > 0 && appNames !== appNamesLast) {
      for (var i = 0; i < appNames.length; i++) {
          this.callAppStatusQueryService(appNames[i])
      }
      this.appNamesLast = appNames
    }

  }

  
  @action.bound
  updateIDXDevices() {
    var idx_devices_changed = false
    var devices_detected = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicNames[i].endsWith("/idx/status")) {
        const idx_device_namespace = this.topicNames[i].replace("/status","")
        if (!(devices_detected.includes(idx_device_namespace))) {
          this.callIDXCapabilitiesQueryService(idx_device_namespace) // Testing
          this.callSettingsCapabilitiesQueryService(idx_device_namespace + "/settings")
          const idxDevices = this.idxDevices[idx_device_namespace]
          if (idxDevices) { // Testing
            devices_detected.push(idx_device_namespace)
          }
          idx_devices_changed = true // Testing -- always declare changed
        }
      }
    }

    // Now clean out any devices that are no longer detected
    const previously_known = Object.keys(this.idxDevices)
    for (i = 0; i < previously_known.length; ++i) {
      if (!(devices_detected.includes(previously_known[i]))) {
        delete this.idxDevices[previously_known[i]]
        idx_devices_changed = true
      }
    }
    return idx_devices_changed
  }

  @action.bound
  updatePTXDevices() {
    var ptx_devices_changed = false
    var ptx_devices_detected = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicNames[i].endsWith("/ptx/status")) {
        const ptx_device_namespace = this.topicNames[i].replace("/status","")
        if (!(ptx_devices_detected.includes(ptx_device_namespace))) {
          this.callPTXCapabilitiesQueryService(ptx_device_namespace)
          this.callSettingsCapabilitiesQueryService(ptx_device_namespace + "/settings")
          const ptxUnit = this.ptxDevices[ptx_device_namespace]
          if (ptxUnit)
          {
            ptx_devices_detected.push(ptx_device_namespace)
          }
        }
        ptx_devices_changed = true
      }
    }

    // Now clean out any units that are no longer detected
    const previously_known = Object.keys(this.ptxDevices)
    for (i = 0; i < previously_known.length; ++i) {
      if (!(ptx_devices_detected.includes(previously_known[i]))) {
        delete this.ptxDevices[previously_known[i]]
        ptx_devices_changed = true
      }
    }
    return ptx_devices_changed
  }
  
  @action.bound
  updateLXSDevices() {
    var lsx_devices_changed = false
    var lsx_devices_detected = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicNames[i].endsWith("/lsx/status")) {
        const lsx_device_namespace = this.topicNames[i].replace("/status","")
        if (!(lsx_devices_detected.includes(lsx_device_namespace))) {
          this.callLSXCapabilitiesQueryService(lsx_device_namespace)
          this.callSettingsCapabilitiesQueryService(lsx_device_namespace + "/settings")
          const lsxDevices = this.lsxDevices[lsx_device_namespace]
          if (lsxDevices)
          {
            lsx_devices_detected.push(lsx_device_namespace)
          }
        }
        lsx_devices_changed = true
      }
    }

    // Now clean out any units that are no longer detected
    const previously_known = Object.keys(this.lsxDevices)
    for (i = 0; i < previously_known.length; ++i) {
      if (!(lsx_devices_detected.includes(previously_known[i]))) {
        delete this.lsxDevices[previously_known[i]]
        lsx_devices_changed = true
      }
    }
    return lsx_devices_changed
  }  
  
  @action.bound
  updateRBXDevices() {
    var rbx_devices_changed = false
    var devices_detected = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicNames[i].endsWith("/rbx/status")) {
        const rbx_device_namespace = this.topicNames[i].replace("/status","")
        if (!(devices_detected.includes(rbx_device_namespace))) {
          this.callRBXCapabilitiesQueryService(rbx_device_namespace)
          this.callSettingsCapabilitiesQueryService(rbx_device_namespace + "/settings")
          const rbxDevice = this.rbxDevices[rbx_device_namespace]
          if (rbxDevice) {
            devices_detected.push(rbx_device_namespace)
          }
          rbx_devices_changed = true // Testing -- always declare changed
        }
      }
    }

    // Now clean out any devices that are no longer detected
    const previously_known = Object.keys(this.rbxDevices)
    for (i = 0; i < previously_known.length; ++i) {
      if (!(devices_detected.includes(previously_known[i]))) {
        delete this.rbxDevices[previously_known[i]]
        rbx_devices_changed = true
      }
    }
    return rbx_devices_changed
  }

  @action.bound
  updateNPXDevices() {
    var npx_devices_changed = false
    var devices_detected = []
    for (var i = 0; i < this.topicNames.length; i++) {
      if (this.topicNames[i].endsWith("/npx/status")) {
        const npx_device_namespace = this.topicNames[i].replace("/status","")
        if (!(devices_detected.includes(npx_device_namespace))) {
          this.callNPXCapabilitiesQueryService(npx_device_namespace) // Testing
          this.callSettingsCapabilitiesQueryService(npx_device_namespace + "/settings")
          const npxSensor = this.npxDevices[npx_device_namespace]
          if (npxSensor) { // Testing
            devices_detected.push(npx_device_namespace)
          }
          npx_devices_changed = true // Testing -- always declare changed
        }
      }
    }

    // Now clean out any devices that are no longer detected
    const previously_known = Object.keys(this.npxDevices)
    for (i = 0; i < previously_known.length; ++i) {
      if (!(devices_detected.includes(previously_known[i]))) {
        delete this.npxDevices[previously_known[i]]
        npx_devices_changed = true
      }
    }
    return npx_devices_changed
  }


  @action.bound
  updateResetTopics() {
    var newResetTopics = []
    for (var i = 0; i < this.topicNames.length; i++) {
      var topic_name_parts = this.topicNames[i].split("/")
      var last_element = topic_name_parts.pop()
      var topic_base = topic_name_parts.join("/")
      if (
        last_element === "system_reset" &&
        this.topicTypes[i] === "nepi_interfaces/Reset"
      ) {
        newResetTopics.push(topic_base)
      }
    }

    // sort the topics for comparison to work
    newResetTopics.sort()

    if (!this.resetTopics.equals(newResetTopics)) {
      this.resetTopics = newResetTopics
      return true
    } else {
      return false
    }
  }

  @action.bound
  destroyROSConnection() {
    this.rosAutoReconnect = false
    this.ros.off("connection", this.onConnectedToROS)
    this.ros.off("error", this.onErrorConnectingToROS)
    this.ros.off("close", this.onDisconnectedToROS)

    this.rosListeners.forEach(listener => {
      listener.unsubscribe()
    })
  }

  @action.bound
  rosLog(text) {
    this.messageLog = `${text}\n${this.messageLog}`
  }

  get rosPrefix() {
    return `/${this.namespacePrefix}/${this.deviceId}`
  }

  publishMessage({ name, messageType, data, noPrefix = false }) {
    const publisher = new ROS.Topic({
      ros: this.ros,
      name: noPrefix ? name : `${this.rosPrefix}/${name}`,
      messageType
    })
    const message = new ROS.Message(data)
    publisher.publish(message)
  }

  addListener({
    name,
    messageType,
    callback,
    noPrefix = false,
    manageListener = true
  }) {
    const listener = new ROS.Topic({
      ros: this.ros,
      name: noPrefix ? name : `${this.rosPrefix}/${name}`,
      messageType
    })
    listener.subscribe(action(callback))

    // add to listeners that get unsubscribed
    if (manageListener) {
      this.rosListeners.push(listener)
    }

    // return listener for clients that manage their own
    return listener
  }

  callService({ name, messageType, args = null, msgKey = null }) {
    return new Promise(resolve => {
      const client = new ROS.Service({
        ros: this.ros,
        name: name.startsWith('/')? name : `${this.rosPrefix}/${name}`,
        serviceType: messageType
      })
      const request = new ROS.ServiceRequest(args)
      client.callService(
        request,
        action(result => {
          resolve(msgKey ? result[msgKey] : result)
        })
      )
    })
  }

  @action.bound
  onConnectedToROS() {
    this.connectedToROS = true
    this.rosCheckDelay = 3000
    this.rosLog("Connected to NEPI device")
    this.checkLicense()
  }

  @action.bound
  initalizeListeners() {
    this.rosListeners.forEach(listener => {
      listener.unsubscribe()
    })

    // listeners
    this.setupMgrSystemStatusListener()
    this.setupRUISettingsListener()

    // services
    this.callSystemDefsService()
    this.callSystemSoftwareStatusQueryService()
    this.startPollingIPAddrQueryService()
    this.startPollingBandwidthUsageService()
    this.startPollingWifiQueryService()
    this.startPollingOpEnvironmentQueryService()
    this.startPollingMgrTimeStatusService()
    
    // automation manager services
    this.startPollingGetScriptsService()  // populate listbox with files
    this.startPollingGetRunningScriptsService()  // populate listbox with active files
    //this.startPollingLaunchScriptService() // invoke script execution
    //this.startPollingStopScriptService() // stop script execution
    //this.callGetSystemStatsQueryService() // get script and system status

    // sequential image mux services
    //this.callMuxSequenceQuery(true) // Start it polling


  }

  @action.bound
  onErrorConnectingToROS() {
    this.connectedToROS = false
    this.rosLog("Error connecting to NEPI device, retrying")
  }

  @action.bound
  onDisconnectedToROS() {
    this.connectedToROS = false

    this.namespacePrefix = null
    this.deviceType = null
    this.deviceId = null
    this.deviceSerial = null

    this.rosLog("Connection to NEPI device closed")
  }


  /*******************************/
  // Generic Listener Functions
  /*******************************/

  @action.bound
  setupStatusListener(namespace, msg_type, callback) {
    if (namespace) {
      return this.addListener({
        name: namespace,
        messageType: msg_type,
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }

  @action.bound
  setupStringListener(namespace,callback) {
    if (namespace) {
      return this.addListener({
        name: namespace,
        messageType: "std_msgs/String",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }

  @action.bound
  setupVector3Listener(namespace, callback) {
    if (namespace) {
      return this.addListener({
        name: namespace,
        messageType: "geometry_msgs/Vector3",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }

  @action.bound
  setupFloatListener(namespace, callback) {
    if (namespace) {
      return this.addListener({
        name: namespace,
        messageType: "std_msgs/Float32",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }

  @action.bound
  setupMgrSystemStatusListener() {
    this.addListener({
      name: "system_status",
      messageType: "nepi_interfaces/MgrSystemStatus",
      callback: message => {
        // turn heartbeat on for half a second
        this.heartbeat = true
        setTimeout(() => {
          this.heartbeat = false
        }, 500)
        this.systemStatus = message
        this.systemDebugEnabled = message.sys_debug_enabled
        this.systemInContainer = message.in_container
        this.systemStatusDiskUsageMB = message.disk_usage
        this.systemStatusDiskRate = message.storage_rate
        
        this.diskUsagePercent = `${parseInt(
          100 * this.systemStatusDiskUsageMB / this.systemDefsDiskCapacityMB,
          10
        )}%`

        this.systemStatusTempC =
          message.temperatures.length && message.temperatures[0]
        this.systemStatusWarnings = message.warnings && message.warnings.flags
        //this.rosLog("Received Status Message:")
        var i
        for(i in message.info_strings) {
          this.rosLog(message.info_strings[i].payload)
        }
      }
    })
  }



  /*******************************/
  // Custom Listener Functions
  /*******************************/

  @action.bound
  setupPTXStatusListener(ptxNamespace, callback) {
    if (ptxNamespace) {
      return this.addListener({
        name: ptxNamespace + "/status",
        messageType: "nepi_interfaces/DevicePTXStatus",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }
    
  @action.bound
  setupLSXStatusListener(lsxNamespace, callback) {
    if (lsxNamespace) {
      return this.addListener({
        name: lsxNamespace + "/status",
        messageType: "nepi_interfaces/DeviceLSXStatus",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }

  setupRUISettingsListener() {
    this.addListener({
      name: "rui_config_mgr/settings",
      messageType: "nepi_interfaces/RUISettings",
      callback: message => {
        this.streamingImageQuality = message.streaming_image_quality
        this.nepiLinkHbAutoDataOffloadingCheckboxVisible = message.nepi_hb_auto_offload_visible
      }
    })
  }


  @action.bound
  setupIDXStatusListener(idxDeviceNamespace, callback) {
    if (idxDeviceNamespace) {
      return this.addListener({
        name: idxDeviceNamespace + "/status",
        messageType: "nepi_interfaces/DeviceIDXStatus",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }

  @action.bound
  setupNPXStatusListener(npxDeviceNamespace, callback) {
    if (npxDeviceNamespace) {
      return this.addListener({
        name: npxDeviceNamespace + "/status",
        messageType: "nepi_interfaces/DeviceNPXStatus",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }



  @action.bound
  setupSaveDataStatusListener(namespace, callback) {
    if (namespace) {
      return this.addListener({
        name: namespace + "/status",
        messageType: "nepi_interfaces/SaveDataStatus",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }

  @action.bound
  setupSettingsStatusListener(namespace, callback) {
    if (namespace) {
      return this.addListener({
        name: namespace,
        messageType: "nepi_interfaces/SettingsStatus",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }

  @action.bound
  setupFrame3DTransformListener(namespace, callback) {
    if (namespace) {
      return this.addListener({
        name: namespace,
        messageType: "nepi_interfaces/Frame3DTransform",
        noPrefix: true,
        callback: callback,
        manageListener: false
      })
    }
  }



  /*******************************/
  // Generic Send Data Functions
  /*******************************/
  @action.bound
  sendTriggerMsg(namespace) {
    this.publishMessage({
      name: namespace,
      messageType: "std_msgs/Empty",
      data: {},
      noPrefix: true
    })
  }

  @action.bound
  sendBoolMsg(namespace, value) {
    this.publishMessage({
      name: namespace,
      messageType: "std_msgs/Bool",
      data: {data: value},
      noPrefix: true
    })
    
  }

  @action.bound
  sendStringMsg(namespace,str) {
    this.publishMessage({
      name: namespace,
      messageType: "std_msgs/String",
      data: {'data':str},
      noPrefix: true
    })
  }

  @action.bound
  sendStringArrayMsg(namespace,strArray) {
    this.publishMessage({
      name: namespace,
      messageType: "nepi_interfaces/StringArray",
      data: {'entries':strArray},
      noPrefix: true
    })
  }


  @action.bound
  sendIntMsg(namespace, int_str) {
    let intVal = parseInt(int_str, 10)
    if (!isNaN(intVal)) {
      this.publishMessage({
        name: namespace,
        messageType: "std_msgs/Int32",
        data: {data: intVal},
        noPrefix: true
      })
    }
  }

  @action.bound
  sendInt8Msg(namespace, int_str) {
    let intVal = parseInt(int_str, 10)
    if (!isNaN(intVal)) {
      this.publishMessage({
        name: namespace,
        messageType: "std_msgs/Int8",
        data: {data: intVal},
        noPrefix: true
      })
    }
  }

  @action.bound
  sendFloatMsg(namespace, float_str) {
    let floatVal = parseFloat(float_str)
    if (!isNaN(floatVal)) {
      this.publishMessage({
        name: namespace,
        messageType: "std_msgs/Float32",
        data: {data: floatVal},
        noPrefix: true
      })
    }
  }


  @action.bound
  sendErrorBoundsMsg(namespace, max_m,max_d,min_stab) {
    this.publishMessage({
      name: namespace,
      messageType: "nepi_interfaces/ErrorBounds",
      data: { 
        data: {
          max_distance_error_m: max_m,
          max_rotation_error_deg: max_d,
          min_stabilize_time_s: min_stab
        }
      },
      noPrefix: true
    })
  }

  @action.bound
  sendUpdateOptionMsg(namespace, comp_name, option_str) {
    this.publishMessage({
      name: namespace,
      messageType: "nepi_interfaces/UpdateOption",

        data: {
        name: comp_name,
        option_str: option_str
      },
      noPrefix: true
    })
  }

  @action.bound
  sendUpdateOrderMsg(namespace, comp_name, move_cmd) {
    this.publishMessage({
      name: namespace,
      messageType: "nepi_interfaces/UpdateOrder",
      data: {    
        name: comp_name,
        move_cmd: move_cmd
      },
      noPrefix: true
    })
  }

  @action.bound
  sendUpdateStateMsg(namespace, comp_name, active_state) {
    this.publishMessage({
      name: namespace,
      messageType: "nepi_interfaces/UpdateState",
      data: {
        name: comp_name,
        active_state: active_state
      },
      noPrefix: true
    })
  }

  @action.bound
  sendUpdateRatioMsg(namespace, comp_name, ratio) {
    this.publishMessage({
      name: namespace,
      messageType: "nepi_interfaces/UpdateRatio",
      data: {
        name: comp_name,
        active_state: ratio
      },
      noPrefix: true
    })
  }

  @action.bound
  sendUpdateRangeWindowMsg(namespace, comp_name, min, max, throttle = true) {
    if (throttle){
      if (throttle && this.isThrottled()) {
        return
      }
    }
    if (namespace) {
      this.publishMessage({
        name: namespace,
        messageType: "nepi_interfaces/UpdateRangeWindow",
        noPrefix: true,
        data: {
          name: comp_name,
          start_range: min,
          stop_range: max
        }
      })
    } else {
      console.warn("publishRangeWindow: namespace not set")
    }
  }

  @action.bound
  sendImageSelectionMsg(namespace, image_index, image_topic) {
    this.publishMessage({
      name: namespace,
      messageType: "nepi_interfaces/ImageSelection",
      data: {
        image_index: image_index,
        image_topic: image_topic
      },
      noPrefix: true
    })
  }



  @action.bound
  sendFloatVector3Msg(namespace, float1_str,float2_str,float3_str) {
    let float1Val = parseFloat(float1_str)
    let float2Val = parseFloat(float2_str)
    let float3Val = parseFloat(float3_str)
    if (!isNaN(float1Val) && !isNaN(float2Val) && !isNaN(float3Val)) {
      this.publishMessage({
        name: namespace,
        messageType: "geometry_msgs/Vector3",
        data: { 
          x: float1Val,
          y: float2Val,
          z: float3Val
        },
        noPrefix: true
      })
    }
  }


  @action.bound
  sendGeoPointMsg(namespace, lat_str,long_str,alt_str) {
    let latVal = parseFloat(lat_str)
    let longVal = parseFloat(long_str)
    let altVal = parseFloat(alt_str)
    if (!isNaN(latVal) && !isNaN(longVal) && !isNaN(altVal)) {
      this.publishMessage({
        name: namespace,
        messageType: "geographic_msgs/GeoPoint",
        data: { 
          latitude: latVal,
          longitude: longVal,
          altitude: altVal
        },
        noPrefix: true
      })
    }
  }

  @action.bound
  sendFloatGotoPoseMsg(namespace, float1_str,float2_str,float3_str) {
    let float1Val = parseFloat(float1_str)
    let float2Val = parseFloat(float2_str)
    let float3Val = parseFloat(float3_str)
    if (!isNaN(float1Val) && !isNaN(float2Val) && !isNaN(float3Val)) {
      this.publishMessage({
        name: namespace,
        messageType: "nepi_interfaces/GotoPose",
        data: { 
          roll_deg: float1Val,
          pitch_deg: float2Val,
          yaw_deg: float3Val
        },
        noPrefix: true
      })
    }
  }

  @action.bound
  sendFloatGotoPositionMsg(namespace, float1_str,float2_str,float3_str,float4_str) {
    let float1Val = parseFloat(float1_str)
    let float2Val = parseFloat(float2_str)
    let float3Val = parseFloat(float3_str)
    let float4Val = parseFloat(float4_str)
    if (!isNaN(float1Val) && !isNaN(float2Val) && !isNaN(float3Val) && !isNaN(float4Val)) {
      this.publishMessage({
        name: namespace,
        messageType: "nepi_interfaces/GotoPosition",
        data: { 
          x_meters: float1Val,
          y_meters: float2Val,
          z_meters: float3Val,
          yaw_deg: float4Val
        },
        noPrefix: true
      })
    }
  }

  @action.bound
  sendFloatGotoLocationMsg(namespace, float1_str,float2_str,float3_str,float4_str) {
    let float1Val = parseFloat(float1_str)
    let float2Val = parseFloat(float2_str)
    let float3Val = parseFloat(float3_str)
    let float4Val = parseFloat(float4_str)
    if (!isNaN(float1Val) && !isNaN(float2Val) && !isNaN(float3Val) && !isNaN(float4Val)) {
      this.publishMessage({
        name: namespace,
        messageType: "nepi_interfaces/GotoLocation",
        data: { 
          lat: float1Val,
          long: float2Val,
          altitude_meters: float3Val,
          yaw_deg: float4Val
        },
        noPrefix: true
      })
    }
  }

  /*******************************/
  // Custom Send Data Functions
  /*******************************/




///// Node IF Calls

@action.bound
saveConfigTriggered(namespace) {
  this.publishMessage({
    name: namespace + "/save_config",
    messageType: "std_msgs/Empty",
    data: {},
    noPrefix: true
  })
}


@action.bound
sendSaveConfigTrigger(namespace) {
  this.publishMessage({
    name: namespace + "/save_config",
    messageType: "std_msgs/Empty",
    data: {},
    noPrefix: true
  })
}


///// System IF Calls

@action.bound
updateCapSetting(namespace,nameStr,typeStr,optionsStrList,default_value_str) {
  this.publishMessage({
    name: namespace + "/update_setting",
    messageType: "nepi_interfaces/SettingCap",
    data: {type_str:typeStr,
      name_str:nameStr,
      options_list:optionsStrList,
      default_value_str:default_value_str
    },
    noPrefix: true
  })
}

  @action.bound
  updateSetting(namespace,nameStr,typeStr,valueStr) {
    this.publishMessage({
      name: namespace + "/update_setting",
      messageType: "nepi_interfaces/Setting",
      data: {type_str:typeStr,
        name_str:nameStr,
        value_str:valueStr
      },
      noPrefix: true
    })
  }

 
  @action.bound
  updateSaveDataPrefix(namespace,saveDataPrefix) {
    this.publishMessage({
      name: namespace + "/save_data_prefix",
      messageType: "std_msgs/String",
      data: {'data':saveDataPrefix},
      noPrefix: true
    })
  }

  @action.bound
  updateSaveDataRate(namespace,data_product,rate_hz) {
    this.publishMessage({
      name: namespace + "/save_data_rate",
      messageType: "nepi_interfaces/SaveDataRate",
      data: {
        data_product: data_product,
        save_rate_hz: rate_hz,
      },
      noPrefix: true
    })
  }



  
  ///// NavPose IF Calls

  @action.bound
  updateNavPoseTopic(namespace, name, topic, apply_transform, transform_list) {
    const apply_tf = apply_transform ? apply_transform : false
    const transform = transform_list ? 
              (transform_list.length === 7 ? transform_list : [0,0,0,0,0,0,0]) :
              [0,0,0,0,0,0,0]

    this.publishMessage({
      name: namespace,
      messageType: "nepi_interfaces/UpdateNavPoseTopic",
      data: { 
          name: name,
          topic: topic,
          apply_transform: apply_tf,
          transform: {
            translate_vector: {
              x: transform[0],
              y: transform[1],
              z: transform[2]
            },
            rotate_vector: {
              x: transform[3],
              y: transform[4],
              z: transform[5]
            },
            heading_offset: transform[6]
          }
      },
      noPrefix: true
    })
  }  


  @action.bound
  sendNavPoseMsg(namespace,navpose_data){
      this.publishMessage({
        name: namespace + '/set_navpose/',
        messageType: "nepi_interfaces/NavPose",
        data: navpose_data,
        noPrefix: true
      })
    }

    @action.bound
    sendInitNavPoseMsg(namespace,navpose_data){
      this.publishMessage({
        name: namespace + '/set_init_navpose/',
        messageType: "nepi_interfaces/NavPose",
        data: navpose_data,
        noPrefix: true
      })
    }

    @action.bound
    sendNavPoseLocationMsg(namespace,lat,long,init_np){
      var np_msg = this.blankNavPose
      np_msg.has_location = true
      np_msg.time_location = moment.utc().unix()
      np_msg.latitude = parseFloat(lat)
      np_msg.longitude = parseFloat(long)
      const init = init_np ? init_np : false
      if (init === false){
        this.sendNavPoseMsg(namespace,np_msg)
      }
      else {
        this.sendInitNavPoseMsg(namespace,np_msg)
      }
    }

    @action.bound
    sendNavPoseHeadingMsg(namespace,heading,init_np){
      var np_msg = this.blankNavPose
      np_msg.has_heading = true
      np_msg.time_heading = moment.utc().unix()
      np_msg.heading_deg = parseFloat(heading)
      const init = init_np ? init_np : false
      if (init === false){
        this.sendNavPoseMsg(namespace,np_msg)
      }
      else {
        this.sendInitNavPoseMsg(namespace,np_msg)
      }
    }


    @action.bound
    sendNavPoseOrienationMsg(namespace,roll,pitch,yaw,init_np){
      var np_msg = this.blankNavPose
      np_msg.has_orientation = true
      np_msg.time_orientation = moment.utc().unix()
      np_msg.roll_deg = parseFloat(roll)
      np_msg.pitch_deg = parseFloat(pitch)
      np_msg.yaw_deg = parseFloat(yaw)
      const init = init_np ? init_np : false
      if (init === false){
        this.sendNavPoseMsg(namespace,np_msg)
      }
      else {
        this.sendInitNavPoseMsg(namespace,np_msg)
      }
    }



    @action.bound
    sendNavPosePositionMsg(namespace,x,y,z,init_np){
      var np_msg = this.blankNavPose
      np_msg.has_position = true
      np_msg.time_position = moment.utc().unix()
      np_msg.x_m = parseFloat(x)
      np_msg.y_m = parseFloat(y)
      np_msg.z_m = parseFloat(z)
      const init = init_np ? init_np : false
      if (init === false){
        this.sendNavPoseMsg(namespace,np_msg)
      }
      else {
        this.sendInitNavPoseMsg(namespace,np_msg)
      }
    }





    @action.bound
    sendNavPoseAltitudeMsg(namespace,alt,init_np){
      var np_msg = this.blankNavPose
      np_msg.has_altitude = true
      np_msg.time_altitude = moment.utc().unix()
      np_msg.altitude_m = parseFloat(alt)
      const init = init_np ? init_np : false
      if (init === false){
        this.sendNavPoseMsg(namespace,np_msg)
      }
      else {
        this.sendInitNavPoseMsg(namespace,np_msg)
      }
    }


    @action.bound
    sendNavPoseDepthMsg(namespace,depth,init_np){
      var np_msg = this.blankNavPose
      np_msg.has_depth = true
      np_msg.time_depth = moment.utc().unix()
      np_msg.depth_m = parseFloat(depth)
      const init = init_np ? init_np : false
      if (init === false){
        this.sendNavPoseMsg(namespace,np_msg)
      }
      else {
        this.sendInitNavPoseMsg(namespace,np_msg)
      }
    }



    @action.bound
    sendFrame3DTransformMsg(namespace, transformFloatList) {
      if (transformFloatList.length === 7){
        this.publishMessage({
          name: namespace,
          messageType: "nepi_interfaces/Frame3DTransform",
          data: { 
              translate_vector: {
                x: transformFloatList[0],
                y: transformFloatList[1],
                z: transformFloatList[2]
              },
              rotate_vector: {
                x: transformFloatList[3],
                y: transformFloatList[4],
                z: transformFloatList[5]
              },
              heading_offset: transformFloatList[6]
  
          },
          noPrefix: true
        })
      }
    }
  
    
    @action.bound
    sendFrame3DTransformUpdateMsg(namespace, name, transformFloatList) {
      if (transformFloatList.length === 7){
        this.publishMessage({
          name: namespace,
          messageType: "nepi_interfaces/UpdateFrame3DTransform",
          data: { 
            name: name,
            transform: {
              translate_vector: {
                x: transformFloatList[0],
                y: transformFloatList[1],
                z: transformFloatList[2]
              },
              rotate_vector: {
                x: transformFloatList[3],
                y: transformFloatList[4],
                z: transformFloatList[5]
              },
              heading_offset: transformFloatList[6]
            }
          },
          noPrefix: true
        })
      }
    }


  ////////////////////////////////
  /////  Service Calls
  ///////////////////////////////

  async callSystemDefsService() {
    this.systemDefs = await this.callService({
      name: "system_defs_query",
      messageType: "nepi_interfaces/SystemDefs",
      msgKey: "defs"
    })
    this.deviceType = this.systemDefs.device_type
    this.deviceSerial = this.systemDefs.device_sn
    this.systemDefsFirmwareVersion = this.systemDefs.firmware_version
    this.systemDefsDiskCapacityMB = this.systemDefs.disk_capacity
  }

  @action.bound
  async callSaveDataCapabilitiesQueryService(namespace) {
    this.saveDataCaps[namespace] = []
    const capabilities = await this.callService({
      name: namespace + "/capabilities_query",
      messageType: "nepi_interfaces/SaveDataCapabilitiesQuery",  
    })
    this.saveDataCaps[namespace] = capabilities
  }



  @action.bound
  async callSettingsCapabilitiesQueryService(namespace) {
    this.settingCaps[namespace] = []
    const capabilities = await this.callService({
      name: namespace + "/capabilities_query",
      messageType: "nepi_interfaces/SettingsCapabilitiesQuery",  
    })
    this.settingCaps[namespace] = capabilities
  }

  @action.bound
  async callImageCapabilitiesQueryService(namespace) {
    const capabilities = await this.callService({
      name: namespace + "/capabilities_query",
      messageType: "nepi_interfaces/ImageCapabilitiesQuery",  
    })
    this.imageCaps[namespace] = capabilities
  }

  @action.bound
  async callNavPoseCapabilitiesQueryService(namespace) {
    const capabilities = await this.callService({
      name: namespace + "/capabilities_query",
      messageType: "nepi_interfaces/NavPoseCapabilitiesQuery",  
    })
    this.navPoseCapsCaps[namespace] = capabilities
  }
  

  @action.bound
  async callIDXCapabilitiesQueryService(idxDeviceNamespace) {
    const capabilities = await this.callService({
      name: idxDeviceNamespace + "/capabilities_query",
      messageType: "nepi_interfaces/IDXCapabilitiesQuery",  
    })
    this.idxDevices[idxDeviceNamespace] = capabilities
  }


  @action.bound
  async callPTXCapabilitiesQueryService(ptxDeviceNamespace) {
    const capabilities = await this.callService({
      name: ptxDeviceNamespace + "/capabilities_query",
      messageType: "nepi_interfaces/PTXCapabilitiesQuery",
    })
    this.ptxDevices[ptxDeviceNamespace] = capabilities
  }

  @action.bound
  async callLSXCapabilitiesQueryService(lsxDeviceNamespace) {
    const capabilities = await this.callService({
      name: lsxDeviceNamespace + "/capabilities_query",
      messageType: "nepi_interfaces/LSXCapabilitiesQuery",
    })
    this.lsxDevices[lsxDeviceNamespace] = capabilities
  }


  @action.bound
  async callRBXCapabilitiesQueryService(rbxDeviceNamespace) {
    const capabilities = await this.callService({
      name: rbxDeviceNamespace + "/capabilities_query",
      messageType: "nepi_interfaces/RBXCapabilitiesQuery",  
    })
    this.rbxDevices[rbxDeviceNamespace] = capabilities
  }

  @action.bound
  async callNPXCapabilitiesQueryService(npxDeviceNamespace) {
    const capabilities = await this.callService({
      name: npxDeviceNamespace + "/capabilities_query",
      messageType: "nepi_interfaces/NPXCapabilitiesQuery",  
    })
    this.npxDevices[npxDeviceNamespace] = capabilities
  }

  @action.bound
  async callSystemSoftwareStatusQueryService() {
    this.systemSoftwareStatus = await this.callService({
      name: "sw_update_status_query",
      messageType: "nepi_interfaces/SystemSoftwareStatusQuery"
    })
  }

  @action.bound
  async callAppStatusQueryService(appName) {
    const appStatus = await this.callService({
      name: 'apps_mgr/app_status_query',
      messageType: "nepi_interfaces/AppStatusQuery",
      args: {app_name : appName},
    })
    const appNames = this.appNameList
    const appInd = appNames.indexOf(appName)
    if (appInd === -1){
      this.appStatusList.push(appStatus)
      this.appNameList.push(appName)

    }
    else {

      this.appNameList[appInd] = appName
      this.appStatusList[appInd] = appStatus
    }
  }

  @action.bound
  async onInstallFullSysImg(new_img_filename) {
    this.publishMessage({
      name: "install_new_image",
      messageType: "std_msgs/String",
      data: { data: new_img_filename }
    })    
  }

  @action.bound
  async onSwitchActiveInactiveRootfs() {
    this.publishMessage({
      name: "switch_active_inactive_rootfs",
      messageType: "std_msgs/Empty",
      data: {}
    })
  }

  @action.bound
  async onStartSysBackup() {
    this.publishMessage({
      name: "archive_inactive_rootfs",
      messageType: "std_msgs/Empty",
      data: {}
    })
  }  

  async startPollingIPAddrQueryService() {
    const _pollOnce = async () => {
      this.ip_query_response = await this.callService({
        name: "ip_addr_query",
        messageType: "nepi_interfaces/IPAddrQuery"
      })

      if (this.connectedToROS) {
        setTimeout(_pollOnce, 1000)
      }
    }

    _pollOnce()
  }

  async startPollingBandwidthUsageService() {
    const _pollOnce = async () => {
      this.bandwidth_usage_query_response = await this.callService({
        name: "bandwidth_usage_query",
        messageType: "nepi_interfaces/BandwidthUsageQuery",
      })

      if (this.connectedToROS) {
        setTimeout(_pollOnce, 3000)
      }
    }

    _pollOnce()
  }

  async startPollingWifiQueryService() {
    const _pollOnce = async () => {
      this.wifi_query_response = await this.callService({
        name: "wifi_query",
        messageType: "nepi_interfaces/WifiQuery",
      })

      if (this.connectedToROS) {
        setTimeout(_pollOnce, 3000)
      }
    }

    _pollOnce()    
  }

  async startPollingOpEnvironmentQueryService() {
    const _pollOnce = async () => {
      this.opEnv = await this.callService({
        name: "op_environment_query",
        messageType: "nepi_interfaces/OpEnvironmentQuery",
        msgKey: "op_env"
      })

      this.deviceInWater = (this.opEnv === "water")

      if (this.connectedToROS) {
        setTimeout(_pollOnce, 5000)
      }
    }

    _pollOnce()
  }


  startPollingMgrTimeStatusService() {
    const _pollOnce = async () => {
      this.timeStatus = await this.callService({
        name: "time_status_query",
        messageType: "nepi_interfaces/SystemTriggersQuery",
      })

      // if last_ntp_sync is 10y, no sync has happened
      this.clockNTP = false
      const currentlySyncd = this.timeStatus.time_status.currently_syncd
      currentlySyncd &&
      currentlySyncd.length &&
      currentlySyncd.forEach(syncd => {
          if (syncd !== false) {
            this.clockNTP = true
          }
        })
      this.available_timezones = this.timeStatus.available_timezones
      // if last_pps – current_time < 1 second no sync has happened
      this.clockPPS = true
      const lastPPSTS = moment.unix(this.timeStatus.time_status.last_pps).unix()
      this.systemStatusTime = moment.unix(this.timeStatus.time_status.current_time)
      this.systemStatusTimeStr =this.timeStatus.time_status.time_str
      this.systemStatusDateStr = this.timeStatus.time_status.date_str
      this.systemStatusTimezone = this.timeStatus.time_status.timezone
      this.systemStatusTimezoneDesc = this.timeStatus.time_status.timezone_description
      const currTS = this.systemStatusTime && this.systemStatusTime.unix()
      if (currTS && lastPPSTS - currTS < 1) {
        this.clockPPS = false
      }

      if (this.connectedToROS) {
        setTimeout(_pollOnce, 1000)
      }
    }

    _pollOnce()
  }


  async startPollingGetScriptsService() {
    const _pollOnce = async () => {
      this.scripts = await this.callService({
        name: "get_scripts",
        messageType: "nepi_interfaces/GetScriptsQuery"
      })

      if (this.connectedToROS) {
        setTimeout(_pollOnce, 1000)
      }
    }

    _pollOnce()
  }

  async startPollingGetRunningScriptsService() {
    const _pollOnce = async () => {
      this.running_scripts = await this.callService({
        name: "get_running_scripts",
        messageType: "nepi_interfaces/GetRunningScriptsQuery"
      })

      if (this.connectedToROS) {
        setTimeout(_pollOnce, 1000)
      }
    }

    _pollOnce()
  }

  async startLaunchScriptService(item) {
    const _pollOnce = async () => {
      this.launchScript = await this.callService({
        name: "launch_script",
        messageType: "nepi_interfaces/LaunchScript",
        args: {script : item}
      })
    }
    _pollOnce()
  }


  async stopLaunchScriptService(item) {
    const _pollOnce = async () => {
      this.stopScript = await this.callService({
        name: "stop_script",
        messageType: "nepi_interfaces/StopScript",
        args: {script : item}
      })
    }
    _pollOnce()
  }

  async callGetSystemStatsQueryService(item, poll = true) {
    const _pollOnce = async () => {
      this.systemStats = await this.callService({
        name: "get_system_stats",
        messageType: "nepi_interfaces/GetSystemStatsQuery",
        args: {script : this.scriptForPolledStats}
      })

      if (this.connectedToROS && poll) {
        setTimeout(_pollOnce, 1000)
      }
    }

    const firstCall = (this.scriptForPolledStats === null)
    this.scriptForPolledStats = item
    
    // Only launch this once, then just change state to start polling a different script
    if (firstCall === true || !poll) {
      _pollOnce()
    }
    
  }

  @action.bound
  setDeviceID({newDeviceID}) {
    this.publishMessage({
      name: "set_device_id",
      messageType: "std_msgs/String",
      data: { data: newDeviceID }
    })
  }

  @action.bound
  onToggleDeviceInWater() {
    this.deviceInWater = !this.deviceInWater

    let newOpEnv = (this.deviceInWater === true)? "water" : "air"
    this.publishMessage({
      name: "set_op_environment",
      messageType: "std_msgs/String",
      data: { data: newOpEnv }
    })
  }



  @action.bound
  onToggleSyncTimezone() {
    const new_val = !this.syncTimezone
    this.syncTimezone = new_val
    if (new_val === true){
      this.onSyncTimezone()
    }
  }


  get_timezone_desc(){
    var timezone = getLocalTZ()
    timezone = timezone.replace(' ','_')
    return timezone
  }


  @action.bound
  onToggleClockUTCMode() {
    this.clockUTCMode = !this.clockUTCMode
    this.clockTZ = this.get_timezone_desc()
  }

  @action.bound
  onSyncTimezone() {
    this.publishMessage({
      name: "set_time",
      messageType: "nepi_interfaces/TimeUpdate",
      data: {
          update_time: false,
          secs: 0,
          nsecs: 0,
          update_timezone: true,
          timezone: this.get_timezone_desc()
      }
    })
  }

  @action.bound
  setTimezone(timezone) {
    this.publishMessage({
      name: "set_time",
      messageType: "nepi_interfaces/TimeUpdate",
      data: {
          update_time: false,
          secs: 0,
          nsecs: 0,
          update_timezone: true,
          timezone:  timezone
      }
    })
  }

  @action.bound
  setTimezoneUTC() {
    this.publishMessage({
      name: "set_time",
      messageType: "nepi_interfaces/TimeUpdate",
      data: {
          update_time: false,
          secs: 0,
          nsecs: 0,
          update_timezone: true,
          timezone:  'Europe/London'
      }
    })
  }



  @action.bound
  syncTime2Device() {
    const utcTS = moment.utc()
      .unix()
    this.publishMessage({
      name: "set_time",
      messageType: "nepi_interfaces/TimeUpdate",
      data: {
          update_time: true,
          secs: Math.floor(utcTS),
          nsecs: 0,
          update_timezone: false,
          timezone:  ''
      }
    })
  }


  @action.bound
  syncTz2Device() {
    this.clockTZ = this.get_timezone_desc()
    this.publishMessage({
      name: "set_time",
      messageType: "nepi_interfaces/TimeUpdate",
      data: {
          update_time: false,
          secs: 0,
          nsecs: 0,
          update_timezone: true,
          timezone:  this.clockTZ
      }
    })
  }

  @action.bound
  syncTimeTz2Device() {
    const utcTS = moment.utc().unix()
    this.clockTZ = this.get_timezone_desc()
    this.publishMessage({
      name: "set_time",
      messageType: "nepi_interfaces/TimeUpdate",
      data: {
          update_time: true,
          secs: Math.floor(utcTS),
          nsecs: 0,
          update_timezone: true,
          timezone:  this.clockTZ
      }
    })
  }

  @action.bound
  onChangeTriggerRate(rate) {
    let freq = parseFloat(rate)

    if (isNaN(freq)) {
      freq = 0
    }

    this.publishMessage({
      name: "set_periodic_sw_trig",
      messageType: "nepi_interfaces/PeriodicSwTrig",
      data: {
        enabled: freq > 0,
        sw_trig_mask: this.triggerMask,
        rate_hz: freq
      }
    })

    // Update the state variable -- if rejected, will get set back on next periodic update
    // This allows the text entry box to immediately switch to using the state variable
    this.triggerAutoRateHz = freq
  }

  @action.bound
  onChangeTXRateLimit(limit) {
    let lim = parseInt(limit, 10)

    if (isNaN(lim)) {
      lim = -1
    }

    this.publishMessage({
      name: "set_tx_bw_limit_mbps",
      messageType: "std_msgs/Int32",
      data: { data: lim }
    })

    // Update locally for display purposes... will be corrected on next periodic update if value is rejected
    this.bandwidth_usage_query_response.tx_limit_mbps = lim
  }

  @action.bound
  onToggleHWTriggerOutputEnabled(e) {
    const checked = e.target.checked

    // If HW Trig Output Enable selected, trig mask is 0xFFFFFFFF, otherwise trig mask is 0x7FFFFFFF
    this.triggerMask = checked
      ? TRIGGER_MASKS.OUTPUT_ENABLED
      : TRIGGER_MASKS.DEFAULT

    // republish rate change with new mask
    this.onChangeTriggerRate({
      target: {
        value: this.triggerAutoRateHz
      }
    })
  }

  @action.bound
  onToggleHWTriggerInputEnabled(e) {
    const checked = e.target.checked

    this.publishMessage({
      name: "hw_trigger_in_enab",
      messageType: "std_msgs/UInt32",
      data: { data: checked ? this.triggerMask : 0 }
    })
  }

  @action.bound
  onToggleDHCPEnabled(e) {
    const checked = e.target.checked

    this.publishMessage({
      name: "enable_dhcp",
      messageType: "std_msgs/Bool",
      data: { data: checked }
    })

    // Set local immediately, will correct on next update if values is rejected
    this.ip_query_response.dhcp_enabled = checked
  }

  @action.bound
  onToggleWifiAPEnabled(e) {
    const checked = e.target.checked

    this.publishMessage({
      name: "enable_wifi_access_point",
      messageType: "std_msgs/Bool",
      data: { data: checked }
    })
  }

  @action.bound
  onToggleWifiClientEnabled(e) {
    const checked = e.target.checked

    this.publishMessage({
      name: "enable_wifi_client",
      messageType: "std_msgs/Bool",
      data: { data: checked }
    })
  }

  @action.bound
  onUpdateWifiClientCredentials(new_ssid, new_passphrase) {
    this.publishMessage({
      name: "set_wifi_client_credentials",
      messageType: "nepi_interfaces/NetworkWifiCredentials",
      data: { ssid: new_ssid, passphrase: new_passphrase }
    })
  }

  @action.bound
  onUpdateWifiAPCredentials(new_ssid, new_passphrase) {

    this.publishMessage({
      name: "set_wifi_access_point_credentials",
      messageType: "nepi_interfaces/NetworkWifiCredentials",
      data: { ssid: new_ssid, passphrase: new_passphrase }
    })
  }  

  @action.bound
  onRefreshWifiNetworks() {
    this.publishMessage({
      name: "refresh_available_wifi_networks",
      messageType: "std_msgs/Empty",
      data: {}
    })    
  }

  @action.bound
  onGenerateLicenseRequest() {
    if (this.license_server && (this.license_server.readyState === 1)) { // Connected
      this.license_server.send("license_request")
      this.license_request_mode = true
    }
    else {
      this.license_request_mode = false
    }
  }

  @action.bound
  onPressManualTrigger() {
    // Pressing Manual Trigger publishes mask on the sw_trigger topic.
    this.publishMessage({
      name: "sw_trigger",
      messageType: "std_msgs/UInt32",
      data: { data: this.triggerMask }
    })
  }

  @action.bound
  onToggleSaveDataAll(value) {
      this.publishMessage({
      name: "save_data_enable",
      messageType: "std_msgs/Bool",
      data: {data: value},
      noPrefix: true
    })
  }

  @action.bound
  onToggleSaveUTCAll(value) {
      this.publishMessage({
      name: "save_data_utc",
      messageType: "std_msgs/Bool",
      data: {data: value},
      noPrefix: true
    })
  }



  @action.bound
  onChangeSaveFreqAll(rate) {
    let freq = parseFloat(rate)

    if (isNaN(freq)) {
      freq = 0
    }

    this.publishMessage({
      name: "save_data_rate",
      messageType: "nepi_interfaces/SaveDataRate",
      data: {
        data_product: "Active",
        save_rate_hz: freq,
      }
    })

    this.saveFreqHz = freq
  }




  @action.bound
  addIPAddr(addr) {
    this.publishMessage({
      name: "add_ip_addr",
      messageType: "std_msgs/String",
      data: { data: addr }
    })
  }

  @action.bound
  removeIPAddr(addr) {
    this.publishMessage({
      name: "remove_ip_addr",
      messageType: "std_msgs/String",
      data: { data: addr }
    })
  }

  @action.bound
  saveCfg({baseTopic}) {
    this.publishMessage({
      name: baseTopic + "/save_config",
      messageType: "std_msgs/Empty",
      data: {},
      noPrefix: true
    })
  }

  @action.bound
  systemReset(baseTopic, reset_type) {
    this.publishMessage({
      name: baseTopic + "/factory_reset_config",
      messageType: "nepi_interfaces/Reset",
      data: {
        reset_type: reset_type
      },
      noPrefix: true
    })
  }

  @action.bound
  onUserCfgRestore() {
    this.publishMessage({
      name: "full_user_restore",
      messageType: "std_msgs/Empty",
      data: {}
    })
  }

  @action.bound
  onFactoryCfgRestore() {
    this.publishMessage({
      name: "full_factory_restore",
      messageType: "std_msgs/Empty",
      data: {}
    })
  }

  @action.bound
  saveSettingsFilePrefix({newFilePrefix}) {
    this.publishMessage({
      name: "save_data/save_data_prefix",
      messageType: "std_msgs/String",
      data: { data: newFilePrefix }
    })
  }

  @action.bound
  deleteAllData() {
    this.publishMessage({
      name: "clear_data_folder",
      messageType: "std_msgs/Empty",
      data: {}
    })
  }

  @action.bound
  onToggleAutoStartEnabled(autoStartScriptName, isEnabled) {
    this.publishMessage({
      name: "enable_script_autostart",
      messageType: "nepi_interfaces/AutoStartEnabled",
      data: { 
        script: autoStartScriptName,
        enabled: isEnabled
       }
    })
  }

  // Control methods //////////////////////////////////////////////
  @action.bound
  isThrottled() {
    var now = new Date()
    if (now - this.lastUpdate < UPDATE_PERIOD) {
      return true
    }
    this.lastUpdate = now
    return false
  }
  
  @action.bound
  publishValue(
    topic,
    msgType,
    value,
    throttle = true,
    noPrefix = false,
  ) {
    if (throttle && this.isThrottled()) {
      return
    }

    this.publishMessage({
      name: topic,
      messageType: msgType,
      data: {data: Number(value)},
      noPrefix: noPrefix,
    })
  }


  @action.bound
  publishRangeWindow(topic, min, max, throttle = true) {
    if (throttle){
      if (throttle && this.isThrottled()) {
        return
      }
    }
    if (topic) {
      this.publishMessage({
        name: topic,
        messageType: "nepi_interfaces/RangeWindow",
        noPrefix: true,
        data: {
          start_range: min,
          stop_range: max
        }
      })
    } else {
      console.warn("publishRangeWindow: topic not set")
    }
  }



  /////////////////////////////////////////////////////////////////////////

  // Image Control methods /////////////////////////////////////////////
 

  @action.bound
  onChangeStreamingImageQuality(quality) {
    this.streamingImageQuality = quality
    this.publishMessage({
      name: "rui_config_mgr/set_streaming_image_quality",
      messageType: "std_msgs/UInt8",
      data: { data: quality }
    })
  }


  /////////////////////////////////////////////////////////////////////////
  // Nav/Pose Control methods /////////////////////////////////////////////




  /////////////////////////////////////////////////////////////////////////

  // PTX
  @action.bound
  onPTXGoHome(ptxNamespace) {
    this.publishMessage({
      name: ptxNamespace + "/go_home",
      messageType: "std_msgs/Empty",
      data: {},
      noPrefix: true
    })    
  }

  @action.bound
  onPTXSetHomeHere(ptxNamespace) {
    this.publishMessage({
      name: ptxNamespace + "/set_home_position_here",
      messageType: "std_msgs/Empty",
      data: {},
      noPrefix: true
    })    
  }  


  @action.bound
  onPTXStop(ptxNamespace) {
    this.publishMessage({
      name: ptxNamespace + "/stop_moving",
      messageType: "std_msgs/Empty",
      data: {},
      noPrefix: true
    }) 
  }

  @action.bound
  onSetPTXHomePos(ptxNamespace, panHomePos, tiltHomePos) {
    this.publishMessage({
      name: ptxNamespace + "/set_home_position",
      messageType: "nepi_interfaces/PanTiltPosition",
      data: {"pan_deg": panHomePos, "tilt_deg": tiltHomePos},
      noPrefix: true
    })
  }

  @action.bound
  onSetPTXGotoPos(ptxNamespace, panPos, tiltPos) {
    this.publishMessage({
      name: ptxNamespace + "/goto_position",
      messageType: "nepi_interfaces/PanTiltPosition",
      data: {"pan_deg": panPos, "tilt_deg": tiltPos},
      noPrefix: true
    })
  }

  @action.bound
  onSetPTXGotoPanPos(ptxNamespace, panPos) {
    this.publishMessage({
      name: ptxNamespace + "/goto_pan_position",
      messageType: "std_msgs/Float32",
      data: {"data": panPos},
      noPrefix: true
    })
  }

  @action.bound
  onSetPTXGotoTiltPos(ptxNamespace, tiltPos) {
    this.publishMessage({
      name: ptxNamespace + "/goto_tilt_position",
      messageType: "std_msgs/Float32",
      data: {"data": tiltPos},
      noPrefix: true
    })
  }

  @action.bound
  onSetPTXSoftStopPos(ptxNamespace, panMin, panMax, tiltMin, tiltMax) {
    this.publishMessage({
      name: ptxNamespace + "/set_soft_limits",
      messageType: "nepi_interfaces/PanTiltLimits",
      data: {"min_pan_deg": panMin,
             "max_pan_deg": panMax,
             "min_tilt_deg": tiltMin,
             "max_tilt_deg": tiltMax},
      noPrefix: true
    })
  }

  @action.bound
  onSetPTXHardStopPos(ptxNamespace, panMin, panMax, tiltMin, tiltMax) {
    this.publishMessage({
      name: ptxNamespace + "/set_hard_limits",
      messageType: "nepi_interfaces/PanTiltLimits",
      data: {"min_pan_deg": panMin,
             "max_pan_deg": panMax,
             "min_tilt_deg": tiltMin,
             "max_tilt_deg": tiltMax},
      noPrefix: true
    })
  }

  @action.bound
  onPTXJogPan(ptxNamespace, direction) {
    this.publishMessage({
      name: ptxNamespace + "/jog_timed_pan",
      messageType: "nepi_interfaces/SingleAxisTimedMove",
      data: {"direction": direction,
             "duration_s": -1},
      noPrefix: true
    })
  }

  @action.bound
  onPTXJogTilt(ptxNamespace, direction) {
    this.publishMessage({
      name: ptxNamespace + "/jog_timed_tilt",
      messageType: "nepi_interfaces/SingleAxisTimedMove",
      data: {"direction": direction,
             "duration_s": -1},
      noPrefix: true
    })
  }

  
  @action.bound
  onLSXSetStandby(lsxNamespace, enable) {
    this.publishMessage({
      name: lsxNamespace + "/set_standby",
      messageType: "std_msgs/Bool",
      data: {"data" : enable},
      noPrefix: true
    })
  }

  @action.bound
  onLSXSetStrobeEnable(lsxNamespace, enable) {
    this.publishMessage({
      name: lsxNamespace + "/set_strobe_enable",
      messageType: "std_msgs/Bool",
      data: {"data" : enable},
      noPrefix: true
    })
  }

}
const stores = {
  ros: new ROSConnectionStore(),
}

export default stores
