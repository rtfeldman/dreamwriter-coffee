{div} = require "../../React/dsl.coffee"

module.exports = RightSidebar =
  render: (notes) ->
    if notes
      div {id: "right-sidebar-container", className: "sidebar", key: "right-sidebar-container"}
