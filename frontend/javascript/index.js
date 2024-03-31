import "$willamette/index.css";

import "$styles/index.css"
import "$styles/syntax-highlighting.css"

import "@shoelace-style/shoelace/dist/components/icon/icon.js"
import { registerIconLibrary } from "@shoelace-style/shoelace/dist/utilities/icon-library.js"

registerIconLibrary('remixicon', {
  resolver: name => {
    const match = name.match(/^(.*?)\/(.*?)?$/)
    return `https://cdn.jsdelivr.net/npm/remixicon@3.4.0/icons/${match[1]}/${match[2]}.svg`
  },
  mutator: svg => svg.setAttribute('fill', 'currentColor')
})

// Use the public icons folder:
import { setBasePath } from "@shoelace-style/shoelace/dist/utilities/base-path.js"
setBasePath("/shoelace-assets")

// Import all JavaScript & CSS files from src/_components
import components from "$components/**/*.{js,jsx,js.rb,css}"
