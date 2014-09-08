Outline = require "./Outline.coffee"

{div, span, ul, li} = require "../../React/dsl.coffee"

module.exports = LeftSidebar =
  render: (currentDoc) ->
    if currentDoc
      (div {id: "left-sidebar-container", className: "sidebar", key: "left-sidebar-container"}, [
        (div {key: "left-sidebar-header", id: "left-sidebar-header", className: "sidebar-header"}, [
          (span {className: "sidebar-header-control", key: "new"}, ["new"])
          (span {className: "sidebar-header-control", key: "open"}, ["open"])
        ])

        (LeftSidebar.renderTitle currentDoc?.title)
        (div {id: "file-buttons", key: "file-buttons"}, [
          (span {className: "file-button", key: "download"}, ["download"])
          (span {className: "file-button", key: "stats"}, ["stats"])
        ])
        (Outline {key: "outline", chapters: currentDoc.chapters})
      ])

  renderTitle: (title) -> (div {id: "title", key: "title"}, [title])

