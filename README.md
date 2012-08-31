
**pry-rescue** super-fast, painless, debugging for the (ruby) masses. (See [Pry to the rescue!](https://cirw.in/blog/pry-to-the-rescue))

Usage
=====

First `gem install pry-rescue pry-stack_explorer`. Then run your program with `rescue`
instead of `ruby`:

```
rescue <script.rb> [arguments..]
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

Occasionally, when using ruby-1.8 the value for `self` will be incorrect. You will still
be able to access local variables, but calling methods will not work as you expect.

On rbx we are unable to intercept some exceptions thrown from inside the C++ VM, for
example the ZeroDivisionError in `1 / 0`.

Meta-fu
=======

Released under the MIT license, see LICENSE.MIT for details. Contributions and bug-reports
are welcome.
