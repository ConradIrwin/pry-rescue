
**pry-rescue** super-fast, painless, debugging for the (ruby) masses. (See [Pry to the rescue!](http://cirw.in/blog/pry-to-the-rescue))

Usage
=====

First `gem install pry-rescue pry-stack_explorer`. Then run your program with `rescue`
instead of `ruby`:

```
rescue <script.rb> [arguments..]
```

If you're using Rails, you should add `pry-rescue` to the development section of your
Gemspec and then run rails server using rescue:

```
rescue rails server
```

If you're using `bundle exec` the rescue should go after the exec:

```
bundle exec rescue rails server
```

If you're using Rack, you should use the middleware instead (though be careful to only
include it in development!)
```
use PryRescue::Rack
```

If you want more fine-grained control over which parts of your code are rescued, you can
also use the block form:

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

Finally. If you're doing your own exception handling, you can ask pry to open on an exception that you've caught.
For this to work you must be inside a Pry::rescue{ } block.

```ruby
def test
  raise "foo"
rescue => e
  Pry::rescued(e)
end

Pry::rescue{ test }
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
`pry-stack\_explorer`. This gives you the ability to move `up` or `down` the stack so that
you can get a better idea of why your function ended up in a bad state. Run
[example2.rb](https://github.com/ConradIrwin/pry-rescue/blob/master/examples/example2.rb) to get a feel for what this is like.

Known bugs
==========

* ruby 2.0, 1.9.3, 1.9.2 – no known bugs
* ruby 1.9.1 — not supported
* ruby 1.8.7 — occasional incorrect values for self
* ree 1.8.7 — no known bugs
* jruby 1.7 (1.8 mode and 1.9 mode) — no known bugs
* jruby 1.6 (1.8 mode and 1.9 mode) — incorrect value for self in NoMethodErrors
* rbx (1.8 mode and 1.9 mode) – does not catch some low-level errors (e.g. ZeroDivisionError)

Meta-fu
=======

Released under the MIT license, see LICENSE.MIT for details. Contributions and bug-reports
are welcome.
