/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React from "react"

import Styles from "./Styles"

const styles = Styles.Create({
  root: {
    color: Styles.vars.colors.black
  },
  disabled: {
    backgroundColor: Styles.vars.colors.orange
  }
})

const Input = props => {
  const { style, children, disabled, backgroundOverride, type } = props

  const actualStyle = {
    ...styles.root,
    ...style,
    ...(disabled ? styles.disabled : {}),
    ...(backgroundOverride? {backgroundColor: backgroundOverride} : {})
  }

  const actualType = type? type : "text"

  return (
    <input {...props} style={actualStyle} type={actualType}>
      {children}
    </input>
  )
}

Input.defaultProps = {
  disabled: false,
  backgroundOverride: null
}

export default Input
