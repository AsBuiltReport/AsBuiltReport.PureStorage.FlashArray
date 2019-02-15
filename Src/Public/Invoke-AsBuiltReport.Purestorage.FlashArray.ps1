#Requires -Modules PScribo, PureStoragePowershellSDK

function Invoke-AsBuiltReport.PureStorage.FlashArray {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of Pure Storage FlashArray in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of Pure Storage FlashArray in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.1
        Author:         Matt Allford
        Twitter:        @mattallford
        Github:         https://github.com/mattallford
        Credits:        Iain Brighton (@iainbrighton) - PScribo module
                        Tim Carman (@tpcarman) - Wrote original report for Pure Storage

    .LINK
        https://github.com/AsBuiltReport/
    #>

    #region Script Parameters
    [CmdletBinding()]
    param (
        $Target,
        [pscredential] $Credential,
		$StyleName
    )

    # If custom style not set, use default style
    if (!$StyleName) {
        & "$PSScriptRoot\..\Assets\Styles\PureStorage.ps1"
    }

    $Script:Array = $Null
    foreach ($FlashArray in $Target) {
        Try {
            $Array = New-PfaArray -EndPoint $FlashArray -Credentials $Credential -IgnoreCertificateError
        } Catch {
            Write-Verbose "Unable to connect to the Pure Storage FlashArray $FlashArray"
        }

        if ($Array) {
            $script:ArrayAttributes = Get-PfaArrayAttributes -Array $Array
            $script:ArrayRemoteAssistSession = Get-PfaRemoteAssistSession -Array $array
            $script:ArrayPhoneHomeStatus = Get-PfaPhoneHomeStatus -Array $array
            $script:ArrayControllers = Get-PfaControllers -Array $Array
            $script:ArrayAlerts = Get-PfaAlerts -Array $Array
            $script:ArrayRelayHost = Get-PfaRelayHost -Array $Array
            $script:ArraySenderDomain = Get-PfaSenderDomain -Array $Array
            $script:ArraySNMPManagers = Get-PfaSnmpManagers -Array $Array
            $script:ArraySSLCertificate = Get-PfaCurrentCertificateAttributes -Array $Array
            $script:ArraySyslogServers = Get-PfaSyslogServers -Array $Array
            $script:ArrayNTPServers = Get-PfaNtpServers -Array $Array
            $script:ArrayVolumes = Get-PfaVolumes -Array $Array
            $Script:ArrayHosts = Get-PfaHosts -Array $Array
            $script:ArrayHostGroups = Get-PfaHostGroups -Array $Array
            $script:ArrayProtectionGroups = Get-PfaProtectionGroups -Array $Array
            $script:ArrayProtectionGroupSchedules = Get-PfaProtectionGroupSchedules -Array $Array
            $script:ArrayProtectionGroupSnapshots = Get-PfaProtectionGroupSnapshots -Array $Array -Name *
            $script:ConnectedArrays = Get-PfaArrayConnections -Array $array
            $script:ArrayProxyServer = Get-PfaProxy -Array $Array
            $script:ArrayNetworkInterfaces = Get-PfaNetworkInterfaces -Array $Array
            $script:ArrayPorts = Get-PfaArrayPorts -Array $array
            $script:ArrayDNS = Get-PfaDnsAttributes -Array $Array
            $script:ArrayDirectoryService = Get-PfaDirectoryServiceConfiguration -Array $Array
            $script:ArrayDirectoryServiceGroups = Get-PfaDirectoryServiceGroups -Array $Array
            $script:ArraySpaceMetrics = Get-PfaArraySpaceMetrics -Array $Array
            $script:ArrayDisks = Get-PfaAllDriveAttributes -Array $Array


            Section -Style Heading1 $ArrayAttributes.array_name {
                Section -Style Heading2 'System Summary' {
                    Paragraph "The following section provides a summary of the array configuration for $($ArrayAttributes.array_name)."
                    BlankLine
                    #Provide a summary of the Array
                    $ArraySummary = [PSCustomObject] @{
                        'Array Name' = $ArrayAttributes.array_name
                        'Purity Version' = $ArrayAttributes.version
                        'Array ID' = $ArrayAttributes.id
                        'Number of Volumes' = $ArrayVolumes.count
                        'Number of Protection Groups' = $ArrayProtectionGroups.count
                        'Number of Protection Group Snapshots' = $ArrayProtectionGroupSnapshots.count
                        'Number of Hosts' = $ArrayHosts.count
                        'Number of Host Groups' = $ArrayHostGroups.count
                        #'Pod #' = 
                        'Number of Connected Arrays' = $ConnectedArrays.count
                    }
                    $ArraySummary | Table -Name 'Array Summary' -List
                }#End Section Heading2 System Summary

                Section -Style Heading2 'Storage Summary' {
                    Paragraph "The following section provides a summary of the storage usage on $($ArrayAttributes.array_name)."
                    BlankLine
                    $ArraySpaceSummary = [PSCustomObject] @{
                        'Capacity' = "$([math]::Round(($ArraySpaceMetrics.capacity) / 1TB, 2)) TB"
                        'Used' = "$([math]::Round(($ArraySpaceMetrics.total) / 1TB, 2)) TB"
                        'Free' = "$([math]::Round(($ArraySpaceMetrics.capacity - $ArraySpaceMetrics.total) / 1TB, 2)) TB"
                        '% Used' = [math]::Truncate(($ArraySpaceMetrics.total / $ArraySpaceMetrics.capacity) * 100)
                        'Volumes' = "$([math]::Round(($ArraySpaceMetrics.volumes) / 1GB, 2)) GB"
                        'Snapshots' = "$([math]::Round(($ArraySpaceMetrics.snapshots) / 1GB, 2)) GB"
                        'Shared Space' = "$([math]::Round(($ArraySpaceMetrics.shared_space) / 1GB, 2)) GB"
                        'System' = "$([math]::Round(($ArraySpaceMetrics.system) / 1GB, 2)) GB"
                        'Data Reduction' = [math]::Round(($ArraySpaceMetrics.data_reduction), 2)
                        'Total Reduction' = [math]::Round(($ArraySpaceMetrics.total_reduction), 2)
                    }
                    $ArraySpaceSummary | Table -Name 'Storage Summary' -List -ColumnWidths 50, 50
                }#End Section Heading2 Storage Summary

                Section -Style Heading2 'Controller Summary' {
                    Paragraph "The following section provides a summary of the controllers in $($ArrayAttributes.array_name)."
                    BlankLine
                    $ArrayControllerSummary = foreach ($ArrayController in $ArrayControllers) {
                        [PSCustomObject] @{
                            'Name' = $ArrayController.name
                            'Mode' = $ArrayController.mode
                            'Model' = $ArrayController.model
                            'Purity Version' = $ArrayController.version
                            'Status' = $ArrayController.status
                        }
                    }
                    $ArrayControllerSummary | Sort-Object -Property Name | Table -Name 'Controller Summary'
                }#End section Heading2 'Controller Summary'

                Section -Style Heading2 'Disk Summary' {
                    Paragraph "The following section provides a summary of the disks in $($ArrayAttributes.array_name)."
                    BlankLine
                    $ArrayDiskSummary = foreach ($ArrayDisk in $ArrayDisks) {
                        [PSCustomObject] @{
                            'Name' = $ArrayDisk.name
                            'Capacity GB' = [math]::Round(($ArrayDisk.capacity) / 1GB, 0)
                            'Type' = $ArrayDisk.Type
                            'Status' = $ArrayDisk.status
                        }
                    }
                    $ArrayDiskSummary | Sort-Object -Property Name | Table -Name 'Disk Summary' -ColumnWidths 25, 25, 25, 25
                }#End section Heading2 'Disk Summary'

                Section -Style Heading2 'Storage Configuration' {
                    Paragraph "The following section provides a summary of the Storage Configuration on $($ArrayAttributes.array_name)."
                    BlankLine
                    if ($ConnectedArrays) {
                        Section -Style Heading3 'Connected Arrays' {
                            Paragraph 'The following section provides information on connected arrays.'
                            BlankLine
                            $ConnectedArrayConfiguration = foreach ($ConnectedArray in $ConnectedArrays) {
                                [PSCustomObject] @{
                                    'Name' = $ConnectedArray.array_name
                                    'ID' = $ConnectedArray.id
                                    'Connected' = $ConnectedArray.connected
                                    'Type' = ($ConnectedArray.type -join ", ")
                                    'Version' = $ConnectedArray.version
                                    'Management Address' = $ConnectedArray.management_address
                                    'Replication Address' = $ConnectedArray.replication_address
                                    'Throttled' = $ConnectedArray.throttled
                                }
                            }
                            $ConnectedArrayConfiguration | Table 'Connected Arrays' -List
                        }#End Section Heading3 Connected Arrays
                    }#End if ($ConnectedArrays)

                    if ($ArrayHosts) {
                        Section -Style Heading3 'Hosts' {
                            Paragraph "The following section provides information on the hosts defined on $($ArrayAttributes.array_name)."
                            BlankLine
                            if ($ArrayHosts.iqn) {
                                $ArrayHostConfigration = foreach ($ArrayHost in $ArrayHosts) {
                                    [PSCustomObject] @{
                                        'Host Name' = $ArrayHost.Name
                                        'Host Group' = $ArrayHost.hgroup
                                        'IQN' = $ArrayHost.iqn
                                    }
                                }
                                $ArrayHostConfigration | Sort-Object -Property 'Host Name', 'Host Group' | Table -Name 'Hosts'
                            } elseif ($ArrayHosts.wwn) {
                                $ArrayHostConfigration = foreach ($ArrayHost in $ArrayHosts) {
                                    [PSCustomObject] @{
                                        'Host Name' = $ArrayHost.Name
                                        'Host Group' = $ArrayHost.hgroup
                                        'WWN' = ($ArrayHost.wwn -split "(\w{2})" | Where-Object {$_ -ne ""}) -join ":"
                                    }
                                }
                                $ArrayHostConfigration | Sort-Object -Property 'Host Name', 'Host Group' | Table -Name 'Hosts'
                            } else {
                                $ArrayHostConfigration = foreach ($ArrayHost in $ArrayHosts) {
                                    [PSCustomObject] @{
                                        'Host Name' = $ArrayHost.Name
                                        'Host Group' = $ArrayHost.hgroup
                                    }
                                }
                                $ArrayHostConfigration | Sort-Object -Property 'Host Name', 'Host Group' | Table -Name 'Hosts'
                            }
                        }#End Section Heading3 Hosts
                    }#End if ($ArrayHosts)

                    if ($ArrayHostGroups) {
                        Section -Style Heading3 'Host Groups' {
                            Paragraph "The following section provides information on the host groups on $($ArrayAttributes.array_name)."
                            BlankLine
                            $ArrayHostGroupConfiguration = foreach ($ArrayHostGroup in $ArrayHostGroups) {
                                [PSCustomObject] @{
                                    'Host Group Name' = $ArrayHostGroup.name
                                    'Hosts' = ($ArrayHostGroup.hosts -join ", ")
                                }
                            }
                            $ArrayHostGroupConfiguration | Sort-Object -Property 'Host Group Name' | Table -Name "Host Groups" -ColumnWidths 50, 50
                        }#End Section Heading3 Host Groups
                    }#End if ($ArrayHostGroups)

                    if ($ArrayVolumes) {
                        Section -Style Heading3 'Volumes' {
                            Paragraph "The following section provides information on the volumes on $($ArrayAttributes.array_name)."
                            Blankline
                            $ArrayVolumeConfiguration = foreach ($ArrayVolume in $ArrayVolumes) {
                                $ArrayVolumeHostGroupConnection = Get-PfaVolumeHostGroupConnections -Array $array -VolumeName $ArrayVolume.name
                                [PSCustomObject] @{
                                    'Volume Name' = $ArrayVolume.name
                                    'Volume Size' = "$(($ArrayVolume.Size / 1GB)) GB"
                                    'Volume Serial' = $ArrayVolume.Serial
                                    'LUN' = ($ArrayVolumeHostGroupConnection.lun | Select-Object -Unique)
                                    'Host Group' = ($ArrayVolumeHostGroupConnection.hgroup | Select-Object -Unique)
                                }
                            }
                            $ArrayVolumeConfiguration | Sort-Object -Property 'Volume Name' | Sort-Object "Volume Name" | Table -Name 'Volumes'
                        }#End Section Heading3 Volumes
                    }#End if ($ArrayVolumes)

                    if ($ArrayProtectionGroups) {
                        Section -Style Heading3 'Protection Groups' {
                            Paragraph "The following section provides information on the protection groups on $($ArrayAttributes.array_name)."
                            BlankLine
                            $ArrayProtectionGroupConfiguration = foreach ($ArrayProtectionGroup in $ArrayProtectionGroups) {
                                [PSCustomObject] @{
                                    'Name' = $ArrayProtectionGroup.Name
                                    'Host Group(s)' = $ArrayProtectionGroup.hgroups
                                    'Source' = $ArrayProtectionGroup.source
                                    'Targets' = ($ArrayProtectionGroup.targets).name
                                    'Replication Allowed' = ($ArrayProtectionGroup.targets).allowed
                                    'Volumes' = ($ArrayProtectionGroup.volumes -join ", ")
                                }
                            }
                            $ArrayProtectionGroupConfiguration | Sort-Object -Property Name | Table -Name 'Protection Groups'
                        }#End Section Heading3 'Protection groups'
                    }#End if ($ArrayProtectionGroups)

                    if ($ArrayProtectionGroupSchedules) {
                        Section -Style Heading3 'Protection Group Schedules' {
                            Paragraph "The following section provides information on the protection group snapshot and replication schedules on $($ArrayAttributes.array_name)."
                            BlankLine
                            $ArrayProtectionGroupScheduleConfiguration = foreach ($ArrayProtectionGroupSchedule in $ArrayProtectionGroupSchedules) {
                                [PSCustomObject] @{
                                    'Name' = $ArrayProtectionGroupSchedule.name
                                    'Snapshot Enabled' = $ArrayProtectionGroupSchedule.snap_enabled
                                    'Snapshot Frequency (Mins)' = ($ArrayProtectionGroupSchedule.snap_frequency / 60)
                                    'Snapshot At' = $ArrayProtectionGroupSchedule.snap_at
                                    'Replication Enabled' = $ArrayProtectionGroupSchedule.replicate_enabled
                                    'Replication Frequency (Mins)' = ($ArrayProtectionGroupSchedule.replicate_frequency / 60)
                                    'Replicate At' = $ArrayProtectionGroupSchedule.replicate_at
                                    'Replication Blackout Times' = $ArrayProtectionGroupSchedule.replicate_blackout
                                }
                            }
                            $ArrayProtectionGroupScheduleConfiguration | Sort-Object -Property Name | Table -Name 'Protection Group Schedule'
                        }#End Section Heading3 'Protection Group Schedules'
                    }#End if (ArrayProtectionGroupSchedules)
                }#End Section Heading2 Storage Configuration

                Section -Style Heading2 'System Configuration' {
                    Paragraph "The following section provides information on the system configuration for $($ArrayAttributes.array_name)."
                    if ($ArrayRelayHost -or $ArraySenderDomain -or $ArrayAlerts) {    
                        Section -Style Heading3 'SMTP Configuration' {
                            Paragraph "The following section provides information on the SMTP configuration for $($ArrayAttributes.array_name)."
                            Blankline
                            $ArraySMTPConfiguration = [PSCustomObject] @{
                                'SMTP Server' = $ArrayRelayHost.relayhost
                                'SMTP Sender Domain' = $ArraySenderDomain.senderdomain
                                'SMTP Recipients' = ($ArrayAlerts.name -join ", ")
                            }
                            $ArraySMTPConfiguration | Table -Name 'SMTP Configuration' -List -ColumnWidths 50, 50 
                        }#End Section Heading3 SMTP Configuration
                    }

                    Section -Style Heading3 'SNMP Configuration' {
                        Paragraph "The following section provides information on the SNMP configuration for $($ArrayAttributes.array_name)."
                        Blankline
                        $ArraySNMPConfiguration = [PSCustomObject] @{
                            'Name' = $ArraySNMPManagers.name
                            'Community' = $ArraySNMPManagers.community
                            'Privacy Protocol' = $ArraySNMPManagers.privacy_protocol
                            'Authentication Protocol' = $ArraySNMPManagers.auth_protocol
                            'Host' = $ArraySNMPManagers.host
                            'Version' = $ArraySNMPManagers.version
                            'User' = $ArraySNMPManagers.user
                            'Privacy Passphrase' = $ArraySNMPManagers.privacy_passphrase
                            'Authentication Passphrase' = $ArraySNMPManagers.auth_passphrase
                        }
                        $ArraySNMPConfiguration | Table -Name 'SNMP Configuration' -List -ColumnWidths 50, 50 
                    }#End Section Heading3 SNMP Configuration

                    if ($ArraySyslogServers) {
                        Section -Style Heading3 'Syslog Configuration' {
                            Paragraph "The following section provides information on the Syslog configuration for $($ArrayAttributes.array_name)."
                            Blankline
                            $ArraySyslogConfiguration = [PSCustomObject] @{
                                'Syslog Servers' = ($ArraySyslogServers.syslogserver -join ", ")
                            }
                            $ArraySyslogConfiguration | Table -Name 'Syslog Configuration' -List -ColumnWidths 50, 50 
                        }#End Section Heading3 Syslog Configuration
                    }

                    if ($ArrayNTPServers) {
                        Section -Style Heading3 'NTP Configuration' {
                            Paragraph "The following section provides information on the NTP configuration for $($ArrayAttributes.array_name)."
                            Blankline
                            $ArrayNTPConfiguration = [PSCustomObject] @{
                                'NTP Servers' = ($ArrayNTPServers.ntpserver -join ", ")
                            }
                            $ArrayNTPConfiguration | Table -Name 'NTP Configuration' -List -ColumnWidths 50, 50 
                        }#End Section Heading3 NTP Configuration
                    }

                    Section -Style Heading3 'Pure1 Support' {
                        Paragraph "The following section provides information on the Pure1 Support configuration for $($ArrayAttributes.array_name)."
                        Blankline
                        $ArrayPure1Configuration = [PSCustomObject] @{
                            'Phone Home Status' = $ArrayPhoneHomeStatus.phonehome
                            'Remote Assist Status' = $ArrayRemoteAssistSession.status
                            'Proxy Server' = $ArrayProxyServer.proxy
                        }
                        $ArrayPure1Configuration | Table -Name 'Pure1 Configuration' -List -ColumnWidths 50, 50 
                    }#End Section Heading3 Pure1 Configuration

                    Section -Style Heading3 'SSL Certificate' {
                        Paragraph "The following section provides information on the SSL certificate for $($ArrayAttributes.array_name)."
                        Blankline
                        $ArraySSLCertConfiguration = [PSCustomObject] @{
                            'Status' = $ArraySSLCertificate.status
                            'Issued To' = $ArraySSLCertificate.issued_to
                            'Issued By' = $ArraySSLCertificate.issued_by
                            'Valid from' = $ArraySSLCertificate.valid_from
                            'Valid To' = $ArraySSLCertificate.valid_to
                            'Locality' = $ArraySSLCertificate.locality
                            'Country' = $ArraySSLCertificate.country
                            'State' = $ArraySSLCertificate.state
                            'Key Size' = $ArraySSLCertificate.key_size
                            'Organisational Unit' = $ArraySSLCertificate.organizational_unit
                            'Organisation' = $ArraySSLCertificate.organization
                            'Email' = $ArraySSLCertificate.email
                        }
                        $ArraySSLCertConfiguration | Table -Name 'SSL Certificate' -List
                    }#End Section Heading3 SSL Certificate
                }#End Section Heading2 System Configuration

                Section -Style Heading2 'Network Configuration' {
                    Paragraph "The following section provides information on the Network configuration for $($ArrayAttributes.array_name)."
                    Section -Style Heading3 'Subnets and Interfaces' {
                        Paragraph "The following section provides information on the subnets and interfaces for $($ArrayAttributes.array_name)."
                        Blankline
                        $ArrayNetworkConfiguration = foreach ($ArrayNetworkInterface in $ArrayNetworkInterfaces) {
                            [PSCustomObject] @{
                                'Name' = $ArrayNetworkInterface.name
                                'Enabled' = $ArrayNetworkInterface.enabled
                                'Subnet' = $ArrayNetworkInterface.subnet
                                'MTU' = $ArrayNetworkInterface.mtu
                                'Services' = ($ArrayNetworkInterface.services -join ", ")
                                'Slaves' = ($ArrayNetworkInterface.slaves -join ", ")
                                'IP Address' = $ArrayNetworkInterface.address
                                'Netmask' = $ArrayNetworkInterface.netmask
                                'Gateway Address' = $ArrayNetworkInterface.gateway
                                'Hardware Address' = $ArrayNetworkInterface.hwaddr
                                #'Speed GB' = Convert-Size -ConvertFrom Bytes -ConvertTo GB -value $ArrayNetworkInterfaces.speed -Precision 2
                            }
                        }
                        $ArrayNetworkConfiguration | Sort-Object -Property Name | Table -Name 'Subnets and Interfaces'
                    }#End Section Heading3 Subnets and Interfaces

                    if ($ArrayPorts.wwn) {
                        Section -Style Heading3 'WWN Target Ports' {
                            Paragraph "The following section provides information on the WWN ports for $($ArrayAttributes.array_name)."
                            Blankline    
                            $ArrayPortWWNConfiguration = foreach ($ArrayPort in $ArrayPorts) { 
                                [PSCustomObject] @{
                                    'Port' = $ArrayPort.Name
                                    'WWN' = ($ArrayPort.wwn -split "(\w{2})" | Where-Object {$_ -ne ""}) -join ":"
                                }
                            }
                            $ArrayPortWWNConfiguration | Sort-Object -Property Port | Table -Name 'WWN Target Ports'
                        }#End Section Heading3 WWN Target Ports
                    } Elseif ($Arrayports.iqn) {
                        Section -Style Heading3 'IQN Target Ports' {
                            Paragraph "The following section provides information on the IQN ports for $($ArrayAttributes.array_name)."
                            Blankline    
                            $ArrayPortIQNConfiguration = foreach ($ArrayPort in $ArrayPorts) {
                                [PSCustomObject] @{
                                    'Port' = $ArrayPort.Name
                                    'IQN' = $ArrayPort.iqn
                                }
                            }
                            $ArrayPortIQNConfiguration | Sort-Object -Property Port | Table -Name 'IQN Target Ports'
                        }#End Section Heading3 IQN Target Ports
                    }#End if $Arrayports

                    if ($ArrayDNS) {
                        Section -Style Heading3 'DNS' {
                            Paragraph "The following section provides information on the DNS configuration for $($ArrayAttributes.array_name)."
                            Blankline
                            $ArrayDNSConfiguration = [PSCustomObject] @{
                                'Domain Name' = $ArrayDNS.domain
                                'DNS Servers' = ($ArrayDNS.nameservers -join ", ")
                            }
                            $ArrayDNSConfiguration | Table -Name 'DNS'
                        }#End Section Heading3 DNS
                    }#End if $ArrayDNS

                }#End Section Heading2 Network Configuration

                Section -Style Heading2 'Users' {
                    Paragraph "The following section provides information on the Users configuration for $($ArrayAttributes.array_name)."
                    if ($ArrayDirectoryService) { 
                        Section -Style Heading3 'Directory Service Configuration' {
                            $ArrayDirectoryServiceConfiguration = [PSCustomObject] @{
                                'Enabled' = $ArrayDirectoryService.Enabled
                                'URI' = ($ArrayDirectoryService.URI -join ", ")
                                'Base DN' = $ArrayDirectoryService.base_dn
                                'Bind User' = $ArrayDirectoryService.Bind_user
                                'Check Peer' = $ArrayDirectoryService.Check_peer
                            }
                            $ArrayDirectoryServiceConfiguration | Table -Name 'Directory Service Configuration' -List
                        }#End Section Directory Service Configuration
                    }#End If ($ArrayDirectoryService)

                    if ($ArrayDirectoryServiceGroups) {
                        Section -Style Heading3 'Directory Service Groups' {
                            $ArrayDirectoryServiceGroupConfiguration = [PSCustomObject] @{
                                'Group Base' = $ArrayDirectoryServiceGroups.group_base
                                'Array Admin Group' = $ArrayDirectoryServiceGroups.array_admin_group
                                'Storage Admin Group' = $ArrayDirectoryServiceGroups.storage_admin_group
                                'Read Only Group' = $ArrayDirectoryServiceGroups.readonly_group
                            }
                            $ArrayDirectoryServiceGroupConfiguration | Table -Name 'Directory Service Groups' -List
                        }
                    }#End if ($ArrayDirectoryServiceGroups)
                }#End Section Heading2 Users
            }#End Section Heading1 $ArrayAttributes.array_name
        }#End if $Array
    }#End foreach $FlashArray in $Target
}#End Function Invoke-AsBuiltReport.PureStorage.FlashArray