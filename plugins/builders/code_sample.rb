class Builders::CodeSample < SiteBuilder
  def build
    code_sample = proc do |file_path|
      File.read(site.in_root_dir("code_samples", file_path))
    end

    liquid_tag :code_sample, &code_sample
    helper :code_sample, &code_sample
  end
end
