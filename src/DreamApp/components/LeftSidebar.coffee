{div, span, ul, li} = require "../../Mercury/dsl.coffee"

module.exports = LeftSidebar =
  render: (currentDoc) ->
    (div {id: "left-sidebar-container", className: "sidebar"}, [
      (div {id: "left-sidebar-header", className: "sidebar-header"}, [
        (span {className: "sidebar-header-control"}, ["new"])
        (span {className: "sidebar-header-control"}, ["open"])
      ])
      (LeftSidebar.renderTitle currentDoc.title)
      (div {id: "file-buttons"}, [
        (span {className: "file-button"}, ["download"])
        (span {className: "file-button"}, ["stats"])
      ])
      (LeftSidebar.renderOutline currentDoc.chapters)
    ])

  renderTitle: (title) -> (div {id: "title"}, [title])

  renderOutline: (chapters) ->
    (ul {id: "outline"},
      (chapters.map (chapter) ->
        (li {}, [chapter.heading])
      ))
