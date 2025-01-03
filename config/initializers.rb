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

  keep_files ["pagefind"]

  collections do
    cheat_sheets do
      output true
      permalink "/cheat-sheets/:slug.*"
      relations do
        has_many "cheat_entries"
      end
    end
    cheat_entries do
      output false
      relations do
        belongs_to "cheat_sheet"
      end
    end
  end

  skip_pagefind_write = false
  hook :site, :post_write do |site|
    next if config.fast_refresh && skip_pagefind_write
    skip_pagefind_write = true

    `rm -rf output/pagefind && npx --yes pagefind --site output`
    Bridgetown.logger.info "Pagefind:", "Wrote search index"
  end
end
