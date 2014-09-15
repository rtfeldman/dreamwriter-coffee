Outline = require "./Outline.coffee"
React   = require "react"

{div, span, ul, li} = require "../../React/dsl.coffee"

module.exports = LeftSidebar = React.createClass
  getInitialState: -> {showOpenMenu: false}

  render: ->
    {currentDoc} = @props

    if @state.showOpenMenu
      (div {id: "left-sidebar-container", className: "sidebar", key: "left-sidebar-container"}, [
        (div {key: "left-sidebar-header", id: "left-sidebar-header", className: "sidebar-header"}, [
          (span {className: "sidebar-header-control", key: "cancel", onClick: @getOpenClickHandler(false)}, ["cancel"])
        ])
        (div {}, "TODO: list open files here")
      ])
    else if currentDoc
      (div {id: "left-sidebar-container", className: "sidebar", key: "left-sidebar-container"}, [
        (div {key: "left-sidebar-header", id: "left-sidebar-header", className: "sidebar-header"}, [
          (span {className: "sidebar-header-control", key: "new"}, ["new"])
          (span {className: "sidebar-header-control", key: "open", onClick: @getOpenClickHandler(true)}, ["open"])
        ])

        (div {id: "title", key: "title"}, [currentDoc.title])
        (div {id: "file-buttons", key: "file-buttons"}, [
          (span {className: "file-button", key: "download"}, ["download"])
          (span {className: "file-button", key: "stats"}, ["stats"])
        ])
        (Outline {key: "outline", chapters: currentDoc.chapters})
      ])
    else
      (span {})

  getOpenClickHandler: (showOpenMenu) ->
    (event) =>
      @setState {showOpenMenu}