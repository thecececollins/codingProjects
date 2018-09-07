# Sync the Casper Scripts to the JSS

We have a workflow for pushing scripts in this repo to the JSS. It is important
to remember that this method will always overwrite what is in the JSS. If you make changes in the JSS whenever someone runs a sync your changes will disappear.

## Setting it up
In order for the script to work you need to provide the JSS api password to it.
You can find the password in the shared IT Vault. In your local Casper/Documents/Scripts,
create a file called .password and add the password to it. The script expects the file to only contain one line with the password followed by a line break character. If you ```cat .password``` and the password blends in with your prompt you are missing the line break.

There is a `.gitignore` file located in Casper/Documents/Scripts, which is set to ignore the .password file. This keeps the API password that you've just added to a file in the folder from accidentally getting pushed from your machine up to GitHub. 

## Causing a sync to happen
If you've set things up you can sync. You must always been in the Scripts directory to run the sync. At the command line you type ```make``` and this runs the process.

1. ```cd Documents/Scripts```
2. ```make```

## What is it doing?
It looks at all the files in the Scripts directing and updates ones already in the JSS and creates ones that aren't already present.

## Caveats?
* It does not handle renames. If you rename something in the Scripts directory
and then update it will be in the JSS twice.
* Resolving conflicts is up to the user. This just helps to push things.
* No metadata is maintained or synced to the JSS, you must specifcy categories and other things in the JSS itself.

