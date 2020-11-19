---
title: Where Do Ruby Blocks Come From?
subtitle: Let me set the mood, because it’s time to get reflective. Here’s your primer on block bindings, local variables, receivers, and more.
categories:
- Syntax and Metaprogramming
author: jared
image: "/images/posts/blocks-everywhere.jpg"
image_hero: "/images/posts/blocks-everywhere.jpg"
image_credit:
  url: https://unsplash.com/photos/kn-UmDZQDjM
  label: Xavi Cabrera on Unsplash
published: true
---

It’s time to get reflective…time for some deep introspection…so light a candle or two, [put some Barry White on the stereo](https://www.youtube.com/watch?v=VdbNoXrbUFY), get nice and comfortable, because we’re going to talk about **Blocks**.

Blocks in Ruby are powerful, and they’re used _everywhere_. You can pass blocks implicitly to enumerable methods like `map` and `select` simply by adding `{ ... }` or `do ... end` after the method name. You can explicitly create [closures](https://en.wikipedia.org/wiki/Closure_(computer_programming)) (aka anonymous functions) by using `proc`, `lambda`, or `->()` semantics and pass them around as method arguments or store them as variables. Yes, blocks are pretty magical.

But we’re not here to talk about how to write blocks per se or what they’re good for. We’re here to talk about _where they come from_.

> What do you mean, where they come from? They come from programmers, silly!

Well, obviously…but I don’t mean how they originate in the minds of intrepid Rubyists everywhere — I mean where do they come from in the execution context of your Ruby program?

> Oh OK. Yes, I’d like to know that too.

Awesome sauce! So let’s dive into what exactly happens when a block is first created.

### Behold the Mighty Binding!

When you write a block, you aren’t merely defining some lines of code that will get executed later. You’re also creating a _binding_. A binding is the execution context in which the block will eventually be executed. It consists of:

* the current receiver — i.e., what the value of `self` is inside your block
* local variables — i.e., any variables that were in the scope of your program right before the block was defined

Bindings are actually instances of the `Binding` class, which means you can inspect the binding of any block’s `Proc` instance you have access to.

> Wait wut?

Yep, in Ruby virtually everything is an object, even blocks (in the form of `Proc` instances). If you’re coming from a less dynamic language (say, Javascript), prepare to have your mind blown! Here’s an example:

```ruby
abc = 123
block = proc {}
block.binding.local_variable_get(:abc) # 123

xyz = 987
block.binding.local_variable_get(:xyz) # NameError (local variable `xyz' is not defined for #<Binding>)

block.binding.local_variables # [:block, :abc, ...]
```

The reason the first variable (`abc`) was part of the binding and the second (`xyz`) wasn’t is because blocks inherit their parent scope at the point where the block is defined, but anything added in that scope later isn’t accessible from within the block. This is sometimes referred to as “lexical scope”.

However — and this is important to note — changes to existing variables *are* accessible. Check this out:

```ruby
abc = 123
block = proc { puts abc }
block.binding.local_variable_get(:abc) # 123
block.call # 123

abc = 456
block.binding.local_variable_get(:abc) # 456
block.call # 456
```

The binding stores references to local variables by name (i.e., it doesn’t copy any variables), so when your variable was reassigned with a different value later, the block could still access the new value.

Of course, you can also reassign variables within a block and the new values are accessible outside the block:

```ruby
abc = 1
proc { abc = 2 }.call

puts abc # 2
```

But what if you want to “hide” a local variable from inside a block — i.e., the variable isn’t included in the block scope and changes don’t propagate back up to the parent scope? Never fear! You can create what are called “block-local variables” by listing them in the block’s parameter list, preceded by a semicolon:

```ruby
abc = 1
proc do |;abc|
  puts abc.nil? # true
  abc = 2
  puts abc
end.call # 2

puts abc # 1
```

So that’s pretty cool! But here’s where things get a little confusing: if you call `binding.local_variable_get(:abc)` on the proc even when specifying `abc` as a block-local variable, you get back the value `1`, not `nil`. I guess that’s because the binding is telling you about the context the block has been bound to, not necessarily what the exact state of affairs will be inside the block. If you know of a way to introspect block-local variables through the `Binding` object, please let me know!

### It is Better to Give Than to Receiver

Another thing to take a look at is the **receiver** of the binding. Any method calls you make implicitly or explicitly to `self`, as well as any instance variables you access, will all be bound to the receiver. When you’re testing this out in IRB or in a basic Ruby script, the receiver will be the `main` object (unless you are inside of another object). Here’s an example:

```ruby
block = proc {}
puts block.binding.receiver # main

class MyObject
  def receiver
    block = proc {}
    block.binding.receiver # return current scope's self, aka MyObject instance
  end
end

puts MyObject.new.receiver.class # MyObject
```

Now here’s where things get _really_ trippy. Ruby lets you **change the receiver of a block!** Yep, that’s right: you can swap one receiver out for another and when you execute the block its `self` will be different than the originally bound receiver.

```ruby
abc = 123

block = proc do
  puts abc
  puts self.xyz # explicit so you can see what's going on
end

block.call # NoMethodError (undefined method `xyz' for main:Object)

class MyObject
  def xyz
    456
  end
end

obj = MyObject.new
block.binding.receiver = obj
block.call
```

Run that and…oh wait, oops, that doesn’t work! 🙁 That’s because there is no `receiver=` method for `binding` like you might expect. Fortunately, there’s another way to go about things (in Ruby there almost always is!). We can use the `instance_exec` method of the object itself. Let’s fix the code and try again:

```ruby
abc = 123

block = proc do
  puts abc
  puts self.xyz
end

block.call # still causes an error…but wait!

class MyObject
  def xyz
    456
  end
end
obj = MyObject.new

# Time to try out instance_exec!
obj.instance_exec(&block)
# output: 123
#         456
```

That works! 😃👍

So using `instance_exec` is very similar to using `call`, only you pass the block in as the first argument (just make sure to include the ampersand in front of the block variable). Any additional arguments will be passed to the block itself, same as any arguments you would give `call`. When you use `instance_exec` to execute the `block` proc, it’s then able to access the `xyz` method of `obj` — whereas before there was no `xyz` method available. In addition, even if you use `instance_exec`, the block still has access to the original local variables (`abc`) as part of its binding.

If you wanted to get _really fancy_ with Ruby-fu metaprogramming, you could store the block’s bound receiver in a variable, then use `instance_exec` in combination with `method_missing` so that method calls in the context of the new object would actually end up shadowing those original receiver’s methods. Why on earth would you want to do this? Let’s just say I have a _story_ to tell you…but we’ll save that for a later date. 😄

### Summary

So there you have it: Ruby blocks are fun and weird and can do so much, yet they ask so little of us in return. May we learn to appreciate how much work they have to do under the hood to make it all seem so easy. And now that you know more about bindings, lexical scope, and the wizard-like power of `instance_exec`, you too can have precise control over exactly what’s going on as you wield (and `yield`) procs and lambdas like a _mahōtsukai_.