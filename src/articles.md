---
layout: page
title: Articles
exclude_from_search: true
pagination:
  enabled: true
---

{% posts = paginator.documents %}
{%= liquid_render "bulmatown/collection", collection: posts, metadata: site.metadata %}

{%= liquid_render "bulmatown/pagination", paginator: paginator %}