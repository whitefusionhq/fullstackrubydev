---
title: "Wrap a Class With Your Own DSL"
subtitle: "If you find yourself often needing to subclass a gnarly third-party Ruby class and configure it before use, you might want to wrap it in your own DSL."
categories:
- Object Orientation
layout: post
author: jared
image: /images/posts/hello-jekyll.jpg
image_hero: /images/posts/hello-jekyll.jpg
published: false
template_engine: liquid
---

Here's the final code example:

```erb
<% # tilt_dsl_template.erb %>

{% code_sample tilt/tilt_dsl_template.erb %}
```

```ruby
# tilt_dsl_example.rb

{% code_sample tilt/tilt_dsl_example.rb %}
```