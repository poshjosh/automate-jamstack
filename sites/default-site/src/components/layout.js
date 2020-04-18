import React from "react"
import { Link } from "gatsby"

import { rhythm, scale } from "../utils/typography"
import "./layout.css"

const Layout = ({ location, title, children }) => {
  const rootPath = `${__PATH_PREFIX__}/`
  let header

  if (location.pathname === rootPath) {
    header = (
      <h1
        style={{
          ...scale(1.5),
          textAlign: `center`,
          padding: rhythm(1.5),
          background: `rgba(0, 0, 0, 0.3)`, /* Black background with 0.5 opacity */        }}
      >
        <Link
          style={{
            boxShadow: `none`,
            color: `inherit`,
          }}
          to={`/`}
        >
          {title}
        </Link>
      </h1>
    )
  } else {
    header = (
      <h3
        style={{
          textAlign: `center`,
          fontFamily: `Montserrat, sans-serif`,
          padding: rhythm(1.0),
          background: `rgba(0, 0, 0, 0.2)`,
        }}
      >
        <Link
          style={{
            boxShadow: `none`,
            color: `inherit`,
          }}
          to={`/`}
        >
          {title}
        </Link>
      </h3>
    )
  }
  return (
    <div
      style={{
        marginLeft: `auto`,
        marginRight: `auto`,
        marginTop: 0,
      }}
    >
      <header
        style={{
          margin: 0,
          border: 0,
          padding: rhythm(5.0),
          backgroundImage: "url(https://img1.wsimg.com/isteam/stock/VJdp5Gd/:/rs=w:1360,h:580,cg:true,m/cr=w:1360,h:580,a:cc)",
          height: `50%`,
          backgroundPosition: `center`,
          backgroundRepeat: `no-repeat`,
          backgroundSize: `cover`,
          position: `relative`,
          color: `white`,
        }}
      >{header}</header>
      <main>{children}</main>
      <footer>
        &copy; {new Date().getFullYear()}
        {` `}
        <a href="http://www.looseboxes.com/legal/licenses/software.html">looseBoxes.com</a>
      </footer>
    </div>
  )
}

export default Layout
