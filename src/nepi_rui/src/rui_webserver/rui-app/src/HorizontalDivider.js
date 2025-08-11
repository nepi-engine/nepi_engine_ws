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
    marginTop: Styles.vars.spacing.medium,
    marginBottom: Styles.vars.spacing.medium
  },
  horizontalDivider: {
    backgroundColor: Styles.vars.colors.grey1,
    width: "100%",
    height: "1px"
  }
})

const HorizontalDivider = ({ name, children }) => {
  return (
    <div style={styles.root}>
      <div style={styles.horizontalDivider} />
    </div>
  )
}

export default HorizontalDivider
