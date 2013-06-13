class DashboardAppView extends JView

  constructor:(options={}, data)->

    options.cssClass or= "content-page"
    data or= @getSingleton("groupsController").getCurrentGroup()
    super options, data

    @header = new HeaderViewSection type : "big", title : "Group Dashboard"
    @nav    = new CommonInnerNavigation
    @tabs   = new KDTabView
      cssClass            : 'dashboard-tabs'
      hideHandleContainer : yes
    , data

    @setListeners()
    @once 'viewAppended', =>
      @header.hide()
      @nav.hide()
      group = KD.getSingleton("groupsController").getCurrentGroup()
      group.canEditGroup (err, success)=>
        if err or not success
          {entryPoint} = KD.config
          KD.getSingleton('router').handleRoute "/Activity", { entryPoint }
        else
          @header.show()
          @nav.show()
          @createTabs()
          @_windowDidResize()

    @searchWrapper = new KDCustomHTMLView
      tagName  : 'section'
      cssClass : 'searchbar'

    @search = new KDHitEnterInputView
      placeholder  : "Search..."
      name         : "searchInput"
      cssClass     : "header-search-input"
      type         : "text"
      focus        : =>
        @tabs.showPaneByName "Members"  unless @tabs.getActivePane().name is 'Invitations'
      callback     : =>
        if @tabs.getActivePane().name is 'Invitations'
          pane = @tabs.getActivePane()
        else
          pane = @tabs.getPaneByName "Members"
        {mainView} = pane
        return unless mainView
        mainView.emit 'SearchInputChanged', @search.getValue()
        @search.focus()
      keyup        : =>
        return unless @search.getValue() is ""
        if @tabs.getActivePane().name is 'Invitations'
          pane = @tabs.getActivePane()
        else
          pane = @tabs.getPaneByName "Members"
        {mainView} = pane
        return unless mainView
        mainView.emit 'SearchInputChanged', ''

    @searchIcon = new KDCustomHTMLView
      tagName  : 'span'
      cssClass : 'icon search'

    @searchWrapper.addSubView @search
    @searchWrapper.addSubView @searchIcon
    @header.addSubView @searchWrapper

  setListeners:->

    @listenWindowResize()
    @nav.on "viewAppended", =>
      @navController = @nav.setListController
        itemClass : ListGroupShowMeItem
      ,
        title     : "SHOW ME"
        items     : []

      @nav.addSubView @navController.getView()

    @nav.on "NavItemReceivedClick", ({title})=> @tabs.showPaneByName title
    @tabs.on "PaneDidShow", (pane)=> @navController.selectItemByName pane.name

  createTabs:->

    data = @getData()
    @getSingleton('appManager').tell 'Dashboard', 'fetchTabData', (tabData)=>
      navItems = []
      for {name, hiddenHandle, viewOptions}, i in tabData
        viewOptions.data = data
        @tabs.addPane (pane = new KDTabPaneView {name, viewOptions}), !(~i+1) # making 0 true the rest false
        navItems.push {title: name, type: if hiddenHandle then 'hidden' else null}

      @navController.instantiateListItems navItems
      @navController.selectItem @navController.itemsOrdered.first

  _windowDidResize:->
    contentHeight = @getHeight() - @header.getHeight()
    @$('>section, >aside').height contentHeight

  pistachio:->
    """
      {{> @header}}
      <aside class='fl'>
        {{> @nav}}
      </aside>
      <section class='right-overflow'>
        {{> @tabs}}
      </section>
    """
