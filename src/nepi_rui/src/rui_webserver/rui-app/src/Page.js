/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React from "react"
import { TypographyStyle, GoogleFont } from "react-typography"
import Typography from "typography"
import theme from "./Theme"

import Styles from "./Styles"

const typography = new Typography({
  ...theme,
  baseFontSize: Styles.vars.fontSize.regular,
  baseLineHeight: Styles.vars.lineHeights.regular,
  blockMarginBottom: 0.5,
  scaleRatio: 1.5,
  overrideStyles: ({ adjustFontSizeTo, rhythm }, options, styles) => ({
    "*": {
      color: Styles.vars.colors.white
    }
  })
})

const styles = Styles.Create({
  container: {
    backgroundColor: Styles.vars.colors.default_dark,
    maxWidth: Styles.vars.pageWidth,
    margin: "0 auto",
    padding: Styles.vars.spacing.large
  }
})

const Page = ({ children }) => {
  return (
    <React.Fragment>
      <TypographyStyle typography={typography} />
      <GoogleFont typography={typography} />
      <div style={styles.container}>{children}</div>
    </React.Fragment>
  )
}

export default Page
