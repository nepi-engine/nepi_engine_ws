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
import Input from "./Input"
import Button from "./Button"

const styles = Styles.Create({
  base: {
      cursor: "default",
      width: Styles.vars.lineHeights.small,
      height: Styles.vars.lineHeights.small
    }
})

export const indicator_colors = Styles.Create({
  red: {
    backgroundColor: Styles.vars.colors.red,
    color: Styles.vars.colors.black
  },
  green: {
    backgroundColor: Styles.vars.colors.green,
    color: Styles.vars.colors.black
  },
  grey: {
    backgroundColor: Styles.vars.colors.grey1,
    color: Styles.vars.colors.black
  },
  orange: {
    backgroundColor: Styles.vars.colors.orange,
    color: Styles.vars.colors.black
  },
  white_on_black: {
    backgroundColor: Styles.vars.colors.black,
    color: Styles.vars.colors.white
  }
})

export const ColoredIndicator = props => {
  const { indicator_color, style } = props

  const actualStyle = {
    ...styles.base,
    ...indicator_color,
    ...style
  }

  return (
    <Button {...props} style={actualStyle} disabled>
      {" "}
    </Button>
  )
}

export const ColoredTextIndicator = props => {
  const { indicator_color, style, text } = props

  const actualStyle = {
    ...styles.base,
    ...indicator_color,
    ...style
  }

  return (
    <Input {...props} style={actualStyle} disabled={true} backgroundOverride={indicator_color.backgroundColor} value={text}/>
  )

}
