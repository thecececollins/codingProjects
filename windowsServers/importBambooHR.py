#!/usr/bin/env python

import requests
import logging
import argparse
import sys
import string
import os
import random
from slacker import Slacker

from PyBambooHR import PyBambooHR
from pyad import adquery
from pyad import aduser
from pyad import adgroup
from pyad import adcontainer
from pyad import *


if hasattr(logging, "NullHandler"):
    # Python 2.7 and newer
    NullHandler = logging.NullHandler
else:
    # Python 2.6 and older
    class NullHandler(logging.Handler):
        def emit(self, record):
            pass

log = logging.getLogger(__name__)
log.addHandler(NullHandler())

pyad.set_defaults(ldap_server="pdx-clay-dc1.corp.simple.com")


def parse_args(argv):
    """Parse any command line arguments
    Returns a Namespace object built from the passed argument vector
    :param argv: argument vector, usually :data:`sys.argv`
    """
    parser = argparse.ArgumentParser()

    defaults = {
        "APIKey": "",
        "userOU": "ou=domain users,dc=corp,dc=simple,dc=com",
        "groupOU": "ou=groups,dc=corp,dc=simple,dc=com",
        "silent": False,
        "quiet": 0,
        "verbose": 0,
    }

    # Configure global options
    parser.add_argument("-a", "--api-key", action="store", dest="APIKey",
                        default=defaults["APIKey"], help="silence logging",
                        type=str, required=True)
    parser.add_argument("-u", "--user-ou", action="store", dest="userOU",
                        default=defaults["userOU"], help="OU for new users",
                        type=str)
    parser.add_argument("-g", "--group-ou", action="store", dest="groupOU",
                        default=defaults["groupOU"], help="OU for new groups",
                        type=str)
    parser.add_argument("-s", "--silent", action="store_true", dest="silent",
                        default=defaults["silent"], help="silence logging")
    parser.add_argument("-q", "--quiet", action="count", dest="quiet",
                        default=defaults["quiet"],
                        help="decrease log verbosity")
    parser.add_argument("-v", "--verbose", action="count", dest="verbose",
                        default=defaults["verbose"],
                        help="increase log verbosity")

    args = parser.parse_args()
    return args


def main(argv, err=None):
    """Main script function
    :param argv: argument vector, usually from :data:`sys.argv`.
    :param err: stream to write errors to, :data:`sys.stderr` if None.
    """
    if err is None:
        err = sys.stderr

    args = parse_args(argv)

    level = logging.WARNING - ((args.verbose - args.quiet) * 10)
    if args.silent:
        level = logging.CRITICAL + 1

    logformat = "%(levelname)s: %(message)s"
    loghandler = logging.StreamHandler(err)
    loghandler.setFormatter(logging.Formatter(logformat))
    log.addHandler(loghandler)
    log.setLevel(level)

    log.debug("Starting...")

    global userOU
    userOU = args.userOU
    global groupOU
    groupOU = args.groupOU

    records = {}
    departments = set([])
    newGroups = []
    newUsers = {}

    report = get_report(args.APIKey)
    for rawRecord in report:
        record = process_record(rawRecord)
        records[record["displayName"]] = record

    for dispName, record in records.items():
        if record["department"]:
            departments.add(record["department"])

    for department in departments:
        groupDN = check_object(groupOU, department)
        if not groupDN:
            add_group(department)
            newGroups.append(department)

    # Get a list of all users with no supervisor
    noSuper = [dispName for dispName, rec in records.items() if not rec["supervisor"]]
    # Iterate that list and add them all if they aren't in AD
    for dispName in noSuper:
        if records[dispName]["status"] == "Active":
            log.debug("Processing no-supervisor user: " + records[dispName]["userName"])
            if not records[dispName]["dn"]:
                if records[dispName]["status"] == "Active":
                    log.debug("Adding no-supervisor user: " + records[dispName]["userName"])
                    records[dispName]["dn"] = add_user(records[dispName])
                    records[dispName]["new"] = True
            # Find and add all the users who report to this person
            add_direct_reports(dispName, records)

    for dispName, rec in records.items():
        if records[dispName]["new"]:
            newUsers[dispName] = records[dispName]

    if len(newUsers) > 0 or len(newGroups) > 0:
        send_slack(newUsers, newGroups)


def add_direct_reports(supervisor, records):
    """Add a supervisor's direct reports
    When given the name of a supervisor and the dict of records, go through
    the dict of records and if any user reports to that supervisor but does
    not exist in AD, add them and then add their reports.
    :param supervisor: The displayName field for the supervisor
    :param records: The records dictionary from this run
    """
    # Get a list of all users who report to this supervisor
    directReports = [dispName for dispName, rec in records.items() if rec["supervisor"] == supervisor]
    # Iterate the list and add them if they aren't in AD
    if len(directReports) > 0:
        log.debug("Processing " + str(len(directReports)) + " reports for: " + supervisor)
        for dispName in directReports:
            records[dispName]["superDN"] = records[supervisor]["dn"]
            if not records[dispName]["dn"]:
                if records[dispName]["status"] == "Active":
                    log.debug("Adding supervised user: " + records[dispName]["userName"])
                    log.debug("Supervisor: " + records[dispName]["supervisor"])
                    records[dispName]["dn"] = add_user(records[dispName])
                    records[dispName]["new"] = True
            # Find and add all the users that report to this person
            add_direct_reports(dispName, records)


def get_report(APIKey):
    """Get Report
    Pulls report #2579 from BambooHR and returns the employees dict.
    :param APIKey: the BambooHR API key
    """
    requests.packages.urllib3.disable_warnings()
    bamboo = PyBambooHR(subdomain="simplelogin", api_key=APIKey)
    report = bamboo.request_company_report(2579, filter_duplicates=True)

    return report[u"employees"]


def process_record(record):
    """Process Record
    Takes in a single record from the report results and processes it, to
    be sure that encoding is correct and certain required values are set.
    Returns a dict with the processed record
    :param record: A dictionary containing BambooHR user info
    """
    newRecord = {}

    # Make sure every record with a value is in utf-8
    for key, value in record.items():
        if value:
            newRecord[key] = value

    if not "status" in newRecord.keys():
        newRecord["status"] = "Active"

    if not "location" in newRecord.keys():
        newRecord["location"] = "Unknown"

    # We want some value for preferredName, even if it's default
    if "preferredName" in newRecord:
        preferredName = newRecord["preferredName"].split("\\")[0]
        preferredName = preferredName.split("/")[0]
    else:
        preferredName = newRecord["firstName"]

    if not "workEmail" in newRecord.keys():
        newRecord["status"] = "Inactive"

    # When possible, call people what they want to be called.  It's polite.
    newRecord["prefFullName"] = preferredName + " " + newRecord["lastName"]

    # If a user doesn't have a supervisor set, at least put a null string in.
    if "supervisor" not in newRecord:
        newRecord["supervisor"] = ""

    # We don't care about the number for the user's department, so strip it off
    if "department" in newRecord:
        newRecord["department"] = newRecord["department"].rpartition(" - ")[2].lstrip()
        newRecord["department"] = newRecord["department"].replace(":", " -")
    else:
        newRecord["department"] = ""

    # If the user has an email address, use the name part to set username
    if "workEmail" in newRecord:
        newRecord["userName"] = newRecord["workEmail"].split("@")[0]
    # Otherwise just use firstname + lastname, or first initial + last
    else:
        fullName = newRecord["firstName"] + newRecord["lastName"]
        if len(fullName) > 15:
            fullName = newRecord["firstName"][0] + newRecord["lastName"]
        else:
            fullName = newRecord["firstName"] + newRecord["lastName"]
        newRecord["userName"] = fullName
        newRecord["workEmail"] = fullName + "@simple.com"

    newRecord["new"] = False

    userDN = check_object(OU=userOU, sAMAccountName=newRecord["userName"])
    newRecord["dn"] = userDN

    return newRecord


def send_slack(newUsers, newGroups):
    slack = Slacker("xoxb-191491987924-MNAyDug515Ma66FKVXZAWX0L")

    body = "I imported some stuff from BambooHR to AD."

    newGroups.sort()

    if len(newUsers):
        body = body + "\n\nNew users:"
        for dispName, record in newUsers.items():
            body = body + "\n\t" + newUsers[dispName]["prefFullName"]
            if len(newUsers[dispName]["prefFullName"]) > 20:
                body = body + " (Fix long name)"
            body = body + "\n\t\t" + newUsers[dispName]["workEmail"]

    if len(newGroups):
        body = body + "\n\nNew Groups:"
        for group in newGroups:
            body = body + "\n\t" + group

    # Send a message to #iteam channel
    slack.chat.post_message('#iteam', body, as_user=True)


def check_object(OU, sAMAccountName="", dispName=""):
    """Check to see if the object exists in AD
    Checks to see if a given object is already in AD based on either
    sAMAccountName or or dispName.  Returns either their distinguishedName
    (if they exist) or False if they don't.
    :param OU: The OU in which to search for the object
    :param sAMAccountName: An optional string with the sAMAccountName
    :param dispName: An optional string with the displayName
    """
    q = adquery.ADQuery()
    # If we have username, query on that
    if sAMAccountName:
        q.execute_query(
            attributes=["distinguishedName"],
            where_clause="sAMAccountName = '" + sAMAccountName + "'",
            base_dn=OU,
        )
    # Otherwise query on displayName
    else:
        q.execute_query(
            attributes=["distinguishedName"],
            where_clause="displayName = '" + dispName + "'",
            base_dn=OU,
        )

    if q.get_row_count() == 0:
        return False
    else:
        # Just return the first result
        for row in q.get_results():
            return row["distinguishedName"]


def add_group(group):
    """Add a group to AD
    Takes the name of a group and creates it in the groupOU
    :param group: The name of the group to add
    """
    log.debug("Creating group: " + group)
    objGroupOU = adcontainer.ADContainer.from_dn(groupOU)
    adgroup.ADGroup.create(
                          group,
                          objGroupOU,
                          optional_attributes={}
                          )


def add_user(record):
    """Add a user record to AD
    Use all of the information about a user to add them to AD.
    Returns the DN of the new user.
    :param record: A dict with the requisite user information for the user
    """
    objUserOU = adcontainer.ADContainer.from_dn(userOU)
    manager = ""
    if "superDN" in record.keys():
        if record["superDN"]:
            manager = record["superDN"]
    password = generate_password()
    log.debug("Adding user with info:\n"
              "displayName: " + record["prefFullName"] +
              "\nPassword: " + password +
              "\nuserPrincipalName: " + record["workEmail"] +
              "\nmail: " + record["workEmail"] +
              "\ngivenName: " + record["firstName"] +
              "\nsn: " + record["lastName"] +
              "\ntitle: " + record["jobTitle"] +
              "\ndescription: " + record["prefFullName"] +
              "\nSAMaccountname: " + record["userName"] +
              "\ndepartment: " + record["department"] +
              "\nst: " + record["location"] +
              "\nmanager: " + manager +
              "\ncompany: Simple" +
              "\nproxyAddresses: SMTP:" + record["workEmail"]
              )
    newUser = aduser.ADUser.create(
        record["prefFullName"][:19],
        objUserOU,
        password=password,
        upn_suffix="@simple.com",
        optional_attributes={
            "displayName": record["prefFullName"],
            "userPrincipalName": record["workEmail"],
            "mail": record["workEmail"],
            "givenName": record["firstName"],
            "sn": record["lastName"],
            "title": record["jobTitle"],
            "description": record["prefFullName"],
            "SAMaccountname": record["userName"],
            "department": record["department"],
            "st": record["location"],
            "manager": manager,
            "company": "Simple",
            "proxyAddresses": "SMTP:" + record["workEmail"]
            })
    department = adgroup.ADGroup.from_cn(record["department"])
    newUser.add_to_group(department)
    userDN = newUser.dn
    return userDN


def generate_password(length=14):
    chars = string.ascii_letters + string.digits + '!@#$%^&*()'
    password = ''
    for i in range(length):
        password += chars[ord(os.urandom(1)) % len(chars)]
    password += random.choice(string.ascii_letters).lower()
    password += random.choice(string.ascii_letters).upper()
    password += random.choice(string.digits)
    password += random.choice('!@#$%^&*()')

    return password


if __name__ == "__main__":
