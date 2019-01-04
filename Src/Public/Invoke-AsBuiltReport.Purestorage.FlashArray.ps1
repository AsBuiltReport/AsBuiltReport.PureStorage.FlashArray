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
        Github:         mattallford
        Credits:        Iain Brighton (@iainbrighton) - PScribo module

    .LINK
        https://github.com/AsBuiltReport/
    #>

    #region Script Parameters
    [CmdletBinding()]
    param (
        $Target,
        [pscredential] $Credential
    )

    # If custom style not set, use default style
    if (!$StyleName) {
        & "$PSScriptRoot\..\Assets\Styles\PureStorage.ps1"
    }

    $Script:Array = $Null
    foreach ($FlashArray in $Target){
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
            #$script:ArrayVolumeSnapshots = $ArrayVolumes | Get-PfaVolumeSnapshots -Array $Array
            $script:ArrayProtectionGroups = Get-PfaProtectionGroups -Array $Array
            $script:ArrayProtectionGroupSnapshots = Get-PfaProtectionGroupSnapshots -Array $Array -Name *
            $script:ConnectedArrays = Get-PfaArrayConnections -Array $array
            $script:ArrayProxyServer = Get-PfaProxy -Array $Array
            $script:ArrayNetworkInterfaces = Get-PfaNetworkInterfaces -Array $Array
            $script:ArrayPorts = Get-PfaArrayPorts -Array $array
            $script:ArrayDNS = Get-PfaDnsAttributes -Array $Array


            Section -Style Heading1 $ArrayAttributes.array_name {
                Section -Style Heading2 'System Summary' {
                    Paragraph 'The following section provides a summary of the array configuration.'
                    BlankLine
                    #Provide a summary of the Array
                    $ArraySummary = [PSCustomObject] @{
                        'Array Name' = $ArrayAttributes.array_name
                        'Purity Version' = $ArrayAttributes.version
                        'Array ID' = $ArrayAttributes.id
                        'Volume #' = $ArrayVolumes.count
                        #'Volume Snapshot #' = 
                        #'Volume Group #' = 
                        'Protection Group #' = $ArrayProtectionGroups.count
                        'Protection Group Snaphost #' = $ArrayProtectionGroupSnapshots.count
                        'Host #' = $ArrayHosts.count
                        'Host Group #' = $ArrayHostGroups.count
                        #'Pod #' = 
                        'Connected Array #' = $ConnectedArrays.count
                    }
                    $ArraySummary | Table -Name 'Array Summary' -List
                }#End Section Heading2 System Summary


                Section -Style Heading2 'System Configuration' {
                Paragraph 'The following section provides information on the array system configuration.'
                    if ($ArrayRelayHost -or $ArraySenderDomain -or $ArrayAlerts){    
                        Section -Style Heading3 'SMTP Configuration' {
                            Paragraph 'The following section provides information on the SMTP configuration.'
                            Blankline
                            $ArraySMTPConfiguration = [PSCustomObject] @{
                                'SMTP Server' = $ArrayRelayHost.relayhost
                                'SMTP Sender Domain' = $ArraySenderDomain.senderdomain
                                'SMTP Recipients' = ($ArrayAlerts.name -join ", ")
                            }
                            $ArraySMTPConfiguration | Table -Name 'SMTP Configuration'
                        }#End Section Heading3 SMTP Configuration
                    }

                    Section -Style Heading3 'SNMP Configuration' {
                        Paragraph 'The following section provides information on the SNMP configuration.'
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
                        $ArraySNMPConfiguration | Table -Name 'SNMP Configuration' -List
                    }#End Section Heading3 SNMP Configuration

                    if ($ArraySyslogServers) {
                        Section -Style Heading3 'Syslog Configuration' {
                            Paragraph 'The following section provides information on the Syslog configuration.'
                            Blankline
                            $ArraySyslogConfiguration = [PSCustomObject] @{
                                'Syslog Servers' = ($ArraySyslogServers.syslogserver -join ", ")
                            }
                            $ArraySyslogConfiguration | Table -Name 'Syslog Configuration'
                        }#End Section Heading3 Syslog Configuration
                    }

                    if ($ArrayNTPServers) {
                        Section -Style Heading3 'NTP Configuration' {
                            Paragraph 'The following section provides information on the NTP configuration.'
                            Blankline
                            $ArrayNTPConfiguration = [PSCustomObject] @{
                                'NTP Servers' = ($ArrayNTPServers.ntpserver -join ", ")
                            }
                            $ArrayNTPConfiguration | Table -Name 'NTP Configuration'
                        }#End Section Heading3 NTP Configuration
                    }

                    Section -Style Heading3 'Pure1 Support' {
                        Paragraph 'The following section provides information on the Pure1 Support configuration.'
                        Blankline
                        $ArrayPure1Configuration = [PSCustomObject] @{
                            'Phone Home Status' = $ArrayPhoneHomeStatus.phonehome
                            'Remote Assist Status' = $ArrayRemoteAssistSession.status
                            'Proxy Server' = $ArrayProxyServer.proxy
                        }
                        $ArrayPure1Configuration | Table -Name 'Pure1 Configuration'
                    }#End Section Heading3 Pure1 Configuration

                    Section -Style Heading3 'SSL Certificate' {
                        Paragraph 'The following section provides information on the array SSL certificate.'
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
                Paragraph 'The following section provides information on the array Network configuration.'
                    Section -Style Heading3 'Subnets and Interfaces'{
                        Paragraph 'The following section provides information on the array subnets and interfaces.'
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
                        $ArrayNetworkConfiguration | Table -Name 'Subnets and Interfaces'
                    }#End Section Heading3 Subnets and Interfaces

                    if ($ArrayPorts.wwn){
                        Section -Style Heading3 'WWN Target Ports'{
                            Paragraph 'The following section provides information on the array WWN ports.'
                            Blankline    
                            $ArrayPortWWNConfiguration = foreach ($ArrayPort in $ArrayPorts) { 
                                [PSCustomObject] @{
                                    'Port' = $ArrayPort.Name
                                    'WWN' = ($ArrayPort.wwn -split "(\w{2})" | Where-Object {$_ -ne ""}) -join ":"
                                }
                            }
                            $ArrayPortWWNConfiguration | Table -Name 'WWN Target Ports'
                        }#End Section Heading3 WWN Target Ports
                    } Elseif ($Arrayports.iqn) {
                        Section -Style Heading3 'IQN Target Ports'{
                            Paragraph 'The following section provides information on the array IQN ports.'
                            Blankline    
                            $ArrayPortIQNConfiguration = foreach ($ArrayPort in $ArrayPorts)  {
                                [PSCustomObject] @{
                                    'Port' = $ArrayPort.Name
                                    'IQN' = $ArrayPort.iqn
                                }
                            }
                            $ArrayPortIQNConfiguration | Table -Name 'IQN Target Ports'
                        }#End Section Heading3 IQN Target Ports
                    }#End if $Arrayports

                    if ($ArrayDNS){
                        Section -Style Heading3 'DNS'{
                            Paragraph 'The following section provides information on the array DNS.'
                            Blankline
                            $ArrayDNSConfiguration = [PSCustomObject] @{
                                'Domain Name' = $ArrayDNS.domain
                                'DNS Servers' = ($ArrayDNS.nameservers -join ", ")
                            }
                            $ArrayDNSConfiguration | Table -Name 'DNS'
                        }#End Section Heading3 DNS
                    }#End if $ArrayDNS

                }#End Section Heading2 Network Configuration
            }#End Section Heading1 $ArrayAttributes.array_name
        }#End if $Array
    }#End foreach $FlashArray in $Target
}#End Function Invoke-AsBuiltReport.PureStorage.FlashArray