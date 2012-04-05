# This class is intended to be run onetime in a oneoff scenario
# to aid in the bootstrapping of a shared ca environment
class shared_ca(
  $ca_folder_source       = "puppet:///modules/${module_name}/ca",
  $mco_credentials_source = "puppet:///modules/${module_name}/credentials",
  $mco_module_source      = "puppet:///modules/${module_name}/pe_mcollective"
) {

$ca_files_to_purge = [ '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
                       "/etc/puppetlabs/puppet/ssl/certs/${::clientcert}.pem",
                       "/etc/puppetlabs/puppet/ssl/private_keys/${::clientcert}.pem",
                       "/etc/puppetlabs/puppet/ssl/public_keys/${::clientcert}.pem",
                       '/etc/puppetlabs/puppet/ssl/crl.pem', ]

$mco_files_to_purge = [ '/etc/puppetlabs/mcollective/ssl',
                        '/etc/puppetlabs/activemq/broker.ks',
                        '/etc/puppetlabs/activemq/broker.p12',
                        '/etc/puppetlabs/activemq/broker.pem',
                        '/etc/puppetlabs/activemq/broker.ts', ]

$old_function_to_purge = '/opt/puppet/share/puppet/modules/pe_accounts/lib/puppet/parser/functions/create_resources.rb'

$mco_credentials_file = '/etc/puppetlabs/mcollective/credentials'



  if $::fact_is_puppetconsole == 'false' {

       $files_to_purge = [ $ca_files_to_purge, $mco_files_to_purge, $old_function_to_purge ]

       file { 'copy_ca_dir':
          ensure  => directory,
          path    => '/etc/puppetlabs/puppet/ssl/ca',
          source  => $ca_folder_source,
          recurse => true,
          owner   => 'pe-puppet',
          group   => 'pe-puppet',
       }

       file { 'copy_mco_credentials':
          ensure => file,
          path   => '/etc/puppetlabs/mcollective/credentials',
          source => $mco_credentials_source,
          owner   => 'pe-puppet',
          group   => 'pe-puppet',
          mode    => '0600',
       }

  } elsif $::fact_is_puppetconsole == 'true' and $::fact_is_puppetca == 'true'{

        $files_to_purge = [ $mco_files_to_purge, $old_function_to_purge ]

  }

        service { [ 'pe-puppet',
                    'pe-httpd',
                    'pe-mcollective',
                    'pe-activemq' ]:
          ensure => 'stopped',
        }

        file { $files_to_purge:
          ensure  => absent,
          recurse => true,
          force   => true,
        }


        file { 'copy_custom_mco_module':
          ensure  => directory,
          path    => '/etc/puppetlabs/puppet/modules/pe_mcollective',
          source  => $mco_module_source,
          recurse => true,
          owner   => 'pe-puppet',
          group   => 'pe-puppet',
        }

}
