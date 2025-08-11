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
    marginTop: Styles.vars.spacing.regular
  },
  labelTitle: {
    flex: 1,
    textAlign: "left"
  },
  rightLabelTitle: {
    flex: 1,
    textAlign: "right"
  },

  container: {
    flex: 1,
    textAlign: "right"
  }
})

const Label = ({ marginLeft, title, children, alignRight, labelStyle}) => {
    const alignmentStyle = alignRight? styles.rightLabelTitle : styles.labelTitle
    const actualStyle = {
      ...alignmentStyle,
      ...labelStyle
    }
  return (
    <div style={{ display: "flex", ...styles.root, marginLeft: marginLeft}}>
      <label style={actualStyle}>{title}</label>
      <div style={styles.container}>{children}</div>
    </div>
  )
}

export default Label
