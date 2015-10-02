require "rake/clean"
require 'yaml'

if not FileList.glob("rakeconfig.yaml").empty?
$config=YAML.load_file("./rakeconfig.yaml")
else
  warn("error, rakeconfig.yaml not found. creating it.")
YAML_NEW=<<EOS

excludes: ['.*readme.*','.*pandoc.*','.*README.*']
header_includes_file: 'header_includes.hincludes'
template: 'mymemo.latex'
EOS
  IO.write("rakeconfig.yaml",YAML_NEW)
  $config=YAML.load_file("./rakeconfig.yaml")
end

if FileList.glob($config['header_includes_file'].to_s).empty?
  IO.write($config['header_includes_file'].to_s,%{%put includes here})
end

task :default =>["installmd","clobber"]

task :clobber do
  puts CLEAN
end

$rmtex=true
$clean_str1 = Regexp.new("(.*\.(snm|out\.ps|nav|vrb|run\.xml|bcf|tmp|blg|toc|log|aux|bbl|fls|fdb_latexmk|synctex.gz))")
$clean_str2=Regexp.new("(.*(blx.bib))")




LATEX_SCRIPT_TO_RUN=<<EOS
pandoc "@input_file" "rakeconfig.yaml" -f markdown -t latex -o "@output_file" -s --template=#{$config['template'].to_s}  --include-in-header=#{$config['header_includes_file']} 
EOS


# This knitr script will set defaults so that you don't generally see anything for output except graphics or things marked for output as 'results'



my_md_files=FileList[Dir.glob("./*.md", File::FNM_CASEFOLD)]



task :installmd



task :installmd=>my_md_files.ext("pdf")




namespace :installmd do
  # file my_md_files.ext("pdf") => my_md_files
  rule ".pdf" =>".md" do |t|
    puts "#{t.source}#{t.name}"
    proc_and_move(t)
  end
end

define_method(:proc_and_move) do |t,*args|
  system %{
  #{LATEX_SCRIPT_TO_RUN.sub("@input_file",t.name.ext(".md")).sub("@output_file",t.name.ext(".tex"))}
  }
  # need to use error handling block here because sometimes biber throws error if run in latexmk
  begin
    sh %Q{latexmk -f -pdf "#{t.name.ext("tex")}"}  
  rescue
    error_string= "proceeding despite errors"
    puts error_string
  else


  end 
  if $rmtex==true then
  CLEAN.include(FileList[t.name.ext("tex")])
  end
  CLEAN.include(FileList[Dir.glob("*").find_all { |j| $clean_str1=~j }])
  # noinspection RubyResolve
  CLEAN.include(FileList[Dir.glob("*").find_all { |j| $clean_str2 =~j }])
  return  
end

### end new

