# Acquia Ready Insight Install Check and Reporting

## Objective 
Reduce the amount of time it takes all 4 COMs to check if their customers have installed Insight.  Additionally make results more accurate and less prone to error.

Current active customers are listed in Salesforce, with the docroot used on the hosting platform as a field.  Querying this data for negative or null Insight install values on open projects can provide us with a list of docroots to check.  Whilst it is easy to generate a report via the web [Insight install check report](https://na13.salesforce.com/a3E?fcf=00Ba000000AC8Ud&rolodexIndex=-1&page=1) for this, we can also generate raw data from the Salesforce force cli (command line interface).

Taking that list and running some AHT commands can show if a standard environment (dev, test, prod) has got the module installed (using drush) and additionally if it has been enabled.  Once the module is enabled it will automatically connect to Insight so any further checking shouldn’t be necessary.

## Requirements
 - Bastion access
 - AHT installation
 - Salesforce Login
 - force cli installed locally (Download from https://force-cli.heroku.com)
   place in ~/bin/ or somewhere in your path

## Firefox
When logging into Salesforce via the 'force' command Firefox may block the request with a "Blocked loading mixed active content" error and a blank page.  To stop this from happening click the shield icon in the address bar and choose Disable Protection on This Page from the dropdown menu.

## Future Enhancements

Currently this script doesn’t make any updates to the Objects but in theory it could be updated in future to support modifying the object in question should a working install of Insight be found

We could also check on the version of the module installed to make sure it is up-to-date by comparing what is in the codebase with the published release on d.o