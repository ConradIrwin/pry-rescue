pry-capture allows you to start a Pry session on any unhandled exceptions in your code.


Installation
============
Either `gem install pry-capture`, or add it to the development section of your Gemfile:

```ruby
source :rubygems
group :development do
  gem 'pry-capture'
  gem 'pry-stack_explorer' # if you're using MRI 1.9 and you want it to be awesome.
end
```

Usage
=====

In development, wrap your code in `Pry::capture{ }`; then any exceptions that are raised
but not rescued will open a pry session.

```ruby
require 'pry-capture'

def test
  raise "foo"
rescue => e
  raise "bar"
end

Pry.capture do
  test
end
```

This will land you in a pry-session:

```
From: examples/example.rb @ line 4 Object#test:

    4: def test
    5:   raise "foo"
    6: rescue => e
 => 7:   raise "bar"
    8: end

RuntimeError: bar
from examples/example.rb:7:in `rescue in test'
[1] pry(main)>
```

If you need to find the reason that the exception happened, you can use the `cd-cause`
command:

```
[1] pry(main)> cd-cause
From: examples/example.rb @ line 4 Object#test:

    4: def test
 => 5:   raise "foo"
    6: rescue => e
    7:   raise "bar"
    8: end

RuntimeError: foo
from examples/example.rb:5:in `test'
[1] pry(main)>
```

To get back from `cd-cause` you can either type `<ctrl+d>` or `cd ..`.

pry-stack explorer
==================

If you're running rubinius, or ruby-1.9, then you can use `pry-capture` alongside
`pry-stack_explorer`. This gives you the ability to move `up` or `down` the stack so that
you can get a better idea of why your function ended up in a bad state. Run
[example2.rb](https://github.com/ConradIrwin/pry-capture/blob/master/examples/example2.rb) to get a feel for what this is like.

Known bugs
==========

Occasionally, when using ruby-1.8 or jruby, the value for `self` will be incorrect. You
will still be able to access local variables, but calling methods will not work as you
expect.

On rbx we are unable to intercept some exceptions thrown from inside the C++ VM, for
example the ZeroDivisionError in `1 / 0`.

Meta-fu
=======

Released under the MIT license, see LICENSE.MIT for details. Contributions and bug-reports
are welcome.
