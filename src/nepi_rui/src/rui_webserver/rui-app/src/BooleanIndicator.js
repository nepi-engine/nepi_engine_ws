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
import Button from "./Button"

const styles = Styles.Create({
  base: {
    cursor: "default",
    width: Styles.vars.lineHeights.small,
    height: Styles.vars.lineHeights.small
  },
  true: {
    backgroundColor: Styles.vars.colors.green
  },
  false: {
    backgroundColor: Styles.vars.colors.grey1
  }
})

const BooleanIndicator = props => {
  const { value, style } = props

  const actualStyle = {
    ...styles.base,
    ...(value ? styles.true : styles.false),
    ...style
  }

  return (
    <Button {...props} style={actualStyle} disabled>
      {" "}
    </Button>
  )
}

export default BooleanIndicator
