function Invoke-AsBuiltReport.PureStorage.FlashArray {
    <#
    .SYNOPSIS
        PowerShell script which documents the configuration of Pure Storage FlashArray in Word/HTML/XML/Text formats
    .DESCRIPTION
        Documents the configuration of Pure Storage FlashArray in Word/HTML/XML/Text formats using PScribo.
    .NOTES
        Version:        0.4.2
        Author:         John Hall
        Twitter:        
        Github:         https://github.com/mattallford
        Credits:        Iain Brighton (@iainbrighton) - PScribo module
                        Tim Carman (@tpcarman) - Wrote original report for Pure Storage
			Matt Allford (@mattallford) - last updated pure flashary

    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.PureStorage.FlashArray
    #>

    #region Script Parameters
    [CmdletBinding()]
    param (
        [string[]] $Target,
        [pscredential] $Credential,
		$StylePath
    )

    # If custom style not set, use default style
    if (!$StylePath) {
        & "$PSScriptRoot\..\..\AsBuiltReport.Purestorage.FlashArray.Style.ps1"
    }

    $Script:Array = $Null
    #Connect to Pure Storage Array using supplied credentials
    foreach ($FlashArray in $Target) {
        Try {
            $Array = Connect-Pfa2Array -EndPoint $FlashArray -Credential $Credential -IgnoreCertificateError -ErrorAction Stop
        } Catch {
            Write-Error $_
        }

        if ($Array) {
            $script:ArrayAttributes = Get-Pfa2Array -Array $Array
            $script:ArrayRemoteAssistSession = Get-Pfa2Support -Array $array
            $script:ArrayPhoneHomeStatus = Get-Pfa2Support -Array $array
            $script:ArrayControllers = Get-Pfa2Controller -Array $Array
            $script:ArrayAlerts = Get-Pfa2Alert -Array $Array
            $script:ArrayRelayHost = Get-Pfa2SmtpServer -Array $Array
            $script:ArraySenderDomain = Get-Pfa2SmtpServer -Array $Array
            $script:ArraySNMPManagers = Get-Pfa2SnmpAgent -Array $Array
            $script:ArraySSLCertificate = Get-Pfa2Certificate -Array $Array
            $script:ArraySyslogServers = Get-Pfa2SyslogServer -Array $Array
            $script:ArrayNTPServers = Get-Pfa2ArrayNtpTest -Array $Array
            $script:ArrayVolumes = Get-Pfa2Volume -Array $Array
            $script:Arrayfiledirectoryexports = Get-Pfa2DirectoryExport -Array $Array
            $script:Arrayfiledirectory = Get-Pfa2Directory -Array $Array
            $Script:ArrayHosts = Get-Pfa2Host -Array $Array
            $script:ArrayHostGroups = Get-Pfa2HostGroup -Array $Array
            $script:ArrayProtectionGroups = Get-Pfa2ProtectionGroup -Array $Array
            $script:ArrayProtectionGroupSchedules = Get-Pfa2ProtectionGroup -Array $Array
            $script:ArrayProtectionGroupSnapshots = Get-Pfa2ProtectionGroupSnapshot -Array $Array -Name *
            $script:ConnectedArrays = Get-Pfa2ArrayConnection -Array $array
            $script:ArrayProxyServer = Get-Pfa2Support -Array $Array
            $script:ArrayNetworkInterfaces = Get-Pfa2NetworkInterface -Array $Array
            $script:ArrayPorts = Get-Pfa2Port -Array $array
            $script:ArrayDNS = Get-Pfa2Dns	 -Array $Array
            $script:ArrayDirectoryService = Get-Pfa2DirectoryService -Array $Array
            $script:ArrayDirectoryServiceGroups = Get-Pfa2DirectoryServiceRole -Array $Array
            $script:ArraySpaceMetrics = Get-Pfa2ArraySpace -Array $Array
            $script:ArrayDisks = Get-Pfa2Drive -Array $Array


            Section -Style Heading1 $ArrayAttributes.Name {
                Section -Style Heading2 'System Summary' {
                    Paragraph "The following section provides a summary of the array configuration for $($ArrayAttributes.Name)."
                    BlankLine
                    #Provide a summary of the Array
                    $ArraySummary = [PSCustomObject] @{
                        'Array Name' = $ArrayAttributes.Name
                        'Purity Version' = $ArrayAttributes.Version
                        'Array ID' = $ArrayAttributes.Id
                        'Number of Volumes' = $ArrayVolumes.count
                        'Number of Protection Groups' = $ArrayProtectionGroups.count
                        'Number of Protection Group Snapshots' = $ArrayProtectionGroupSnapshots.count
                        'Number of Hosts' = $ArrayHosts.count
                        'Number of Host Groups' = $ArrayHostGroups.count
                        'Number of Connected Arrays' = $ConnectedArrays.count
                    }
                    $ArraySummary | Table -Name 'Array Summary' -List -ColumnWidths 50, 50
                }#End Section Heading2 System Summary

                Section -Style Heading2 'Storage Summary' {
                    Paragraph "The following section provides a summary of the storage usage on $($ArrayAttributes.Name)."
                    BlankLine
                    $ArraySpaceSummary = [PSCustomObject] @{
                        'Capacity' = "$([math]::Round(($ArraySpaceMetrics.capacity) / 1TB, 2)) TB"
                        'Used' = "$([math]::Round(($ArraySpaceMetrics.space.TotalProvisioned) / 1TB, 2)) TB"
                        'Free' = "$([math]::Round(($ArraySpaceMetrics.capacity - $ArraySpaceMetrics.space.totalphysical) / 1TB, 2)) TB"
                        '% Used' = [math]::Truncate(($ArraySpaceMetrics.space.totalphysical / $ArraySpaceMetrics.capacity) * 100)
                        'Volumes' = "$([math]::Round(($ArraySpaceMetrics.space.TotalProvisioned) / 1GB, 2)) GB"
                        'Snapshots' = "$([math]::Round(($ArraySpaceMetrics.space.Snapshots) / 1GB, 2)) GB"
                        'Shared Space' = "$([math]::Round(($ArraySpaceMetrics.space.shared) / 1GB, 2)) GB"
                        'System' = "$([math]::Round(($ArraySpaceMetrics.space.system) / 1GB, 2)) GB"
                        'Data Reduction' = [math]::Round(($ArraySpaceMetrics.space.DataReduction), 2)
                        'Total Reduction' = [math]::Round(($ArraySpaceMetrics.space.totalreduction), 2)
                    }
                    $ArraySpaceSummary | Table -Name 'Storage Summary' -List -ColumnWidths 50, 50
                }#End Section Heading2 Storage Summary

                Section -Style Heading2 'Controller Summary' {
                    Paragraph "The following section provides a summary of the controllers in $($ArrayAttributes.Name)."
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
                    Paragraph "The following section provides a summary of the disks in $($ArrayAttributes.Name)."
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
                    Paragraph "The following section provides a summary of the Storage Configuration on $($ArrayAttributes.Name)."
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
                            Paragraph "The following section provides information on the hosts defined on $($ArrayAttributes.Name)."
                            BlankLine
                            if ($ArrayHosts.iqns) {
                                $ArrayHostConfigration = foreach ($ArrayHost in $ArrayHosts) {
                                    [PSCustomObject] @{
                                        'Host Name' = $ArrayHost.Name
                                        'Host Group' = $ArrayHost.HostGroup.name
                                        'IQN' = $ArrayHost.iqns
                                    }
                                }
                                $ArrayHostConfigration | Sort-Object -Property 'Host Name', 'Host Group' | Table -Name 'Hosts'
                            } elseif ($ArrayHosts.wwns) {
                                $ArrayHostConfigration = foreach ($ArrayHost in $ArrayHosts) {
                                    [PSCustomObject] @{
                                        'Host Name' = $ArrayHost.Name
                                        'Host Group' = $ArrayHost.HostGroup.name
                                        'WWN' = ($ArrayHost.wwns -split "(\w{2})" | Where-Object {$_ -ne ""}) -join ":"
                                    }
                                }
                                $ArrayHostConfigration | Sort-Object -Property 'Host Name', 'Host Group' | Table -Name 'Hosts'
                            } else {
                                $ArrayHostConfigration = foreach ($ArrayHost in $ArrayHosts) {
                                    [PSCustomObject] @{
                                        'Host Name' = $ArrayHost.Name
                                        'Host Group' = $ArrayHost.HostGroup.name
                                    }
                                }
                                $ArrayHostConfigration | Sort-Object -Property 'Host Name', 'Host Group' | Table -Name 'Hosts'
                            }
                        }#End Section Heading3 Hosts
                    }#End if ($ArrayHosts)

                    if ($ArrayHostGroups) {
                        Section -Style Heading3 'Host Groups' {
                            Paragraph "The following section provides information on the host groups on $($ArrayAttributes.Name)."
                            BlankLine
                            $ArrayHostGroupConfiguration = foreach ($ArrayHostGroup in $ArrayHostGroups) {
                                $ArrayHostGroupConnection = Get-Pfa2Hostgrouphost -Array $array -groupname $ArrayHostGroup.name
                                [PSCustomObject] @{
                                    'Host Group' = $ArrayHostGroup.name
                                    'Hosts' = ($ArrayHostGroupConnection.member.name -join ", ")
                                }
                            }
                            $ArrayHostGroupConfiguration | Sort-Object -Property 'Host Group Name' | Table -Name "Host Groups" -ColumnWidths 50, 50
                        }#End Section Heading3 Host Groups
                    }#End if ($ArrayHostGroups)

                    if ($ArrayVolumes) {
                        Section -Style Heading3 'Volumes' {
                            Paragraph "The following section provides information on the volumes on $($ArrayAttributes.Name)."
                            Blankline
                            $ArrayVolumeConfiguration = foreach ($ArrayVolume in $ArrayVolumes) {
                                $ArrayVolumeHostGroupConnection = Get-Pfa2Connection -Array $array -VolumeName $ArrayVolume.name
                                [PSCustomObject] @{
                                    'Volume Name' = $ArrayVolume.name
                                    'Volume Size' = "$(($ArrayVolume.space.TotalProvisioned / 1GB)) GB"
                                    'Volume Serial' = $ArrayVolume.Serial
                                    #need to work this shit out with pure need to match $ArrayVolumeHostGroupConnection.volume.name to $ArrayVolume.name
                                    'Host Group' = ($ArrayVolumeHostGroupConnection.hostgroup.name | Select-Object -Unique)
                                }
                            }
                            $ArrayVolumeConfiguration | Sort-Object -Property 'Volume Name' | Sort-Object "Volume Name" | Table -Name 'Volumes'
                        }#End Section Heading3 Volumes
                    }#End if ($ArrayVolumes)

                    if ($ArrayProtectionGroups) {
                        Section -Style Heading3 'Protection Groups' {
                            Paragraph "The following section provides information on the protection groups on $($ArrayAttributes.Name)."
                            BlankLine
                            $ArrayProtectionGroupConfiguration = foreach ($ArrayProtectionGroup in $ArrayProtectionGroups) {
                                $ArrayProtectionGroupvolume = Get-Pfa2ProtectionGroupVolume -Array $array -groupname $ArrayProtectionGroup.name
                                [PSCustomObject] @{
                                    'Name' = $ArrayProtectionGroup.Name
                                    'Host Group(s)' = $ArrayProtectionGroup.hgroups
                                    'Source' = $ArrayProtectionGroup.source.name
                                    'Targets' = $ArrayProtectionGroup.targets.name
                                    'Replication Allowed' = $ArrayProtectionGroup.targets.allowed
                                    'Volumes' = ($ArrayProtectionGroupvolume.member.name -join ", ")
                                }
                            }
                            $ArrayProtectionGroupConfiguration | Sort-Object -Property Name | Table -Name 'Protection Groups'
                        }#End Section Heading3 'Protection groups'
                    }#End if ($ArrayProtectionGroups)

                    if ($ArrayProtectionGroupSchedules) {
                        Section -Style Heading3 'Protection Group Schedules' {
                            Paragraph "The following section provides information on the protection group snapshot and replication schedules on $($ArrayAttributes.Name)."
                            BlankLine
                            $ArrayProtectionGroupScheduleConfiguration = foreach ($ArrayProtectionGroupSchedule in $ArrayProtectionGroupSchedules) {
                                [PSCustomObject] @{
                                    'Name' = $ArrayProtectionGroupSchedule.name
                                    'Snapshot Enabled' = $ArrayProtectionGroupSchedule.snapshotschedule.enabled
                                    'Snapshot Frequency (Mins)' = ($ArrayProtectionGroupSchedule.sourceretention.AllForSec)
                                    'Snapshot At' = $ArrayProtectionGroupSchedule.snapshotschedule.at
                                    'Replication Enabled' = $ArrayProtectionGroupSchedule.ReplicationSchedule.enabled
                                    'Replication Frequency (Mins)' = ($ArrayProtectionGroupSchedule.ReplicationSchedule.Frequency / 60)
                                    'Replicate At' = $ArrayProtectionGroupSchedule.ReplicationSchedule.at
                                    'Replication Blackout Times' = $ArrayProtectionGroupSchedule.ReplicationSchedule.blackout
                                }
                            }
                            $ArrayProtectionGroupScheduleConfiguration | Sort-Object -Property Name | Table -Name 'Protection Group Schedule'
                        }#End Section Heading3 'Protection Group Schedules'
                    }#End if (ArrayProtectionGroupSchedules)
                    
                    if ($Arrayfiledirectory) {
                        Section -Style Heading3 'Pure Storage //file Directory Configuration' {
                            Paragraph "The following section provides information on the configuration of NFS/SMB file objects on $($ArrayAttributes.Name)."
                            BlankLine
                            $ArrayfiledirectoryConfiguration = foreach ($Arrayfiledir in $Arrayfiledirectory) {
                                [PSCustomObject] @{
                                    'Name' = $Arrayfiledir.name
                                    'Directory Name' = $Arrayfiledir.DirectoryName
                                    'Path ' = $Arrayfiledir.path
                                    'Provisioned Space' = "$([math]::Round(($Arrayfiledir.space.TotalPhysical) / 1GB, 2)) GB"
                                    #'Resource Type' = $Arrayfiledir.limitedby.ResourceType
                                }
                            }
                            $ArrayfiledirectoryConfiguration | Sort-Object -Property Name | Table -Name 'Protection Group Schedule'
                        }#End Section Heading3 'Pure Storage //file Configuration'
                    }#End if Arrayfiledirectory)

                    if ($Arrayfiledirectoryexports) {
                        Section -Style Heading3 'Pure Storage //file Directory Exports Configuration' {
                            Paragraph "The following section provides information on the configuration of NFS/SMB file Directory exports on $($ArrayAttributes.Name)."
                            BlankLine
                            $ArrayfiledirectoryexportsConfiguration = foreach ($Arrayfiledirectoryexport in $Arrayfiledirectoryexports) {
                                [PSCustomObject] @{
                                    'Name' = $Arrayfiledirectoryexport.exportname
                                    'Path' = $Arrayfiledirectoryexport.path
                                    'Resource Type' = $Arrayfiledirectoryexport.policy.resourcetype
                                    'Enabled' = $Arrayfiledirectoryexport.enabled
                                }
                            }
                            $ArrayfiledirectoryexportsConfiguration | Sort-Object -Property Name | Table -Name 'Protection Group Schedule'
                        }#End Section Heading3 'Pure Storage //file Configuration'
                    }#End if Arrayfiledirectory)
                }#End Section Heading2 Storage Configuration

                Section -Style Heading2 'System Configuration' {
                    Paragraph "The following section provides information on the system configuration for $($ArrayAttributes.Name)."
                    if ($ArrayRelayHost -or $ArraySenderDomain -or $ArrayAlerts) {    
                        Section -Style Heading3 'SMTP Configuration' {
                            Paragraph "The following section provides information on the SMTP configuration for $($ArrayAttributes.Name)."
                            Blankline
                            $ArraySMTPConfiguration = [PSCustomObject] @{
                                'SMTP Server' = $ArrayRelayHost.relayhost
                                'SMTP Sender Domain' = $ArrayRelayHost.senderdomain
                                'SMTP Recipients' = ($ArrayAlerts.name -join ", ")
                            }
                            $ArraySMTPConfiguration | Table -Name 'SMTP Configuration' -List -ColumnWidths 50, 50 
                        }#End Section Heading3 SMTP Configuration
                    }

                    Section -Style Heading3 'SNMP Configuration' {
                        Paragraph "The following section provides information on the SNMP configuration for $($ArrayAttributes.Name)."
                        Blankline
                        $ArraySNMPConfiguration = [PSCustomObject] @{
                            'Name' = $ArraySNMPManagers.name
                            'Community V2' = $ArraySNMPManagers.v2c.community
                            'Community V3' = $ArraySNMPManagers.v3.community
                            'Privacy Protocol' = $ArraySNMPManagers.v3.privacy_protocol
                            'Authentication Protocol' = $ArraySNMPManagers.v3.auth_protocol
                            'Host' = $ArraySNMPManagers.host
                            'Version' = $ArraySNMPManagers.version
                            'User' = $ArraySNMPManagers.user
                            'Privacy Passphrase' = $ArraySNMPManagers.v3.privacy_passphrase
                            'Authentication Passphrase' = $ArraySNMPManagers.v3.auth_passphrase
                        }
                        $ArraySNMPConfiguration | Table -Name 'SNMP Configuration' -List -ColumnWidths 50, 50 
                    }#End Section Heading3 SNMP Configuration

                    if ($ArraySyslogServers) {
                        Section -Style Heading3 'Syslog Configuration' {
                            Paragraph "The following section provides information on the Syslog configuration for $($ArrayAttributes.Name)."
                            Blankline
                            $ArraySyslogConfiguration = [PSCustomObject] @{
                                'Syslog Servers' = ($ArraySyslogServers.Uri -join ", ")
                            }
                            $ArraySyslogConfiguration | Table -Name 'Syslog Configuration' -List -ColumnWidths 50, 50 
                        }#End Section Heading3 Syslog Configuration
                    }

                    if ($ArrayNTPServers) {
                        Section -Style Heading3 'NTP Configuration' {
                            Paragraph "The following section provides information on the NTP configuration for $($ArrayAttributes.Name)."
                            Blankline
                            $ArrayNTPConfiguration = [PSCustomObject] @{
                                'NTP Servers' = ($ArrayNTPServers.Destination -join ", ")
                            }
                            $ArrayNTPConfiguration | Table -Name 'NTP Configuration' -List -ColumnWidths 50, 50 
                        }#End Section Heading3 NTP Configuration
                    }

                    Section -Style Heading3 'Pure1 Support' {
                        Paragraph "The following section provides information on the Pure1 Support configuration for $($ArrayAttributes.Name)."
                        Blankline
                        $ArrayPure1Configuration = [PSCustomObject] @{
                            'Phone Home Status' = $ArrayPhoneHomeStatus.PhonehomeEnabled
                            'Remote Assist Status' = $ArrayRemoteAssistSession.RemoteAssistStatus
                            'Proxy Server' = $ArrayProxyServer.Proxy
                        }
                        $ArrayPure1Configuration | Table -Name 'Pure1 Configuration' -List -ColumnWidths 50, 50 
                    }#End Section Heading3 Pure1 Configuration

                    Section -Style Heading3 'SSL Certificate' {
                        Paragraph "The following section provides information on the SSL certificate for $($ArrayAttributes.Name)."
                        Blankline
                        $ArraySSLCertConfiguration = [PSCustomObject] @{
                            'Status' = $ArraySSLCertificate.status
                            'Issued To' = $ArraySSLCertificate.issuedto
                            'Issued By' = $ArraySSLCertificate.issuedby
                            'Valid from' = $ArraySSLCertificate.validfrom
                            'Valid To' = $ArraySSLCertificate.validto
                            'Locality' = $ArraySSLCertificate.locality
                            'Country' = $ArraySSLCertificate.country
                            'State' = $ArraySSLCertificate.state
                            'Key Size' = $ArraySSLCertificate.keysize
                            'Organisational Unit' = $ArraySSLCertificate.organizationalunit
                            'Organisation' = $ArraySSLCertificate.organization
                            'Email' = $ArraySSLCertificate.email
                        }
                        $ArraySSLCertConfiguration | Table -Name 'SSL Certificate' -List -ColumnWidths 50, 50
                    }#End Section Heading3 SSL Certificate
                }#End Section Heading2 System Configuration

                Section -Style Heading2 'Network Configuration' {
                    Paragraph "The following section provides information on the Network configuration for $($ArrayAttributes.Name)."
                    Section -Style Heading3 'Subnets and Interfaces' {
                        Paragraph "The following section provides information on the subnets and interfaces for $($ArrayAttributes.Name)."
                        Blankline
                        $ArrayNetworkConfiguration = foreach ($ArrayNetworkInterface in $ArrayNetworkInterfaces) {
                            [PSCustomObject] @{
                                'Name' = $ArrayNetworkInterface.name
                                'Enabled' = $ArrayNetworkInterface.enabled
                                'Subnet' = $ArrayNetworkInterface.eth.subnet
                                'MTU' = $ArrayNetworkInterface.eth.mtu
                                'IP Address' = $ArrayNetworkInterface.eth.address
                                'Netmask' = $ArrayNetworkInterface.eth.netmask
                                'Gateway Address' = $ArrayNetworkInterface.eth.gateway
                                'Hardware Address' = $ArrayNetworkInterface.eth.macaddress
                                'Interface Type' = $ArrayNetworkInterface.eth.subtype
                                'Services' = ($ArrayNetworkInterface.services -join ", ")
                                'Slaves' = ($ArrayNetworkInterface.slaves -join ", ")
                                'Speed GB' = "$([math]::round($ArrayNetworkInterface.speed / 1000000000 , 2)) GB"
                            }
                        }
                        $ArrayNetworkConfiguration | Sort-Object -Property Name | Table -Name 'Subnets and Interfaces'
                    }#End Section Heading3 Subnets and Interfaces

                    if ($ArrayPorts.wwn) {
                        Section -Style Heading3 'WWN Target Ports' {
                            Paragraph "The following section provides information on the WWN ports for $($ArrayAttributes.Name)."
                            Blankline    
                            $ArrayPortWWNConfiguration = foreach ($ArrayPort in $ArrayPorts) { 
                                [PSCustomObject] @{
                                    'Port' = $ArrayPort.Name
                                    'WWN' = ($ArrayPort.wwn -split "(\w{2})" | Where-Object {$_ -ne ""}) -join ":"
                                }
                            }
                            $ArrayPortWWNConfiguration | Sort-Object -Property Port | Table -Name 'WWN Target Ports'
                        }#End Section Heading3 WWN Target Ports
                    } if ($Arrayports.iqn) {
                        Section -Style Heading3 'IQN Target Ports' {
                            Paragraph "The following section provides information on the IQN ports for $($ArrayAttributes.Name)."
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
                            Paragraph "The following section provides information on the DNS configuration for $($ArrayAttributes.Name)."
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
                    Paragraph "The following section provides information on the Users configuration for $($ArrayAttributes.Name)."
                    if ($ArrayDirectoryService) { 
                        Section -Style Heading3 'Directory Service Configuration' {
                            $ArrayDirectoryServiceConfiguration = [PSCustomObject] @{
                                'Enabled' = $ArrayDirectoryService.Enabled
                                'URI' = ($ArrayDirectoryService.uris -join ", ")
                                'Base DN' = $ArrayDirectoryService.basedn
                                'Bind User' = $ArrayDirectoryService.Binduser
                                'Check Peer' = $ArrayDirectoryService.Checkpeer
                            }
                            $ArrayDirectoryServiceConfiguration | Table -Name 'Directory Service Configuration' -List
                        }#End Section Directory Service Configuration
                    }#End If ($ArrayDirectoryService)

                    if ($ArrayDirectoryServiceGroups) {
                        Section -Style Heading3 'Directory Service Groups' {
                            $ArrayDirectoryServiceGroupConfiguration = foreach ($ArrayDirectoryServiceGroup in $ArrayDirectoryServiceGroups) { 
                                [PSCustomObject] @{
                                'Group Base' = $ArrayDirectoryServiceGroup.groupbase
                                'Array Groups' = $ArrayDirectoryServiceGroup.group
                                'Role' = $ArrayDirectoryServiceGroup.role.name
                                #'Read Only Group' = $ArrayDirectoryServiceGroups.role.name
                                }
                            }
                            $ArrayDirectoryServiceGroupConfiguration | Table -Name 'Directory Service Groups'
                        }
                    }#End if ($ArrayDirectoryServiceGroups)
                }#End Section Heading2 Users
            }#End Section Heading1 $ArrayAttributes.Name
        }#End if $Array
        #Clear the $Array variable ready for reuse for a connection attempt on the next foreach loop
        Clear-Variable -Name Array
    }#End foreach $FlashArray in $Target
}#End Function Invoke-AsBuiltReport.PureStorage.FlashArray
