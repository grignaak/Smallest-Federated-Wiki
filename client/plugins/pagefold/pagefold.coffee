window.plugins.pagefold =
  emit: (div, item) -> div.append """
    <div>
        <span class="page-background">#{item.text}</span>
    </div>
  """
  bind: (div, item) ->
    div.dblclick -> wiki.textEditor div, item
