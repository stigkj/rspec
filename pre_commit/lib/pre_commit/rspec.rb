class PreCommit::Rspec < PreCommit
  def pre_commit
    check_for_gem_dependencies
    touch_revision_storing_files
    pre_commit_core
    update_dependencies
    pre_commit_rails
    ok_to_commit    
  end
  
  def check_for_gem_dependencies
    gem 'rake'
    gem 'rcov'
    gem 'webgen', '>= 0.4.2'
    gem 'RedCloth'
    gem 'syntax'
    gem 'diff-lcs'
    gem 'heckle'    
  end
  
  def touch_revision_storing_files
    # See http://svnbook.red-bean.com/en/1.0/ch07s02.html - the section on svn:keywords
    files = [
      'rspec/lib/spec/version.rb',
      'rspec_on_rails/lib/spec/rails/version.rb'
    ]
    new_token = rand
    files.each do |path|
      abs_path = File.join(root_dir, path)
      content = File.open(abs_path).read
      touched_content = content.gsub(/# RANDOM_TOKEN: (.*)\n/n, "# RANDOM_TOKEN: #{new_token}\n")
      File.open(abs_path, 'w') do |io|
        io.write touched_content
      end
    end
  end
  
  def pre_commit_core
    Dir.chdir 'rspec' do
      rake = (PLATFORM == "i386-mswin32") ? "rake.cmd" : "rake"
      system("#{rake} pre_commit --verbose")
      raise "RSpec Core pre_commit failed" if error_code?
    end    
  end

  def install_dependencies
    Dir.chdir 'example_rails_app' do
      RSPEC_DEPS.each do |dep|
        puts "\nChecking for #{dep[:name]} ..."
        dest = File.expand_path(File.join(root_dir, dep[:checkout_path]))
        if File.exists?(dest)
          puts "#{dep[:name]} already installed"
        else
          cmd = "svn co #{dep[:url]} #{dest}"
          puts "Installing #{dep[:name]}"
          puts "This may take a while."
          puts cmd
          system(cmd)
          puts "Done!"
        end
      end
      puts
    end    
  end
  
  def update_dependencies
    RSPEC_DEPS.each do |dep|
      raise "There is no checkout of #{dep[:checkout_path]}. Please run rake install_dependencies" unless File.exist?(dep[:checkout_path])
      # Verify that the current working copy is right
      if `svn info #{dep[:checkout_path]}` =~ /^URL: (.*)/
        actual_url = $1
        if actual_url != dep[:url]
          raise "Your working copy in #{dep[:checkout_path]} points to \n#{actual_url}\nIt has moved to\n#{dep[:url]}\nPlease delete the working copy and run rake install_dependencies"
        end
      end
      next if dep[:tagged?] #
      puts "\nUpdating #{dep[:name]} ..."
      dest = File.expand_path(File.join(root_dir, dep[:checkout_path]))
      system("svn cleanup #{dest}")
      cmd = "svn up #{dest}"
      puts cmd
      system(cmd)
      puts "Done!"
    end
  end
  
  def pre_commit_rails
    Dir.chdir 'example_rails_app' do
      rake = (PLATFORM == "i386-mswin32") ? "rake.cmd" : "rake"
      cmd = "#{rake} -f Multirails.rake pre_commit --trace"
      system(cmd)
      if error_code?
        message = <<-EOF
        ############################################################
        RSpec on Rails Plugin pre_commit failed. For more info:

          cd example_rails_app
          #{cmd}

        ############################################################
        EOF
        raise message.gsub(/^        /)
      end
    end
  end
  
  def ok_to_commit
    puts "OK TO COMMIT"
  end

  protected
  RSPEC_DEPS = [
    {
      :checkout_path => "example_rails_app/vendor/rails/1.1.6",
      :name =>  "rails 1.1.6",
      :url => "http://dev.rubyonrails.org/svn/rails/tags/rel_1-1-6",
      :tagged? => true
    },
    {
      :checkout_path => "example_rails_app/vendor/rails/1.2.1",
      :name =>  "rails 1.2.1",
      :url => "http://dev.rubyonrails.org/svn/rails/tags/rel_1-2-1",
      :tagged? => true
    },
    {
      :checkout_path => "example_rails_app/vendor/rails/1.2.2",
      :name =>  "rails 1.2.2",
      :url => "http://dev.rubyonrails.org/svn/rails/tags/rel_1-2-2",
      :tagged? => true
    },
    {
      :checkout_path => "example_rails_app/vendor/rails/1.2.3",
      :name =>  "rails 1.2.3",
      :url => "http://dev.rubyonrails.org/svn/rails/tags/rel_1-2-3",
      :tagged? => true
    },
    {
      :checkout_path => "example_rails_app/vendor/rails/edge",
      :name =>  "edge rails",
      :url => "http://svn.rubyonrails.org/rails/trunk",
      :tagged? => false
    },
    # NOTE - assert_select is only necessary for 1.1.6 (it is bundled in >= 1.2.x). If
    # discontinue support for 1.1.6, this can go.
    {
      :checkout_path => "example_rails_app/vendor/plugins/assert_select",
      :name =>  "assert_select",
      :url => "http://labnotes.org/svn/public/ruby/rails_plugins/assert_select",
      :tagged? => false
    }
  ]  
end