require 'bundler/gem_tasks'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'rbeapi/version'

task :build do
    system "gem build rbeapi.gemspec"
end

RPM_OPTS = '--define "_topdir %(pwd)/rpmbuild" --define "_builddir %{_topdir}" --define "_rpmdir %(pwd)/rpms" --define "_srcrpmdir %{_rpmdir}" --define "_sourcedir  %(pwd)" --define "_specdir %(pwd)" -bb'
desc "Generate regular and puppet-enterprise rbeapi RPMs for EOS"
task :rpm => :build do
    system "sed -e 's/^Version:.*/Version: #{Rbeapi::VERSION}/g' rbeapi.spec.tmpl > rbeapi.spec"
    system "rpmbuild #{RPM_OPTS} rbeapi.spec"
    system "rpmbuild #{RPM_OPTS} --define 'enterprise 1' rbeapi.spec"
    puts "RPMs are available in rpms/noarch/"
end

desc "Package the inifile gem in to regular and puppet-enterprise RPMs for EOS"
task :inifile do
    # Get the latest version info
    INIFILE_VERSION = `wget -q  --output-document=- https://rubygems.org/gems/inifile/versions.atom | awk -e '/title>inifile/ {match($2, \"[0-9.]+\", a); print a[0]; exit}'`.strip
    system "gem fetch inifile --version '=#{INIFILE_VERSION}'"
    puts "Building rpm for inifile (#{INIFILE_VERSION})"
    system "sed -e 's/^Version:.*/Version: #{INIFILE_VERSION}/g' gems/inifile/inifile.spec.tmpl > gems/inifile/inifile.spec"
    system "rpmbuild #{RPM_OPTS} gems/inifile/inifile.spec"
    system "rpmbuild #{RPM_OPTS} --define 'enterprise 1' gems/inifile/inifile.spec"
    puts "RPMs are available in rpms/noarch/"
end

desc "Package the net_http_unix gem in to an RPM for EOS"
task :net_http_unix do
    # Get the latest version info
    NET_HTTP_VERSION = `wget -q  --output-document=- https://rubygems.org/gems/net_http_unix/versions.atom | awk -e '/title>net_http_unix/ {match($2, \"[0-9.]+\", a); print a[0]; exit}'`.strip
    system "gem fetch net_http_unix --version '=#{NET_HTTP_VERSION}'"
    puts "Building rpm for net_http_unix (#{NET_HTTP_VERSION})"
    system "sed -e 's/^Version:.*/Version: #{NET_HTTP_VERSION}/g' gems/net_http_unix/net_http_unix.spec.tmpl > gems/net_http_unix/net_http_unix.spec"
    system "rpmbuild #{RPM_OPTS} gems/net_http_unix/net_http_unix.spec"
    puts "RPMs are available in rpms/noarch/"
end

desc "Generate all RPM packages needed for an EOS SWIX"
task :all_rpms => :build do
    Rake::Task['rpm'].invoke
    Rake::Task['inifile'].invoke
    Rake::Task['net_http_unix'].invoke
    puts "RPMs are available in rpms/noarch/"
    puts "Copy the RPMs to an EOS device then run the 'swix create' command."
    puts "  Example: cd /mnt/flash; swix create rbeapi-0.1.0-1.swix \\"
    puts "           rubygem-rbeapi-0.1.0-1.eos4.noarch.rpm \\"
    puts "           rubygem-inifile-3.0.0-1.eos4.noarch.rpm \\"
    puts "           rubygem-net_http_unix-0.2.1-1.eos4.noarch.rpm"
    puts "  For PE:: cd/mnt/flash; swix create pe-rbeapi-0.1.0-1.swix \\"
    puts "           pe-rubygem-rbeapi-0.1.0-1.eos4.noarch.rpm \\"
    puts "           pe-rubygem-inifile-3.0.0-1.eos4.noarch.rpm "
end

task :release => :build do
    system "gem push rbeapi-#{Rbeapi::VERSION}.gem"
end
