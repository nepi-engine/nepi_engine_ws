/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */


import React from "react"
import { Option } from "./Select"
import Styles from "./Styles"


/////////////////////////////
// MISC FUNCTIONS

export function doNothing(){
  var ret = false
  return ret
}

export function round(value, decimals = 0) {
  return Number(value).toFixed(decimals)
  //return value && Number(Math.round(value + "e" + decimals) + "e-" + decimals)
}

export function convertStrToStrList(inputStr) {
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

export function filterStrList(inputList,filterList) {
  var outputList = []
  for (var i = 0; i < inputList.length; ++i) {
    var filter_check = false
    for (var j = 0; j < filterList.length; ++j) {
      if (inputList[i].indexOf(filterList[j]) !== -1) {
        filter_check = true
      }
    }
    if (filter_check === false){
      outputList.push(inputList[i])
    }
  }
  return outputList
}


export class Queue {
  constructor() {
      this.items = []
      this.frontIndex = 0
      this.backIndex = 0
  }
  pushItem(item) {
      this.items[this.backIndex] = item
      this.backIndex++
      return item + ' inserted'
  }
  pullItem() {
      var item = ""
      if (this.frontIndex < this.backIndex){
        item = this.items[this.frontIndex]
        delete this.items[this.frontIndex]
        this.frontIndex++
      }
      return item
  }
  clearItems(){
    var queue_length = this.getLength()
    while ( queue_length > 0 ){
      this.pullItem()
      queue_length = this.getLength()
    }
  }
  getItems(){
    return this.items.slice(this.frontIndex,this.backIndex)
  }
  getLength(){
    return this.backIndex - this.frontIndex
  }
  peek() {
      return this.items[this.frontIndex]
  }
  get printQueue() {
      return this.items;
  }
}

/////////////////////////////
// TOGGLE FUNCTIONS

export function onChangeSwitchStateValue(stateVarNameStr,currentVal){
  var key = stateVarNameStr
  var value = currentVal === false
  var obj  = {}
  obj[key] = value
  this.setState(obj)
}

export function onChangeSwitchStateNestedValue(parentKey, nestedKey, currentVal) {
  var value = currentVal === false;
  
  this.setState({
    [parentKey]: {
      ...this.state[parentKey],
      [nestedKey]: {
        ...this.state[parentKey][nestedKey],
        fixed: value
      }
    }
  });
}

/////////////////////////////
// MENU FUNCTIONS

export function createShortValues(list) {
  var tokenizedList = []
  var depthsToShort = 2
  var shortList = []
  for (var i = 0; i < list.length; ++i) {
    tokenizedList.push(list[i].split("/").reverse())
  }
  // Now create the return list
  for (i = 0; i < tokenizedList.length; ++i) {
    shortList.push(tokenizedList[i].slice(0, depthsToShort).reverse().join("/"))
  }
  return shortList
}

export function createShortUniqueValues(list) {
  var tokenizedList = []
  var depthsToUnique = []
  var uniqueList = []
  for (var i = 0; i < list.length; ++i) {
    tokenizedList.push(list[i].split("/").reverse())
    depthsToUnique.push(1)
    const newItemIndex = tokenizedList.length - 1 
    for (var j = 0; j < tokenizedList.length - 1; ++j) {
      var currentTestDepth = 0
      while (tokenizedList[j][currentTestDepth] === tokenizedList[newItemIndex][currentTestDepth]) {
        currentTestDepth += 1
        if (currentTestDepth >= depthsToUnique[j]) {
          depthsToUnique[j] += 1
        }
        if (currentTestDepth >= depthsToUnique[newItemIndex]) {
          depthsToUnique[newItemIndex] += 1
        }
      }
    }
  }
  // Now create the return list
  for (i = 0; i < tokenizedList.length; ++i) {
    uniqueList.push(tokenizedList[i].slice(0, depthsToUnique[i]).reverse().join("/"))
  }
  return uniqueList
}


export function createShortValuesFromNamespaces(namespacesList) {
  var tokenizedList = []
  var outputList = []
  var shortName = ''
  for (var i = 0; i < namespacesList.length; ++i) {
      tokenizedList = namespacesList[i].slice(1).split("/")
      var tokens_len = tokenizedList.length
      if(tokenizedList.length === 2){
        shortName = tokenizedList[1]
      }     
      if(tokenizedList.length === 3){
        shortName = tokenizedList[2]
      }
      else if(tokenizedList.length === 4){
        shortName = tokenizedList[2] + "/" + tokenizedList[3]
      }
      else if(tokenizedList.length === 5){
        shortName = tokenizedList[3] + "/" + tokenizedList[4]
      }
      else {
        shortName = tokenizedList[tokens_len-3] + "/" + tokenizedList[tokens_len-1]
      }
      outputList.push(shortName)
  }
  return outputList
}

export function createShortImagesFromNamespaces(baseNamespace,namespacesList) {
  const filterList = [baseNamespace + '/' , 'idx/', 'ptx/', 'rbx/' , 'lsx/', 'npx/', 'ai/' ]
  var outputList = []
  var shortName = ""
  for (var i = 0; i < namespacesList.length; ++i) {
      shortName = namespacesList[i]
      for (var i2 = 0; i2 < filterList.length; ++i2) {
        shortName = shortName.replace(filterList[i2],"")
      }
      outputList.push(shortName)
    }
  return outputList
}

export function createShortImageFromNamespace(baseNamespace,namespace) {
  const filterList = [baseNamespace + '/', 'idx/', 'ptx/', 'rbx/' , 'lsx/', 'npx/', 'ai/' ]
  var shortName = ""
  for (var i2 = 0; i2 < filterList.length; ++i2) {
    shortName = shortName.replace(filterList[i2],"")
  }
  return shortName
}


export function createMenuListFromStrList(optionsStrList, useShortNames, filterOut, prefixOptionsStrList, appendOptionsStrList) {
  var filteredTopics = []
  var i
  if (filterOut) {
    for (i = 0; i < optionsStrList.length; i++) {
        if (filterOut.includes(optionsStrList[i]) === false){
          filteredTopics.push(optionsStrList[i])
        }
    }
  }
  var unique_names = null
  if (useShortNames === true){
    unique_names = createShortValuesFromNamespaces(filteredTopics)
  } 
  else{
    unique_names = filteredTopics
  }
  var menuList = []
  for (i = 0; i < prefixOptionsStrList.length; i++) {
      let option = prefixOptionsStrList[i]
      menuList.push(<Option value={option}>{option}</Option>)
  }

  for (i = 0; i < filteredTopics.length; i++) {
    menuList.push(<Option value={filteredTopics[i]}>{unique_names[i]}</Option>)
  }

  for (i = 0; i < appendOptionsStrList.length; i++) {
    let option = appendOptionsStrList[i]
    menuList.push(<Option value={option}>{option}</Option>)
  }

   return menuList
}


export function onDropdownSelectedSetState(event, stateVarStr) {
  var key = stateVarStr
  var value = event.target.value
  var obj  = {}
  obj[key] = value
  this.setState(obj)
}


export function onDropdownSelectedSendStr(event, namespace) {
  const {sendStringMsg} = this.props.ros
  const value = event.target.value
  sendStringMsg(namespace,value)
}

export function onDropdownSelectedSendIndex(event, namespace) {
  const {sendIntMsg} = this.props.ros
  const value = event.target.value
  if (value !== "None") {
    const index = event.target.selectedIndex
    sendIntMsg(namespace,index)
  }
}

export function onDropdownSelectedSendIndex8(event, namespace) {
  const {sendInt8Msg} = this.props.ros
  const value = event.target.value
  if (value !== "None") {
    const index = event.target.selectedIndex
    sendInt8Msg(namespace,index)
  }
}

export function onDropdownSelectedSendDriverOption(event, namespace) {
  const {driverUpdateOptionMsg} = this.props.ros
  const driver_name = this.state.driver_name
  const option_str = event.target.value
  driverUpdateOptionMsg(namespace, driver_name, option_str)
}

/////////////////////////////
// INPUT BOX FUNCTIONS

export function onUpdateSetStateValue(event,stateVarStr) {
  var key = stateVarStr
  var value = event.target.value
  var obj  = {}
  obj[key] = value
  this.setState(obj)
  document.getElementById(event.target.id).style.color = Styles.vars.colors.red
  this.render()
}

export function onUpdateSetStateNestedValue(event,stateVarStr) {
  var key = stateVarStr
  var value = event.target.value
  var obj  = {}
  obj[key] = value
  this.setState(obj)
  document.getElementById(event.target.id).style.color = Styles.vars.colors.red
  this.render()
}






export function onEnterSendIntValue(event, namespace) {
  const {sendIntMsg} = this.props.ros
  if(event.key === 'Enter'){
    const value = parseInt(event.target.value, 10)
    if (!isNaN(value)){
      sendIntMsg(namespace,value)
    }
    document.getElementById(event.target.id).style.color = Styles.vars.colors.black
  }
}


export function onEnterSendFloatValue(event, namespace) {
  const {sendFloatMsg} = this.props.ros
  if(event.key === 'Enter'){
    const value = parseFloat(event.target.value)
    if (!isNaN(value)){
      sendFloatMsg(namespace,value)
    }
    document.getElementById(event.target.id).style.color = Styles.vars.colors.black
  }
}

export function onEnterSetStateFloatValue(event, stateVarStr) {
  if(event.key === 'Enter'){
    const value = parseFloat(event.target.value)
    if (!isNaN(value)){
      var key = stateVarStr
      var obj  = {}
      obj[key] = value
      this.setState(obj)
    }
    document.getElementById(event.target.id).style.color = Styles.vars.colors.black
  }
}

export function onUpdateSetStateNestedFloatValue(component, event, stateVarStr) {
  const rawVal = event.target.value;
  const floatVal = parseFloat(rawVal);
  const value = isNaN(floatVal) ? rawVal : floatVal;

  const keys = stateVarStr.split('.');
  const lastKey = keys.pop();

  const newState = { ...component.state };
  let ref = newState;

  for (let key of keys) {
    ref[key] = { ...ref[key] };
    ref = ref[key];
  }

  ref[lastKey] = value;
  component.setState(newState);

  const input = document.getElementById(event.target.id);
  if (input) input.style.color = isNaN(floatVal) ? 'red' : 'black';
}

/////////////////////////////
// STYLE FUNCTIONS
export function setElementStyleModified(e) {
  e.style.color = Styles.vars.colors.red
  e.style.fontWeight = "bold"
}

export function clearElementStyleModified(e) {
  e.style.color = Styles.vars.colors.black
  e.style.fontWeight = "normal"
}


