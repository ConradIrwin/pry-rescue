
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

Someones bugs in your program don't cause exceptions. Instead your program just gets
stuck. Examples include infinite loops, slow network calls, or badly backtracking
parsers.

In this case it's useful to be able to open a pry console when you notice that your
program is not going anywhere. To enable this feature you need to run:

```
rescue --peek <script.rb>
```

Then hit `<ctrl+c>` at any time to stop your program and have a peek at what it's actually
doing. Hitting `<ctrl-c>` a second time will quit your program, if that's what you were
trying to do.

Advanced peeking
================

It's tedious to have to remember to always start your program with `rescue --peek`. To
this end, there are two ways to make peeking happen automatically.

Firstly, if you want to always be able to peek a given program, just explicitly require
this functionality at the start of that program.

```ruby
require "pry-rescue/peek/int"
```

Secondly, if you want to always be able to peek any program, without changing the code,
you can configure ruby to do this automatically. To do so, set RUBYOPT in your `~/.bashrc`
(or equivalent).

```bash
export RUBYOPT="-rpry-rescue/peek/int"
```

If you like the idea of peeking but don't want it to interfere with the normal purpose of
`<ctrl+c>` then you can ask pry-rescue to listen to SIGUSR1 or SIGUSR2 instead by just
changing the path that you require.

```ruby
require "pry-rescue/peek/usr1"
require "pry-rescue/peek/usr2"
```

To send a SIGUSR1 to a process you can use the kill command.

```bash
kill -USR1 <process-id>
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
