class Builders::Helpers < SiteBuilder
  def build
    helper :ruby_gem do
      '<img src="/images/ruby.svg" alt="small red gem symbolizing the Ruby language" width="14" style="vertical-align: -0.05em;margin-left: 0.1em" />'
    end
  end
end
