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


### Merge Request

Normally you shouldn't push on master branch your WIP codes.
Make branch for that feature, and merge onto master branch.
But merge onto master yourself is not recommended. Use Merge Request for it.
The project manager and other can see your progress on that branch,
And the project manager can merge your codes onto master branch by clicking button on web page.


### Managing issues

You can reference issue on git commit message.
_\#issue\_number_ will be shown as link to the issue.
And _!MR\_number_ will be shown as link to the Merge Request.
