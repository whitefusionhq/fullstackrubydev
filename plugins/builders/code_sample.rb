class CodeSample < SiteBuilder
  def build
    liquid_tag :code_sample do |attributes|
      File.read(site.in_root_dir("code_samples", attributes))
    end
  end
end
