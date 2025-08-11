/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React from "react"
import PropTypes from "prop-types"

import Styles from "./Styles"

const containerBaseStyle = {
  display: "flex"
}

const columnBaseStyle = {
  textAlign: "left",
  padding: `0 ${Styles.vars.spacing.regular.raw / 2}px`
}

const equalStyle = {
  flex: 1
}

const doubleStyle = {
  flex: 2
}

const firstStyle = {
  textAlign: "left",
  paddingLeft: 0
}

const lastStyle = {
  textAlign: "right",
  paddingRight: 0
}

const singleStyle = {
  paddingLeft: 0,
  paddingRight: 0,
  textAlign: "center"
}

export const Column = ({
  children,
  first,
  last,
  equalWidth,
  centered,
  style
}) => {
  const colStyle = Styles.Create({
    ...columnBaseStyle,
    ...(first ? firstStyle : {}),
    ...(last ? lastStyle : {}),
    ...((first && last) || centered ? singleStyle : {}),
    ...(first && last ? singleStyle : {}),
    ...(equalWidth ? equalStyle : doubleStyle),
     ...(style || {})
  })

  return <div style={colStyle}>{children}</div>
}

Column.propTypes = {
  /** Is this the first column in the group? */
  first: PropTypes.bool,
  /** Is this the last column in the group? */
  last: PropTypes.bool,
  /** Should this column be centered? */
  centered: PropTypes.bool,
  /** Should this column have an equal size as the other columns? */
  equalWidth: PropTypes.bool,
  /** Other custom override styles */
  style: PropTypes.object,
  /** The content of the column */
  children: PropTypes.node
}

Column.defaultProps = {
  centered: false,
  equalWidth: true
}

export const Columns = ({ children, alignColumns }) => {
  const columns = React.Children.toArray(children).filter(child => child)
  const childCount = columns.length
  const style = Styles.Create({
    ...containerBaseStyle,
    alignItems: alignColumns
  })

  return (
    <div style={style}>
      {columns.map((column, index) =>
        React.cloneElement(column, {
          first: index === 0,
          last: index === childCount - 1
        })
      )}
    </div>
  )
}

Columns.propTypes = {
  /** How should the columns align themselves */
  alignColumns: PropTypes.string,
  /** The columns to display */
  children: PropTypes.node.isRequired
}
