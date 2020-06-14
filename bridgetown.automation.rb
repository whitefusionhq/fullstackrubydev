require 'fileutils'

unless Dir.exist? "frontend/fonts"
  FileUtils.mkdir_p "frontend/fonts"
end

run "cp node_modules/fork-awesome/fonts/* frontend/fonts"
