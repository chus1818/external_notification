ExternalNotification
====================

Rails service to perform HTTP request in a syntax-friendly style via Net::HTTP

Dependencies
------------

* Rails

Developer dependencies
----------------------

* Rspec
* Webmock

##Syntax
  
###Get requests

You can perform a get request without params using:

```ruby
ExternalNotification.new.send_to( your_url_or_endpoint )
  ```

###Post requests

To perform a post request simply use the "with" method to define the params you want to send along with the request:

```ruby
ExternalNotification.new.with( :params => { :param => value } ).send_to( your_url_or_endpoint )
```

The "with" method also accepts a block which return value will be tryed to be parsed as params:

```ruby
notification = ExternalNotification.new.with do 
  my_value = method_to_get_the_value
  { :param => my_value }
end

notification.send_to( your_url_or_endpoint )
```

###Get requests with extra params

If you want to perform a get request with extra params simply tell the with method that your input params are intended to be used on a get request:

```ruby
ExternalNotification.new.with( { :request_type => :GET }, :params => { :param => value } ).send_to( your_url_or_endpoint )
```

##Endpoints

You can alias a commonly used endpoint and use its alias during a send_to call, for instance:

```ruby
ExternalNotification.new.send_to( :my_endpoint )
```

###Adding endpoints

Add an endpoint with:

```ruby
ExternalNotification.import_constant { :my_endpoint => "http://test_endpoint.com" }
```

## Credits

2014 Jesús Prieto.

