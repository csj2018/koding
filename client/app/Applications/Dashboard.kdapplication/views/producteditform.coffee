class GroupProductEditForm extends KDFormViewWithFields

  constructor: (options = {}, data = {}) ->

    model = data  if data.planCode

    options.isRecurOptional ?= yes

    options.callback ?= =>
      @emit 'SaveRequested', model, @getProductData()

    options.buttons ?=
      Save        :
        cssClass  : "modal-clean-green"
        type      : "submit"
      cancel      :
        cssClass  : "modal-cancel"
        callback  : =>
          @emit 'CancelRequested'

    options.fields ?=

      title             :
        label           : "Title"
        placeholder     : options.placeholders?.title
        defaultValue    : data.title

      description       :
        label           : "Description"
        placeholder     : options.placeholders?.description or "(optional)"
        defaultValue    : data.description


      subscriptionType  :
        label           : "Subscription type"
        itemClass       : KDSelectBox
        defaultValue    : data.subscriptionType ? "mo"
        selectOptions   : do ->

          selectOptions = [
            { title: "Recurs every month",     value: 'mo' }
            { title: "Recurs every 3 months",  value: '3 mo' }
            { title: "Recurs every 6 months",  value: '6 mo' }
            { title: "Recurs every year",      value: 'yr' }
            { title: "Recurs every 2 years",   value: '2 yr' }
            { title: "Recurs every 5 years",   value: '5 yr' }
          ]

          if options.isRecurOptional
            selectOptions.push { title: "Single payment", value: 'single' }

          return selectOptions

        callback: @bound 'handleSubscriptionType'

    options.fields.feeAmount ?=
      label           : "Amount"
      placeholder     : "0.00"
      defaultValue    :
        if data.feeAmount
        then (data.feeAmount / 100).toFixed(2)
      change          : ->
        num = parseFloat @getValue()

        @setValue if isNaN num then '' else num.toFixed(2)
      nextElementFlat :

        perMonth      :
          itemClass   : KDCustomHTMLView
          partial     : "/ #{ data.subscriptionType ? 'mo' }"
          cssClass    : 'fr'

    if options.showPriceIsVolatile
      options.fields.priceIsVolatile =
        label         : "Price is volatile"
        itemClass     : KDOnOffSwitch
        defaultValue  : data.priceIsVolatile
        callback      : =>
          enabled = @inputs.priceIsVolatile.getValue()
          do @fields.feeAmount[if enabled then 'hide' else 'show']

    if options.showOverage
      options.fields.overageEnabled =
        label         : "Overage enabled"
        itemClass     : KDOnOffSwitch
        defaultValue  : data.overageEnabled

    if options.showSoldAlone
      options.fields.soldAlone =
        label         : "Sold alone"
        itemClass     : KDOnOffSwitch
        defaultValue  : data.soldAlone

    super options, data

    @fields.feeAmount.hide()  if data.priceIsVolatile

  getPlanInfo: (subscriptionType = @inputs.subscriptionType?.getValue()) ->
    feeUnit     : 'months'
    feeInterval : switch subscriptionType
      when 'mo'     then 1
      when '3 mo'   then 3
      when '6 mo'   then 6
      when 'yr'     then 12
      when '2 yr'   then 12 * 2 # 24 mo
      when '5 yr'   then 12 * 5 # 60 mo
    subscriptionType: subscriptionType

  getProductData: ->
    do (i = @inputs) =>
      title           = i.title.getValue()
      description     = i.description.getValue()
      overageEnabled  = i.overageEnabled.getValue()
      soldAlone       = i.soldAlone.getValue()
      priceIsVolatile = i.priceIsVolatile.getValue()
      feeAmount       =
        unless priceIsVolatile
        then i.feeAmount.getValue() * 100

      { subscriptionType, feeUnit, feeInterval } = @getPlanInfo()

      {
        title         : i.title.getValue()
        description   : i.description.getValue()
        feeAmount
        feeUnit
        feeInterval
        subscriptionType
        overageEnabled
        soldAlone
        priceIsVolatile
      }

  handleSubscriptionType: ->
    subscriptionType = @inputs.subscriptionType.getValue()
    if subscriptionType is 'single'
      @inputs.perMonth.hide()
    else
      @inputs.perMonth.show()
      @inputs.perMonth.updatePartial "/ #{subscriptionType}"
