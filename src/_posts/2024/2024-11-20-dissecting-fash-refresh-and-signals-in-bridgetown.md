---
date: Wed, 20 Nov 2024 09:24:48 -0800
title: Dissecting Bridgetown 2.0’s Signalize-based Fast Refresh
subtitle: How to rerender specific parts of a website based on the dependency graph of how modified code touches various pages.
category: Jamstack Frameworks
---

As the lead maintainer of the [Bridgetown web framework](https://www.bridgetownrb.com), I get work on interesting (and sometimes very thorny!) Ruby problems which veer from what is typical for individual application projects.

With version 2 of Bridgetown about to drop, I’m starting a series of articles regarding intriguing aspects of the framework’s internals. This time around, we’re taking a close look at one of the marquee features: **Fast Refresh**.

## The Feedback Loop

Bridgetown is billed as a “progressive site generator” which offers a “hybrid” architecture for application deployments. What all this jargon means is that you can have both statically-generated content which is output as final HTML and other files to a destination folder, and dynamically-served routes which offer the typical request/response cycle you see in traditional web applications.

When it comes to the common development feedback loop of save-and-reload, traditional web applications are fairly straightforward. You make a change to some bit of code or content, you reload your browser tab which makes a new request to the application server, and *BOOM!* You’re refeshed.

But what about in a static site? You make a change, and suddenly the question becomes: _which_ HTML files need to be regenerated? And what if your change isn’t in a specific page template or blog post or whatever, but some shared template or model or even another page that’s referenced by the one you’re trying to look at? Suddenly you’re talking about the possibility that your change might require regenerating only one literal `.html` file…or _thousands_. As the saying goes, **it depends**.

Prior to the fast refresh feature, Bridgetown regenerated _an entire website_ on every change. You fix a typo in a single Markdown file…entire site regenerated. You update a logo URL in a site layout header…entire site regenerated. This may sound like a slow and laborious process, but on most sites of modest size, complete regeneration is only a second or two. Not that big of a deal, right?

And yet…some sites definitely grow beyond modest size. On my personal blog [Jared White.com](https://jaredwhite.com), the number of resources (posts, podcast episodes, photos, etc.) plus the number of generated pages (tag archives, category archives, etc.) has reached around 1,000 at this point, with no signs of stopping. What used to be measured in the milliseconds is now measured in the **seconds** on a full build—and while that’s perfectly reasonable in production when a site’s deploying, it _stinks_ when you’re talking about that save-and-reload process in development.

Hence the need for a new approach. Some frameworks call this “incremental regeneration”, but I think “fast refresh” sounds cooler. Bridgetown has already had a live reload feature since its inception—aka, you don’t need to manually go to your browser and reload the page, **the framework does it for you**. But now with fast refresh enabled, your browser reloads almost instantly! It’s so fast, sometimes by the time I get back to my browser window, *the change has already appeared*. What a huge quality of life improvement! **DX at its finest.**

But how did we pull off such a feat? How do we know _which_ `.html` files need to be regenerated? Is it ✨ magic ✨? The power of AI?

Nope. Just some good ol’ fashioned dependency-tracking via linked lists and closures…aka Signals. What the what? **Let’s dive in.**

## I thought "signals" was a frontend thing. Why does Ruby need them?

I’ve [talked a lot about signals before](https://www.fullstackruby.dev/podcast/9/) here on Fullstack Ruby so I won’t go into the whole rationale again. Suffice it to say, if you need to establish any sort of dependency graph such that when one piece of data over _here_ changes, you need to be notified so you can update another piece of data over _there_, the signals paradigm is a compelling way to do it. At first glance it looks a lot like the “observables” pattern, but where observables require a manual opt-in process (you as the developer need to indicate which bit of data you’d like to observe), signals do this automatically. When you write an “effect” closure (in JavaScript called a function, in Ruby called a proc) and access any signals-based data within that closure, a dependency is created between the effect and that signal (tracked using linked lists under the hood). Any time in the future some of that data changes, because the effect is dependent on the data, it is executed again. This automatic re-run functionality is what makes signals feel like ✨ magic ✨.

Some signals are “computed”—meaning you write a special closure to access one or more other signals, perform some calculation, and return a result. Computed signals update “lazily”—in other words, the calculation is only performed at the point the result is required. Under the hood, a computed signal is built out of an effect, which means when you write your own effects to access the values of computed signals, effects are dependent on other effects. Again, it can feel like ✨ magic ✨ until you understand how it works.

Now it’s true that the signals paradigm has taken off like wildfire on the frontend as a serious solution to the state -> UI update lifecycle. You need to know which specific parts of the interface need to be rerendered based on which specific state has changed.

_Hmm._

Rerendering based on changes to data. *Now where have I heard that one before?*

Yeah, that’s it! Sounds an awful lot like the exact problem Bridgetown faces when you modify code or content in a file. We need to know how to rerender specific parts of the interface (aka which particular `.html` files) based on the dependency graph of how your modified code touches various pages.

Here’s how Fast Refresh solves the problem by effectively utilizing the [Signalize gem](https://github.com/whitefusionhq/signalize). For a framework-level overview of the feature, [check out this post on the Bridgetown blog](https://www.bridgetownrb.com/future/road-to-bridgetown-2.0-fast-refresh/).

## Transformations in Effects

The first road along our journey is making sure the process of _transformation_—aka compiling Markdown down to HTML, rendering view components, placing page content inside of a layout, etc. is wrapped in an _effect_. This way, if during the course of transforming Page A, there's a reference to the “title” signal of Page B, any future change to Page B's “title” would trigger a rerun of Page A's transformation.

However, it's a wee bit more complicated than that. We don't want to perform the rerender immediately when the effect is triggered for a variety of reasons (performance, avoiding infinite loops, etc.). We instead want to _mark_ the resource which needs to be transformed, and then later on we'll go through all of the queued resources in a single pass in order to perform transformations.

Here's a snippet from the Bridgetown codebase of what that looks like:

```ruby
# bridgetown-core/lib/bridgetown-core/resource/base.rb
def transform!
  internal_error = nil
  @transform_effect_disposal = Signalize.effect do
    if !@fast_refresh_order && @previously_transformed
      self.content = untransformed_content
      @transformer = nil
      mark_for_fast_refresh! if site.config.fast_refresh && write?
      next
    end

    transformer.process! unless collection.data?
    slots.clear
    @previously_transformed = true
  rescue StandardError, SyntaxError => e
    internal_error = e
  end

  raise internal_error if internal_error

  self
end
```

There are a few things going here, so let's walk through it:

* We set up our effect using `Signalize.effect` by wrapping logic within the block.
* Every time there's a full build, transformations start anew, so the value of `@previously_transformed` will be falsy (aka `nil`). Thus we go ahead with the `process!` method of the transformer object.
* If in the future this effect has been triggered "out of band", meaning there was a downstream change in a dependency, that first `if` statement conditional will run. We'll reset the transformation pipeline, mark the resource for fast refresh, and exit.
* For the curious: we have to be cautious about handling errors during transformations (perhaps raised in executing code in userland when a template is processed) because Signalize's internals require special cleanup and we don't want to eject out of the block prematurely.

So that's one facet of the overall process. Here's another one: we needed to refactor resource data (front matter + content) to use signals, otherwise our effects will be useless.

Here's a snippet showing what happens when new data is assigned to a resource:

```ruby
# bridgetown-core/lib/bridgetown-core/resource/base.rb
def data=(new_data)
  mark_for_fast_refresh! if site.config.fast_refresh && write?

  Signalize.batch do
    @content_signal.value += 1
    @data.value = @data.value.merge(new_data)
  end
  @data.peek
end
```

First of all, we immediately mark the resource itself as ready for fast refresh. This is to handle the first-party use case where someone has made a change to a resource and we definitely want to rerender that resource…no need for a fancy dependency graph in that case!

Next, we create a batch routine to set a couple of signals: updating the data hash itself, and incrementing the “content” signal. For legacy reasons, we don't use a signal internally to store the body content of a resource, but we still track its usage via an incrementing integer.

All right, so we now have two core pieces of functionality in place. We can track when a resource is directly updated, and we can also track when another resource is updated that the first one is dependent on in order to rerender both of them.

(I’ll leave out all of the primary file watcher logic which matches file paths with resources or other data structures in the first place and handles all the queue processing because it's quite complex. [You can look at it here](https://github.com/bridgetownrb/bridgetown/blob/main/bridgetown-core/lib/bridgetown-core/concerns/site/fast_refreshable.rb).)

Instead, let's turn our attention to yet another use case: you've just updated the template of a component (say, a site-wide page header). How could Bridgetown possibly know which resources (in this instance, probably all of them!) need to be rerendered? Well, the solution is to use signal tracking when rendering components!

Here's the method which runs when a component is rendered. If fast refresh is enabled, we create or reuse an incrementing integer signal cached using a stable id (the location of the component source file), and then “subscribe" the effect that's in the process of executing to that signal.

```ruby
# bridgetown-core/lib/bridgetown-core/component.rb
def render_in(view_context, &block)
  @view_context = view_context
  @_content_block = block

  if render?
    if helpers.site.config.fast_refresh
      signal = helpers.site.tmp_cache["comp-signal:#{self.class.source_location}"] ||=
        Signalize.signal(1)
      # subscribe so resources are attached to this component within effect
      signal.value
    end
    before_render
    template
  else
    ""
  end

  # and some other stuff…
end
```

Later on, when it’s time to determine which type of file has just changed on disk, we loop through component paths, and if we find one, increment the corresponding cached signal.

```ruby
# bridgetown-core/lib/bridgetown-core/concerns/site/fast_refreshable.rb
def locate_components_for_fast_refresh(path)
  comp = Bridgetown::Component.descendants.find do |item|
    item.component_template_path == path || item.source_location == path
  rescue StandardError
  end
  return unless comp

  tmp_cache["comp-signal:#{comp.source_location}"]&.value += 1

  # and some other stuff…
end
```

So now, any time a component changes, the resources which had _previously_ rendered that component will get marked for fast refresh and thus rerendered. (We do a similar thing for template partials as well.)

## Create Your Own Signals

There's so much more we could go over, but I'll mention one other cool addition to the system. Bridgetown offers the concept of a "site-wide" data object, which you can think of as global state. Site data (accessed via `site.data` naturally) can come from specific files which get read in from the `src/_data` folder like `.csv`, `.yaml`, or `.json`, but it can also be provided by code which runs at the start of a site build via a Builder.

Bridgetown 2.0's fast refresh necessitated the need to make even site data reactive, so that's exactly what we did using a special feature of the Signalize gem: `Signalize::Struct` (with some Bridgetown-specific enhancements layered in to make it feel more Hash-like).

In a nutshell, you can now set global data with `site.signals.some_value = 123` and read that later with `site.signals.some_value`. In any template for a resource, a component, whatever, if you read in that value you'll make that template dependent on the signal value. So in the future, when that signal changes for any reason, your template(s) will get rerendered to display the new value.

Bridgetown uses this internally for "metadata" (aka site title, tagline, etc.) so templates can get refreshed if you update the metadata, and who knows what use cases might be unlocked by this feature in the future? For example, you could spin up a thread and poll an external API such as a CMS every few seconds, and once you detect a new changeset, update a signal and get your site fast refreshed with the API's new content.

## Fast Refresh Edge Cases

As anyone who has worked on incremental regeneration for a static site generator can tell you, *the devil's in the details*. There are so many edge cases which can make it seem like the site is "broken" — aka you update a piece of data over here, and then view some page over there and wonder why nothing got updated. 🧐

Some solutions have come in the form of **elaborate JavaScript frontend frameworks** which require complex data pipelines and GraphQL and TypeScript and static analysis and Hot Module Reload and an ever-growing string of buzzwords…and even then, performance in other areas can suffer such as on first build or when accessing various resources for the first time.

Bridgetown will no doubt ship its v2 with a few remaining edge cases, but I'm feeling confident we've dealt with most of the low-hanging fruit. I've been using alpha and beta versions of Bridgetown 2.0 in production on my own projects, and by now I'm so used to fast refresh making it so **I'm virtually never waiting for my browser to display updated content or UI**, I've forgotten the *bad old days* of when we didn't have this feature!

It was (and is) complicated to build, but I'm sure it would have been even harder and more byzantine if we'd needed to architect the feature from scratch. By leveraging the capabilities afforded by the [Signalize gem](https://github.com/whitefusionhq/signalize) and making it possible for dependency graphs to self-assemble based on how developers have structured their application code and site content, we now have a solid foundation for this major performance boost and can refactor bit by bit as issues and fixes arise.

Bridgetown 2.0 is currently in beta and slated for final release before the end of the year. If you’re looking to develop a new website or modest web application using Ruby, [check it out!](https://www.bridgetownrb.com) {%= ruby_gem %}
