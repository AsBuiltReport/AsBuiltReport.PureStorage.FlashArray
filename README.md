<p align="center">
    <a href="https://www.powershellgallery.com/packages/AsBuiltReport.PureStorage.FlashArray/" alt="PowerShell Gallery Version">
        <img src="https://img.shields.io/powershellgallery/v/AsBuiltReport.PureStorage.FlashArray.svg" /></a>
    <a href="https://www.powershellgallery.com/packages/AsBuiltReport.PureStorage.FlashArray/" alt="PS Gallery Downloads">
        <img src="https://img.shields.io/powershellgallery/dt/AsBuiltReport.PureStorage.FlashArray.svg" /></a>
    <a href="https://www.powershellgallery.com/packages/AsBuiltReport.PureStorage.FlashArray/" alt="PS Platform">
        <img src="https://img.shields.io/powershellgallery/p/AsBuiltReport.PureStorage.FlashArray.svg" /></a>
</p>
<p align="center">
    <a href="https://github.com/AsBuiltReport/AsBuiltReport.PureStorage.FlashArray/graphs/commit-activity" alt="GitHub Last Commit">
        <img src="https://img.shields.io/github/last-commit/AsBuiltReport/AsBuiltReport.PureStorage.FlashArray/master.svg" /></a>
    <a href="https://raw.githubusercontent.com/AsBuiltReport/AsBuiltReport.PureStorage.FlashArray/master/LICENSE" alt="GitHub License">
        <img src="https://img.shields.io/github/license/AsBuiltReport/AsBuiltReport.PureStorage.FlashArray.svg" /></a>
    <a href="https://github.com/AsBuiltReport/AsBuiltReport.PureStorage.FlashArray/graphs/contributors" alt="GitHub Contributors">
        <img src="https://img.shields.io/github/contributors/AsBuiltReport/AsBuiltReport.PureStorage.FlashArray.svg"/></a>
</p>
<p align="center">
    <a href="https://twitter.com/AsBuiltReport" alt="Twitter">
            <img src="https://img.shields.io/twitter/follow/AsBuiltReport.svg?style=social"/></a>
</p>

# Pure Storage FlashArray AsBuiltReport

Pure Storage FlashArray AsBuiltReport is a module of the parent "AsBuiltReport" [project](https://github.com/AsBuiltReport/AsBuiltReport). AsBuiltReport is a PowerShell module which generates As-Built documentation for many common datacentre infrastructure systems. Reports can be generated in Text, XML, HTML and MS Word formats and can be presented with custom styling to align with your company/customer's brand.

For detailed documentation around the whole project, please refer to the `README.md` file in the parent AsBuiltReport repository (linked to above). This README is specific only to the PureStorage Flasharray repository.

# Sample Reports

<Coming Soon>

# Getting Started

Below are the instructions on how to install, configure and generate a Pure Storage Flash Array As Built Report

## Pre-requisites
The following PowerShell modules are required for generating a Pure Storage Flash Array As Built report.

Each of these modules can be easily downloaded and installed via the PowerShell Gallery 

- [Pure Storage Powershell SDK2 Module](https://www.powershellgallery.com/packages/PureStoragePowerShellSDK2)
- [AsBuiltReport Module](https://www.powershellgallery.com/packages/AsBuiltReport/)

### Module Installation

Open a Windows PowerShell terminal window and install each of the required modules as follows;
```powershell
Install-Module PureStoragePowerShellSDK2
Install-Module AsBuiltReport
```

### Required Privileges

To generate a Pure Storage FlashArray report, a user account with the readonly role of higher on the FlashArray is required.

## Configuration

The Pure Storage Flash Array As Built Report utilises a JSON file to allow configuration of report information, options, detail and healthchecks.

A Pure Storage Flash Array report configuration file can be generated by executing the following command;
```powershell
New-AsBuiltReportConfig -Report PureStorage.FlashArray -Path <User specified folder> -Name <Optional>
```

Executing this command will copy the default FlashArray report JSON configuration to a user specified folder.

All report settings can then be configured via the JSON file.

The following provides information of how to configure each schema within the report's JSON file.

<Placeholder for future - there are currently no configurable options for the Pure Storage FlashArray Report>


## Examples
There is one example listed below on running the AsBuiltReport script against a Pure Storage FlashArray target. Refer to the `README.md` file in the main AsBuiltReport project repository for more examples.

- The following creates a Pure Storage FlashArray As-Built report in HTML & Word formats in the folder C:\scripts\.
```powershell
PS C:\>New-AsBuiltReport -Report PureStorage.FlashArray -Target 192.168.1.100 -Credential (Get-Credential) -Format HTML,Word -OutputPath C:\scripts\
```

## Known Issues

- Missing Infomation in the Storage summary for Used space and Volumes.

  This Issue has been noticed in Purity Version 6.4.10 but could effect other versions in the 6.4.x branch this issue has been raised to the Pure Storage product team to rectify missing or non fucntioning API's.

- Incorrect Speed shown Network Configuration

  Due to An issue with the Purity code the interface Speed that is shown in the UI and via API calls will default to the Maximum speed avalible on that interface not the current interface/SFP speed. 
