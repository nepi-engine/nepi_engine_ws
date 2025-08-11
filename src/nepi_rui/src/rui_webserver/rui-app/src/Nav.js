/*
 * Copyright (c) 2024 Numurus, LLC <https://www.numurus.com>.
 *
 * This file is part of nepi-engine
 * (see https://github.com/nepi-engine).
 *
 * License: 3-clause BSD, see https://opensource.org/licenses/BSD-3-Clause
 */
import React, { Component } from "react"
import { Link } from "react-router-dom"

import { Columns, Column } from "./Columns"
import Styles from "./Styles"
import Label from "./Label"

import logo from "./logos/logo.webp"
import powered_by_nepi from "./logos/powered_by_nepi.webp"

const styles = Styles.Create({
  logo: {
    width: "100%",
  },
  powered_by_nepi: {
    width: "100%"
  },
  navItem: {
    display: "inline-block",
    marginLeft: Styles.vars.spacing.small,
    marginRight: Styles.vars.spacing.small,
    textTransform: "uppercase",
    cursor: "pointer",
  },
  activeNavItem: {
    color: Styles.vars.colors.blue,
    fontWeight: "bold"
  },
  subNavItem: {
    backgroundColor: Styles.vars.colors.grey2,
    position: "absolute",
    marginTop: 0,
    marginLeft: 0,
    marginRight: Styles.vars.spacing.small,
    left: 0,
    listStyleType: "none",
    width: "150px",
    textAlign: "left"
  }
})

class SubNavMenu extends Component {
  constructor(props) {
    super(props)

    this.state = {
      showMenu: false,
      top: 0,
      left: 0
    }

    this.showMenu = this.showMenu.bind(this)
    this.closeMenu = this.closeMenu.bind(this)
  }

  showMenu(event) {
    event.preventDefault()
    this.setState({ showMenu: true }, () => {
      document.addEventListener("click", this.closeMenu)
    })
  }

  closeMenu() {
    this.setState({ showMenu: false }, () => {
      document.removeEventListener("click", this.closeMenu)
    })
  }

  render() {
    const { active, subItems } = this.props

    var subitemActive = false
    for (const sub in subItems) {
      if (subItems[sub].path === window.location.pathname) {
        subitemActive = true
        break
      }
    }
    
    const style = {
      ...styles.navItem,
      /*...(active? styles.activeNavItem : {}),*/
      position: "relative"
    }

    const activeStyle = {
      ...styles.navItem,
      ...styles.activeNavItem,
      position: "relative"
    }

    const activeAbsoluteStyle = {
      ...styles.activeNavItem
    }

    const subStyle = {
      ...styles.navItem,
      ...styles.subNavItem
    }

    return (

      <div style={(active || subitemActive)? activeStyle : style} onMouseEnter={this.showMenu} onMouseLeave={this.closeMenu}>
        <div style={(active || subitemActive)? activeAbsoluteStyle : {}}>{this.props.label}</div>
        {this.state.showMenu ? (
          <ul style={subStyle}>
            {subItems.map(({ path, label }) => {
              return (
                <li>
                  <Link style={(path === window.location.pathname)? activeStyle : style} to={path}>
                    {" "}
                    {label}{" "}
                  </Link>
                </li>
              )
            })}
          </ul>
        ) : null}
      </div>
    )
  }
}

const NavItem = ({ active, label, path, subItems }) => {
  const style = {
    ...styles.navItem,
    ...(active ? styles.activeNavItem : {})
  }

  this.subMenu = new SubNavMenu()
  return (
    <React.Fragment>
      {subItems ? (
        <SubNavMenu style={style} label={label} subItems={subItems} />
      ) : (
        <Link style={style} to={path}>
          {label}
        </Link>
      )}
    </React.Fragment>
  )
}

NavItem.defaultProps = {
  active: false
}

class Nav extends Component {
  render() {
    const { pages, unlicensed, license_type} = this.props
    return (
      <div style={styles.root}>
        <Columns>
          <Column>
            <Columns alignColumns={"flex-end" /* Bottom-justified logo images */}>
                <Column>
                  <div style={styles.logo}>
                    <img src={logo} alt={""} height={"auto"}/>
                  </div>
                </Column>
                <Column>
                  <div style={styles.powered_by_nepi}>
                    <img src={powered_by_nepi} alt={""} height={"auto"}/>
                  </div>
                </Column>
            </Columns>
          </Column>
          <Column style={{ flex: 3 }}>
            {pages.map(({ path, label, subItems }) => {
              return (
                <NavItem
                  active={path === window.location.pathname}
                  path={path}
                  label={label}
                  key={label}
                  subItems={subItems}
                />
              )
            })}
          </Column>
        </Columns>
        {unlicensed?
          <Label
            labelStyle={{ color: Styles.vars.colors.red, fontWeight: "bold", fontSize: Styles.vars.fontSize.large}}
            title={"LICENSE ACTIVATION REQUIRED"}
          />
          : null
        }
        {(license_type === "education" || license_type === "Education") ?
          <Label
            labelStyle={{ fontWeight: "bold", fontSize: Styles.vars.fontSize.medium}}
            title={"EDUCATION LICENSE"}
          />
          : null
        }
      </div>
    )
  }
}

export default Nav
