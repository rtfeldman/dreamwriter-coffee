{div} = require "../../React/dsl.coffee"

module.exports = RightSidebar =
  render: (state) ->
    div {id: "right-sidebar-container", className: "sidebar", key: "right-sidebar-container"}
