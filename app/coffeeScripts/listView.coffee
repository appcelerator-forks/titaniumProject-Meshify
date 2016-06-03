#This object contains the last clicked section and item for scrolling the list to the correct place
lastVisibleItem = {
  item: 0
  section: 0
}

openDetails = (e) ->
  #Get the section of the clicked item
  section = $.listView.sections[e.sectionIndex]
  #Get the clicked item from that section
  item = section.getItemAt(e.itemIndex)
  #Set the last visible item to the one that has been clicked
  lastVisibleItem.item = e.itemIndex
  lastVisibleItem.section = e.sectionIndex
  
  Ti.App.fireEvent 'changeMainView', {
    view: 'detailsView',
    e: item.detailView
  }

$.listView.setListPosition = ->
  $.listView.scrollToItem lastVisibleItem.section, lastVisibleItem.item
  
if OS_IOS
  Alloy.Globals.refreshControl = $.refreshControl