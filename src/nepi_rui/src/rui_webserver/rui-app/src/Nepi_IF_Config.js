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


import Button, { ButtonMenu } from "./Button"
import { Columns, Column } from "./Columns"
import Label from "./Label"
import Styles from "./Styles"


function round(value, decimals = 0) {
  return Number(value).toFixed(decimals)
  //return value && Number(Math.round(value + "e" + decimals) + "e-" + decimals)
}

@inject("ros")
@observer
class NepiIFConfig extends Component {
  constructor(props) {
    super(props)

  }


  render() {
    const namespace = this.props.namespace ? this.props.namespace : 'None'

    if (namespace === 'None'){
      return (
  
        <Columns>
          <Column>
  
  
          </Column>
        </Columns>
      )
    }

    else {

        return (

          <Columns>
          <Column>
                  <div style={{ borderTop: "1px solid #ffffff", marginTop: Styles.vars.spacing.medium, marginBottom: Styles.vars.spacing.xs }}/>

                  <Columns>
                    <Column>


                      <ButtonMenu>
                          <Button onClick={() => this.props.ros.sendTriggerMsg(namespace + "/save_config")}>{"Save"}</Button>
                    </ButtonMenu>


                      </Column>
                    <Column>


                    <ButtonMenu>
                        <Button onClick={() => this.props.ros.sendTriggerMsg( namespace + "/reset_config")}>{"Reset"}</Button>
                      </ButtonMenu>

                    </Column>
                    <Column>

                    <ButtonMenu>
                          <Button onClick={() => this.props.ros.sendTriggerMsg( namespace + "/factory_reset_config")}>{"Factory"}</Button>
                    </ButtonMenu>


                    </Column>
                  </Columns>
          </Column>
          </Columns>
        )
      }
  }

}
export default NepiIFConfig
