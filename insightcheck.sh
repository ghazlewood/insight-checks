#!/bin/bash
#
# Insight Install Check 
# 
# Requires https://force-cli.heroku.com
#
# Before running this script you will need to login to Bastion and Saleforce 
# Login to Salesforce with
#
# force login
# 
# this will redirect to a browser and ask you to allow the force cli to use your Salesforce account

. ~/.ah_profile

# Check Bastion connection is open
function isControlMasterActive
{
    pgrep -f "ssh.*bastion" > /dev/null 2>&1
    echo $?
}
if [[ $(isControlMasterActive) -eq 0 ]]; then

  # Check we have an active salesforce login available
  if [ ! -z $(force active) ]; then

    sfDocroots=$(./force query select Name From Onboarding__c Where \(Insight_Connector__c = \'No\' OR Insight_Connector__c = null\) AND \(Onboarding_Stage__c NOT IN \(\'Complete\', \'Complete-Survey\',\'On Hold\',\'Closed\' \)\) ORDER BY Name ASC --format:csv)
    # Make an array of results
    sfDocrootsArray=( $sfDocroots )
    # Remove the header row
    sfDocrootsArray=("${sfDocrootsArray[@]:1}")

    # Test docroots (enabled, not installed, not enabled or installed)
    #sfDocrootsArray=('sarepta' 'uafs' 'isover');
    if [ ${#sfDocrootsArray[@]} -eq 0 ]; then
      echo "No docroots found"
    else
      for docroot in ${sfDocrootsArray[@]}; do
        # make sure docroot is lower
        docroot=$(echo $docroot | tr '[:upper:]' '[:lower:]')
        # trim double quotes
        docroot="${docroot%\"}"
        docroot="${docroot#\"}"
        # check not empty
        if [ ${#docroot} -ne 0 ]; then
          echo "Checking $docroot.dev/test/prod"
          for env in dev test prod; do
            ahtresult=$(aht --mc \@$docroot.$env drush pml | grep acquia_spi)
            if [ ! -z "$ahtresult" ]; then
              # get the version number of the module installed
              for m in ${ahtresult[@]}; do 
                if [ $( echo $m | grep '.x-' ) ]; then
                  version=$m; 
                fi
              done
              # check if module enabled
              enabled_check=$( echo "$ahtresult" | grep Enabled )
              if [ ! -z "$enabled_check" ]; then  
                enabled+=("$docroot.$env $version")
              fi
              # check if module in codebase but not installed
              installed_check=$( echo "$ahtresult" | grep "Not installed" )
              if [ ! -z "$installed_check" ]; then
                notinstalled+=("$docroot.$env $version")
              fi
            fi
          done
          echo "Done $docroot"
        fi
      done
    fi

    if [ ${#enabled[@]} -eq 0 ] && [ ${#notinstalled[@]} -eq 0 ]; then
      echo "\n----------\nNo new Insight installs found"
    else
      echo "\n----------\nThe following docroots have Insight installed"
      for enable in ${enabled[@]}; do
        echo $enable;
      done
      echo "\n----------\nThe following docroots have Insight in the codebase but haven't enabled it"
      for noinstall in ${notinstalled[@]}; do
        echo $noinstall;
      done
    fi
  else
    echo "Please login to Salesforce with './force login' first"
  fi
else
  echo 'Bastion not connected';
fi

# drush pm-releases acquia_connector --fields=release,status --pipe
