Mill house
==========

Mill house is a develop environment that includes Git repository, issue tracker, Continuous Integration, etc.


Installation
------------

Installation is very simple. with Vagrant or shell script.


```sh
# Using vagrant
$ vagrant up
# Or using shell script
$ ./install.sh
```


### GitLab CI runner

You have to enter GitLab CI token on GitLab CI runner.
GitLab CI web console is at _http://localhost:18181/_.

1. Copy GitLab CI token on _Admin_ -> _Runners_.
2. Run this command on terminal
    ```sh
    $ docker exec -it gitlab-runner gitlab-runner register
    Please enter the gitlab-ci coordinator URL (e.g. http://gitlab-ci.org:3000/):
    http://localhost:18181/
    Please enter the gitlab-ci token for this runner:
    <Your copied token here>
    Please enter the gitlab-ci description for this runner:
    [06c8c47f317e]: docker-on-millhouse
    INFO[0048] b5fbcb73 Registering runner... succeeded
    Please enter the executor: ssh, shell, parallels, docker, docker-ssh:
    [shell]: docker
    Please enter the Docker image (eg. ruby:2.1):
    gitlab-ci-box
    If you want to enable mysql please enter version (X.Y) or enter latest?

    If you want to enable postgres please enter version (X.Y) or enter latest?

    If you want to enable redis please enter version (X.Y) or enter latest?

    If you want to enable mongo please enter version (X.Y) or enter latest?

    INFO[0066] Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded!
    ```


Usage
-----

You can browse GitLab on http://localhost:10080 and Jenkins CI on http://localhost:18888.
GitLab's default root password is "5iveL!fe". You should change this at the first login.


### Project setup

When you create a project on GitLab, GitLab CI automatically build your project for Continuous Integration.

1. Create own project on GitLab.
2. Enable GitLab CI on web console (http://localhost:18181/).


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
