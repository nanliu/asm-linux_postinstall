# Add support for postinstall file and script:
class linux_postinstall(
  $install_packages = undef,
  $upload_share     = 'puppet:///modules/linux_postinstall',
  $upload_file      = undef,
  $upload_recursive = false,
  $execute_file_command,
) {

  $path = "${vardir}/staging:${vardir}/staging/${file}:${::path}"
  $vardir  = $::puppet_vardir,

  if $install_packages {
    $packages = split($install_packages, ',')

    package { $packages:
      ensure => present,
    }
  }

  if $file {
    $staging = "${vardir}/staging"
    file { $staging:
      ensure => directory,
      mode   => 755,
    }

    file { "${staging}/${file}":
      source  => "${upload_share}/${upload_file}",
      recurse => $upload_recursive,
      before  => Exec[$name],
    }

    if $upload_recursive {
      $cwd = "${staging}/${file}"
    } else {
      $cwd = $staging
    }
  }

  $exec_lck = "${vardir}/postinstall.lck"

  exec { postinstall:
    command   => $execute_file_command,
    path      => $path,
    cwd       => $cwd,
    creates   => $exec_lck,
    logoutput => true,
  }

  file { $exec_lck:
    ensure  => file,
    require => Exec[$name],
  }
}
