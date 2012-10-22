
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

<a name="peeking"/>
Peeking
=======

Sometimes bugs in your program don't cause exceptions. Instead your program just gets
stuck. Examples include infinite loops, slow network calls, or tests that take a
suprisingly long time to run.

In this case it's useful to be able to open a pry console when you notice that your
program is not going anywhere. To do this, send your process a `SIGQUIT` using `<ctrl+\>`.

```
cirwin@localhost:/tmp/pry $ ruby examples/loop.rb
^\
Preparing to peek via pry!
Frame number: 0/4

From: ./examples/loop.rb @ line 10 Object#r
    10: def r
    11:   some_var = 13
    12:   loop do
 => 13:     x = File.readlines('lib/pry-rescue.rb')
    14:   end
    15: end
pry (main)>
```

Advanced peeking
================

You can configure which signal pry-rescue listens for by default by exporting the PRY_PEEK
environment variable that suits your use-case best:

```
export PRY_PEEK=""    # don't autopeek at all
export PRY_PEEK=INT   # peek on SIGINT (<ctrl+c>)
export PRY_PEEK=QUIT  # peek on SIGQUIT
export PRY_PEEK=USR1  # peek on SIGUSR1
export PRY_PEEK=USR2  # peek on SIGUSR2
export PRY_PEEK=EXIT  # peek on program exit
```

If it's only important for one program, then you can also set the environment variable in
ruby before requiring pry-rescue

```ruby
ENV['PRY_PEEK'] = '' # disable SIGQUIT handler
require "pry-rescue"
```

Finally, you can enable peeking into programs that do not include pry-rescue by
configuring ruby to always load one (or several) of these files:

```
export RUBYOPT=-rpry-rescue/peek/int   # peek on SIGINT (<ctrl-c>)
export RUBYOPT=-rpry-rescue/peek/quit  # peek on SIGQUIT (<ctrl-\>)
export RUBYOPT=-rpry-rescue/peek/usr1  # peek on SIGUSR1
export RUBYOPT=-rpry-rescue/peek/usr2  # peek on SIGUSR2
export RUBYOPT=-rpry-rescue/peek/exit  # peek on program exit
```

These last examples relies on having pry-rescue in the load path (i.e. at least in the
gemset, or Gemfile of the program). If that is not true, you can use absolute paths. The
hook files do not require the whole of pry-rescue, nor is any of pry itself loaded until
you trigger the signal.

```
export RUBYOPT=-r/home/cirwin/src/pry-rescue/lib/pry-rescue/peek/usr2
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
