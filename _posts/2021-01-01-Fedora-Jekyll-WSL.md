---
title: "Fedora on Windows Subsystem for Linux (WSL) and Jekyll"
excerpt: "Installing WSL, configuring Fedora and firing up Jekyll"
last_modified_at: 2021-01-1 17:00:00
tags:
  - Linux
  - WSL
  - Jekyll
---

Still a work in progress, but I have been mucking about with the Windows Subsystem for Linux. It's basically a linux VM with pretty good integrated support built into Windows 10. With CentOS declared dead, I'm looking at Fedora as a replacement. I also wanted to use it to muck with Jekyll on Github pages. Here's some of my notes from the process. Hopefully it saves someone some googling. 

Fire up an administrator powershell window, and run:

~~~~PowerShell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
~~~~

Download and follow the directions from https://github.com/yosukes-dev/FedoraWSL

For using git and github, check http://kbroman.org/github_tutorial/pages/first_time.html

You can access the Fedora file system at:
\\wsl$\Fedora33

You can access the Windows file system at:
/mnt/c/temp

~~~~bash
yum update
yum install wget iputils nano ruby ruby-devel zlib gcc make g++ git zlib-devel curl file libxcrypt-compat
yum groupinstall 'Development Tools'
dnf install @development-tools
dnf install @rpm-development-tools

gem install bundler
gem install jekyll
gem install github-pages

jekyll new git-site && cd git-site
~~~~

#Uncomment github in the _config.yml
Add your repository name with organization to your _config.yml, like: repository: henry/henrydf.github.io

~~~~bash
bundle update github-pages
bundle update jekyll
bundle update
bundle install

jekyll serve -w
bundle exec jekyll serve -w

git config --global user.email "your@email.com"
git config --global user.name "your username"
git config --global color.ui true
git config --global core.editor nano

ssh-keygen -t rsa -C "chris@casper.im"
# Add SSH key to github at https://github.com/settings/keys

chown root /etc/crypto-policies/back-ends/openssh.config

git config --global user.email "chris@casper.im"
git config --global user.name "chris-casper"

git init REPOSITORY-NAME
bundle exec jekyll serve
~~~~
