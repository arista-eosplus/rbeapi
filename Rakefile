require 'bundler/gem_tasks'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'rbeapi/version'

task :build do
    system "gem build rbeapi.gemspec"
end

task :rpm => :build do
    system "cp rbeapi.spec.tmpl rbeapi.spec"
    system "sed -i -e 's/^Version:.*/Version: #{Rbeapi::VERSION}/g' rbeapi.spec"
    system 'rpmbuild --define "_topdir %(pwd)/rpmbuild" --define "_builddir %{_topdir}" --define "_rpmdir %(pwd)/rpms" --define "_srcrpmdir %{_rpmdir}" --define "_sourcedir  %(pwd)" --define "_specdir %(pwd)" -ba rbeapi.spec'
end

task :release => :build do
    system "gem push rbeapi-#{Rbeapi::VERSION}.gem"
end
