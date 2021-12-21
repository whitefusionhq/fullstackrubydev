class Builders::Mugshot < SiteBuilder
  def build
    if Bridgetown.env.production?
      hook :posts, :post_read do |post|
        post.data.image ||= "https://mugshotbot.com/m?theme=two_up&mode=light&color=8a1024&pattern=diagonal_lines&image=eed29abf&hide_watermark=true&url=#{CGI.escape(post.absolute_url)}"
      end
    end
  end
end
