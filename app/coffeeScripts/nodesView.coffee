Alloy.Globals.customCompnay = new Object
Alloy.Globals.customCompnay.line1 = ""
Alloy.Globals.customCompnay.line2 = ""
Alloy.Globals.customCompnay.line3 = ""
Alloy.Globals.customCompnay.line4 = ""
Alloy.Globals.customCompnay.line5 = ""
Alloy.Globals.running = true
Alloy.Globals.firstRun = true

args = arguments[0] or {}

nodes = require('nodeItemsLib')

#The list view object
listView = args.listView

if listView.footerView
  listView.footerView.show()
  listView.footerView.addEventListener 'click', () ->
    $.nodesMainView.loadMoreLocations()

#This will hold the sections that need to be set on view change
if OS_ANDROID
  sections = []

#This flag indicate that we need to clear the list view
Alloy.Globals.clearTable = false

Alloy.Globals.searchObj = {
  searchTerm: ""
  systemTypes: ""
  problemStatuses: ""
  customGroups: ""
  pageIndex: 0
  pageSize: 10
}

#get company data
getCompanyData = ->
  
  url = Alloy.Globals.rootURL + "/api/companyproperties?companyId=" + Alloy.Globals.UserData.person.Company_CompanyId
  client = Ti.Network.createHTTPClient(
  
    # function called when the response data is available
    onload: (e) ->
      try
        data = JSON.parse(@responseText)
      catch e
        Ti.API.info 'Company data error: ' + e
        #Alloy.Globals.hideIndicator()
        #alert "Network Error, Please Try Again"
        return
      for i in data
        
        if i.PropertyId == 15
          Alloy.Globals.customCompnay.line1 = i.Value
        else if i.PropertyId == 16
          Alloy.Globals.customCompnay.line2 = i.Value
        else if i.PropertyId == 17
          Alloy.Globals.customCompnay.line3 = i.Value
        else if i.PropertyId == 18
          Alloy.Globals.customCompnay.line4 = i.Value
        else if i.PropertyId == 19
          Alloy.Globals.customCompnay.line5 = i.Value
        Ti.API.info 'i.Value ' + i.PropertyId + ' : ' + i.Value

      
      Ti.App.fireEvent 'setCompanyData'
    # function called when an error occurs, including a timeout
    onerror: (e) ->
      Ti.API.info 'Company data error: ' + e
      #Alloy.Globals.hideIndicator()
      #alert "Error Sending Data, Please Try Again" 
      
  
    timeout: 35000 # in milliseconds
  )
  
  # Prepare the connection.
  client.open "GET", url
  # Send the request.
  client.send()

$.nodesMainView.initiate = ->
  getCompanyData()
  Alloy.Globals.isScollLoad = false
  $.nodesMainView.loadLocations()

#require the templates we are going to use
ItemGatelist = require("itemgatelist")
ItemMc13List = require("itemmc13list")
ItemMc13zList = require("itemmc13zlist")
ItemMc3List = require("itemmc3list")
ItemMc3zList = require("itemmc3zlist")

#this is the function that will get passed into the nodes.getdata function as a call back and will get called when the node list is created, it must always take in the list of nodes
buildView = (list) ->
  
  #clear the section if we load the first results
  if Alloy.Globals.clearTable
    listView.setSections []
    sections = []
  
  #iterage over the list and add them to the table
  headerRow = false
    
  #Alloy.Globals.listLen1 = false
  for item in list
    for i in item.models
      Ti.API.info "adding node"
      Ti.API.info i.nodetemplate
      if i.nodetemplate == "nodeRowHeader"
        if headerRow != false
          Ti.API.info "adding section to listView"
          listView.appendSection headerRow
          #Save the sections for later readding on view change
          if OS_ANDROID
            sections.push headerRow
          
        Ti.API.info "making new section"
        #View that need to be pud as header for the section
        headerView = Alloy.createController("itemnodeRowHeaderlist", i).getView()
        
        #Section for every row
        headerRow = Alloy.createController("sectionList", {
          headerView: headerView
          fromMapView: false
        }).getView()
        
      else
        template = "item" + i.nodetemplate + "list"
        Ti.API.info 'template ' + template
        try
          switch template
            when "itemgatelist"
              headerRow.appendItems ItemGatelist.getItem(i)
            when "itemmc13list"
              headerRow.appendItems ItemMc13List.getItem(i)
            when "itemmc13zlist"
              headerRow.appendItems ItemMc13zList.getItem(i)
            when "itemmc3list"
              headerRow.appendItems ItemMc3List.getItem(i)
            when "itemmc3zlist"
              headerRow.appendItems ItemMc3zList.getItem(i)  
            else
              Ti.API.info 'template not supported'
              
        catch err  
          Ti.API.info err
          
  if Alloy.Globals.isScollLoad == true
    Alloy.Globals.isScollLoad = false
  
  Alloy.Globals.hideIndicator()
  if OS_IOS
    listView.refreshControl.endRefreshing()
  
  #If only 1 node, skip to details view
  if list.length == 1 and Alloy.Globals.isScollLoad == false
    if list[0].models.length == 2
      Alloy.Globals.listLen1 = true
      Ti.App.fireEvent 'changeMainView', {
        view: 'detailsView',
        e: list[0].models[1]
      }
  
  
  #count the pageIndex up by 1 so on infinate scoll you get the next page
  Alloy.Globals.searchObj.pageIndex += 1
  #Ti.API.info 'Alloy.Globals.searchObj.pageIndex: ' + Alloy.Globals.searchObj.pageIndex
  
#this is where I load a list of locatoins with their noes, it takes in a bunch of search params 
$.nodesMainView.loadLocations = () ->
  
  Alloy.Globals.searchObj.pageIndex = 0
  
  #Indicator to clear the list view
  Alloy.Globals.clearTable = true
    
  index = Alloy.Globals.searchObj.pageIndex
    
  #reset what my last search was
  Alloy.Globals.lastSearchObj = Alloy.Globals.searchObj
  
  e = Alloy.Globals.searchObj
  Ti.API.info "here is the search obj"
  Ti.API.info e
  if OS_IOS
    nodes.getdata(buildView, e.searchTerm, e.systemTypes, e.problemStatuses, e.customGroups, index, e.pageSize, listView.refreshControl)
  else
    nodes.getdata(buildView, e.searchTerm, e.systemTypes, e.problemStatuses, e.customGroups, index, e.pageSize)


#Method for loading more locations in the table view
$.nodesMainView.loadMoreLocations = () ->
  
  #Indicator to not clear the list view
  Alloy.Globals.clearTable = false
  
  Alloy.Globals.showIndicator()
  index = Alloy.Globals.searchObj.pageIndex
  if index == 0
    Alloy.Globals.clearTable = true
    
  #reset what my last search was
  Alloy.Globals.lastSearchObj = Alloy.Globals.searchObj
  
  e = Alloy.Globals.searchObj
  Ti.API.info "here is the search obj"
  Ti.API.info e
  nodes.getdata(buildView, e.searchTerm, e.systemTypes, e.problemStatuses, e.customGroups, index, e.pageSize)
  

#Method for setting the sections if the view is reopened again
if OS_ANDROID
  $.nodesMainView.reSetContent = () ->
    listView.setSections sections
    $.nodesMainView.setListPosition()
 
$.nodesMainView.setListPosition = () ->
  listView.setListPosition()
  
$.nodesMainView.clearListView = () ->
  Ti.API.info 'table is cleared!!!'
  listView.setSections []
  
#pull to refresh for ios
if OS_IOS
  listView.refreshControl.addEventListener 'refreshstart', () ->
    $.nodesMainView.loadLocations()