---
title: Everything You Need to Know About Destructuring in Ruby 3
subtitle: Updated for Ruby 3.1! How improved pattern matching and rightward assignment make it possible to “destructure” hashes and arrays in Ruby 3.
categories:
- Ruby 3 Fundamentals
author: jared
image: "/images/posts/gearbox.jpg"
image_hero: "/images/posts/gearbox.jpg"
image_credit:
  url: https://unsplash.com/photos/Hld-BtdRdPU
  label: Kiwihug on Unsplash
published: true
---

Welcome to our first article in a [series all about the exciting new features in Ruby 3](/topics/ruby-3-fundamentals)! Today we’re going to look how improved pattern matching and rightward assignment make it possible to “destructure” hashes and arrays in Ruby 3—much like how you’d accomplish it in, say, JavaScript—and some of the ways it goes far beyond even what you might expect. **December 2021: now updated for Ruby 3.1** — see below!

### First, a primer: destructuring arrays

For the longest time Ruby has had solid destructuring support for arrays. For example:

```ruby
a, b, *rest = [1, 2, 3, 4, 5]
# a == 1, b == 2, rest == [3, 4, 5]
```

So that’s pretty groovy. However, you haven’t been able to use a similar syntax for hashes. This doesn’t work unfortunately:

```ruby
{a, b, *rest} = {a: 1, b: 2, c: 3, d: 4}
# syntax errors galore! :(
```

Now there’s a method for Hash called `values_at` which you could use to pluck keys out of a hash and return in an array which you could then destructure:

```ruby
a, b = {a: 1, b: 2, c: 3}.values_at(:a, :b)
```

But that feels kind of clunky, y’know? Not very Ruby-like.

So let’s see what we can do now in Ruby 3!

### Introducing rightward assignment

In Ruby 3 we now have a “rightward assignment” operator. This flips the script and lets you write an expression _before_ assigning it to a variable. So instead of `x = :y`, you can write `:y => x`. (Yay for the hashrocket resurgence!)

What’s so cool about this is the smart folks working on Ruby 3 realized that they could use the same rightward assignment operator for **pattern matching** as well. Pattern matching was introduced in Ruby 2.7 and lets you write conditional logic to find and extract variables from complex objects. Now we can do that in the context of assignment!

Let’s write a simple method to try this out. We’ll be bringing our A game today, so let’s call it `a_game`:

```ruby
def a_game(hsh)
  hsh => {a:}
  puts "`a` is #{a}, of type #{a.class}"
end
```

Now we can pass some hashes along and see what happens!

```ruby
a_game({a: 99})

# `a` is 99, of type Integer

a_game({a: "asdf"})

# `a` is asdf, of type String
```

But what happens when we pass a hash that _doesn’t_ contain the “a” key?

```ruby
a_game({b: "bee"})

# NoMatchingPatternError ({:b=>"bee"})
```

Darn, we get a runtime error. Now maybe that’s what you want if your code would break horribly with a missing hash key. But if you prefer to fail gracefully, `rescue` comes to the rescue. You can rescue at the method level, but more likely you’d want to rescue at the statement level. Let’s fix our method:

```ruby
def a_game(hsh)
  hsh => {a:} rescue nil
  puts "`a` is #{a}, of type #{a.class}"
end
```

And try it again:

```ruby
a_game({b: "bee"})

# `a` is , of type NilClass
```

Now that you have a nil value, you can write defensive code to work around the missing data.

### What about all the \*\*rest?

Looking back at our original array destructuring example, we were able to get an array of all the values besides the first ones we pulled out as variables. Wouldn’t it be cool if we could do that with hashes too? Well now we can!

```ruby
{a: 1, b: 2, c: 3, d: 4} => {a:, b:, **rest}

# a == 1, b == 2, rest == {:c=>3, :d=>4}
```

But wait, there’s more! Rightward assignment and pattern matching actually works with arrays as well! We can replicate our original example like so:

```ruby
[1, 2, 3, 4, 5] => [a, b, *rest]

# a == 1, b == 2, rest == [3, 4, 5]
```

In addition, we can do some crazy stuff like pull out array slices before and after certain values:

```ruby
[-1, 0, 1, 2, 3] => [*left, 1, 2, *right]

# left == [-1, 0], right == [3]
```

### Rightward assignment within pattern matching 🤯

Ready to go all _Inception_ now?!

![freaky folding city GIF](/images/posts/inception.gif){:style="width:100%"}
{:.has-text-centered .mx-auto .my-5}
{:style="max-width:600px"}

You can use rightward assignment techniques **within a pattern matching expression** to pull out disparate values from an array. In other words, you can pull out everything up to a particular type, grab that type’s value, and then pull out everything after that.

You do this by specifying the type (class name) in the pattern and using `=>` to assign anything of that type to the variable. You can also put types in without rightward assignment to “skip over” those and move on to the next match.

Take a gander at these examples:

```ruby
[1, 2, "ha", 4, 5] => [*left, String => ha, *right]

# left == [1, 2], ha == "ha", right == [4, 5]

[8, "yo", 12, 14, 16] => [*left, String => yo, Integer, Integer => fourteen, *
right]

# left == [8], yo == "yo", fourteen == 14, right == [16]
```

Powerful stuff!

### And the pièce de résistance: the pin operator

What if you don’t want to hardcode a value in a pattern but have it come from somewhere else? After all, you can’t put existing variables in patterns directly:

```ruby
int = 1

[-1, 0, 1, 2, 3] => [*left, int, *right]

# left == [], int == -1 …wait wut?!
```

But in fact you can! You just need to use the pin operator `^`. Let’s try this again!

```ruby
int = 1

[-1, 0, 1, 2, 3] => [*left, ^int, *right]

# left == [-1, 0], right == [2, 3]
```

You can even use `^` to match variables previously assigned in the same pattern. Yeah, it’s nuts. Check out this [example from the Ruby docs](https://ruby-doc.org/core-3.0.0/doc/syntax/pattern_matching_rdoc.html):

```ruby
jane = {school: 'high', schools: [{id: 1, level: 'middle'}, {id: 2, level: 'high'}]}

jane => {school:, schools: [*, {id:, level: ^school}]}

# id == 2
```

In case you didn’t follow that mind-bendy syntax, it first assigns the value of `school` (in this case, `"high"`), then it finds the hash within the `schools` array where `level` matches `school`. The `id` value is then assigned from that hash, in this case, `2`.

So this is all amazingly powerful stuff. Of course you can use pattern matching in conditional logic such as `case` which is what all the original Ruby 2.7 examples showed, but I tend to think rightward assignment is even more useful for a wide variety of scenarios.

### "Restructuring" for hashes and keyword arguments in Ruby 3.1

New with the release of Ruby 3.1 is the ability to use a short-hand syntax to avoid repetition in hash literals or when calling keyword arguments.

First, let's see this in action for hashes:

```ruby
a = 1
b = 2
hsh = {a:, b:}

hsh[:a] # 1
hsh[:b] # 2
```

What's going on here is that `{a:}` is shorthand for `{a: a}`. For the sake of comparison, JavaScript provides the same feature this way: `const a = 1; const obj = {a}`.

I like `{a:}` because it's a mirror image of the hash destructuring feature we discussed above. Let's round-trip-it!

```ruby
hsh1 = {xyz: 123}

hsh1 => {xyz:}

# now local variable `xyz` equals `123`

hsh2 = {xyz:}

# hsh2 now equals `{:xyz=>123}`
```

Better yet, this new syntax doesn't just work for hash literals. It also works for keyword arguments when calling methods!

```ruby
def say_hello(first_name:)
  puts "Hello #{first_name}!"
end

# elsewhere…

first_name = "Jared"

say_hello(first_name:)

# Hello Jared!
```

Prior to Ruby 3.1, you would have needed to write `say_hello(first_name: first_name)`. Now you can DRY up your method calls!

Another goodie: the values you're passing via a hash literal or keyword arguments don't have to be merely local variables. They can be method calls themselves. It even works with `method_missing`!

```ruby
class MissMe
  def print_message
    miss_you(dear:)
  end

  def miss_you(dear:)
    puts "I miss you, #{dear} :'("
  end

  def method_missing(*args)
    if args[0] == :dear
      "my dear"
    else
      super
    end
  end
end

MissMe.new.print_message

# I miss you, my dear :'(
```

What's happening here is we're instantiating a new `MissMe` object and calling `print_message`. That method in turn calls `miss_you` which actually prints out the message. But wait, where is `dear` actually being defined?! `print_message` certainly isn't defining that before calling `miss_me`. Instead, what's actually happening is the reference to `dear` in `print_message` is triggering `method_missing`. That in turn supplies the return value of `"my dear"`.

Now this all may seem quite magical, but it would have worked virtually the same way in Ruby 3.0 and prior—only you would have had to write `miss_you(dear: dear)` inside of `print_message`. Is `dear: dear` any clearer? I don't think so.

In summary, the new short-hand hash literals/keyword arguments in Ruby 3.1 feels like we've come full circle in making both those language features a lot more ergonomic and—dare I say it—modern.

### Conclusion

While you might not be able to take advantage of all this flexibility if you’re not yet able to upgrade your codebase to v3 of Ruby, it’s one of those features I feel you’ll keenly miss after you’ve gotten a taste of it, just like keyword arguments when they were first released. I hope you enjoyed this deep dive into rightward assignment and pattern matching! Stay tuned for further examples of rightward assignment and how they improve the readability of Ruby templates. {%= ruby_gem %}
