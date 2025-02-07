---
date: Thu, 06 Feb 2025 19:05:45 -0800
title: Finding My Happy Place with Hanami and Serbea Templates
subtitle: I figured it was high time I took Hanami for a spin with all the news it's been getting lately!
category: Hanami
---

It sure seems like the [Hanami web framework](https://hanamirb.org) been in the news lately, most notably the announcement that Mike Perham of [Sidekiq](https://sidekiq.org) fame [has provided a $10,000 grant to Hanami](https://www.mikeperham.com/2025/01/17/sponsoring-hanami/) to keep building off the success of version 2.2. I also deeply appreciate Hanami's [commitment to fostering a welcoming and inclusive community](https://hanamirb.org#our-community-values#:~:text=Our community values).

Thus I figured it was high time I took Hanami for a spin, so after running `gem install hanami`, along with a few setup commands and a few files to edit, I had a working Ruby-powered website running with Hanami! **Yay!!** 🎉

But then I started to miss the familiar comforts of [Serbea](https://www.serbea.dev), a Ruby template language based on ERB but with a few extra tricks up its sleeve to make it feel more like “brace-style” template languages such as Liquid, Nunjucks, Twig, Jinja, Mustache, etc. I've been using Serbea on nearly all of my [Bridgetown](https://www.bridgetownrb.com) sites as well as a substantial Rails client project, so it's second nature to write my HTML in this syntax. (Plus, y'know, Serbea is a [gem I wrote](https://rubygems.org/gems/serbea). 😋)

After feeling sad for a moment, it occurred to me that I'd read that Hanami—like many Ruby frameworks—[uses Tilt under the hood to load templates](https://guides.hanamirb.org/v2.2/views/templates-and-partials/#template-engines). _Ah ha!_ Serbea is also built on top of Tilt, so it shouldn't be too difficult to get things working. One small hurdle I knew I'd have to overcome is that I don't auto-register Serbea as a handler for ".serb" files, as Serbea requires a mixin for its "pipeline" syntax support as an initial setup step. So I'd need to figure out where that registration should go and how to apply the mixin.

Turns out, there was a pretty straightforward solution. (Thanks Hanami!) I found that templates are rendered within a `Scope` object, and while a new Hanami application doesn't include a dedicated "base scope" class out of the box, it's very easy to create one. Here's what mine looks like with the relevant Serbea setup code:

{% raw %}
```ruby
# this file is located at app/views/scope.rb

require "serbea"

Tilt.register Tilt::SerbeaTemplate, "serb"

module YayHanami
  module Views
    class Scope < Hanami::View::Scope
      include Serbea::Helpers
    end
  end
end
```

Just be sure to replace `YayHanami` with your application or slice constant. That and a `bundle add serbea` should be all that's required to get Serbea up and running!

Once this was all in place, I was able to convert my `.html.erb` templates to `.html.serb`. I don't have anything whiz-bang to show off yet, but for your edification here's one of Hanami's ERB examples rewritten in Serbea:

```serb
<h1>What's on the Bookshelf</h1>
<ul>
  {% books.each do |book| %}
    <li>{{ book.title }}</li>
  {% end %}
</ul>

<h2>Don't miss these best selling titles</h2>
<ul>
  {% best_sellers.each do |book| %}
    <li>{{ book.title }}</li>
  {% end %}
</ul>
```

This may not look super thrilling, but imagine you wanted to write a helper that automatically creates a search link for a book title and author to a service like [BookWyrm](https://bookwyrm.social). You could add a method to your Scope class like so:

```ruby
def bookwyrm(input, author:)
  "<a href='https://bookwyrm.social/search?q=#{escape(input)} #{escape(author)}'>#{escape(input)}</a>".html_safe
end
```

and then use it filter-style in the template:

```serb
<li>{{ book.title | bookwyrm: author: book.author }}</li>
```

I like this much more than in ERB where helpers are placed _before_ the data they're acting upon which to me feels like a logical inversion:

```erb
<li><%= bookwyrm(book.title, author: book.author) %></li>
```

Hmm. 🤨

{% endraw %}

Anyway, I'm totally jazzed that I got **Hanami** and **Serbea** playing nicely together, and I can't wait to see what I might try building next in Hanami! This will be an ongoing series here on **Fullstack Ruby** (loosely titled "Jared Tries to Do Unusual Things with Hanami"), so make sure that you [follow us on Mastodon](https://ruby.social/@fullstackruby) and subscribe to the newsletter to keep abreast of further developments. {%= ruby_gem %}
