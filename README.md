Mill house
==========

Mill house is a develop environment that includes Git repository, issue tracker, Continuous Integration, etc.


Installation
------------

Installation is very simple. with Vagrant or shell script.


### Vagrant

```sh
$ vagrant up
```


### Shell script

```sh
$ ./install.sh
```

You have to manually setup GitLab hostname, url on Jenkins.

1. Go to GitLab web page.
2. Click _Profile settings_.
3. Click _Account_ on the left side.
4. Copy private token.
5. Go to Jenkins web page.
6. Click _Manage Jenkins_.
7. Click _Configure System_.
8. Input GitLab's hostname and paste the private token.
9. Setting Maven, Ant, etc. as you need to.


Usage
-----

You can browse GitLab on http://localhost:10080 and Jenkins CI on http://localhost:18888.
GitLab's default root password is "5iveL!fe". You should change this at the first login.


### Project setup

When you create a project on GitLab, You should create Jenkins job for Continuous Integration.
I installed _GitLab Plugin_ on Jenkins that makes GitLab think Jenkins as GitLab CI.

1. Create own project on GitLab.
2. Create Job on Jenkins.
3. Go to your project settings on GitLab project.
4. Click _Service_ tab on left side.
5. Click the _GitLab CI_.
6. Click on _active_, Set random token, Set project url as Jenkins give
(Project url is shown at _Build Triggers_ on Jenkins job configure).
