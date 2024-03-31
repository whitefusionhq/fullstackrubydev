---
title: Topics
layout: page
---

{% site.taxonomy_types.category.terms.each do |term, _| %}
  {% term_link = "/topics/#{slugify(term)}" %}
  {:style="font-size: 1.25em; font-weight: bold; margin-block-end: var(--wlm-prose-spacing)"}
  * {{ term | link_to: term_link }}

{% end %}
