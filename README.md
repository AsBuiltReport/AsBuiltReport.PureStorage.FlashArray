# Pure Storage FlashArray AsBuiltReport

Pure Storage FlashArray AsBuiltReport is a module of the parent "AsBuiltReport" project (https://github.com/AsBuiltReport/AsBuiltReport). AsBuiltReport is a PowerShell module which generates As-Built documentation for many common datacentre infrastructure systems. Reports can be generated in Text, XML, HTML and MS Word formats and can be presented with custom styling to align with your company/customer's brand.

For detailed documentation around the whole project, please refer to the `README.md` file in the parent AsBuiltReport repository (linked to above). This README is specific only to the PureStorage Flasharray repository.

# Getting Started

The following simple list of instructions will get you started with the AsBuiltReport module.

## Pre-requisites

All CmdLets and Functions require the [PScribo](https://github.com/iainbrighton/PScribo) module version 0.7.24 or later.
PScribo can be installed from the PowerShell Gallery with the following command:

```powershell
Install-Module PScribo
```

Installing the AsBuiltReport module from the Powershell Gallery will install the framework module, and all sub-product modules such as this PureStorage.FlashArray module.
AsBuiltReport can be installed from the PowerShell Gallery with the following command:
```powershell
Install-Module AsBuiltReport
```

For the Pure Storage FlashArray report, you are required to install the Pure Storage Powershell SDK module.
The Pure Storage Powershell SDK Module can be installed with the following command:
```powershell
Install-Module PureStoragePowerShellSDK
```

## Using AsBuiltReport

Each report type utilises a common set of parameters. Additional parameters specific to each report will be detailed in the report's `README.md` file, along with any relevant examples.

For a full list of common parameters and examples you can view the `New-AsBuiltReport` CmdLet help with the following command.

```powershell
Get-Help New-AsBuiltReport -Full
```

## Examples
There is one example listed below on running the AsBuiltReport script against a Pure Storage FlashArray target. Refer to the `README.md` file in the main AsBuiltReport repository for more examples.

- The following creates a Pure Storage FlashArray As-Built report in HTML & Word formats.
```powershell
PS C:\>New-AsBuiltReport -Report PureStorage.FlashArray -Target 192.168.1.100 -Credential (Get-Credential) -Format HTML,Word
```

# Samples


# Release Notes

## [0.1.0] - Unreleased
### What's New

- This version contains a complete refactor of the project so that it is now a PowerShell module.