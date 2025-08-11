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
    textAlign: "left",
    marginTop: Styles.vars.spacing.regular,
    padding: Styles.vars.spacing.regular,
    border: `1px solid ${Styles.vars.colors.grey1}`
  },
  sectionTitle: {
    fontSize: Styles.vars.fontSize.regular,
    textTransform: "uppercase",
    fontWeight: "bold",
    marginBottom: Styles.vars.spacing.regular
  }
})

const Section = ({ title, children }) => {
  return (
    <div style={styles.root}>
      <div style={styles.sectionTitle}>{title}</div>
      <div>{children}</div>
    </div>
  )
}

export default Section
