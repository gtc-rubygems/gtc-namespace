# GTC::Namespace

Namespace is a Object-extension to provide unified namespace methods, that are used to simplify a dynamic access of every module.

-----

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gtc-namespace'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install gtc-namespace

-----

## Enhancements
* Unified namespace methods (like: components, modules, sections) to simplify the use of modules & sections.
* Additional methods to ```transform```, ```build``` or re-```path``` a object

-----

## Examples

```ruby
require 'gtc-namespace'

# build new namespace instance
namespace = Admin::UsersController.namespace

namespace.scope
# > :admin

namespace.resource
# > :user

namespace.concept
# > :controller
```

```ruby
require 'gtc-namespace'

# print info about the namespace
My::Membership::Operation::Index.namespace.info
# > -----------------------------------------------------------------------------------------------
# > => My::Membership::Operation::Index <=
# > components: [My, My::Membership, My::Membership::Operation, My::Membership::Operation::Index]
# > modules   : ["My", "Membership", "Operation", "Index"]
# > sections  : [:my, :membership, :operation, :index]
# > scope     : my
# > concept   :
# > resource  : membership
# > service   : operation
# > handle    : index
# > -----------------------------------------------------------------------------------------------
```


```ruby
# inflect gtc-namespace to 'root' -> ::Namespace
require 'gtc/inflections/namespace'

# the following object does NOT exist
MyApplication::Commands::ImportUsers rescue nil
#> nil

# create new module from namespace
mod = Namespace.build("MyApplication::Commands::ImportUsers")
# > MyApplication::Commands::ImportUsers

mod.namespace.components
# > [MyApplication, MyApplication::Commands, MyApplication::Commands::ImportUser]
```

-----

## gem requirement & inflections

Initialize the namespace by simply require the gem:

```ruby
require 'gtc/namespace'

# access any object's namespace through #namespace
# e.g.
Kernel.namespace

# access resolve, path, transform & build methods through GTC::Namespace::Base
# e.g.
GTC::Namespace::Base.resolve(:a,:b,:c)
```

Inflect the ```GTC::Namespace::Base``` as a direct accessible constant ```Namespace```:
```ruby
require 'gtc/inflections/namespace'

# directly access
Namespace.resolve(:a,:b,:c)
```

-----

## Object Usage

### components
returns all components as array

```ruby
My::Membership::Operation::Index.namespace.components
# > [My, My::Membership, My::Membership::Operation, My::Membership::Operation::Index]

Admin::UsersController.namespace.components
# > [Admin, Admin::UsersController]
```

### modules
returns all modules as array

```ruby
My::Membership::Operation::Index.namespace.modules
# > ["My", "Membership", "Operation", "Index"]

Admin::UsersController.namespace.modules
# > ["Admin", "UsersController"]
```

### sections
returns all sections as array

```ruby
My::Membership::Operation::Index.namespace.sections
# > [:my, :membership, :operation, :index]

Admin::UsersController.namespace.sections
# > [:admin, :users_controller]
```

### scope
returns the scope of a provided klass.

_PLEASE NOTE:_ There is no scope for a class with a single module

```ruby
My::Membership::Operation::Index.namespace.scope
# > :my

Admin::UsersController.namespace.scope
# > :admin
```

### concept
Returns the concept name of a provided klass.
It detects the first camel-case module and returns its concept name.

```ruby
My::Membership::Operation::Index.namespace.concept
# > nil

Admin::UsersController.namespace.concept
# > :controller
```

### resource
Returns the resource name of a provided klass.
It checks for at least three modules and returns the first module name.
If there is more or less than three modules it detects the first camel-cased module and returns its resource name (all camelcase token, except the last one - then singularize).
As last fallback it uses the first module.

```ruby
My::Membership::Operation::Index.namespace.resource
# > :membership

Admin::UsersController.namespace.resource
# > :user
```

### service
Returns the service name of a provided klass.
It checks for at least three modules and returns the penultimate service.

```ruby
My::Membership::Operation::Index.namespace.service
# > :operation

Admin::UsersController.namespace.service
# > nil
```

### section(pos = 0)
Returns the (first) section name of a provided klass (by default).
If a _pos_ was provided it'll return the _pos_ section.

```ruby
My::Membership::Operation::Index.namespace.section
# > :my

My::Membership::Operation::Index.namespace.section(2)
# > :operation

Admin::UsersController.namespace.section(1)
# > :users_controller
```

### handle
Returns the handle name of a provided klass.
It checks for at least three modules and returns the last module name.

```ruby
My::Membership::Operation::Index.namespace.handle
# > :index

My::Membership::Operation::Index.namespace.handle
# > :index

Admin::UsersController.namespace.handle
# > nil
```

### info
Prints a info string for each namespace method.
just for debugging

```ruby
My::Membership::Operation::Index.namespace.info
# -----------------------------------------------------------------------------------------------
# => My::Membership::Operation::Index <=
# components: [My, My::Membership, My::Membership::Operation, My::Membership::Operation::Index]
# modules   : ["My", "Membership", "Operation", "Index"]
# sections  : [:my, :membership, :operation, :index]
# scope     : my
# concept   :
# resource  : membership
# service   : operation
# handle    : index
# -----------------------------------------------------------------------------------------------

Admin::UsersController.namespace.info
# -----------------------------------------------------------------------------------------------
# => Admin::UsersController <=
# components: [Admin, Admin::UsersController]
# modules   : ["Admin", "UsersController"]
# sections  : [:admin, :users_controller]
# scope     : admin
# concept   : controller
# resource  : user
# service   :
# handle    :
#  -----------------------------------------------------------------------------------------------
```

-----

## Namespace Usage

### resolve
resolves a object by provided names

```ruby
require 'gtc/inflections/namespace'


::Namespace.resolve(:users,'cell','indEx')
# > ::User::Cell::Index
```

### path
returns the full object name as string.
_Please note:_ it's always a ```classify``` version of each name

```ruby
::Namespace.path(:user, 'Models',:open_tags, 'find')
# > "User::Model::OpenTag::Find"
```

### build
builds & resolves a new module by provided module names.
Only builds, if not exists previously!

```ruby
::Namespace.build(:user,'cell','index')
# > ::User::Cell::Index
# > ::User::Cell::Index.class == Module
```

### transform
converts a provided module to a totally new one.

Shorts can be used, to access the namespace methods:
* :__scope
* :__concept
* :__resource
* :__section
* :__service
* :__handle

```ruby
::Namespace.transform(User::Cell::Index, [:__resource, :endpoint, :__handle])
# > User::Endpoint::Index

::Namespace.transform(Admin::UsersController, [:__scope, :home_controller])
# > Admin::HomeController
```

-----

## Docs

[CHANGELOG](./docs/CHANGELOG.md)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/gtc-simple_logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/gtc-simple_logger/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

A copy of the [LICENSE](./docs/LICENSE.txt) can be found @ the docs.

## Code of Conduct

Everyone interacting in the Gtc::Namespace project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [CODE OF CONDUCT](./docs/CODE_OF_CONDUCT.md).
