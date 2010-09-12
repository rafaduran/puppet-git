# The git module
#
# License: GPLv3+
# Documentation: http://puppetmanaged.org/documentation/git-module.html
# Tickets: http://puppetmanaged.org/trac/report/12
#

class git {

    class client {

        #
        # Documentation on this class
        #
        # This class causes the client to gain git capabilities. Boo!
        #

        package { "git":
            ensure => installed
        }
    }

    class server inherits client {

        #
        # Documentation on this class
        #
        # Including this class will install git, the git-daemon, ensure the
        # service is running
        #

        if defined(Package["xinetd"]) {
            realize(Package["xinetd"])
        } else {
            @package { "xinetd":
                ensure => installed
            }

            realize(Package["xinetd"])
        }

        package { [
                "diffstat",
                "git-daemon"
            ]:
            ensure => installed
        }

        service { "git":
            enable => true,
            require => Package["git-daemon"],
            notify => Service["xinetd"]
        }

        service { "xinetd":
            enable => true,
            ensure => running,
            require => Package["xinetd"]
        }

        file { "/git/":
            ensure => directory,
            mode => 755
        }

        file { "/usr/local/bin/git_init_script":
            owner => "root",
            group => "root",
            mode => 750,
            source => [
                "puppet://$server/private/$environment/git/git_init_script",
                "puppet://$server/modules/files/git/git_init_script",
                "puppet://$server/modules/git/git_init_script"
            ]
        }
    }

    define repository(  $public = false, $shared = false,
                        $localtree = "/srv/git/", $owner = "root",
                        $group = "root", $symlink_prefix = false,
                        $symbolic_link = true,
                        $prefix = false, $recipients = false,
                        $real_name = false,
                        $description = false) {
        # FIXME
        # Why does this include server? One can run repositories without a
        # git daemon..!!
        #
        # - The defined File["git_init_script"] resource will need to move to
        # this class
        #
        # Documentation on this resource
        #
        # Set $public to true when calling this resource to make the repository
        # readable to others
        #
        # Set $shared to true to allow the group owner (set with $group) to
        # write to the repository
        #
        # Set $localtree to the base directory of where you would like to have
        # the git repository located.
        #
        # The actual git repository would end up in $localtree/$name, where
        # $name is the title you gave to the resource.
        #
        # Set $owner to the user that is the owner of the entire git repository
        #
        # Set $group to the group that is the owner of the entire git repository
        #
        # Set $init to false to prevent the initial commit to be made
        #

        if !defined(File["/usr/local/bin/git_init_script"]) {
            file { "/usr/local/bin/git_init_script":
                owner => "root",
                group => "root",
                mode => 750,
                source => [
                    "puppet://$server/private/$environment/git/git_init_script",
                    "puppet://$server/modules/files/git/git_init_script",
                    "puppet://$server/modules/git/git_init_script"
                ]
            }
        }

        if defined(User["$owner"]) {
            realize(User["$owner"])
        } else {
            @user { "$owner":
                ensure => present
            }
            realize(User["$owner"])
        }

        if defined(Group["$group"]) {
            realize(Group["$group"])
        } else  {
            @group { "$group":
                ensure => present
            }
            realize(Group["$group"])
        }

        if ($real_name) {
            $_name = $real_name
        } else {
            $_name = $name
        }

        file { "git_repository_$name":
            path => $prefix ? {
                false => "$localtree/$_name",
                default => "$localtree/$prefix-$_name"
            },
            ensure => directory,
            owner => "$owner",
            group => "$group",
            mode => $public ? {
                true => $shared ? {
                    true => 2775,
                    default => 0755
                },
                default => $shared ? {
                    true => 2770,
                    default => 0750
                }
            },
            require => [ User["$owner"], Group["$group"] ]
        }

        # Set the hook for this repository
        file { "git_repository_hook_post-commit_$name":
            path => $prefix ? {
                false => "$localtree/$_name/hooks/post-commit",
                default => "$localtree/$prefix-$_name/hooks/post-commit"
            },
            source => [
                "puppet://$server/private/$environment/git/post-commit",
                "puppet://$server/modules/files/git/post-commit",
                "puppet://$server/modules/git/post-commit"
            ],
            mode => 755,
            require => [
                File["git_repository_$name"],
                Exec["git_init_script_$name"],
                User["$owner"],
                Group["$group"]
            ]
        }

        file { "git_repository_hook_update_$name":
            path => $prefix ? {
                false => "$localtree/$_name/hooks/update",
                default => "$localtree/$prefix-$_name/hooks/update"
            },
            ensure => $prefix ? {
                false => "$localtree/$_name/hooks/post-commit",
                default => "$localtree/$prefix-$_name/hooks/post-commit"
            },
            links => manage,
            require => [
                File["git_repository_$name"],
                Exec["git_init_script_$name"],
                User["$owner"],
                Group["$group"]
            ]
        }

        file { "git_repository_hook_post-update_$name":
            path => $prefix ? {
                false => "$localtree/$_name/hooks/post-update",
                default => "$localtree/$prefix-$_name/hooks/post-update"
            },
            mode => 755,
            owner => "$owner",
            group => "$group",
            require => [
                File["git_repository_$name"],
                Exec["git_init_script_$name"],
                User["$owner"],
                Group["$group"]
            ]
        }

        # In case there are recipients defined, get in the commit-list
        case $recipients {
            false: {
                file { "git_repository_commit_list_$name":
                    path => $prefix ? {
                        false => "$localtree/$_name/commit-list",
                        default => "$localtree/$prefix-$_name/commit-list"
                    },
                    content => "",
                    require => [
                        File["git_repository_$name"],
                        Exec["git_init_script_$name"],
                        User["$owner"],
                        Group["$group"]
                    ]
                }
            }
            default: {
                file { "git_repository_commit_list_$name":
                    path => $prefix ? {
                        false => "$localtree/$_name/commit-list",
                        default => "$localtree/$prefix-$_name/commit-list"
                    },
                    content => template('git/commit-list.erb'),
                    require => [
                        File["git_repository_$name"],
                        Exec["git_init_script_$name"],
                        User["$owner"],
                        Group["$group"]
                    ]
                }
            }
        }

        case $description {
            false: {
                file { "git_repository_description_$name":
                    path => $prefix ? {
                        false => "$localtree/$_name/description",
                        default => "$localtree/$prefix-$_name/description"
                    },
                    content => "Unnamed repository",
                    require => [
                        File["git_repository_$name"],
                        Exec["git_init_script_$name"],
                        User["$owner"],
                        Group["$group"]
                    ]
                }
            }
            default: {
                file { "git_repository_description_$name":
                    path => $prefix ? {
                        false => "$localtree/$_name/description",
                        default => "$localtree/$prefix-$_name/description"
                    },
                    content => "$description",
                    require => [
                        File["git_repository_$name"],
                        Exec["git_init_script_$name"],
                        User["$owner"],
                        Group["$group"]
                    ]
                }
            }
        }

        if $symbolic_link {
            file { "git_repository_symlink_$name":
                path => $symlink_prefix ? {
                    false => $prefix ? {
                        false => "/git/$_name",
                        default => "/git/$prefix-$_name"
                    },
                    default => $prefix ? {
                        false => "/git/$symlink_prefix-$_name",
                        default => "/git/$symlink_prefix-$prefix-$_name"
                    }
                },
                links => manage,
                backup => false,
                ensure => $prefix ? {
                    false => "$localtree/$_name",
                    default => "$localtree/$prefix-$_name"
                },
                require => [ User["$owner"], Group["$group"] ]
            }
        }

        exec { "git_init_script_$name":
            command => $prefix ? {
                false => "git_init_script --localtree $localtree --name $_name --shared $shared --public $public --owner $owner --group $group",
                default => "git_init_script --localtree $localtree --name $prefix-$_name --shared $shared --public $public --owner $owner --group $group"
            },
            creates => $prefix ? {
                false => "$localtree/$_name/info",
                default => "$localtree/$prefix-$_name/info"
            },
            require => [
                File["git_repository_$name"],
                File["/usr/local/bin/git_init_script"],
                User["$owner"],
                Group["$group"]
            ]
        }
    }

    define repository::domain(  $public = false,
                                $shared = false,
                                $localtree = "/srv/git/",
                                $owner = "root",
                                $group = "root",
                                $prefix = false,
                                $symlink_prefix = false,
                                $recipients = false,
                                $satelliteuser = false,
                                $description = false) {
        repository { "$name":
            public => $public,
            shared => $shared,
            localtree => "$localtree/",
            owner => "$owner",
            group => "git-$name",
            prefix => $prefix,
            symlink_prefix => $symlink_prefix,
            recipients => $recipients,
            description => "$description",
            require => Group["git-$name"]
        }

        if defined(Group["git-$name"]) {
            realize(Group["git-$name"])
        } else {
            @group { "git-$name":
                ensure => present
            }
            realize(Group["git-$name"])
        }

        if ($satelliteuser) {
            if defined(User["satellite-$name"]) {
                realize(User["satellite-$name"])
            } else {
                @user { "satellite-$name":
                    ensure => present,
                    comment => "Satellite user for domain $name",
                    groups => "git-$name",
                    shell => "/usr/bin/git-shell"
                }
                realize(User["satellite-$name"])
            }
        }
    }

    define clean($localtree = "/srv/git/", $real_name = false) {

        #
        # Resource to clean out a working directory
        # Useful for directories you want to pull from upstream, but might
        # have added files. This resource is applied for all pull resources,
        # by default.
        #

        exec { "git_clean_exec_$name":
            cwd => $real_name ? {
                false => "$localtree/$name",
                default => "$localtree/$real_name"
            },
            command => "git clean -d -f"
        }
    }

    define reset($localtree = "/srv/git/", $real_name = false, $clean = true) {

        #
        # Resource to reset changes in a working directory
        # Useful to undo any changes that might have occured in directories
        # that you want to pull for. This resource is automatically called
        # with every pull by default.
        #
        # You can set $clean to false to prevent a clean (removing untracked
        # files)
        #

        exec { "git_reset_exec_$name":
            cwd => $real_name ? {
                false => "$localtree/$name",
                default => "$localtree/$real_name"
            },
            command => "git reset --hard HEAD"
        }

        if $clean {
            clean { "$name":
                localtree => "$localtree",
                real_name => "$real_name"
            }
        }
    }

    define pull($localtree = "/srv/git/", $real_name = false,
                $reset = true, $clean = true, $branch = false) {

        #
        # This resource enables one to update a working directory
        # from an upstream GIT source repository. Note that by default,
        # the working directory is reset (undo any changes to tracked
        # files), and clean (remove untracked files)
        #
        # Note that to prevent a reset to be executed, you can set $reset to
        # false when calling this resource.
        #
        # Note that to prevent a clean to be executed as part of the reset, you
        # can set $clean to false
        #

        if $reset {
            reset { "$name":
                localtree => "$localtree",
                real_name => "$real_name",
                clean => $clean
            }
        }

        @exec { "git_pull_exec_$name":
            cwd => "$localtree/$real_name",
            command => "git pull",
            onlyif => "test -d $localtree/$real_name/.git/info"
        }

        case $branch {
            false: {}
            default: {
                exec { "git_pull_checkout_$branch_$localtree/$_name":
                    cwd => "$localtree/$_name",
                    command => "git checkout --track -b $branch origin/$branch",
                    creates => "$localtree/$_name/refs/heads/$branch"
                }
            }
        }

        if defined(Git::Reset["$name"]) {
            Exec["git_pull_exec_$name"] {
                require +> Git::Reset["$name"]
            }
        }

        if defined(Git::Clean["$name"]) {
            Exec["git_pull_exec_$name"] {
                require +> Git::Clean["$name"]
            }
        }

        realize(Exec["git_pull_exec_$name"])
    }

    define clone(   $source,
                    $localtree = "/srv/git/",
                    $real_name = false,
                    $branch = false) {
        if $real_name {
            $_name = $real_name
        }
        else {
            $_name = $name
        }

        exec { "git_clone_exec_$localtree/$_name":
            cwd => $localtree,
            command => "git clone `echo $source | sed -r -e 's,(git://|ssh://)(.*)//(.*),\\1\\2/\\3,g'` $_name",
            creates => "$localtree/$_name/.git/",
            require => File["$localtree"]
        }

        if defined(File["$localtree"]) {
            realize(
                File["$localtree"]
            )
        } else {
            @file { "$localtree":
                ensure => directory
            }
            realize(
                File["$localtree"]
            )
        }

        case $branch {
            false: {}
            default: {
                exec { "git_clone_checkout_$branch_$localtree/$_name":
                    cwd => "$localtree/$_name",
                    command => "git checkout --track -b $branch origin/$branch",
                    creates => "$localtree/$_name/.git/refs/heads/$branch",
                    require => Exec["git_clone_exec_$localtree/$_name"]
                }
            }
        }
    }
}
