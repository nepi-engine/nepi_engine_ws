/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React from "react"
import {Link} from "react-router-dom"

import Styles from "./Styles"

const styles = Styles.Create({
    link_style: {
      color: Styles.vars.colors.blue,
      fontSize: Styles.vars.fontSize.large,
      lineHeight: Styles.vars.lineHeights.xl 
    }
})

const NepiHelp = () => {
    return (
      <div>
        <div>
            <Link to={{ pathname: "https://nepi.com/documentation/" }} target="_blank" style={styles.link_style}>
                NEPI Online Docs (will open in new tab)
            </Link>
        </div>
        <div>
            <Link to={{ pathname: "https://nepi.com/tutorials/" }} target="_blank" style={styles.link_style}>
                NEPI Online Tutorials (will open in new tab)
              </Link>
        </div>
        <div>
            <Link to={{ pathname: "https://nepi.com/videos/" }} target="_blank" style={styles.link_style}>
              NEPI Online Videos (will open in new tab)
            </Link>
        </div>
      </div>
    )
  }
  
  export default NepiHelp