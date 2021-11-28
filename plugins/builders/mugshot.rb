class Builders::Mugshot < SiteBuilder
  def build
    if Bridgetown.env.production?
      hook :posts, :pre_render do |post|
        if !post.data.image
          posturl = CGI.escape "#{site.config.url}#{post.relative_url}"
          post.data.image = "https://mugshotbot.com/m?theme=two_up&mode=light&color=8a1024&pattern=diagonal_lines&image=eed29abf&hide_watermark=true&url=#{posturl}"
        end
      end
    end
  end
end
