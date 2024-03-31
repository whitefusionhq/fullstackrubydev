---
title: "Ractors: Multi-Core Parallel Processing Comes to Ruby 3"
subtitle: Historically, the only way you could truly achieve async parallelism in Ruby would be to fork multiple processes or schedule background jobs. Until now.
categories:
- Ruby 3 Fundamentals
author: jared
image: "/images/posts/so-many-roads.jpg"
image_hero: "/images/posts/so-many-roads.jpg"
image_credit:
  url: https://unsplash.com/photos/SXsxdZ5shaw
  label: Mukund Nair on Unsplash
published: true
---

For the longest time, I've wanted to be able to do a very simple thing in Ruby.

I've wanted to be able to run a block of expensive code multiple times in parallel and see all my CPU cores light up. ✨

This was very hard to do before! While Ruby does support multi-threaded code, only one thread at a time can be actively executing instructions (due to the Global Interpreter Lock, or GIL). That's fine for apps that are often waiting on external I/O and so forth, but it doesn't help you much if all your app is primarily concerned with is internal data processing. Historically, the only way you could truly achieve async parallelism in Ruby would be to fork multiple processes or schedule background jobs.

_Until now._

Welcome to **Ractor**, a brand-new method of running async code in Ruby 3.

### OK, Ractor sounds cool. But what is it?

Ractor is an experimental new class in the Ruby corelib. With ractors, Ruby has for the first time lifted restrictions on the GIL. Now you can have multiple "RILs" if you will—aka one interpreter lock per ractor (and shared between multiple threads within a single ractor if you spawn threads).

Ractor is shorthand for “Ruby actor”. The actor concept has long been established in other languages such as Elixr to handle concurrency concerns. Essentially an actor is a unit of code that executes asynchronously and uses message passing to send and receive data from the main codepath or even other actors. For more on the history and conceptual thinking behind Ruby actors, [read this Scout APM blog post](https://scoutapm.com/blog/ruby-ractor) by Kumar Harsh.

There are a variety of patterns at your disposal when using ractors, some of which are explained in the [extensive Ractor documentation](https://docs.ruby-lang.org/en/3.0.0/doc/ractor_md.html#label-Examples).

I'm very impressed by how simple it is to program with ractors. I've tried to work with Threads or gems in the past that aid with async development, and it's always made my brain hurt with little to show for my efforts. Using the `Ractor` class is about as easy as I could possibly imagine (short of a one-line `async` keyword).

The other thing I’m impressed by is how straightforward it is to get deterministic, ordered output from multiple ractors. In the past if I tried to use threads to process data and add the outputs to an array, the array values would be out of order. If thread 1 finished _after_ thread 2, the final array would be in 2, 1 order. With the `ractors.map(&:take)` pattern, you're guaranteed that even if one ractor takes 2 seconds to process and another takes 6, you'll still end up with an array of values in the same order in which you started up the ractors.

### Example Time!

I wanted to create the most basic example of ractors I could think of that would also be an interesting sort of benchmark comparing to typical, synchronous Ruby code.

Here’s a script that spins up 20 ractors which perform some intensive data processing and return an output value, and the final script output is a joined array of all the ractor outputs.

```ruby
require "benchmark"

ractors = []
values = []

puts "Starting Ractor processing"

time_elapsed = Benchmark.measure do
  20.times do |i|
    ractors << Ractor.new(i) do |i|
      puts "In Ractor #{i}"
      5_000_000.times do |t|
        str = "#{t}"; str = str.upcase + str;
      end
      puts "Finished Ractor #{i}"
      "i: #{i}" # implicit return value, or use Ractor.yield
    end
  end

  values = ractors.map(&:take)
end

# avg: 22 seconds, 1.6x performance over not_ractors
puts "End of processing, time elapsed: #{time_elapsed.real}"

# deterministic output. nice!
puts values.join(", ")
```

As you can see, using the `Ractor` class can be nearly as easy as working with standard lambdas. You don’t have to spend much mental overhead working through any additional data structures, scheduling, or thread concepts like mutexes. It “just works”.

And not only that, but it’s noticeably faster than a non-`Ractor`-based script:

```ruby
require "benchmark"

values = []

puts "Starting Not-Ractor processing"

time_elapsed = Benchmark.measure do
  20.times do |i|
    puts "In Not-Ractor #{i}"
    5_000_000.times do |t|
      str = "#{t}"; str = str.upcase + str;
    end
    puts "Finished Not-Ractor #{i}"
    values << "i: #{i}"
  end
end

# 34.5 seconds, fans spun up !!!
puts "End of processing, time elapsed: #{time_elapsed.real}"

puts values.join(", ")
```

After a number of runs of both scripts on my tricked-out 16” MacBook Pro, the ractors exhibited a 1.6x performance increase. I’ve heard reports of other tests where converting Ruby code to use ractors resulted in 3x performance increases.

It’s very exciting to run a Ruby script and see every CPU light up in Activity Monitor, plus I noticed the single-core script made my fans spin up whereas the multi-core script kept my fans nearly inaudible.

### Caveats

As cool as ractors are, you can’t just flip a switch and `Ractor` all the things (!). There are a number of limitations around how sharing objects and passing them back and forth via messages works—limitations that make sense considering we’re now bypassing the GIL. So it really does require a whole new level of thinking around how you structure your objects, methods, and data structures in general (particularly objects which are “global” in nature). As an example of something I’m hoping to work on soon, I recently started a rewrite of the content pipeline in [Bridgetown](https://www.bridgetownrb.com) (a static site generator). When Bridgetown is processing a site, there are a number of shared objects in memory—most notably, a site object and a series of collection objects. Typically, when a particular page/post/etc. is getting loaded, it adds itself to the necessary arrays in the site or the collection. With ractors, you can’t do that! Multiple concurrent ractors running in parallel can’t be modifying shared state directly. Instead, you’d have to separate the whole process out into multiple stages: gather the metadata required to load the page, then spin up ractors to perform all the loading logic, and then use message passing to gather up the loaded pages from the ractors and add them to the shared objects.

That’s the theory anyway. I’ll have to report back (a) if it works, and (b) if it’s a performance improvement over the regular synchronous code. But the promise is there: by architecting your app or gem around the ractor concept, your Ruby code gains the ability to shuttle intensive operations off to all your CPU cores at once—potentially yielding monumental performance increases.

### Conclusion

Since Ruby 3 is so new and `Ractor` itself is marked experimental, I think it will take some time for the Ruby ecosystem at large to evolve into this exciting new direction. And it may take a few point releases for esoteric ractor bugs or gotchas to get resolved. But I have no doubt this will happen. The rewards are too tantalizing to be left on the table for long. Finally, we can look at other languages like Elixir or Go and, instead of sighing wistfully at how easy might be to write concurrent code, we can roll up our sleeves, fire up some ractors, and watch those CPU cores light up. {%= ruby_gem %}