Bridgetown.configure do |config|
  timezone "America/Los_Angeles"
  # permalink "/:year/:slug/" – bug, need to use YAML file for now
  template_engine "serbea"
  pagination do
    enabled true
    per_page 8
  end
  html_inspector_parser "nokolexbor"

  init :"bridgetown-feed"
  init :"bridgetown-seo-tag"

  # TODO: fix this bug!
  keep_files ["_bridgetown", "pagefind"]

  # hook :site, :fast_refresh do |site|
  #   site.data._skip_pagefind = true
  # end

  skip_pagefind_write = false
  # TODO: why are hooks not getting block params ??!!?!!?!
  hook :site, :post_write do |site|
    next if config.fast_refresh && skip_pagefind_write
    skip_pagefind_write = true

    `rm -rf output/pagefind && npx --yes pagefind --site output`
    Bridgetown.logger.info "Pagefind:", "Wrote search index"
  end
end
