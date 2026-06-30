# omnistudio-quote-docgen

## Overview

This repo was created from a labor of love and with the hope of paying it forward so that the next person that has to travel this road has an easier time.

## Quick Install

Use either of the following options to deploy this project to your org.

### Option 1: VS Code

1. Open the project in VS Code.
2. Authorize your target org from the Command Palette.
3. Right-click [manifest/package.xml](manifest/package.xml) and select SFDX: Deploy Source in Manifest to Org.
4. After deployment, assign the included permission set to your test users in addition the standard Omnistudio and DocGen permission sets based on role and need.

### Option 2: SF CLI

1. Authorize your org:

```bash
sf org login web --alias revcloud --set-default
```

2. Deploy metadata using the manifest:

```bash
sf project deploy start --manifest manifest/package.xml --target-org revcloud
```

3. Assign the permission set (replace name as needed):

```bash
sf org assign permset --name RCA_DocGen_User --target-org revcloud
```

## Key Features

Key features include:

- Document Template that defines the template and data mappers
- Data Mappers used to extract and transform data
- Microsoft Word template with Data Tags
- Flows that step users through the generatation process:
  - LWC and Apex
  - LWC and Omniscript
- Apex
  - Core Document Generation
  - Multi Currency support
  - Test Factory and Classes @ 100% coverage
- Omniscript used to by flow

## Components

Here is a quick overview of the assets included in this repo:

| Component Type               | Purpose                                                                                                                                                     |
| ---------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Apex Classes and Tests       | Core classes that generate the documents plus support classes for currency support and lwc methods as well as the test factory and classes @ 100% coverage. |
| Custom Metadata              | Object used to manage supported currencies. Supported by default: EUR, GBP, INR, JPY, MXN, and USD                                                          |
| Document Generation Settings | Defines Salesforce Document Generation configuration and Content Library.                                                                                   |
| Document Templates           | Document Template record that defines the Data Mappers and the Word Document with the data tags defined                                                     |
| Flows                        | Used to generate the Quote Docs from the Quote object                                                                                                       |
| Lightning Web Components     | LWC's used via flow to help manage the document generation process.                                                                                         |
| Objects and Fields           | Fields on the Quote and the Custom Metadata object used for custom currencies.                                                                              |
| OmniDataTransforms           | The Data Mappers used to extract and transform the data for the Document Generation process.                                                                |
| Permission Sets              | Example permission set that grants permissions users need to generate omniscript document generation successfully.                                          |
| Quick Actions                | Example quick actions that call the flow from the Quote in order to generate the quote document.                                                            |
| Deployment Manifest          | Defines metadata selection for retrieve and deploy operations.                                                                                              |
| Currency Metadata Backup     | Backup of 30 currencies that can be imported in addition to the 5 already included.                                                                         |
| Omniscripts                  | Contains the Omniscript import/export files and notes on how to install.                                                                                    |
| Quote Template               | Two example Microsoft Word document templates to use with this example setup.                                                                               |

## Lessons Learned

Here are some of the lessons learned:

- Package vs. Core
  - I would like to think I learned Omnistudio the old fashion way as a lot of the online tutorials on youtube are several years old and reference the package functionality that has since been replaced and/or updated in both the package and the core versions that exist today. And ai was also constantly confused with the different versions and functionality that has existed over the last 3+ years. That’s not to say the internet was not a resource because it was. It just was a lot harder than it usually is when learning new stuff.
- Watermarks
  - There were a lot of clues on how to get the watermark working but it took a bit of work to sort through them all. Ai thought I should inject the watermark in to the document at time of generation using base64 and an apex class. That failed miserably.
  - Other solutions included outdated functionality not found in word and even if it was there included the instructions to insert the image, delete it, and then somehow click on where it was and insert the tab and that would somehow trick word to show the image on rendering.
  - Bottom line is the solution I documented works…use it.
- Security
  - For some reason using the base permission sets for users (non-admin) does not work. It requires a custom permission set to fix field and record visibility issues. Sharing rules can be used but the permission via the perm set I think is a better solution.
  - Below is a detail explanation of the security in the permission set included in this repo.
- Embedding Omniscripts in Flows
  - At one point google and ai told me I could not embed omniscripts in to lwc’s and flow but after peeling back the Salesforce documentation I figured out how to get it working. The solution feels a bit like a set of Russian stacking dolls as the omniscript also calls a component to get this to work so it’s flow → lwc → omniscript → omniscript component but it does work.
  - The draw back with using at least this omniscript in flows is that the component that gets called to generate the document does not give any error or timeout messages to the user. So if there’s an issue with security or if the process failed the user is never notified which is why I switched to the apex version as it does give the user the ability to see error messages and if the process runs long the solution will give the user the option of exiting the flow or waiting longer.
- Content Libraries
  - Hope you can still get to the salesforce classic ui because to set this up you will need to create a library named “Docgen Document Template Library”. I tried using a different name and it kind of works but it requires that you share the template out to the org via the classic files interface. It’s easier to just create the library and sticking the template and watermark in it. The watermark can technically be in any library.
  - Most org’s default to 5 libraries but you can get that extended in case you are already at your limit. Just open a case and request the limit increase.
