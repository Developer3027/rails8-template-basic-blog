# Main template file for generating a rails 8 blog.

# --- Template Configuration ---
# Define the desired indentation (e.g., 2 spaces)
# This is not used in the template itself, but for readability of the output messages.
INDENT = "  " # Two spaces - standard Ruby style

# ===== System Checks ====
# Run system checks
say "#{INDENT}Running system checks...", :blue
apply File.join(File.dirname(__FILE__), 'rails8-template-basic-blog', 'sys-checks.rb')

# CONFIRMATION
unless yes?("All checks passed.Continue with setup? (Y/n)", :cyan)
  say "Aborting template setup.", :red
  exit 0
end
