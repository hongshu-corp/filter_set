# FilterSet

## Installation

``` ruby
  gem 'filter_set'
```


## Basic use

``` ruby
  # In slim view
  = filter_set do |filter|
    = filter.by :text
    = filter.submit :search
    = filter.submit :export, format: :excel

  # In controller
  # GET index
  def index
    @orders = Order.where name: filter_conditions.text
  end
```
Rendered HTML:

``` html
<form class="filter-set" id="new_filter_conditions" action="original url" accept-charset="UTF-8" method="get">
  <label class="caption caption-text">Text</label>
  <input class="by-text" type="text" name="filter_conditions[text]" id="filter_conditions_text">
  <button name="filter_submit" type="submit" class="submit submit-search" value="{&quot;type&quot;:&quot;search&quot;}">Search</button>
</form>
```
Label and button text can be changed by options(:caption) or I18n yml

Define method to transform string to object in controller
``` ruby
  def filter_text_object value
    Order.find_by_id value
  end

  # GET index
  def index
    @orders = [filter_conditions.text_object]
  end
```

## Filter types
### Common options
#### :caption
Set label caption before filter field. Default value is I18n.t("filter_set.by.#{type}")

#### :key
Rename the filter field name.
``` ruby
  # In slim:
  = filter_set do |filter|
    = filter.by :text, key: sender, caption: 'Sender'
    = filter.by :text, key: receiver, caption: 'Receiver'

  # In controller:
  Message.where sender: filter_conditions.sender, receiver: filter_conditions.receiver
```

If use option :key without :caption, I18n.t("filter_set.by.#{key}") will be shown as label text.

``` ruby
  # In slim:
  = filter_set do |filter|
    = filter.by :text, key: sender

  ### yml
  filter_set:
    by:
      sender: 发送者
```
Rendered HTML:
``` html
<form class="filter-set" id="new_filter_conditions" action="original url" accept-charset="UTF-8" method="get">
  <label class="caption caption-text caption-render">发送者</label>
  <input class="by-text by-render" type="text" name="filter_conditions[sender]" id="filter_conditions_sender">
</form>
```

### Supported field types:
#### :text
Render a text input as a filter condition.

### Define filter
Define partial views in views/filter_set/_new_type.slim
``` ruby
  # render caption
  = builder.caption caption, clazz: caption_class

  # render field
  = builder.text_field key, **options
```
use:
``` ruby
  = filter_set do |filter|
    = filter.by :new_type
```


## Filter Submit
### Common options
#### :caption
Set caption on the button.  
Default value is I18n.t("filter_set.submit.#{type}.caption", _scope: I18n.t(filter_set.submit.#{type}.scopes.#{scope}), [other formets])

#### :scope
Set an extra parameter for different search or export. User can get it by:
``` ruby
  Order.where scope: filter_action.scope
```
If option :scope was set, it will try to get I18n.t(filter_set.submit.#{type}.scopes.#{scope} as _scope in caption.

### Supported submit types:
#### :search
Render a submit button for search

#### :export
Render a submit button for export  
Options for export:

|option | values | remark|
|- | - | -|
|:format | :csv(default)/:excel | File format|
|:paging | true/false (default) | Export with paging(only support will_paginate)|
|:template | string | partial template for exporting|
|:data_name | symbol | var name for partial template render|
|:data_source | string | data_source for data_name|
|:data_css | string | css selector for export, default is 'table'|
|:row_css | string | css selector for data row, default is 'tr'|
|:cell_css | string | css selector for data cell, default is all td and th with out class 'no-export'|
|:sheet_name | string | use for sheet name in excel|
|:data_pattern | hash | export css and sheet name for excel export|

``` ruby
  # in slim
  = filter_set do |filter|

    # export all html tables in rendered html to excel in sheet name 'Sheet1', 'Sheet2'...
    = filter.submit :export, format: :excel

    # export all html tables in rendered html to csv, under paginate method enabled
    = filter.submit :export, paging: true

    # export table in partial template
    = filter.submit :export, format: :excel, template: 'orders_table', data_name: 'orders'
    # will export data from `render partial: 'orders_table', orders: (@orders || orders)`

    # specify data_source:
    = filter.submit :export, format: :excel, template: 'orders_table', data_name: 'orders', data_source: '@enabled_orders'
    # will export data from `render partial: 'orders_table', orders: @enabled_orders`

    # export with sheet_name
    = filter.submit :export, format: :excel, data_css: '.orders', sheet_name: 'Order List'

    # export with custorm data struct
    = filter.submit :export, data_css: '.orders', row_css: '.row', cell_css: '.cell'

    # export with data_pattern
    = filter.submit :export, data_pattern: {'.orders': 'Order List', '.users': 'User List'}
    # will export first table of '.orders' to excel with sheet name 'Order List', first table of '.users' to excel with sheet name 'User List'
```
To make paging params work in data export, paginate logic controller
``` ruby
  def index
    @orders = Order.all.paginate page: params[:page]
  end
```
should be changed to:
``` ruby
  def index
    @orders = paginate Order.all
  end
```

