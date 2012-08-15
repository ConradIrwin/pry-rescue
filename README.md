
**pry-rescue** helps you quickly figure out why your code broke; when an exception is raised that would normally kill your program, Pry comes to the rescue, opening a Pry session in the context of code that raised the exception.

Installation
============

Either `gem install pry-rescue`, or add it to the development section of your Gemfile:

```ruby
source :rubygems
group :development do
  gem 'pry-rescue'
  gem 'pry-stack_explorer' # if you're using MRI 1.9 and you want it to be awesome.
end
```

Usage
=====

There are *two ways* to use pry-rescue:

Wrap an entire script
---------------------

Use the launcher script:

```
rescue <script.rb> [arguments..]
```

Wrap a block in your code
-------------------------
In development, wrap your code in `Pry::rescue{ }`; then any exceptions that are raised
but not rescued will open a pry session. This is particularly useful for debugging
servers and other long-running processes.

```ruby
require 'pry-rescue'

def test
  raise "foo"
rescue => e
  raise "bar"
end

Pry.rescue do
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

cd-cause
========

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

try-again
=========

Once you've used Pry's `edit` or `edit-method` commands to fix your code, you can issue a
`try-again` command to re-run your code. (Either from the start in the case of using the
`rescue` script, or from the block if you're using that API).

```
[1] pry(main)> edit-method
[2] pry(main)> whereami
From: examples/example.rb @ line 4 Object#test:

    4: def test
 => 5:   puts "foo"
    6: rescue => e
    7:   raise "bar"
    8: end
[3] pry(main)> try-again
foo
```

pry-stack explorer
==================

If you're running rubinius, or ruby-1.9, then you can use `pry-rescue` alongside
`pry-stack_explorer`. This gives you the ability to move `up` or `down` the stack so that
you can get a better idea of why your function ended up in a bad state. Run
[example2.rb](https://github.com/ConradIrwin/pry-rescue/blob/master/examples/example2.rb) to get a feel for what this is like.

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
