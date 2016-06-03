listView = $.list.getView()

nodesView = Alloy.createController('nodesView', {
  listView : listView,
}).getView()

#This method calls the initiate method in nodes view
$.container.initiateNodesView = ->
  nodesView.clearListView()
  nodesView.initiate()

$.container.clearListView = ->
  nodesView.clearListView()
  
if OS_ANDROID
  $.container.reSetNodesContent = ->
    nodesView.reSetContent()

#This method shows the last view visible in the list
$.container.setListPosition = ->
  listView.setListPosition()