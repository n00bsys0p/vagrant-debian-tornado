class application {
	include pyenv

    $user = "vagrant"
    $python_ver = "3.4.2"
    $vhost = "tornado.local"
    $app_install_dir = "/srv/www/app"
    $deployment_type = 'DEV'
    $path_var = "/home/${user}/.pyenv/shims:/home/${user}/.pyenv/bin:/usr/local/bin:/usr/bin:/bin"

    pyenv::install { $user : }
    pyenv::compile { "compile_${python_ver}_${user}" :
        user => $user,
        python => $python_ver,
        global => true,
        require => Pyenv::Install[$user]
    }

    file { "common_requirements_file" :
    	ensure => file,
    	path => "${app_install_dir}/requirements/common.txt"
    }

    $requirements_file = downcase($deployment_type)
    file { "env_requirements_file" :
    	ensure => file,
    	path => "${app_install_dir}/requirements/${requirements_file}.txt"
    }

    exec { "install_common_requirements" :
    	command => "pip install -r ${app_install_dir}/requirements/common.txt",
    	path => $path_var,
    	require => Pyenv::Compile["compile_${python_ver}_${user}"],
    	subscribe => File["common_requirements_file"]
	}

	exec { "install_${requirements_file}_requirements" :
    	command => "pip install -r ${app_install_dir}/requirements/${requirements_file}.txt",
    	path => $path_var,
    	require => Pyenv::Compile["compile_${python_ver}_${user}"],
    	subscribe => File["env_requirements_file"]
	}

    package { "supervisor" :
        ensure => present
    }

    service { "supervisor" :
    	ensure => running,
    	require => Package["supervisor"],
    	subscribe => [
    		Exec["install_common_requirements"],
    		Exec["install_${requirements_file}_requirements"]
    	]
	}

	file { "supervisor_config" :
    	path => "/etc/supervisor/conf.d/tornado.conf",
        ensure => file,
        content => template('application/supervisor.erb'),
        require => Package['supervisor']
    }

    class { "nginx" : }

    nginx::resource::upstream { "tornado_app" :
        members => [
            'localhost:8001',
            'localhost:8002',
            'localhost:8003',
            'localhost:8004'
        ]
    }

    nginx::resource::vhost { $vhost :
        proxy => 'http://tornado_app'
    }
}