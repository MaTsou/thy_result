# ThyResult

This tiny gem is largely inspired by dry-monad and what I understood of it (and I know I am far from understanding what is a monad).

TheResult provide a way to wrap anything a method could returned. The wrapper 
is carrying information about what is the content ( Success, Failure, ... ). 
See examples below.

## Installation

This gem is not on rubygems.org..
To install it you can either clone this repository or add this line in your 
Gemfile, and then call `bundle install` :
```
gem 'thy_result', git: 'https://github.com/MaTsou/thy_result.git'
```

## Usage
Here an example on a subscription process
```
def check_subscription( *args )
  # some code here
  return ThyResult.set( :Granted, account_id ) if condition
  # further checks
  return ThyResult.set( :Denied, issue_msg ) if condition
  # etc
  return ThyResult.set( :Incomplete, ... )
end
```

```
def typically_a_rails_controller_method
  check_subscription( ... ) do |access|
    access.isGranted { |id| redirect_to :home_page( account_id: id ) }
    access.isDenied { |msg| redirect_to :login_page, alert: msg }
    access.isIncomplete { |state| ... }
  end
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
