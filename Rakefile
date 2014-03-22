require "bundler/gem_tasks"

doc_file = 'docs/index.markdown'

desc "Copy README.md contents into #{doc_file}"
task :update_docs do
  contents = File.open('README.md').read
  contents.sub!(/^# (.*)$/, "#{title('\1').strip}")
  File.open(doc_file, 'w') {|f| f.write(contents) }
  puts "Updated #{doc_file} from README.md"
end

def title(input)
  <<-YAML
---
title: "#{input.strip}"
---  
YAML
end
