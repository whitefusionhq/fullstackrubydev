class Builders::Inspectors < SiteBuilder
  def build
    inspect_html do |document|
      document.query_selector_all("a").each do |anchor|
        next if anchor[:target]

        next unless anchor[:href]&.starts_with?("http") && !anchor[:href]&.include?(site.config.url)

        anchor[:target] = "_blank"
      end
    end

    inspect_html do |document|
      document.query_selector_all("article h2[id], article h3[id]").each do |heading|
        heading << document.create_text_node(" ")
        heading << document.create_element(
          "a", "#",
          href: "##{heading[:id]}",
          class: "heading-anchor"
        )
      end
    end
  end
end
