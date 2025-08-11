/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React, { Component } from "react"
import Section from "./Section"
import Label from "./Label"
import Input from "./Input"
import Button, { ButtonMenu } from "./Button"

const PASSWORD = "numurus"

class PageLock extends Component {
  constructor(props) {
    super(props)

    this.state = {
      passwordValue: ""
    }

    this.onUpdatePassword = this.onUpdatePassword.bind(this)
    this.handleKeyPress = this.handleKeyPress.bind(this)
    this.checkLock = this.checkLock.bind(this)
  }

  onUpdatePassword(e) {
    const passwordValue = e.target.value
    this.setState({ passwordValue })
  }

  handleKeyPress(e) {
    if (e.key === "Enter") {
      this.checkLock()
    }
  }

  checkLock() {
    if (this.state.passwordValue === PASSWORD) {
      this.props.onUnlockPage()
    }
  }

  render() {
    const { passwordValue } = this.state
    return (
      <React.Fragment>
        <Section title={"Page locked"}>
          <Label title={"Please enter the password to unlock the page"}>
            <Input
              type={"password"}
              value={passwordValue}
              onChange={this.onUpdatePassword}
              onKeyPress={this.handleKeyPress}
            />
          </Label>
          <ButtonMenu>
            <Button onClick={this.checkLock}>{"Check password"}</Button>
          </ButtonMenu>
        </Section>
      </React.Fragment>
    )
  }
}

export default PageLock
