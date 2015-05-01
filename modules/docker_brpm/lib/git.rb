def clone_git_repo(git_repo_name, output_dir)
  BrpmAuto.log "Downloading the git repository for the application ..."

  root_git_repo_dir = "#{output_dir}/git_repos"

  FileUtils.rm_r(root_git_repo_dir) if Dir.exists?(root_git_repo_dir)

  Dir.mkdir(root_git_repo_dir)

  git_repo_dir = "#{root_git_repo_dir}/#{git_repo_name}"
  Dir.mkdir(git_repo_dir)

  BrpmAuto.exec_command("git clone https://github.com/brpm-dev/#{git_repo_name}.git #{git_repo_dir}")

  git_repo_dir
end
