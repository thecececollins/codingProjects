#!/bin/bash

if [ `which pip` ] 
	then 
		echo 'Pip is installed.'
	else
		easy_install pip
		echo 'Pip was installed.'
fi

pip install -U pip > /dev/null			
pip install pyperclip > /dev/null	

echo """#!/usr/bin/env python
import pyperclip, time, webbrowser, urllib, os, sys
print '''
 ===================================================================================
 Welcome to the SAM script. Please use this along with the SAM Form Results Sheet to
 populate Access Request issues.
 This is SAM Script v 0.6.5. If at any point you run into an error, use CTRL+C to exit
 the program. For questions or feedback, please reach out to @alana.
 =================================================================================== 
 '''
user = raw_input('Access For (@handle or Full Name): ')
requestor = raw_input('Requested By (@handle or Full Name): ')
date = raw_input('Start Date (if applicable): ')
datetext = ''
linebreak = '.' * 20
form = ''
compasstools = '%s please have %s complete [this form](https://goo.gl/forms/TTKIFaDUFOzNrwFz1) to initiate Compass Tool account setup. @mcdonough will process form results once received.' % (requestor, user)
gsuite = '%s (or manager), please add %s to team-specific Google Groups.\n  - [ ] IT: Save first time password & 2FA Backup Code in IT Vault' % (requestor, user)
gsuite_c = '\n  - [ ] Add \'(Contractor)\' to last name in Google'
github_e = '%s (or manager), please add %s to team-specific GitHub Teams & Repos.' % (requestor, user)
github_pub = '%s, please provide us with %s\'s public GitHub handle, or have them create one.' % (requestor, user)
lucidchart = 'LucidChart Read-Only access is granted by the user signing in using Google Sign-On. For a full licensed version (which grants Edit rights), we will need a +1 in this ticket from %s purchasing manager to approve an annual license subscription cost of $%d.' % (user, 99.99)
concord = 'Concord Fax access should be available for %s to setup following [this guide](https://github.banksimple.com/it/help/blob/master/Guides/faxing.md). Please reach out if there are issues with this process.' % user
delegated = 'IT: Please update the [delegated inbox tracking sheet](https://docs.google.com/spreadsheets/d/1aIbPCRn-jKSHZcjETINdwqTkCfZdtYFVOIiujQW22v4/edit#gid=0).'
visaonline = 'To sign up with Visa Online, have %s visit their [online setup tool](https://www.visaonline.com) and choose **Enroll Now**.' % user
lifecycletoken = '%s can request a LifeCycle token once they\'ve enrolled at [visaonline.com](https://www.visaonline.com). If there are issues, we can reach out to John Cates for assistance.' % user
sharepointgroup = 'IT: Please reference the [O365 License & Permissions sheet](https://docs.google.com/spreadsheets/d/1vqtmyqhM3uT9ueDeev-RzFbIAP7wLVcqC7lC4T_opr4/edit?ts=58698493#gid=0) for proper assignment of licenses. We will need a +1 in this ticket from %s manager for an annual license subscription cost.' % user
larry = 'IT: Paste the requested reasoning for Local Admin Access in the comments below.'
chartio = 'IT add to Simple Employees group. %s (or manager), please add %s to team-specific ChartIO dashboards' % (requestor, user)
redshift = '%s (or manager), if %s needs a Navicat license, please comment in this issue approving a license purchase of $%d to be billed to your department. We will make the app available for them to install via Self Service.' % (requestor, user, 49.99)
davenport = 'IT: Davenport access are distributed from within Active Directory by assigning group membership.'
salesforce = 'IT: Salesforce Profiles are distributed from within Active Directory by assigning group membership.'
segmentio = 'IT: Please add user to both the [SegmentIO](https://segment.com/banksimple) & [SegmentIO Dev](https://segment.com/banksimple-dev)'
newrole = False
newrolename = ''
employee = ''
roleselect = ''
fte = False 
duplicates = []
e_status = ''
if len(date) > 2 :
	datetext = '**Start Date:** ' + date
	date = ' - %s' % date
text = '''
## SAM %s Request
**Name:** %s
**Requested by:** %s
%s
**NOTE:** If %s is not %s\'s manager or a recruiter, please ping %s\'s manager to approve this access request.
''' % (form, user, requestor, datetext, requestor, user, user)
spec = ''
form = ''
rolefilled = False
subject = ''
approval = True
additionalcount = 0
e_status = ['FTE', 'Temporary Employee', 'Contractor or Consultant', 'BBVAC']
menulist = ['Back', 'New Employee, Temp or Contractor', 'Conversion to FTE', 'Role Change', 'Add Individual Systems Access']
reqtypes = ['Back', 'Additional access for an individual', 'Additional access for an entire role']
groups = ['Back', 'Simple Basics', 'Office', 'CR', 'Business Administration', 'Creative & Studio', 'Marketing', 'Risk, Compliance & Fraud', 'Engineering, Infra & IT', 'Security', 'Exit']
deptlist = ['Back', 'Brand', 'CEO', 'Customer Operations', 'Engineering', 'Finance & ERM', 'People', 'Product']
# deptlist = ['Back', 'Accounting & Finance', 'CR', 'Engineering', 'ELT', 'InfoSec & IT', 'Marketing', 'Operations', 'People', 'Product', 'Risk & Compliance']
systems  = {
'Simple Basics': {
	'ADP': {
		'name': 'ADP',
		'access': ['User', 'Manager', 'Admin'],
		'provisioner': '@mandara'
		},
	'Bamboo HR': {
		'name': 'Bamboo HR',
		'access': ['User', 'Manager'],
		'provisioner': '@tempyvermeire'
		},
	'BVS': {
		'name': 'BVS',
		'access': ['User', 'Admin'],
		'provisioner': '@matts'
		},
	'Concur': {
		'name': 'Concur',
		'access': ['User', 'Approver'],
		'provisioner': '@nik'
		},
	'G Suite': {
		'name': 'G Suite',
		'access': ['User', 'Admin', 'Super Admin'],
		'special': [gsuite]
		},
	'GitHub: Enterprise': {
		'name': 'GitHub: Enterprise',
		'access': ['User', 'Admin'],
		'special': [github_e]
		},
	'GitHub: Simple Public': {
		'name': 'GitHub: Simple Public',
		'access': ['User', 'Admin'],
		'special': [github_pub]
		},
	'Asterisk VoIP': {
		'name': 'Asterisk VoIP',
		'access': ['Extension', 'Admin'],
		'provisioner': '@it/itinfra'
		},
	'ChartIO': {
		'name': 'ChartIO',
		'access': ['Read Only', 'Editor', 'Admin', 'Owner'],
		'provisioner': '@loricrew @zihe', 
		'special' : [chartio]
		},
	'LucidChart': {
		'name': 'LucidChart',
		'access': ['User (Unlicensed - Read Only)', 'Admin - (Unlicensed - Admin & Read Only)']#,
		#'special': [lucidchart]
		},
	'Slack': {
		'name': 'Slack',
		'access': ['Guest', 'User', 'Admin', 'Owner'],
		},
	'Team Gantt': {
		'name': 'Team Gantt', 
		'access': ['Basic', 'Advanced', 'Account Manager'],
		'approver': '@tc'
		},
	'ZNC': {
		'name': 'ZNC',
		'access': ['User', 'Admin'],
		'provisioner': '@whit'
		},
	'VPN': {
		'name': 'VPN',
		'access': ['Access']
		},
	'Simple WiFi': {
		'name': 'Simple WiFi',
		'access': ['User', 'Admin']
		}},
'Office': {
	'Envoy Sign-In System': {
		'name': 'Envoy Sign-In System',
		'access': ['User', 'Admin'], 
		'provisioner': '@tia'
		},
	'Everbridge': {
		'name': 'Everbridge',
		'access': ['User', 'Admin'],
		'provisioner': '@tia'
		},
	'ExacqVision Video Surveilance': {
		'name': 'ExacqVision Video Surveilance',
		'access': ['User', 'Admin'],
		'provisioner': '@tia'
		},
	'Office Security System': {
		'name': 'Office Security System',
		'access': ['User', 'Admin'],
		'provisioner': '@tia'
		},
	'Physical Badge Access': {
		'name': 'Physical Badge Access',
		'access': ['Basic', 'Network & Wiring Rooms', 'Storage Closets'],
		'provisioner': '@aveidenheimer'
		}},
'CR': {
	'Belvedere': {
		'name': 'Belvedere',
		'access': ['Admin', 'Backend', 'CR', 'Disputes', 'Engineer', 'Fraud', 'IDV', 'Onboarding', 'RDC', 'Risk']
		},
	'Chili': {
		'name': 'Chili',
		'access': ['Access']
		},
	'Concord Fax': {
		'name': 'Concord Fax',
		'access': ['Access'],
		'special': [concord]
		},
	'RETIRED: CPI Advantage': {
		'name': 'RETIRED: CPI Advantage',
		'access': ['User', 'Admin'],
		'provisioner': '@naps',
		'retired': [True]
		},
	'CPI Card Group': {
		'name': 'CPI Card Group',
		'access': ['Find a Card', 'Check Inventory', 'Reports', 'Special Handling', 'Track an Order', 'Admin'],
		},
	'Compass Tools': {
		'name': 'Compass Tools',
		'access': ['Citrix Server', 'Content_Viewer', 'OneStop'],
		'special': [compasstools]
		},
	'Fiserv PartnerCare': {
		'name': 'Fiserv PartnerCare',
		'access': ['User', 'Admin']
		},
	'Mr. Burns': {
		'name': 'Mr. Burns',
		'access': ['User', 'Admin']
		},
	'Google Inbox': {
		'name': 'Google Inbox',
		'access': ['applications@', 'qualityresources@', 'escalations@', 'validate@', 'verify@'],
		'special': [delegated]
		},
	'Orderly Stats': {
		'name': 'Orderly Stats',
		'access': ['Agent', 'Admin'],
		'provisioner': '@elisabethhowell'
		},
	'Primer': {
		'name': 'Primer',
		'access': ['User', 'Editor', 'Admin'],
		'provisioner': '@amac'
		},
	'Salesforce Profile': {
		'name': 'Salesforce Profile',
		'access': ['General User', 'Systems Administrator', 'CR Agent', 'CR Lead', 'CR FDA', 'QA & Education', 'Risk', 'Deposit Risk', 'Disputes', 'Compliance', 'Banking Ops', 'Integration User'],
		'approver': '@barbara @mcdonough',
		'special': [salesforce]
		},
	'Salesforce Permissions': {
		'name': 'Salesforce Permissions',
		'access': ['Account Management', 'Document Review', 'CR + Dispute', 'Delegated Administrator', 'Knowledge LSF', 'Knowledge-Escalations', 'Override Audit Fields', 'Report and Dashboard Folder and Sharing', 'Manage Knowledge', 'Manage List Views', 'Manage Users', 'View Setup and Configuration-READONLY'],
		'provisioner': '@ryanpking @codikodama'
		},
	'Salesforce Public Group': {
		'name': 'Salesforce Public Group',
		'access': ['Employee Group'],
		'provisioner': '@codikodama @ryanpking'
		},
	'Sprout Social': {
		'name': 'Sprout Social',
		'access': ['Twitter', 'Facebook', 'Admin', 'Read Only', 'Reporting'],
		'provisioner': '@carlynovak'
		},
	'Lifecycle Token Management': {
		'name': 'Lifecycle Token Management',
		'access': ['Access'],
		'special': [lifecycletoken]
		},
	'Voci': {
		'name': 'Voci',
		'access': ['User', 'Manager'],
		'provisioner': '@it/itinfra'
		},
	'WFM Admin Client': {
		'name': 'WFM Admin Client',
		'access': ['WF Analyst', 'IT/Infra', 'Super Administrator'],
		'provisioner': '@elisabethhowell'
		},
	'WFM MyTime': {
		'name': 'WFM MyTime',
		'access': ['Agent'],
		'provisioner': '@elisabethhowell'
		},
	'WFM Teams': {
		'name': 'WFM Teams',
		'access': ['Shift Lead', 'Support Manager', 'Manager (Read Only)'],
		'provisioner': '@elisabethhowell'
		}},
'Business Administration': {
	'ADP Administration': {
		'name': 'ADP Administration',
		'access': ['Superuser', 'Reporting', 'Timecard Manager', 'Leadership'],
		'provisioner': '@mandara'
		},
	'Axiom EPM': {
		'name': 'Axiom EPM',
		'access': ['User', 'Admin'],
		'provisioner': '@stuartbell'
		},
	'Axiom Windows Server': {
		'name': 'Axiom Windows Server',
		'access': ['User', 'Admin']
		},
	'Bamboo HR': {
		'name': 'Bamboo HR',
		'access': ['Reporting', 'Admin'],
		'provisioner': '@tempyvermeire'
		},
	'Basecamp: Finance': {
		'name': 'Basecamp: Finance',
		'access': ['User', 'Admin', 'Read Only'],
		'provisioner': '@murphy'
		},
	'BBVA Compass Treasury': {
		'name': 'BBVA Compass Treasury',
		'access': ['Access'],
		'provisioner': '@coryruell'
		},
	'Google Inbox': {
		'name': 'Google Inbox',
		'access': ['bd@']
		},
	'Bill.com': {
		'name': 'Bill.com',
		'access': ['User', 'Admin'],
		'provisioner': '@murphy'
		},
	'Box.com': {
		'name': 'Box.com',
		'access': ['User', 'Admin'],
		'provisioner': '@murphy'
		},
	'Concur': {
		'name': 'Concur',
		'access': ['Manager', 'Travel Admin', 'Admin'],
		'provisioner': '@nik'
		},
	'ContractWorks': {
		'name': 'ContractWorks',
		'access': ['User', 'Admin'],
		'provisioner': '@nik'
		},
	'DocuSign': {
		'name': 'DocuSign',
		'access': ['User', 'Admin'],
		'provisioner': '@nik'
		},
	'Fidelity': {
		'name': 'Fidelity',
		'access': ['User'],
		'provisioner': '@murphy'
		},
	'Floqast': {
		'name': 'Floqast',
		'access': ['User', 'Admin'],
		'provisioner': '@murphy'
		},
	'Greenhouse': {
		'name': 'Greenhouse',
		'access': ['User', 'Job Admin', 'Site Admin', 'Offer Letter Admin'],
		'provisioner': '@anthonyadams'
		},
	'Intacct': {
		'name': 'Intacct',
		'access': ['User', 'Admin'],
		'provisioner': '@murphy'
		},
	'Quickbooks': {
		'name': 'Quickbooks',
		'access': ['User'],
		'provisioner': '@murphy'
		},
	'TBBK Treasury': {
		'name': 'TBBK Treasury',
		'access': ['Access'],
		'provisioner': '@murphy'
		}},
'Creative & Studio': {
	'Drop Box: Creative Team': {
		'name': 'Drop Box: Creative Team',
		'access': ['Access'],
		'provisioner': '@ian'
		},
	'InVision': {
		'name': 'InVision',
		'access': ['Contributor', 'Reviewer', 'Admin'],
		'provisioner': '@ian'
		},
	'Mural': {
		'name': 'Mural',
		'access': ['User', 'Admin'],
		'provisioner': '@ian'
		}},
'Marketing': {
	'Adroll': {
		'name': 'Adroll',
		'access': ['User', 'Admin'],
		'provisioner': '@scott'
		},
	'Amplifier': {
		'name': 'Amplifier',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik'
		},
	'AppFollow': {
		'name': 'AppFollow',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik'
		},
	'Apple Search Ads': {
		'name': 'Apple Search Ads',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik'
		},
	'Bing': {
		'name': 'Bing',
		'access': ['User', 'Admin'],
		'provisioner': '@scott'
		},
	'Crazy Egg': {
		'name': 'Crazy Egg',
		'access': ['Admin'],
		'provisioner': '@tylerbullen'
		},
	'Google Adwords': {
		'name': 'Google Adwords',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik'
		},
	'Google Analytics': {
		'name': 'Google Analytics',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik'
		},
	'Google Tag Manager': {
		'name': 'Google Tag Manager',
		'access': ['Admin'],
		'provisioner': '@scott'
		},
	'Iterable': {
		'name': 'Iterable',
		'access': ['Reader', 'Contributor', 'Admin', 'Super Admin'],
		'provisioner': '@stefanihass'
		},
	'Liftoff': {
		'name': 'Liftoff',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik'
		},
	'Litmus': {
		'name': 'Litmus',
		'access': ['Admin', 'Reader'],
		'provisioner': '@stefanihass'
		},
	'RETIRED: Localytics': {
		'name': 'RETIRED: Localytics',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik',
		'retired': [True]
		},
	'Nanigans': {
		'name': 'Nanigans',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik'
		},
	'1Password for Growth Team': {
		'name': '1Password for Growth Team',
		'access': ['Access'],
		'approver': '@scott'
		},
	'Optimizely': {
		'name': 'Optimizely',
		'access': ['User', 'Admin'],
		'provisioner': '@cslowik'
		},
	'Outbrain': {
		'name': 'Outbrain',
		'access': ['User', 'Admin'],
		'provisioner': '@scott'
		},
	'Segment.io': {
		'name': 'Segment.io',
		'access': ['User', 'Admin'],
		'special': [segmentio]
		},
	'Simple Social Media': {
		'name': 'Simple Social Media',
		'access': ['Facebook', 'Instagram', 'LinkedIn', 'Pinterest', 'Twitter', 'YouTube'],
		'provisioner': '@jenjoyce'
		},
	'Simply Measured': {
		'name': 'Simply Measured',
		'access': ['User', 'Admin'],
		'provisioner': '@jenjoyce'
		},
	'Taboola': {
		'name': 'Taboola',
		'access': ['User', 'Admin'],
		'provisioner': '@tylerbullen'
		},
	'Trendkite': {
		'name': 'Trendkite',
		'access': ['User', 'Admin'],
		'provisioner': '@jenjoyce'
		}},
'Risk, Compliance & Fraud': {
	'BWise': {
		'name': 'BWise',
		'access': ['Access']
		},
	'Google Inbox': {
		'name': 'Google Inbox',
		'access': ['confirmation@', 'depositrisk@', 'disputes@', 'risk-inbox@', 'verification@'],
		'special': [delegated]
		},
	'Davenport': {
		'name': 'Davenport',
		'access': ['Single PAN/UUID Conversion', 'Bulk PAN/UUID Conversion'],
		'special': [davenport]
		},
	'Digility (Cachet) - Check Review': {
		'name': 'Digility (Cachet) - Check Review',
		'access': ['User', 'Admin'],
		'provisioner': '@joseph'
		},
	'Drivers License Guide': {
		'name': 'Drivers License Guide',
		'access': ['Access'],
		'provisioner': '@megan'
		},
	'FD ServiceCenter': {
		'name': 'FD ServiceCenter',
		'access': ['User'],
		'provisioner': '@monique'
		},
	'RETIRED: FDWC': {
		'name': 'RETIRED: FDWC',
		'access': ['User', 'Admin'],
		'retired': [True]
		},
	'RETIRED: Greenscreen': {
		'name': 'RETIRED: Greenscreen',
		'access': ['Access'],
		'retired': [True]
		},
	'IDology': {
		'name': 'IDology',
		'access': ['Web Portal User', 'Admin', 'API'],
		'provisioner': '@naps'
		},
	'LexisNexis Accurint': {
		'name': 'LexisNexis Accurint',
		'access': ['User', 'Admin'],
		'provisioner': '@kevinsanchez'
		},
	'Lynx': {
		'name': 'Lynx',
		'access': ['User', 'Admin']
		},
	'Nelson': {
		'name': 'Nelson',
		'access': ['User', 'Admin']
		},
	'McBain': {
		'name': 'McBain',
		'access': ['User', 'Admin']
		},
	'Milhouse': {
		'name': 'Milhouse',
		'access': ['User', 'Admin']
		},
	'SharePoint': {
		'name': 'SharePoint',
		'access': ['Dept_Risk', 'Dept_Disputes', 'Dept_FE-CR', 'Dept_DepositRisk', 'Dept_Compliance', 'ViewAll_Risk', 'Dept_Legal', 'Dept_Audit', 'ViewAll_Compliance', 'Dept_BE-CR', 'Dept_Tech-CR', 'Dept_Edu-CR', 'Dept_QA-CR', 'User', 'Admin'],
		'special': [sharepointgroup]
		},
	'Socure': {
		'name': 'Socure',
		'access': ['User', 'Admin'],
		'provisioner': '@kevinsanchez'
		},
	'Visa VROL': {
		'name': 'Visa VROL',
		'access': ['Access'],
		'provisioner': '@faye'
		},
	'Visa Online': {
		'name': 'Visa Online',
		'access': ['Access'],
		'special': [visaonline]
		},
	'Wasau Help Desk': {
		'name': 'Wasau Help Desk',
		'access': ['User', 'Admin'],
		'provisioner': '@joseph'
		},
	'ZenGRC': {
		'name': 'ZenGRC',
		'access': ['User', 'Admin'],
		'provisioner': '@matts'
		}},
'Engineering, Infra & IT' : {
	'EC2/VPC-hosted Services via SSH': {
		'name': 'EC2/VPC-hosted Services via SSH',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'AWS': {
		'name': 'AWS',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Beam': {
		'name': 'Beam',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Buckingham': {
		'name': 'Buckingham',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Carmel': {
		'name': 'Carmel',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Chili': {
		'name': 'Chili',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Corndog': {
		'name': 'Corndog',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Centrify': {
		'name': 'Centrify',
		'access': ['User','Admin']
		},
	'AD Domain Admin': {
		'name': 'AD Domain',
		'access': ['Admin'],
		'provisioner': '@it/itinfra'
		},
	'DynECT': {
		'name': 'DynECT',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'EZ Office Inventory': {
		'name': 'EZ Office Inventory',
		'access': ['Admin']
		},
	'Frontend Services': {
		'name': 'Frontend Services',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Jamf Pro': {
		'name': 'Jamf Pro',
		'access': ['Admin', 'Owner']
		},
	'G Suite user internal-feedback@': {
		'name': 'G Suite user internal-feedback@',
		'access': ['Access'],
		'provisioner': '@jtowle'
		},
	'Network Infrastructure (routers, switches, firewalls, WAPs)': {
		'name': 'Network Infrastructure (routers, switches, firewalls, WAPs)',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Kickflip': {
		'name': 'Kickflip',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Nacho': {
		'name': 'Nacho',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Local Admin Access': {
		'name': 'Local Admin Access',
		'access': ['Access'],
		'special': larry
		},
	'AWS IAM Group': {
		'name': 'AWS IAM Group',
		'access': ['Humans', 'Analytics-Analyst', 'Analytics-Engineer', 'AppSec', 'BizOps', 'CR-Pager-Duty-Agent', 'CR-Shift-Lead', 'CR-Shift-Manager', 'Engineering', 'Engineering-Backend', 'Engineering-Clients', 'Engineering-Data', 'Engineering-Data-Science', 'Engineering-Frontend', 'Engineering-Infrastructure', 'Engineering-Infrastructure-Liaison', 'Engineering-Security', 'Engineering-QAE', 'Finance', 'IT', 'Marketing', 'Risk']
		},
	'VPC Host Access': {
		'name': 'VPC Host Access',
		'access': ['banksimple', 'data', 'developers', 'IT', 'oncall', 'ops', 'security'],
		'provisioner': '@whit'
		},
	'LDAP': {
		'name': 'LDAP',
		'access': ['Oncall_Cartesian', 'Oncall_Internal']
		},
	'1Password for IT Team': {
		'name': '1Password for IT Team',
		'access': ['Access']
		},
	'1Password for Mobile Team': {
		'name': '1Password for Mobile Team',
		'access': ['Access'],
		'approver': '@sasha'
		},
	'Pingdom': {
		'name': 'Pingdom',
		'access': ['Access'],
		'provisioner': '@whit'
		},
	'Apple App & Google Play Store': {
		'name': 'Apple App & Google Play Store',
		'access': ['Access'],
		'provisioner': '@sasha'
		},
	'BBVA API Market': {
		'name': 'BBVA API Market',
		'access': ['Access']
		},
	'BBVA JIRA': {
		'name': 'BBVA JIRA',
		'access': ['Access']
		},
	'SSL Cert Authorization': {
		'name': 'SSL Cert Authorization',
		'access': ['Client', 'Intermediate Cert Authority', 'Root SSL Cert'],
		'provisioner': '@whit'
		},
	'Jenkins': {
		'name': 'Jenkins',
		'access': ['User', 'Admin'],
		'provisioner': '@whit'
		},
	'EC2/VPC-hosted Services in Dev/Test': {
		'name': 'EC2/VPC-hosted Services in Dev/Test',
		'access': ['Admin'],
		'provisioner': '@whit'
		},
	'Grafana': {
		'name': 'Grafana',
		'access': ['User', 'Admin'],
		'provisioner': '@whit'
		},
	'PagerDuty': {
		'name': 'PagerDuty',
		'access': ['User', 'Admin']
		},
	'Plaid': {
		'name': 'Plaid',
		'access': ['Support', 'Keys', 'Admin'],
		'provisioner': '@stanleyhsing'
		},
	'Redshift': {
		'name': 'Redshift',
		'access': ['User', 'Admin'],
		'provisioner': '@allison @mikena',
		'special': redshift
		}},
'Security' : {
	'BugCrowd': {
		'name': 'BugCrowd',
		'access': ['User', 'Admin'],
		'provisioner': '@jensells @xavier'
		},
	'CrowdStrike': {
		'name': 'CrowdStrike',
		'access': ['User', 'Admin'],
		'provisioner': '@mcdonough'
		},
	'Equinix DC Cameras': {
		'name': 'Equinix DC Cameras',
		'access': ['Access'],
		'provisioner': '@dave',
		'retired': [True]
		},
	'Nessus': {
		'name': 'Nessus',
		'access': ['User', 'Admin'],
		'provisioner': '@jensells'
		},
	'ThreatStack': {
		'name': 'ThreatStack',
		'access': ['User', 'Admin'],
		'provisioner': '@jensells'
		},
	'Security Scorecard': {
		'name': 'Security Scorecard',
		'access': ['User', 'Admin'],
		'provisioner': '@mcdonough'
		}}
}
def a(group, system, access) :
	global text, spec, rolefilled, fte, roleselect, rolewritten
	name = systems[group][system]['name']
	access = systems[group][system]['access'][access]
	provisioner = systems[group][system].get('provisioner', '')
	approver = systems[group][system].get('approver', '')
	retired = systems[group][system].get('retired', False)
	approval = ''
	cleared = True
	if rolefilled == True :		
		approver = ''
		section = text.find(roleselect)
		position = text.find(name, section + 2)
		namelen = len(name) + 2
		if retired != False :		#doesn't print retired system item to screen if it was previously part of a role.
			cleared = False         #useful when deprovisioning.
		if position > 2 :
			position = position + namelen
			if name in duplicates :
				text = text[:position] + '\n  - [ ] %s' % access + text[position:]
			else :
				text = text[:position] + '\n  - [ ] %s\n  - [ ] ' % access + text[position:]
				duplicates.append(name)
		
			cleared = False
	if fte == False :
		if name == 'ChartIO' or name == 'Concur' or name == 'Bamboo HR' or name == 'Redshift' or name == 'ADP' or name == 'Greenhouse':
			cleared = False
		if roleselect == 'Customer Support Agent' and name == 'VPN' :
			cleared = False
	if fte == True : 
		if name == 'Centrify' :
			if access == 'User':
				cleared = False
	if cleared == False :
		pass 
	
	else : 
		if approver != '' :
			approval = ' - (requires %s\'s approval before IT can provision)' % approver
		if name == 'ChartIO' :
			if access == 'Read Only' :
				provisioner = '' 
		if name == 'Primer' :
			if access == 'User' :
				provisioner = ''
	
		text = text + '\n- [ ] %s: %s %s %s' % (name, access, provisioner, approval)
		special = systems[group][system].get('special', None)
		if special != None :
			text = text + '\n  - [ ] %s' % ''.join(special)
##########################################################################################################################
##############																								##############
##############										ROLE DEFINITIONS										##############
##############																								##############
##############																								##############
##########################################################################################################################
############################################   		 	BRAND ROLES  	 	  ############################################
def brand_vp():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Trendkite', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def mktg_dirbrandcomms() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Sprout Social', 4)
	a('Business Administration', 'Greenhouse', 1)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Simple Social Media', 0)
	a('Marketing', 'Simple Social Media', 2)
	a('Marketing', 'Simple Social Media', 4)
	a('Marketing', 'Simply Measured', 1)
	a('Marketing', 'Trendkite', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def mktg_internalbrandmgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Trendkite', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_internalcommsspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Trendkite', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_corpcommsmgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Sprout Social', 4)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Simple Social Media', 0)
	a('Marketing', 'Simple Social Media', 2)
	a('Marketing', 'Simple Social Media', 4)
	a('Marketing', 'Trendkite', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def mktg_socialmediaspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Sprout Social', 4)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Simple Social Media', 0)
	a('Marketing', 'Simple Social Media', 1)
	a('Marketing', 'Simple Social Media', 2)
	a('Marketing', 'Simple Social Media', 3)
	a('Marketing', 'Simple Social Media', 4)
	a('Marketing', 'Simple Social Media', 5)
	a('Marketing', 'Simply Measured', 1)
	a('Marketing', 'Trendkite', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def mktg_commspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Simple Social Media', 0)
	a('Marketing', 'Simple Social Media', 2)
	a('Marketing', 'Simple Social Media', 4)
	a('Marketing', 'Trendkite', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def brand_ea() :
	a('Simple Basics', 'ADP', 0)
	a('Business Administration', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 1)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_dirprodmktg() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_prodmktgmgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_brandfedev() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_branddesigner():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
############################################    	FINANCE & ERM ROLES    	  ############################################
def fin_erm_ea():
	a('Simple Basics', 'ADP', 0)
	a('Business Administration', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 1)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Basecamp: Finance', 0)
	a('Business Administration', 'BBVA Compass Treasury', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'Box.com', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def rc_dir() :
 	a('Business Administration', 'ADP Administration', 2)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Salesforce Profile', 6)
	a('CR', 'WFM Teams', 2)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 14)
	a('Risk, Compliance & Fraud', 'LexisNexis Accurint', 1)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 21)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def ops_auditmgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Compass Tools', 0)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 5)
	a('Risk, Compliance & Fraud', 'SharePoint', 7)
	a('Risk, Compliance & Fraud', 'SharePoint', 8)
	a('Risk, Compliance & Fraud', 'ZenGRC', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ops_auditor() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 5)
	a('Risk, Compliance & Fraud', 'SharePoint', 7)
	a('Risk, Compliance & Fraud', 'SharePoint', 8)
	a('Risk, Compliance & Fraud', 'ZenGRC', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def erm_complianceofficer() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 0)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 5)
	a('Risk, Compliance & Fraud', 'SharePoint', 7)
	a('Risk, Compliance & Fraud', 'SharePoint', 8)
	a('Engineering, Infra & IT', 'Centrify', 0)
def rc_compliancemgr() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Google Inbox', 3)
	a('CR', 'Primer', 0)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Risk, Compliance & Fraud', 'Drivers License Guide', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 4)
	a('Risk, Compliance & Fraud', 'LexisNexis Accurint', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 4)
	a('Engineering, Infra & IT', 'Centrify', 0)
def rc_amlanalyst() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('Risk, Compliance & Fraud', 'Google Inbox', 0)
	a('CR', 'Primer', 0)
	a('Risk, Compliance & Fraud', 'Drivers License Guide', 0)
	a('Risk, Compliance & Fraud', 'LexisNexis Accurint', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 4)
	a('Risk, Compliance & Fraud', 'SharePoint', 5)
	a('Engineering, Infra & IT', 'Centrify', 0)
def rc_complianceanalyst() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Sprout Social', 3)
	a('Risk, Compliance & Fraud', 'Google Inbox', 0)
	a('Risk, Compliance & Fraud', 'Drivers License Guide', 0)
	a('Risk, Compliance & Fraud', 'LexisNexis Accurint', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 4)
	a('Risk, Compliance & Fraud', 'SharePoint', 5)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ops_corpcounsel() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('Business Administration', 'ContractWorks', 1)
	a('Business Administration', 'DocuSign', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 6)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def ops_attourney() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('Business Administration', 'ContractWorks', 1)
	a('Business Administration', 'DocuSign', 1)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 6)
	a('Engineering, Infra & IT', 'Centrify', 0)
def infosec_riskanalyst() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'GitHub: Simple Public', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Everbridge', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 4)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Risk, Compliance & Fraud', 'ZenGRC', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'CrowdStrike', 0)
	a('Security', 'ThreatStack', 0)
	a('Security', 'Security Scorecard', 1)
def infosec_riskmanager() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'GitHub: Simple Public', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Risk, Compliance & Fraud', 'ZenGRC', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'BugCrowd', 0)
	a('Security', 'CrowdStrike', 1)
	a('Security', 'Nessus', 0)
	a('Security', 'ThreatStack', 0)
	a('Security', 'Security Scorecard', 0)
def infosec_dir() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'GitHub: Simple Public', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 2)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Risk, Compliance & Fraud', 'ZenGRC', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'BugCrowd', 0)
	a('Security', 'CrowdStrike', 1)
	a('Security', 'Equinix DC Cameras', 0)
	a('Security', 'ThreatStack', 0)
	a('Security', 'Security Scorecard', 0)
def it_dir():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 2)
	a('Simple Basics', 'G Suite', 2)
	a('Simple Basics', 'GitHub: Enterprise', 1)
	a('Simple Basics', 'LucidChart', 1)
	a('Simple Basics', 'Slack', 3)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 1)
	a('Office', 'Envoy Sign-In System', 1)
	a('Office', 'Everbridge', 1)
	a('Office', 'ExacqVision Video Surveilance', 0)
	a('Office', 'Physical Badge Access', 1)
	a('Office', 'Physical Badge Access', 2)
	a('CR', 'Belvedere', 0)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Primer', 2)
	a('CR', 'Voci', 1)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Axiom Windows Server', 1)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Marketing', 'Segment.io', 1)
	a('Risk, Compliance & Fraud', 'Milhouse', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 14)
	a('Engineering, Infra & IT', 'AWS', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 19)
	a('Engineering, Infra & IT', 'Centrify', 1)
	a('Engineering, Infra & IT', 'EZ Office Inventory', 0)
	a('Engineering, Infra & IT', 'Jamf Pro', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 3)
	a('Engineering, Infra & IT', '1Password for IT Team', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Security', 'CrowdStrike', 1)
def it_systems():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 2)
	a('Simple Basics', 'GitHub: Enterprise', 1)
	a('Simple Basics', 'Asterisk VoIP', 1)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 1)
	a('Office', 'ExacqVision Video Surveilance', 0)
	a('Office', 'Office Security System', 1)
	a('Office', 'Physical Badge Access', 1)
	a('Office', 'Physical Badge Access', 2)
	a('CR', 'Belvedere', 0)
	a('CR', 'Mr. Burns', 1)
	a('CR', 'Orderly Stats', 1)
	a('CR', 'Voci', 1)
	a('Business Administration', 'Greenhouse', 0)
	a('Business Administration', 'Axiom Windows Server', 0)
	a('Risk, Compliance & Fraud', 'Milhouse', 1)
	a('Risk, Compliance & Fraud', 'Nelson', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 14)
	a('Engineering, Infra & IT', 'AWS', 0)
	a('Engineering, Infra & IT', 'EC2/VPC-hosted Services via SSH', 0)
	a('Engineering, Infra & IT', 'Network Infrastructure (routers, switches, firewalls, WAPs)', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'Centrify', 1)
	a('Engineering, Infra & IT', 'AD Domain Admin', 0)
	a('Engineering, Infra & IT', 'EZ Office Inventory', 0)
	a('Engineering, Infra & IT', 'Jamf Pro', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 3)
	a('Engineering, Infra & IT', 'Pingdom', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 1)
	a('Engineering, Infra & IT', '1Password for IT Team', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
def it_support():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 2)
	a('Simple Basics', 'G Suite', 2)
	a('Simple Basics', 'GitHub: Enterprise', 1)
	a('Simple Basics', 'LucidChart', 1)
	a('Simple Basics', 'Slack', 2)
	a('Simple Basics', 'Team Gantt', 2)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 1)
	a('Office', 'Envoy Sign-In System', 1)
	a('Office', 'ExacqVision Video Surveilance', 0)
	a('Office', 'Office Security System', 1)
	a('Office', 'Physical Badge Access', 1)
	a('Office', 'Physical Badge Access', 2)
	a('CR', 'Belvedere', 0)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'CPI Card Group', 5)
	a('CR', 'Fiserv PartnerCare', 1)
	a('CR', 'Mr. Burns', 1)
	a('Business Administration', 'Greenhouse', 0)
	a('Business Administration', 'Axiom Windows Server', 1)
	a('Marketing', 'Segment.io', 1)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 1)
	a('Risk, Compliance & Fraud', 'Nelson', 1)
	a('Risk, Compliance & Fraud', 'Milhouse', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 14)
	a('Engineering, Infra & IT', 'AWS', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 19)
	a('Engineering, Infra & IT', 'Centrify', 1)
	a('Engineering, Infra & IT', 'AD Domain Admin', 0)
	a('Engineering, Infra & IT', 'EZ Office Inventory', 0)
	a('Engineering, Infra & IT', 'Jamf Pro', 0)
	a('Engineering, Infra & IT', '1Password for IT Team', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Security', 'CrowdStrike', 1)
############################################    ACCOUNTING & FINANCE ROLES    ############################################
def acctfin_acctpayable() :
	a('Simple Basics', 'ADP', 0)
	a('Business Administration', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 2)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Basecamp: Finance', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'Box.com', 0)
	a('Business Administration', 'ContractWorks', 1)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Floqast', 0)
	a('Business Administration', 'Intacct', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_accountant() :
	a('Business Administration', 'ADP Administration', 1)
	a('Business Administration', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 2)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 1)
	a('Business Administration', 'Basecamp: Finance', 0)
	a('Business Administration', 'Bill.com', 1)
	a('Business Administration', 'Box.com', 0)
	a('Business Administration', 'ContractWorks', 1)
	a('Business Administration', 'DocuSign', 1)
	a('Business Administration', 'Floqast', 0)
	a('Business Administration', 'Intacct', 1)
	a('Business Administration', 'Quickbooks', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_payroll() :
	a('Business Administration', 'ADP Administration', 0)
	a('Business Administration', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Basecamp: Finance', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'Box.com', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 1)
	a('Business Administration', 'Fidelity', 0)
	a('Business Administration', 'Floqast', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Business Administration', 'Intacct', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 18)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_accountingmgr() :
	a('Business Administration', 'ADP Administration', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Bamboo HR', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 1)
	a('Business Administration', 'Basecamp: Finance', 1)
	a('Business Administration', 'BBVA Compass Treasury', 0)
	a('Business Administration', 'Bill.com', 1)
	a('Business Administration', 'Box.com', 1)
	a('Business Administration', 'ContractWorks', 1)
	a('Business Administration', 'DocuSign', 1)
	a('Business Administration', 'Fidelity', 0)
	a('Business Administration', 'Floqast', 1)
	a('Business Administration', 'Greenhouse', 0)
	a('Business Administration', 'Intacct', 1)
	a('Business Administration', 'Quickbooks', 0)
	a('Business Administration', 'TBBK Treasury', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 18)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_dirfinance() :
	a('Business Administration', 'ADP Administration', 3)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Business Administration', 'Bamboo HR', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 1)
	a('Business Administration', 'Basecamp: Finance', 1)
	a('Business Administration', 'BBVA Compass Treasury', 0)
	a('Business Administration', 'Bill.com', 1)
	a('Business Administration', 'Box.com', 1)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Fidelity', 0)
	a('Business Administration', 'Floqast', 1)
	a('Business Administration', 'Greenhouse', 0)
	a('Business Administration', 'Intacct', 1)
	a('Business Administration', 'Quickbooks', 0)
	a('Business Administration', 'TBBK Treasury', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 18)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_cfo() :
	a('Business Administration', 'ADP Administration', 3)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Business Administration', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 1)
	a('Business Administration', 'Basecamp: Finance', 1)
	a('Business Administration', 'BBVA Compass Treasury', 0)
	a('Business Administration', 'Bill.com', 1)
	a('Business Administration', 'Box.com', 1)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Fidelity', 0)
	a('Business Administration', 'Floqast', 1)
	a('Business Administration', 'Greenhouse', 0)
	a('Business Administration', 'Intacct', 1)
	a('Business Administration', 'Quickbooks', 0)
	a('Business Administration', 'TBBK Treasury', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 18)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_decisionsci() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 2)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_bs_finanalyst() : 
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Basecamp: Finance', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Floqast', 0)
	a('Business Administration', 'Intacct', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_bizstrategymgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Basecamp: Finance', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Business Administration', 'Floqast', 0)
	a('Business Administration', 'Intacct', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_fpa_finanalyst() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Basecamp: Finance', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'Box.com', 0)
	a('Business Administration', 'Floqast', 0)
	a('Business Administration', 'Intacct', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_fpamanager() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Basecamp: Finance', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'Box.com', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Floqast', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Business Administration', 'Intacct', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def acctfin_dirfpa() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 1)
	a('Business Administration', 'Basecamp: Finance', 1)
	a('Business Administration', 'Bill.com', 1)
	a('Business Administration', 'Box.com', 1)
	a('Business Administration', 'ContractWorks', 1)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Business Administration', 'Intacct', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 18)
	a('Engineering, Infra & IT', 'Centrify', 0)
#####################################################    CO ROLES    #####################################################
def cr_vp() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_ea() :
	a('Simple Basics', 'ADP', 0)
	a('Business Administration', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 1)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_businessanalyst() :
	a('Simple Basics', 'ADP', 0)
	a('Business Administration', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 2)
	a('CR', 'Chili', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Engineering, Infra & IT', 'Centrify', 0) 
def cr_csagent() : 
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 2)
	a('CR', 'Chili', 0)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 2)
	a('CR', 'WFM MyTime', 0)
	# a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_cssl() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Chili', 0)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Google Inbox', 3)
	a('CR', 'Google Inbox', 4)	
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 3)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 4)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_csstl() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Chili', 0)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Google Inbox', 0)
	a('CR', 'Google Inbox', 3)
	a('CR', 'Google Inbox', 4)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 3)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 0)
	a('CR', 'WFM Teams', 1)
	a('Business Administration', 'Greenhouse', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 4)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_sm() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'GitHub: Simple Public', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Everbridge', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Concord Fax', 0)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Google Inbox', 0)
	a('CR', 'Google Inbox', 2)
	a('CR', 'Google Inbox', 4)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 3)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Business Administration', 'Greenhouse', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 4)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_escalationsagent() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Concord Fax', 0)
	a('CR', 'CPI Card Group', 0)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Google Inbox', 2)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 2)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_escalationsmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'GitHub: Simple Public', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'CPI Card Group', 0)
	a('CR', 'CPI Card Group', 1)
	a('CR', 'CPI Card Group', 2)
	a('CR', 'CPI Card Group', 3)
	a('CR', 'CPI Card Group', 4)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Google Inbox', 2)
	a('CR', 'Google Inbox', 4)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 2)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 1)
	a('Business Administration', 'Greenhouse', 0)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_acctmgmtagent() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Office', 'Everbridge', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Concord Fax', 0)
	a('CR', 'CPI Card Group', 0)
	a('CR', 'CPI Card Group', 1)
	a('CR', 'CPI Card Group', 2)
	a('CR', 'CPI Card Group', 3)
	a('CR', 'CPI Card Group', 4)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Google Inbox', 2)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 2)
	a('CR', 'WFM MyTime', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_wfm() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Everbridge', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 2)
	a('CR', 'Chili', 0)
	a('CR', 'Concord Fax', 0)
	a('CR', 'Orderly Stats', 1)
	a('CR', 'Primer', 0)
	a('CR', 'WFM Admin Client', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_dircs() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Everbridge', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Concord Fax', 0)
	a('CR', 'Salesforce Profile', 3)
	a('CR', 'Primer', 0)
	a('Business Administration', 'Axiom EPM', 1)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Risk, Compliance & Fraud', 'BWise', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_dirops() :
	a('Business Administration', 'ADP Administration', 2)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Google Inbox', 1)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 2)
	a('CR', 'Salesforce Profile', 3)
	a('CR', 'Voci', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_pjm() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 0)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_programmgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 4)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Voci', 1)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_trainingopsspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'RETIRED: CPI Advantage', 1)
	# a('CR', 'CPI Card Group', 5)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 5)
	a('CR', 'Voci', 0)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 11)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_supportcontentmgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 2)
	a('CR', 'Sprout Social', 2)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def cr_resourcespec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 2)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def cr_eduspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Chili', 0)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 2)
	a('CR', 'Salesforce Profile', 5)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 11)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_qaspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Google Inbox', 1)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 2)
	a('CR', 'Salesforce Profile', 5)
	a('CR', 'Voci', 1)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 12)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_qamgr() :
	a('Business Administration', 'ADP Administration', 2)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Google Inbox', 1)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 2)
	a('CR', 'Salesforce Profile', 5)
	a('CR', 'Voci', 1)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 12)
	a('Engineering, Infra & IT', 'Centrify', 0)
def cr_edumgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Asterisk VoIP', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Chili', 0)	
	a('CR', 'RETIRED: CPI Advantage', 1)
	# a('CR', 'CPI Card Group', 5)
	a('CR', 'Google Inbox', 1)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Orderly Stats', 0)
	a('CR', 'Primer', 2)
	a('CR', 'Salesforce Profile', 5)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 11)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def rc_depositriskmgr() : 
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Salesforce Profile', 7)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 1)
	a('Risk, Compliance & Fraud', 'Google Inbox', 1)
	a('Risk, Compliance & Fraud', 'Digility (Cachet) - Check Review', 1)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Risk, Compliance & Fraud', 'SharePoint', 3)
	a('Risk, Compliance & Fraud', 'Wasau Help Desk', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def rc_depositriskspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Salesforce Profile', 7)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 1)
	a('Risk, Compliance & Fraud', 'Digility (Cachet) - Check Review', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Risk, Compliance & Fraud', 'SharePoint', 3)
	a('Risk, Compliance & Fraud', 'Wasau Help Desk', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def rc_disputesmgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Business Administration', 'Greenhouse', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Salesforce Profile', 8)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 1)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 2)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Risk, Compliance & Fraud', 'Visa VROL', 0)
	a('Risk, Compliance & Fraud', 'Visa Online', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def rc_fdagent() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('CR', 'Salesforce Profile', 8)
	a('CR', 'WFM MyTime', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 2)
	a('Risk, Compliance & Fraud', 'RETIRED: Greenscreen', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	# a('Risk, Compliance & Fraud', 'SharePoint', 1)
	# a('Risk, Compliance & Fraud', 'SharePoint', 2)
	a('Risk, Compliance & Fraud', 'Visa VROL', 0)
	a('Risk, Compliance & Fraud', 'Visa Online', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def rc_riskmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Google Inbox', 3)
	a('CR', 'Google Inbox', 4)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 6)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 1)
	a('Risk, Compliance & Fraud', 'Drivers License Guide', 0)
	a('Risk, Compliance & Fraud', 'FD ServiceCenter', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 1)
	a('Risk, Compliance & Fraud', 'Google Inbox', 2)
	a('Risk, Compliance & Fraud', 'Google Inbox', 3)
	a('Risk, Compliance & Fraud', 'IDology', 0)
	a('Risk, Compliance & Fraud', 'LexisNexis Accurint', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 4)
	a('Engineering, Infra & IT', 'Centrify', 0)
def rc_risk_riskspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Google Inbox', 0)
	a('CR', 'Google Inbox', 2)
	a('CR', 'Google Inbox', 3)
	a('CR', 'Google Inbox', 4)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 6)
	a('CR', 'WFM MyTime', 0)
	a('CR', 'WFM Teams', 1)
	a('Risk, Compliance & Fraud', 'Drivers License Guide', 0)
	a('Risk, Compliance & Fraud', 'FD ServiceCenter', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'Google Inbox', 3)
	a('Risk, Compliance & Fraud', 'IDology', 0)
	a('Risk, Compliance & Fraud', 'LexisNexis Accurint', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def rc_riskarchitechturemgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 9)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Lynx', 0)
	a('Risk, Compliance & Fraud', 'Milhouse', 0)
	a('Risk, Compliance & Fraud', 'Socure', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 14)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 21)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def rc_riskarchitecht() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 9)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: Greenscreen', 0)
	a('Risk, Compliance & Fraud', 'Lynx', 0)
	a('Risk, Compliance & Fraud', 'Milhouse', 0)
	a('Risk, Compliance & Fraud', 'Socure', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 21)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def rc_riskstatistician() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 9)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Lynx', 0)
	a('Risk, Compliance & Fraud', 'Milhouse', 0)
	a('Risk, Compliance & Fraud', 'Socure', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 21)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def ops_dirbizops():
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 8)	
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'RETIRED: CPI Advantage', 0)
	# a('CR', 'Card Services - CPI', 0)
	a('CR', 'Fiserv PartnerCare', 1)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Primer', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Digility (Cachet) - Check Review', 0)
	a('Risk, Compliance & Fraud', 'FD ServiceCenter', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 4)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'BBVA API Market', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def ops_bizopsmgr(): 
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 8)	
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'RETIRED: CPI Advantage', 1)
	# a('CR', 'Card Services - CPI', 1)
	a('CR', 'Fiserv PartnerCare', 1)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 10)
	a('CR', 'Lifecycle Token Management', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Digility (Cachet) - Check Review', 1)
	a('Risk, Compliance & Fraud', 'Drivers License Guide', 0)
	a('Risk, Compliance & Fraud', 'FD ServiceCenter', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'IDology', 0)
	a('Risk, Compliance & Fraud', 'Lynx', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Risk, Compliance & Fraud', 'Socure', 0)
	a('Risk, Compliance & Fraud', 'Visa VROL', 0)
	a('Risk, Compliance & Fraud', 'Visa Online', 0)
	a('Risk, Compliance & Fraud', 'Wasau Help Desk', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 4)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'BBVA API Market', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def ops_consulting():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 8)	
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'RETIRED: CPI Advantage', 0)
	# a('CR', 'Card Services - CPI', 0)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Primer', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Digility (Cachet) - Check Review', 0)
	a('Risk, Compliance & Fraud', 'Drivers License Guide', 0)
	a('Risk, Compliance & Fraud', 'FD ServiceCenter', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'IDology', 0)
	a('Risk, Compliance & Fraud', 'Lynx', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Risk, Compliance & Fraud', 'Socure', 0)
	a('Risk, Compliance & Fraud', 'Visa VROL', 0)
	a('Risk, Compliance & Fraud', 'Visa Online', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 4)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def ops_bankingops():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)	
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'RETIRED: CPI Advantage', 0)
	a('CR', 'CPI Card Group', 0)
	a('CR', 'CPI Card Group', 1)
	a('CR', 'CPI Card Group', 2)
	a('CR', 'CPI Card Group', 3)
	a('CR', 'CPI Card Group', 4)
	a('CR', 'Fiserv PartnerCare', 0)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Salesforce Profile', 10)
	a('Risk, Compliance & Fraud', 'Davenport', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Digility (Cachet) - Check Review', 0)
	a('Risk, Compliance & Fraud', 'FD ServiceCenter', 0)
	a('Risk, Compliance & Fraud', 'RETIRED: FDWC', 0)
	a('Risk, Compliance & Fraud', 'Nelson', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 4)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def ops_partnermgmt():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 8)	
	a('CR', 'Belvedere', 9)
	a('CR', 'Chili', 0)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 1)
	a('CR', 'Compass Tools', 2)
	a('CR', 'RETIRED: CPI Advantage', 1)
	# a('CR', 'Card Services - CPI', 1)
	a('CR', 'Fiserv PartnerCare', 1)
	a('CR', 'Mr. Burns', 0)
	a('CR', 'Primer', 0)
	a('CR', 'Lifecycle Token Management', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Risk, Compliance & Fraud', 'Digility (Cachet) - Check Review', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Risk, Compliance & Fraud', 'Visa VROL', 0)
	a('Risk, Compliance & Fraud', 'Visa Online', 0)
	a('Risk, Compliance & Fraud', 'Wasau Help Desk', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 4)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'BBVA API Market', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
	
################################################    ENGINEERING ROLES    ################################################
def eng_iosandroid() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 10)
	a('Engineering, Infra & IT', '1Password for Mobile Team', 0)
	a('Engineering, Infra & IT', 'G Suite user internal-feedback@', 0)
	a('Engineering, Infra & IT', 'Apple App & Google Play Store', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def eng_qa() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1) 
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 4)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('Marketing', 'Segment.io', 0)   
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 17)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', '1Password for Mobile Team', 0)
	a('Engineering, Infra & IT', 'G Suite user internal-feedback@', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def eng_fe() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 13)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def eng_clientmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', '1Password for Mobile Team', 0)
	a('Engineering, Infra & IT', 'G Suite user internal-feedback@', 0)
	a('Engineering, Infra & IT', 'Apple App & Google Play Store', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def eng_qamanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1) 
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 3)
	a('CR', 'Belvedere', 4)
	a('CR', 'Belvedere', 5)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 7)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9) 
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Business Administration', 'Greenhouse', 1)
def eng_femanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Engineering, Infra & IT', 'Redshift', 0)
def eng_dirclient() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'Centrify', 0)
def eng_beeng() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('CR', 'Chili', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 9)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'LDAP', 0)
	a('Engineering, Infra & IT', 'LDAP', 1)
	a('Engineering, Infra & IT', 'BBVA API Market', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'EC2/VPC-hosted Services via SSH', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def eng_beengmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 4)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'VPC Host Access', 4)
	a('Engineering, Infra & IT', 'LDAP', 0)
	a('Engineering, Infra & IT', 'LDAP', 1)
	a('Engineering, Infra & IT', 'BBVA API Market', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'EC2/VPC-hosted Services via SSH', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Engineering, Infra & IT', 'Redshift', 0)
def eng_dirbeeng() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 4)
	a('CR', 'Compass Tools', 0)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'VPC Host Access', 4)
	a('Engineering, Infra & IT', 'BBVA API Market', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'EC2/VPC-hosted Services via SSH', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Engineering, Infra & IT', 'Redshift', 0)
def eng_infraeng() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Simple Basics', 'ZNC', 0)
	a('CR', 'Belvedere', 4)
	a('CR', 'Chili', 0)
	a('Engineering, Infra & IT', 'EC2/VPC-hosted Services via SSH', 0)
	a('Engineering, Infra & IT', 'AWS', 0)
	a('Engineering, Infra & IT', 'DynECT', 0)
	a('Engineering, Infra & IT', 'Network Infrastructure (routers, switches, firewalls, WAPs)', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 14)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 1)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'VPC Host Access', 4)
	a('Engineering, Infra & IT', 'VPC Host Access', 5)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'LDAP', 0)
	a('Engineering, Infra & IT', 'LDAP', 1)	
	a('Engineering, Infra & IT', 'Pingdom', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 1)
	a('Engineering, Infra & IT', 'Jenkins', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'Nessus', 0)
def eng_infraengmgr() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Simple Basics', 'ZNC', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'EC2/VPC-hosted Services via SSH', 0)
	a('Engineering, Infra & IT', 'AWS', 0)
	a('Engineering, Infra & IT', 'DynECT', 0)
	a('Engineering, Infra & IT', 'Network Infrastructure (routers, switches, firewalls, WAPs)', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 14)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 1)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'VPC Host Access', 4)
	a('Engineering, Infra & IT', 'VPC Host Access', 5)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'LDAP', 0)
	a('Engineering, Infra & IT', 'LDAP', 1)	
	a('Engineering, Infra & IT', 'Pingdom', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 1)
	a('Engineering, Infra & IT', 'Jenkins', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'Nessus', 0)
	a('Security', 'ThreatStack', 1)
def eng_infraengdir() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Slack', 2)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 4)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Simple Basics', 'ZNC', 1)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'EC2/VPC-hosted Services via SSH', 0)
	a('Engineering, Infra & IT', 'AWS', 0)
	a('Engineering, Infra & IT', 'DynECT', 0)
	a('Engineering, Infra & IT', 'Network Infrastructure (routers, switches, firewalls, WAPs)', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 14)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 1)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'VPC Host Access', 4)
	a('Engineering, Infra & IT', 'VPC Host Access', 5)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'LDAP', 0)
	a('Engineering, Infra & IT', 'LDAP', 1)	
	a('Engineering, Infra & IT', 'Pingdom', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 1)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 2)
	a('Engineering, Infra & IT', 'Jenkins', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'Nessus', 0)
	a('Security', 'ThreatStack', 1)
def eng_security() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Simple Basics', 'ZNC', 0)
	a('CR', 'Belvedere', 4)
	a('CR', 'Chili', 0)
	a('Engineering, Infra & IT', 'EC2/VPC-hosted Services via SSH', 0)
	a('Engineering, Infra & IT', 'AWS', 0)
	a('Engineering, Infra & IT', 'Network Infrastructure (routers, switches, firewalls, WAPs)', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 16)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 1)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'VPC Host Access', 4)
	a('Engineering, Infra & IT', 'VPC Host Access', 5)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'LDAP', 0)
	a('Engineering, Infra & IT', 'LDAP', 1)	
	a('Engineering, Infra & IT', 'Pingdom', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 1)
	a('Engineering, Infra & IT', 'Jenkins', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'Nessus', 0)
	a('Security', 'ThreatStack', 0)
def eng_data() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Simple Basics', 'ZNC', 0)
	a('CR', 'Belvedere', 4)
	a('Engineering, Infra & IT', 'AWS', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 1)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'VPC Host Access', 5)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'Jenkins', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Redshift', 1)
def eng_vp() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 4)
	a('CR', 'Compass Tools', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Risk, Compliance & Fraud', 'McBain', 0)
	a('Risk, Compliance & Fraud', 'Davenport', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 2)
	a('Engineering, Infra & IT', 'VPC Host Access', 4)
	a('Engineering, Infra & IT', 'LDAP', 0)
	a('Engineering, Infra & IT', 'LDAP', 1)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'BBVA API Market', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 1)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Engineering, Infra & IT', 'Redshift', 0)
def infosec_prodseceng() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Business Administration', 'Greenhouse', 0)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 16)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'BugCrowd', 1)
	a('Security', 'CrowdStrike', 0)
	a('Security', 'Nessus', 0)
	a('Security', 'ThreatStack', 0)
	a('Security', 'Security Scorecard', 0)
def infosec_prodsecmanager() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 1)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Slack', 2)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Risk, Compliance & Fraud', 'ZenGRC', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 16)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 6)
	a('Engineering, Infra & IT', 'PagerDuty', 1)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Security', 'BugCrowd', 1)
	a('Security', 'CrowdStrike', 1)
	a('Security', 'Nessus', 1)
	a('Security', 'ThreatStack', 0)
	a('Security', 'Security Scorecard', 0)
##############################################    ELT & SUPPORT ROLES    ##############################################
def elts_ceo() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 6)
	a('CR', 'Belvedere', 8)
	a('CR', 'Belvedere', 9)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def elts_ea() :
	a('Simple Basics', 'ADP', 0)
	a('Business Administration', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 1)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)	
#################################################   MARKETING ROLES  #################################################
def mktg_digmktgmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Marketing', 'Amplifier', 1)
	a('Marketing', 'AppFollow', 1)
	a('Marketing', 'Apple Search Ads', 1)
	a('Marketing', 'Crazy Egg', 0)
	a('Marketing', 'Google Adwords', 1)
	a('Marketing', 'Google Analytics', 1)
	a('Marketing', 'Google Tag Manager', 0)
	a('Marketing', 'Liftoff', 1)
	a('Marketing', 'RETIRED: Localytics', 1)
	a('Marketing', 'Nanigans', 1)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Optimizely', 1)
	a('Marketing', 'Outbrain', 1)
	a('Marketing', 'Segment.io', 1)
	a('Marketing', 'Taboola', 1)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 20)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_digmktgspec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Physical Badge Access', 0)
	a('Marketing', 'AppFollow', 0)
	a('Marketing', 'Crazy Egg', 0)
	a('Marketing', 'Google Adwords', 0)
	a('Marketing', 'Google Analytics', 0)
	a('Marketing', 'Google Tag Manager', 0)
	a('Marketing', 'RETIRED: Localytics', 0)
	a('Marketing', 'Optimizely', 0)
	a('Marketing', 'Segment.io', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_lifecyclemanager() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 4)
	a('Business Administration', 'Greenhouse', 0)
	a('Marketing', 'Iterable', 3)
	a('Marketing', 'Litmus', 1)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Segment.io', 1)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 20)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def mktg_lifecyclespec() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 2)
	a('Marketing', 'Iterable', 3)
	a('Marketing', 'Litmus', 1)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Segment.io', 1)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 20)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def mktg_contentprod() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Marketing', 'Iterable', 1)
	a('Marketing', 'Litmus', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Segment.io', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Jenkins', 0)
def mktg_optmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Business Administration', 'Greenhouse', 0)
	a('Marketing', 'AppFollow', 1)
	a('Marketing', 'Crazy Egg', 0)
	a('Marketing', 'Google Adwords', 1)
	a('Marketing', 'Google Analytics', 1)
	a('Marketing', 'Iterable', 3)
	a('Marketing', 'RETIRED: Localytics', 1)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Optimizely', 1)
	a('Marketing', 'Segment.io', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def mktg_dirgrowth() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 2)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 2)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Marketing', 'Adroll', 0)
	a('Marketing', 'Bing', 1)
	a('Marketing', 'Google Analytics', 0)
	a('Marketing', 'Google Tag Manager', 0)
	a('Marketing', 'Iterable', 2)
	a('Marketing', '1Password for Growth Team', 0)
	a('Marketing', 'Segment.io', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_vidphotographer() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_copywriter() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Creative & Studio', 'InVision', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_artdir() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_brandvoicelead() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_studiomgr() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_cmoea() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def mktg_cmo() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Office', 'Physical Badge Access', 0)
	a('Marketing', '1Password for Growth Team', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
#################################################    PEOPLE ROLES   #################################################
def ppl_cpo() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_dirpplops() :
	a('Simple Basics', 'ADP', 1)
	a('Business Administration', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_pplopsmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Business Administration', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_pplopsanalyst() :
	a('Simple Basics', 'ADP', 0)
	a('Business Administration', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_officeadminmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Office', 'Envoy Sign-In System', 1)
	a('Office', 'Everbridge', 1)
	a('Office', 'ExacqVision Video Surveilance', 0)
	a('Office', 'Office Security System', 1)
	a('Office', 'Physical Badge Access', 1)
	a('Office', 'Physical Badge Access', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_facilitiesmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Office', 'Everbridge', 1)
	a('Office', 'ExacqVision Video Surveilance', 0)
	a('Office', 'Office Security System', 1)
	a('Office', 'Physical Badge Access', 1)
	a('Office', 'Physical Badge Access', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_officemanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Envoy Sign-In System', 1)
	a('Office', 'ExacqVision Video Surveilance', 0)
	a('Office', 'Office Security System', 1)
	a('Office', 'Physical Badge Access', 1)
	a('Office', 'Physical Badge Access', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_adminassistant() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Envoy Sign-In System', 1)
	a('Office', 'Everbridge', 0)
	a('Office', 'Office Security System', 0)
	a('Office', 'Physical Badge Access', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_facilities() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Office Security System', 0)
	a('Office', 'Physical Badge Access', 1)
	a('Office', 'Physical Badge Access', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
	
def ppl_ldcoach() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'GitHub: Simple Public', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_talentpartner() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_mgrpd() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'GitHub: Simple Public', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_recruitingmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ppl_recruiter() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
#################################################    PRODUCT ROLES   #################################################
def prod_dircreative() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Creative & Studio', 'InVision', 2)
	a('Creative & Studio', 'Mural', 1)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	a('Engineering, Infra & IT', 'AWS IAM Group', 20)
	a('Engineering, Infra & IT', 'Centrify', 0)
def prod_prodcutdesigner() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 4)
	a('Creative & Studio', 'Drop Box: Creative Team', 0)
	a('Creative & Studio', 'InVision', 2)
	a('Creative & Studio', 'Mural', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def prod_dirprodmanagement() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 4)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Plaid', 0)
	a('Engineering, Infra & IT', 'Plaid', 2)
def prod_groupprodmanager() :
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 4)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def prod_productmanager() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 4)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def prod_diruserresearch() : 
	a('Simple Basics', 'ADP', 1)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def prod_userresearchmanager() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 4)
	a('Engineering, Infra & IT', 'Centrify', 0)
def prod_cpo() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 2)
	a('CR', 'Compass Tools', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
def prod_ea():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 1)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Office', 'Physical Badge Access', 1)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Bamboo HR', 0)
	a('Business Administration', 'Bill.com', 0)
	a('Business Administration', 'ContractWorks', 0)
	a('Business Administration', 'DocuSign', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
def ops_projectmanager() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 8)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def ops_techwriter() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'BBVA API Market', 0)
	a('Engineering, Infra & IT', 'SSL Cert Authorization', 0)
	a('Engineering, Infra & IT', 'Jenkins', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def ops_pjmmanager() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'ChartIO', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'Team Gantt', 1)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'VPN', 0)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('CR', 'Belvedere', 0)
	a('CR', 'Belvedere', 1)
	a('CR', 'Belvedere', 2)
	a('CR', 'Belvedere', 8)
	a('CR', 'Compass Tools', 0)
	a('CR', 'Compass Tools', 2)
	a('Risk, Compliance & Fraud', 'SharePoint', 13)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'VPC Host Access', 0)
	a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	a('Engineering, Infra & IT', 'PagerDuty', 0)
def prod_analyticsmgr():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 1)
	a('Simple Basics', 'BVS', 0)
	a('Business Administration', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 2)
	a('CR', 'Belvedere', 4)
	a('Office', 'Physical Badge Access', 0)
	a('Business Administration', 'Axiom EPM', 0)
	a('Business Administration', 'Greenhouse', 1)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 1)
	a('Engineering, Infra & IT', 'AWS IAM Group', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
def prod_analyticseng():
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 2)
	a('Office', 'Physical Badge Access', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 2)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
	a('Marketing', 'Segment.io', 1)
def mktg_growthdataanalyst() :
	a('Simple Basics', 'ADP', 0)
	a('Simple Basics', 'Bamboo HR', 0)
	a('Simple Basics', 'BVS', 0)
	a('Simple Basics', 'Concur', 0)
	a('Simple Basics', 'G Suite', 0)
	a('Simple Basics', 'GitHub: Enterprise', 0)
	a('Simple Basics', 'Slack', 1)
	a('Simple Basics', 'LucidChart', 0)
	a('Simple Basics', 'VPN', 0)
	a('Simple Basics', 'Simple WiFi', 0)
	a('Simple Basics', 'ChartIO', 1)
	a('Office', 'Physical Badge Access', 0)
	a('Marketing', 'AppFollow', 0)
	a('Marketing', 'Google Adwords', 0)
	a('Marketing', 'Google Analytics', 0)
	a('Marketing', 'RETIRED: Localytics', 0)
	a('Marketing', 'Optimizely', 0)
	a('Marketing', 'Segment.io', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	a('Engineering, Infra & IT', 'AWS IAM Group', 1)
	a('Engineering, Infra & IT', 'Centrify', 0)
	a('Engineering, Infra & IT', 'Redshift', 0)
#################################################    RETIRED ROLES    #################################################
# def elts_coo() :
 # 	a('Simple Basics', 'ADP', 0)
 # 	a('Simple Basics', 'Bamboo HR', 0)
 # 	a('Simple Basics', 'BVS', 0)
 # 	a('Simple Basics', 'ChartIO', 1)
 # 	a('Business Administration', 'Concur', 0)
 # 	a('Simple Basics', 'G Suite', 0)
 # 	a('Simple Basics', 'GitHub: Enterprise', 0)
 # 	a('Simple Basics', 'Team Gantt', 0)
 # 	a('Simple Basics', 'Slack', 1)
 # 	a('Simple Basics', 'Simple WiFi', 0)
 # 	a('Simple Basics', 'VPN', 0)
 # 	a('Office', 'Physical Badge Access', 0)
 # 	a('CR', 'Belvedere', 0)
 # 	a('CR', 'Belvedere', 2)
 # 	a('CR', 'Belvedere', 4)
 # 	a('Business Administration', 'Axiom EPM', 0)
 # 	a('Business Administration', 'ContractWorks', 0)
 # 	a('Business Administration', 'DocuSign', 0)
 # 	a('Business Administration', 'Greenhouse', 1)
 # 	a('Engineering, Infra & IT', 'AWS IAM', 0)
 # 	a('Engineering, Infra & IT', 'AWS IAM', 1)
 # 	a('Engineering, Infra & IT', 'Centrify', 0)
# def acctfin_dataarchitect() :
	# a('Simple Basics', 'ADP', 0)
	# a('Simple Basics', 'Bamboo HR', 0)
	# a('Simple Basics', 'BVS', 0)
	# a('Simple Basics', 'ChartIO', 3)
	# a('Simple Basics', 'Concur', 0)
	# a('Simple Basics', 'G Suite', 0)
	# a('Simple Basics', 'GitHub: Enterprise', 0)
	# a('Simple Basics', 'LucidChart', 0)
	# a('Simple Basics', 'Slack', 1)
	# a('Simple Basics', 'VPN', 0)
	# a('Simple Basics', 'Simple WiFi', 0)
	# a('Office', 'Physical Badge Access', 0)
	# a('Marketing', 'Segment.io', 1)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	# a('Engineering, Infra & IT', 'Redshift', 1)
	# a('Engineering, Infra & IT', 'Centrify', 0)
# def rc_compliance_riskspec() :
	# a('Simple Basics', 'ADP', 0)
	# a('Simple Basics', 'Bamboo HR', 0)
	# a('Simple Basics', 'BVS', 0)
	# a('Simple Basics', 'Concur', 0)
	# a('Simple Basics', 'ChartIO', 0)
	# a('Simple Basics', 'G Suite', 0)
	# a('Simple Basics', 'GitHub: Enterprise', 0)
	# a('Simple Basics', 'Slack', 1)
	# a('Simple Basics', 'VPN', 0)
	# a('Simple Basics', 'Simple WiFi', 0)
	# a('Office', 'Physical Badge Access', 0)
	# a('CR', 'Belvedere', 0)
	# a('CR', 'Belvedere', 1)
	# a('CR', 'Belvedere', 2)
	# a('CR', 'Belvedere', 5)
	# a('CR', 'Belvedere', 6)
	# a('CR', 'Belvedere', 7)
	# a('CR', 'Belvedere', 9)
	# a('CR', 'Chili', 0)
	# a('CR', 'Compass Tools', 0)
	# a('CR', 'Compass Tools', 1)
	# a('CR', 'Google Inbox', 0)
	# a('CR', 'Google Inbox', 2)
	# a('CR', 'Google Inbox', 3)
	# a('CR', 'Google Inbox', 4)
	# a('Risk, Compliance & Fraud', 'Google Inbox', 3)
	# a('Risk, Compliance & Fraud', 'Google Inbox', 4)
	# a('CR', 'Primer', 0)
	# a('Risk, Compliance & Fraud', 'Drivers License Guide', 0)
	# a('Risk, Compliance & Fraud', 'LexisNexis Accurint', 0)
	# a('Risk, Compliance & Fraud', 'SharePoint', 13)
	# a('Engineering, Infra & IT', 'Centrify', 0)
# def ops_vp() :
	# a('Simple Basics', 'ADP', 0)
	# a('Simple Basics', 'Bamboo HR', 1)
	# a('Simple Basics', 'BVS', 0)
	# a('Simple Basics', 'ChartIO', 1)
	# a('Business Administration', 'Concur', 0)
	# a('Simple Basics', 'LucidChart', 0)
	# a('Simple Basics', 'Slack', 1)
	# a('Simple Basics', 'Team Gantt', 1)
	# a('Simple Basics', 'VPN', 0)
	# a('Simple Basics', 'Simple WiFi', 0)
	# a('CR', 'Belvedere', 0)
	# a('CR', 'Belvedere', 1)
	# a('CR', 'Belvedere', 2)
	# a('CR', 'Belvedere', 5)
	# a('CR', 'Belvedere', 6)
	# a('CR', 'Belvedere', 8)
	# a('CR', 'Belvedere', 9)
	# a('CR', 'Chili', 0)
	# a('CR', 'Compass Tools', 0)
	# a('CR', 'Compass Tools', 2)
	# a('Business Administration', 'Axiom EPM', 0)
	# a('Business Administration', 'ContractWorks', 0)
	# a('Business Administration', 'Greenhouse', 1)
	# a('Risk, Compliance & Fraud', 'Digility (Cachet) - Check Review', 0)
	# a('Risk, Compliance & Fraud', 'LexisNexis Accurint', 0)
	# a('Risk, Compliance & Fraud', 'SharePoint', 13)
	# a('Risk, Compliance & Fraud', 'ZenGRC', 0)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 21)
	# a('Engineering, Infra & IT', 'Centrify', 0)
	# a('Engineering, Infra & IT', 'VPC Host Access', 0)
	# a('Engineering, Infra & IT', 'BBVA JIRA', 0)
	# a('Engineering, Infra & IT', 'PagerDuty', 0)
	# a('Engineering, Infra & IT', 'Redshift', 0)
# def prod_dirdatasci() :
	# a('Simple Basics', 'ADP', 1)
	# a('Simple Basics', 'Bamboo HR', 1)
	# a('Simple Basics', 'BVS', 0)
	# a('Simple Basics', 'ChartIO', 3)
	# a('Business Administration', 'Concur', 1)
	# a('Simple Basics', 'G Suite', 0)
	# a('Simple Basics', 'GitHub: Enterprise', 0)
	# a('Simple Basics', 'Slack', 1)
	# a('Simple Basics', 'VPN', 0)
	# a('Simple Basics', 'Simple WiFi', 0)
	# a('Office', 'Physical Badge Access', 0)
	# a('CR', 'Belvedere', 4)
	# a('Business Administration', 'Axiom EPM', 0)
	# a('Business Administration', 'Greenhouse', 1)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 12)
	# a('Engineering, Infra & IT', 'Redshift', 0)
	# a('Engineering, Infra & IT', 'Centrify', 0)
# def prod_datascientist() :
	# a('Simple Basics', 'ADP', 0)
	# a('Simple Basics', 'Bamboo HR', 0)
	# a('Simple Basics', 'BVS', 0)
	# a('Simple Basics', 'ChartIO', 1)
	# a('Simple Basics', 'ChartIO', 2)	
	# a('Simple Basics', 'Concur', 0)
	# a('Simple Basics', 'G Suite', 0)
	# a('Simple Basics', 'GitHub: Enterprise', 0)
	# a('Simple Basics', 'Slack', 1)
	# a('Simple Basics', 'VPN', 0)
	# a('Simple Basics', 'Simple WiFi', 0)
	# a('Office', 'Physical Badge Access', 0)
	# a('CR', 'Belvedere', 4)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 0)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 8)
	# a('Engineering, Infra & IT', 'AWS IAM Group', 12)
	# a('Engineering, Infra & IT', 'Redshift', 0)
	# a('Engineering, Infra & IT', 'Centrify', 0)
#################################################   ROLE DICTIONARY   #################################################
roles = {
	'Brand': {
		'Vice President - Brand': brand_vp,
		'Director - Brand Strategy and External Communications': mktg_dirbrandcomms,
		'Internal Brand Manager': mktg_internalbrandmgr,
		'Internal Communications Specialist': mktg_internalcommsspec,
		'Corporate Communications Manager': mktg_corpcommsmgr,
		'Social Media Specialist': mktg_socialmediaspec,
		'Communications Specialist': mktg_commspec,
		'Executive Assitant': brand_ea,
	 	'Director - Product Marketing': mktg_dirprodmktg,
	 	'Product Marketing Manager': mktg_prodmktgmgr,
	 	'Brand Front End Developer': mktg_brandfedev,
	 	'Brand Designer': mktg_branddesigner
		},
	'CEO': {
		'Executive Assistant': elts_ea,
		'CEO': elts_ceo
		},
	'Customer Operations': {
		'Vice President - Customer Operations': cr_vp,
		'Executive Assistant': cr_ea,
		'Business Analyst': cr_businessanalyst,
		'Customer Support Agent': cr_csagent, 
	 	'Customer Support Shift Lead': cr_cssl, 
	 	'Customer Support Shift Team Lead': cr_csstl, 
	 	'Customer Support Manager': cr_sm, 
	 	'Escalations Agent': cr_escalationsagent, 
	 	'Escalations Manager': cr_escalationsmanager, 
	 	'Account Management Agent': cr_acctmgmtagent, 
	 	'Workforce Management': cr_wfm, 
	 	'Director - Customer Support': cr_dircs,
	 	'Training Operations Specialist': cr_trainingopsspec,
	 	'Support Content Manager': cr_supportcontentmgr,
	 	'Resource Specialist': cr_resourcespec,
	 	'Education Specialist': cr_eduspec,
	 	'QA Specialist': cr_qaspec,
	 	'QA Manager': cr_qamgr,
	 	'Education Manager': cr_edumgr,
	 	'Program Manager': cr_programmgr,
	 	'Project Manager': cr_pjm,
	 	'Director - CR Operations': cr_dirops,
		'Deposit Risk Specialist': rc_depositriskspec,
		'Deposit Risk Manager': rc_depositriskmgr,
		'Fraud & Disputes Agent': rc_fdagent,
		'Disputes Manager': rc_disputesmgr,
		'Risk Specialist/Analyst': rc_risk_riskspec, 
		'Risk Manager': rc_riskmanager,
		'Risk Statistician': rc_riskstatistician,
		'Risk Architecht': rc_riskarchitecht,
		'Risk Architecture Manager': rc_riskarchitechturemgr,
		'Director - Risk Operations': rc_dir,
		'Director - Business Operations': ops_dirbizops,
		'Consulting': ops_consulting,
		'Banking Operations Specialist': ops_bankingops,
		'Business Operations - Partner Management': ops_partnermgmt,
		'Business Operations Manager': ops_bizopsmgr,
		},
	'Engineering': {
	 	'Vice President - Engineering': eng_vp,
	 	'Backend Engineer': eng_beeng,
	 	'Backend Engineering Manager': eng_beengmanager,
	 	'Director - Backend Engineering': eng_dirbeeng,
	 	'iOS & Android Engineer': eng_iosandroid, 
	 	'QA Engineer': eng_qa, 
	 	'Front End Engineer': eng_fe, 
	 	'Client Engineering Manager': eng_clientmanager, 
	 	'QA Engineering Manager': eng_qamanager, 
	 	'Front End Engineering Manager': eng_femanager,
	 	'Director - Client Engineering': eng_dirclient,
	 	'Director - Infrastructure Engineering': eng_infraengdir,
	 	'Infrastructure Engineering Manager': eng_infraengmgr,
	 	'Data Engineer': eng_data,
	 	'Infrastructure Engineer': eng_infraeng,
	 	'Security Engineer': eng_security,
	 	'Product Security Engineer': infosec_prodseceng, 
	 	'Product Security Manager': infosec_prodsecmanager
	 	},
	'Finance & ERM': {
		'Chief Financial Officer': acctfin_cfo,
		'Executive Assistant': fin_erm_ea,
		'Director - Finance': acctfin_dirfinance,
		'Accounting Manager': acctfin_accountingmgr,
		'Payroll': acctfin_payroll,
		'Accountant': acctfin_accountant,
		'Accounts Payable': acctfin_acctpayable,
		'Director - FP&A': acctfin_dirfpa,
		'FP&A Manager': acctfin_fpamanager,
		'FP&A - Financial Analyst': acctfin_fpa_finanalyst,
		'Audit Manager': ops_auditmgr,
		'Auditor': ops_auditor,
		'Compliance Officer': erm_complianceofficer,
		'Compliance Manager': rc_compliancemgr,
		'AML Analyst': rc_amlanalyst,
		'Compliance Analyst': rc_complianceanalyst,
		'Corporate Counsel': ops_corpcounsel,
		'Staff Attorney': ops_attourney,
		'Director - IT': it_dir,
		'IT Support Engineer': it_support,
		'IT Systems Engineer': it_systems,
		'InfoSec Risk Analyst': infosec_riskanalyst,
		'InfoSec Risk Manager': infosec_riskmanager,
		'Director - InfoSec': infosec_dir
		},
	'People': {
	 	# 'Chief People Officer': ppl_cpo,
	 	'Director - People Operations': ppl_dirpplops,
	 	'Talent Business Partner': ppl_talentpartner, 
	 	'People Operations Manager': ppl_pplopsmanager,
	 	'People Operations Analyst': ppl_pplopsanalyst,
	 	# 'Workplace Experience Manager': ppl_workplaceexpmanager, #previously office admin manager - update role function for this
	 	'Facilities Manager': ppl_facilitiesmanager,
	 	'Office Manager': ppl_officemanager,
	 	'Administrative Assistant': ppl_adminassistant,
	 	'Facilities Coordinator/Assistant': ppl_facilities,
	 	'Learning & Development Coach': ppl_ldcoach, 
	 	'Performance & Development Manager': ppl_mgrpd, 
	 	'Recruiting Manager': ppl_recruitingmanager,
	 	'Recruiter': ppl_recruiter
	 	},
	'Product': {
		'Chief Product Officer': prod_cpo,
		'Executive Assistant': prod_ea, 
		'Director - Product Management': prod_dirprodmanagement,
		'Group Product Manager': prod_groupprodmanager,
		'Product Manager': prod_productmanager,
		# 'Director - Growth': mktg_dirgrowth, wait to confirm same role as Dir Product Operations
		'Digital Marketing Manager': mktg_digmktgmanager, 
		'Digital Marketing Specialist': mktg_digmktgspec, 
	 	'Lifecycle Marketing Manager': mktg_lifecyclemanager, 
	 	'Lifecycle Marketing Specialist': mktg_lifecyclespec, 
	 	'Content Producer': mktg_contentprod, 
	 	'Optimization Manager': mktg_optmanager, 
		'Data Analyst': mktg_growthdataanalyst,
		'Analytics Engineer': prod_analyticseng,
		'Analytics Manager': prod_analyticsmgr, 
		'Director - Creative': prod_dircreative,
		'Product Designer': prod_prodcutdesigner,
		'Project Management Manager': ops_pjmmanager,
		'Project Manager': ops_projectmanager,
		'Technical Writer': ops_techwriter,
		'Director - User Research': prod_diruserresearch, 
		'User Research Manager': prod_userresearchmanager,		
		}}
### Retired Roles Dict		
	# 'Accounting & Finance': {
	# 	'Business Strategy Manager': acctfin_bizstrategymgr,
	# 	'Business Strategy - Financial Analyst': acctfin_bs_finanalyst,
	# 	'Data Architect': acctfin_dataarchitect,
	# 	'Decision Scientist': acctfin_decisionsci,
	# 	},
	# 'ELT': {
	# 	'COO': elts_coo,
	# 	},
	# 'Marketing': {
	#  	'Videographer/Photographer': mktg_vidphotographer,
	#  	'Copywriter': mktg_copywriter,
	#  	'Art Director': mktg_artdir, 
	#  	'Brand Team Voice Lead': mktg_brandvoicelead,
	#  	'Brand Designer': mktg_branddesigner, 
	#  	'Studio Manager': mktg_studiomgr,
	#  	'Chief Marketing Officer': mktg_cmo,
	#  	},
	# 'Operations': {
	# 	'Vice President - Operations': ops_vp,
	# 	},
	# 'Product': {
    # 'Director - Data Science': prod_dirdatasci,
		# }
	# 'Risk & Compliance': {
	# 	
		# 'Compliance - Risk Specialist': rc_compliance_riskspec, 
		
	 	# 'Data Scientist': prod_datascientist, 
	# }
	
def employment_type() :
	global e_status, text, gsuite, employee, fte
	print '\n' + '.' * 85 + '\n\n' + 'EMPLOYEE TYPE\n'.center(85)
	print 'What type of employee is %s?\n'.center(85) % user
	print 'Temporary staff, contractors & consultants have restricted access to some systems.\n\nPLEASE SEE SPREADSHEET TO DETERMINE EMPLOYEE TYPE.\n\n' + linebreak.center(85) + '\n'
	for c, value in enumerate(e_status) :
		print '[', c, ']', value
	valid = False 
	menuselect = int(raw_input('\nEnter a number selection from the options above:    '))
	while valid == False :
		try : 
			e_status[menuselect]
			e_status_value = e_status[menuselect].format(value) 
			if menuselect == 0 :
				fte = True
			if menuselect == 1 or menuselect == 2 or menuselect == 3 :
				fte = False
				if menuselect == 1 :
					employee = '(Temp) '
				if menuselect == 2 : 
					employee = '(Contractor) '
				if menuselect == 3 : 
					employee = '(BBVAC) '
				systems['Simple Basics']['G Suite']['special'] = gsuite + gsuite_c
			
			valid = True
			
		except IndexError:
			print 'Invalid selection.'
			menuselect = int(raw_input('\nEnter a number selection from the options above:    '))
		start()
def start() :
	global form, text
	
	print '\n' + '.' * 85 + '\n\n' + 'REQUEST TYPE\n'.center(85)
	print 'What type of request is being submitted for %s?\n'.center(85) % user
	print 'Options 1-3 will take you to select role-based access from a menu of roles. Option 4\nwill allow you to specify systems-based access.\n\nChoose 0 to return to the previous menu.\n\n' + linebreak.center(85) + '\n'
	for c, value in enumerate(menulist) :
		print '[', c, ']', value
	valid = False 
	menuselect = int(raw_input('\nEnter a number selection from the options above:    '))
	if menuselect == 0 :
				valid = True
				employment_type()
	else :
		while valid == False :
			try : 
				menulist[menuselect]
				if menuselect < 4 :
					if menuselect == 1 :
						form = 'New Access'
					if menuselect == 2 :
						form = 'FTE Conversion'
					if menuselect == 3 : 
						form = 'Role Change'
					role_based()
					valid = True
				if menuselect == 4 : 
					form = 'Additional Access'
		
					print '\n' + '.' * 85 + '\n\n' + 'ADDITIONAL ACCESS\n'.center(85)
					print 'Is the access request SPECIFIC FOR THIS USER, or does this access need to be\nADDED TO A ROLE?\n\nChoose 0 to return to the previous menu.\n\n' + linebreak.center(85) + '\n'
					for c, value in enumerate(reqtypes) :
						print '[', c, ']', value
					menuselect = int(raw_input('\nEnter a number selection from the options above:    '))
					if menuselect == 0 :
						start()
						valid = True
					else : 
						while valid == False :
							try : 
								reqtypes[menuselect]
								if menuselect == 1 :
									text = text + '\n\nThe following system(s) are requested specifically for this individual.'
								if menuselect == 2 :
									role = raw_input('Enter the name of the role that needs to be updated: ')
									text = text + '\n\n@mcdonough: please add the following system(s) to the %s role description.\n' % role
								system_based()
								valid = True
							except IndexError:
								print 'Invalid selection.'
								menuselect = int(raw_input('\nEnter a number selection from the options above:    '))
			
				if valid == True :
					break
			except IndexError:
				print 'Invalid selection.'
				menuselect = int(raw_input('\nEnter a number selection from the options above:    '))
		
	
def role_based() :
	
	print '\n' + '.' * 85 + '\n\n' + 'DEPARTMENTS\n'.center(85)
	print 'What department is %s in?'.center(85) % user
	print '(This should be listed under "SIMPLE ORG")'.center(85)
	print '\n\nChoose 0 to return to the previous menu.\n\n' + linebreak.center(85) + '\n'
	for c, value in enumerate(deptlist) :
		print '[', c, ']', value
	valid = False 
	deptselect = int(raw_input('\nEnter a number selection from the options above:    '))
	if deptselect == 0 :
				valid = True
				start()
	else :
		while valid == False :
			try : 
				deptlist[deptselect]
				deptselect = deptlist[deptselect].format(value)
				
				if deptselect == 0 :
					start()
				else :
					rolelist(deptselect)
				valid = True
			except IndexError:
				print 'Invalid selection.'
				deptselect = int(raw_input('\nEnter a number selection from the options above:    '))	
	
def rolelist(deptselect) :
	global text, rolefilled, roleselect, rolecount
	
	header = '%s ROLES\n' % deptselect.upper()
	print '\n' + '.' * 85 + '\n\n' + header.center(85)
	print 'What department is %s in?'.center(85) % user
	print '(This should be listed under "SIMPLE ORG")'.center(85)
	print '\n\nChoose 0 to return to the previous menu.\n\n' + linebreak.center(85) + '\n'
	rolekeys = roles[deptselect].keys()
	rolekeys.insert(0, 'Back')
	rolekeys.append('Role Not Listed')
	role_len = len(rolekeys) - 1
	valid = False
	for c, value in enumerate(rolekeys) :
		print '[', c, ']', value
	roleselect = int(raw_input('\nEnter a number selection from the options above:    '))
	
	if roleselect == 0 :
			role_based()
	elif roleselect == role_len :
		newrole = True
		newrolename = raw_input('What is the name of the role? ')
		text = text + '\n## Access for %s\nRole coming soon - @alana is working on getting this role definition into SAM. Please hang tight for an update!' % newrolename
		rolefilled = True
		additional()
	else :
		while valid == False and rolefilled != True :
			try :
				rolekeys[roleselect]
				valid = True
				rolefilled = True
				roleselect = rolekeys[roleselect].format(value)
				text = text + '\n## Access for %s' % roleselect
				role = roles[deptselect][roleselect]()
				duplicates = []
				additional()
			except IndexError:
				print 'Invalid selection.'
				roleselect = int(raw_input('\nEnter a number selection from the options above:    '))
def additional() :
	global rolefilled
	
	print '\n' + '.' * 85 + '\n'
	additional = raw_input('Does %s require access to any additional systems? (Y/N) ' % user)
	while additional.lower() != 'y' and additional.lower() != 'n' :
		print 'Invalid Selection.'
		additional = raw_input('Does %s require access to any additional systems? (Y/N) ' % user)		
	if additional.lower() == 'y' :
		rolefilled = False
		system_based()
	if additional.lower() == 'n' :
		exit()
def system_based():
	print '\n' + '.' * 85 + '\n\n' + 'SYSTEMS by CATEGORY\n'.center(85)
	print 'Simple systems are broken up into categories. These categories are mirrored to match\nthe categories listed on the spreadsheet (row 3). Use the sheet to determine where  \nan individual system will be in this menu.\n\nChoose 0 to return to the previous menu.\n\n' + linebreak.center(85) + '\n'
	
	for c, value in enumerate(groups) :
		print '[', c, ']', value
	
	groupselect = int(raw_input('\nEnter a number selection from the options above:    '))
	valid = False 
	while valid == False :
		if groupselect == 0 :
			start()
			valid = True
		if groupselect == 10 :
			exit()
			valid = True
		if valid == True :
			break
		else :
			try : 
				groups[groupselect]
				groupselect = groups[groupselect].format(value)
				valid = True
				systemlist(groupselect)
				break
			except IndexError:
				print 'Invalid selection.'
				groupselect = int(raw_input('\nEnter a number selection from the options above:    '))	
def systemlist(groupselect) :
	global additionalcount, text
	
	header = '%s:\n' % groupselect.upper()
	print '\n' + '.' * 85 + '\n\n' + 'SYSTEMS by CATEGORY\n'.center(85) + '\n\n' + header.center(85)
	print 'Simple systems are broken up into categories. These categories are mirrored to match\nthe categories listed on the spreadsheet (row 3). Use the sheet to determine where  \nan individual system will be in this menu.\n\nChoose 0 to return to the previous menu.\n\n' + linebreak.center(85) + '\n'
	syskeys = systems[groupselect].keys()
	syskeys.insert(0, 'Back')
	valid = False
	for c, value in enumerate(syskeys) :
		print '[', c, ']', value
	sysselect = int(raw_input('\nEnter a number selection from the options above:    '))
	
	if sysselect == 0 :
				system_based()
	else :
		while valid == False :
			try :
				syskeys[sysselect]
				valid = True
				sysselect = syskeys[sysselect].format(value)
				system = systems[groupselect][sysselect]
				print sysselect
				accessoptions = systems[groupselect][sysselect].get('access', '')
				len(accessoptions)
				if len(accessoptions) > 1 :
					for c, value in enumerate(accessoptions) : 
						print '[', c, ']', value
					access = int(raw_input('Select the Access Level: '))
					
				else : 
					access = 0
				additionalcount = additionalcount + 1
				if additionalcount == 1 :
					text = text + '\n## Additional Systems Access:\n'
				a(groupselect, sysselect, access)	
				additional()
			except IndexError:
				print 'Invalid selection.'
				sysselect = int(raw_input('\nEnter a number selection from the options above:    '))
def exit() :
	print '\n' + '=' * 85 + '\n\n' + 'Do you need to add anything else for %s?' % user + '\nY to CONTINUE IN SCRIPT. N to FINISH.\n\n' + linebreak.center(85)
	confirm = raw_input('Enter (Y/N):   ' ) 
	while confirm.lower() != 'y' and confirm.lower() != 'n' :
		print 'Invalid Selection.'
		confirm = raw_input()		
	if confirm.lower() == 'y' :
		system_based()
	else :
		return 'fin'
employment_type()
pyperclip.copy(text)
subject = '%s: %s %s%s' % (form, user, employee, date)
print 'Markdown text copied to clipboard...'
time.sleep(1.0)
print 'Redirecting to GitHub....'
time.sleep(1.0)
print 'Paste clipboard contents into GitHub issue body in a moment.'
time.sleep(1.0)
chrome_path = 'open -a /Applications/Google\ Chrome.app %s'
url = 'https://github.banksimple.com/it/SAM/issues/new?'
encoded = urllib.urlencode({'title': subject, 'body': text})
url = 'https://github.banksimple.com/it/SAM/issues/new?' + encoded
webbrowser.get(chrome_path).open_new_tab(url)
complete = raw_input('Do you need to create another SAM request? (Y/N): ')
while complete.lower() != 'y' and complete.lower() != 'n' : 
	print 'Invalid selection.'
	complete = raw_input('Enter Y to continue or N to end script: ')
if complete.lower() == 'n' :
	print 'SAM Script is complete.'
elif complete.lower() == 'y' :
	os.execl(sys.executable, sys.executable, *sys.argv)
	
print '=' * 85
""" > /tmp/samscript.py


echo """tell application \"Terminal\"
    tell window 1
        set size to {800, 800}
        set position to {50, 50}
    end tell
end tell""" > /tmp/tellterminal.applescript

#chown root:wheel /tmp/samscript.py

chmod 755 /tmp/samscript.py 
chmod 755 /tmp/tellterminal.applescript

open -a Terminal.app /tmp/samscript.py && osascript /tmp/tellterminal.applescript
