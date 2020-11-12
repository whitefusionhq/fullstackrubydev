---
title: Gsub Blocks, Partitions, and StringScanners, Oh My!
subtitle: "Ruby gives you a lot of flexibility right out of the box when it comes to manipulating text due to its Perl-flavored heritage. Let's dig into what's possible!"
categories:
- String Theory
author: jared
image: /images/posts/string-theory.jpg
image_hero: /images/posts/string-theory.jpg
image_credit:
  url: https://unsplash.com/photos/G-AQWUTgMZo
  label: Tara Evans on Unsplash
---

It should come as no surprise that Ruby gives you a lot of flexibility right out of the box when it comes to manipulating text. After all, it originated in the 90s when Perl was on the ascension, and [Matz](https://www.ruby-lang.org/en/about/) took inspiration from that language which is famous for its text processing prowess.

I’ve needed to do a fair bit of parsing work lately, and as part of that I’ve become more familiar with some of the ins and outs of using [Regular Expressions](https://regexr.com) to seek through text to find and possibly replace tokens. This is by no means an exhaustive resource, but it should provide you with a general idea of what’s possible in your day-to-day Ruby programming.

### Gsub

If you need to do a search and replace in one or more places throughout your string, [`gsub`](https://rubyapi.org/2.7/o/string#method-i-gsub) is typically the way to go. I think most Rubyists will discover this method pretty early on when learning about string manipulation.

What I _didn’t_ know until recently is you can pass a block to `gsub`. For each match in the string, the block will be evaluated and the return value will be the replacement for that match. This means you can write code that will determine the replacement values conditionally based on what exactly is getting matched!

For example, if you wanted to change `<div>` tags to `<span>` tags, but only if there are no attributes, you could write something like this:

```ruby
"<div>This is a string</div>" \
"<div class='centered'>This is another string</div>"
  .gsub(/(<.*?[ >])(.*?)(<\/.*?>)/) do |match|
    if $1.end_with?(" ")
      match
    else
      "<span>#{$2}</span>"
    end
  end

# <span>This is a string</span><div class='centered'>This is another string</div>
```

(Now this isn’t a great example because it doesn’t handle nested tags, but you get the idea…)

In case you’re not familiar with capture groups, the `$1` and `$2` are referencing the first capture group which is an opening tag (aka `<div>`) and the second capture group which is the text inside the tag.

`gsub` also lets you provide a hash where matches will be replaced by the values of matched keys:

```ruby
"Foo is the nicest bar you'll ever meet."
  .gsub(/Foo|bar/, "Foo" => "Joe", "bar" => "guy")

# Joe is the nicest guy you'll ever meet.
```

I suspect the block syntax is ultimately of more value though.

### Partition

The [`partition`](https://rubyapi.org/2.7/o/string#method-i-partition) method lets you divide a string into three pieces: the part of the string before a single match, the match itself, and everything that comes after that match. If you include capture groups in your regular expression, you can utilize those as well. One way you can take advantage of this type of data is by using `partition` to search a string for tokens, and build a new string up via a buffer as you transform the tokens.

Let’s say you want to be able to put colons around words where you’d like the word length to appear as a kind of footnote after the world. You want `text :like: this` to turn into `text like(4) this`.

Here’s how you could write it using `partition`, a buffer, and an `until` loop:

```ruby
string = "This is :something: you'll :want: to try :out: for yourself."
buffer = ""

until string.empty?
  text, token, string = string.partition(/ :(.*?): /)

  buffer << text

  if token.length.positive?
    buffer << " #{$1}"
    buffer << "(#{$1.length}) "
  end
end

puts buffer

# This is something(9) you'll want(4) to try out(3) for yourself.
```

Now, is this something you could do with a `gsub` block as described previously? Yes indeed:

```ruby
string = "This is :something: you'll :want: to try :out: for yourself."
string.gsub!(/ :(.*?): /) do
  " #{$1}(#{$1.length}) "
end

puts string
```

In fact that’s a lot simpler. _However_, in this example you don’t have access to any of the text before or after the token. If that’s something that’s important to you (maybe you need to process the token differently depending on what comes before it, or after it), you’ll want to use `partition`.

_Or will you??_ There is another way!

### StringScanner

Using [StringScanner](https://rubyapi.org/2.7/o/stringscanner) is like bringing a bazooka to a paintball tournament. It’s extraordinarily powerful, but it can also land you in some serious trouble—not to mention get a little mind bend-y if you’re not careful.

`StringScanner` is actually the name of a Ruby class in the standard library (`stdlib`), which you’ll need to import by adding `require "strscan"` to the top of your code. You use it by instantiating a scanner with a string, and then you use various methods to scan the string for patterns and advance a “pointer”.

Let’s say you want to replace “cake” with “pie” in a string, but _not_ if the keyword is preceded by “short” or if it’s followed by "pops". We'll use a buffer and do string replacement like in previous examples, but because we have all the benefits of a scanner it's pretty easy to look backwards and forwards and determine our next course of action.

```ruby
require "strscan"

string = "Let them eat cake and then more shortcake and finally cake pops!"
scanner = StringScanner.new(string)
buffer = ""

until scanner.eos?
  portion = scanner.scan_until(/cake/)
  if portion.nil?
    buffer << scanner.rest
    scanner.terminate
    next
  end
  unless scanner.pre_match =~ /short$/ or scanner.check(/\s+pops/)
    buffer << portion.sub(/cake/, "pie")
  else
    buffer << portion
  end
end

puts buffer

# Let them eat pie and then more shortcake and finally cake pops!
```

Whoa, what's going on here?

First, we set up an `until scanner.eos?` loop. This means the loop will iterate until we've reached the end of the string.

The `scan_until` method looks for a pattern and advances the current pointer to that location. (You can verify this by adding `puts scanner.pointer` below `scan_until`.) It returns the portion of the string that matches the pattern, so we can use that to perform string substitution to change "cake" to "pie".

However, we don't want to do the substitution if cake is preceeded immediately by "short", so we'll check for a regex match on everything that's come before the portion (`scanner.pre_match`) to see if it ends with "short". We also want to check if the very next part of the string is the word "pops", so we'll use the `scanner.check` method. This checks what comes immediately next in the string, but it _doesn't advance the pointer_. (There's also a `check_until` method which is analogous to `scan_until`.) By not advancing the pointer, we avoid messing up our position in the string and can continue looping normally.

The `if portion.nil?` block near the top of the loop handles the case where there are no more instances of "cake" in the string but there's still more to the string we need to account for. By adding the `.rest` of the string to our buffer and calling `scanner.terminate`, we force the scanner to advance to the end of the string, in which case `until scanner.eos?` will evaluate true and end the loop.

This example is fairly simple because it's only changing a single word to another word, so the substitution itself doesn't require any fancy regex. But combine `StringScanner` with all of the techniques we've already learned (`gsub` blocks, even `partition`), and you're able to build extremely sophisticated routines to handle nearly any kind of text processing imaginable.

### Summary

Whew, that's a lot to take in! Today you've leaned that `gsub` is much more than just a way to say that "a" should become "b". By supplying a block, you have precise control over the replacement strings by first inspecting each match of the source string.

In addition, the `partition` string method lets you divide a string into pre-match, match, and post-match components—and by doing so over and over in a loop and using a buffer, you can transform a large and complicated string section-by-section.

Finally, for the most precise control over searching text for one or more tokens and performing elaborate search-and-replace actions based on the relationships those tokens have with the rest of the text, the `StringScanner` object is there just waiting to unleash its full power. Not only that, your code can benefit from previous techniques in the midst of using `StringScanner` for maximum Ruby text processing prowess. {%= ruby_gem %}
