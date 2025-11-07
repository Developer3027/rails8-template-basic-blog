# --- Version Checks ---
begin
  required_rails_version = Gem::Version.new("8.0.2")
  rails_spec = Gem::Specification.find_by_name("rails")
  current_rails_version = rails_spec.version

  if current_rails_version < required_rails_version
    say "#{INDENT}❌ Error: Needs Rails >= #{required_rails_version} (using #{current_rails_version})", :red
  else
    say "#{INDENT}✅ Rails #{current_rails_version} detected", :green
  end
rescue Gem::LoadError
  say "#{INDENT}❌ Error: Rails gem not found. Please ensure Rails is installed.", :red
  exit 1
rescue => e
  say "#{INDENT}⚠️ Rails version check failed: #{e.message}", :yellow
end

# Ruby check
begin
  ruby_version_output = `ruby -v`.chomp
  required_ruby = Gem::Version.new("3.3.0")
  match = ruby_version_output.match(/ruby (\d+\.\d+\.\d+)/)
  if match
    current_ruby = Gem::Version.new(match[1])
    if current_ruby < required_ruby
      say "#{INDENT}❌ Error: Requires Ruby >= #{required_ruby} (found #{ruby_version_output})", :red
      exit 1
    else
      say "#{INDENT}✅ Ruby #{current_ruby} detected", :green
    end
  else
    say "#{INDENT}❌ Error: Could not determine Ruby version from `ruby -v` output: #{ruby_version_output}", :red
  end
rescue => e
  say "#{INDENT}⚠️ Ruby version check failed: #{e.message}", :yellow
end

# FFmpeg check
begin
  say "#{INDENT}Checking for FFmpeg...", :blue
  `ffmpeg -version 2>&1`
  raise "FFmpeg not found or not working." unless $?.success?

  say "#{INDENT}✅ FFmpeg detected", :green
rescue Errno::ENOENT
  say "#{INDENT}❌ Error: FFmpeg not found. Please install FFmpeg (e.g., `sudo apt install ffmpeg`).", :red
  exit 1
rescue => e
  say "#{INDENT}⚠️ FFmpeg check failed: #{e.message}", :yellow
  exit 1
end

  # libvips check
begin
  say "#{INDENT}Checking for libvips (via 'vips' command)...", :blue
  `vips --version 2>&1`
  raise "libvips not found or not working." unless $?.success?

  say "#{INDENT}✅ libvips detected", :green
rescue Errno::ENOENT
  say "#{INDENT}❌ Error: libvips not found. Please install libvips (e.g., `sudo apt install libvips` or `brew install vips`).#{RESET}", :red
  exit 1
rescue => e
  say "#{INDENT}⚠️ libvips check failed: #{e.message}", :yellow
  exit 1
end

# Node check
begin
  node_version_output = `node -v`.chomp
  match = node_version_output.match(/v(\d+)\./)
  if match
    node_major = match[1].to_i

    if node_major < 18
      say "#{INDENT}⚠️ Warning: Node 18.x recommended (found #{node_version_output})", :yellow
    else
      say "#{INDENT}✅ Node #{node_version_output} detected", :green
    end
  else
    say "#{INDENT}❌ Error: Could not determine Node version from `node -v` output: #{node_version_output}", :red
  end
rescue Errno::ENOENT
  say "#{INDENT}❌ Error: Node.js not found. Please ensure Node.js is installed.", :red
rescue => e
  say "#{INDENT}⚠️ Node version check failed: #{e.message}", :yellow
end
