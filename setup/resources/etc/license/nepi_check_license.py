#!/usr/bin/python3

import os
import yaml
import gnupg
from datetime import datetime
import fcntl
import socket
import struct
import asyncio
import websockets
import random

NEPI_LICENSE_FOLDER = '/mnt/nepi_storage/license'
NEPI_LICENSE_BASENAME = NEPI_LICENSE_FOLDER + '/nepi_license_'
NEPI_LICENSE_EXTENSION = '.gpg'
NEPI_LICENSE_REQUEST_BASENAME = NEPI_LICENSE_FOLDER + '/nepi_license_request_'
NEPI_LICENSE_REQUEST_EXTENSION = '.yaml'
NEPI_GPG_KEYPATH = '/home/nepi/.gnupg'
NEPI_VERSION_FILE = '/opt/nepi/engine/etc/fw_version.txt'
LICENSE_WARNING_FILE = '/home/nepi/UNLICENSED_NEPI_ENGINE.txt'
UNLICENSED_LICENSE_DICT = {'licensed_components':{'nepi_base':{'commercial_license_type': 'Unlicensed'}}}

def getHardwareId():
        ifname = ''
        if not os.path.exists("/etc/network/interfaces.d/nepi_static_ip"):
            raise Exception("Indeterminate hardware for hardware ID")
        with open("/etc/network/interfaces.d/nepi_static_ip", 'r') as f:
            for line in f:
                if line.startswith('auto'):
                    ifname = line.split(' ')[1].strip()
                    break
        
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        info = fcntl.ioctl(s.fileno(), 0x8927,  struct.pack('256s', bytes(ifname, 'utf-8')[:15]))
        hardware_id = ''.join('%02x' % b for b in info[18:24])
        return hardware_id

def getNEPIVersion():
    if not os.path.exists(NEPI_VERSION_FILE):
        raise Exception("Unable to determine NEPI version")
    with open(NEPI_VERSION_FILE, 'r') as f:
        return f.readline()

def checkLicense():
    try:
        detected_key = getHardwareId()
        license_fullpath = NEPI_LICENSE_BASENAME + detected_key + NEPI_LICENSE_EXTENSION
        if not os.path.exists(license_fullpath):
            raise Exception("License file not found: " + license_fullpath)

        gpg = gnupg.GPG(gnupghome=NEPI_GPG_KEYPATH)
        
        license_text = ''
        with open(license_fullpath, 'rb') as license_file:
            license_obj = gpg.decrypt_file(license_file, always_trust=True, extra_args=['--ignore-time-conflict'])
            #print('ok:' + str(license_obj.ok) + ", status: " + license_obj.status + ", stderr: " + license_obj.stderr)
            #if (not license_obj.ok):
            if (license_obj.status != "signature valid"):
                raise Exception("License decrypt failed: " + license_obj.status)
            license_text = str(license_obj)

        license_contents = yaml.load(license_text)
        
        if ('licensed_components' not in license_contents) or ('nepi_base' not in license_contents['licensed_components']):
            raise Exception("Bad format")
        
        nb_license_contents = license_contents['licensed_components']['nepi_base']
        
        if ('hardware_key' not in nb_license_contents):
            raise Exception("Missing h/w key")
        
        if detected_key != nb_license_contents['hardware_key']:
            raise Exception("H/W key mismatch")
        
        if ('commercial_license_type' not in nb_license_contents):
            raise Exception("Missing lic. type")
                
        now = datetime.now()
        if ('expiration_date' in nb_license_contents):
            #print("Debug: expiration_date = " + nb_license_contents['expiration_date'])
            expiration = datetime.strptime(nb_license_contents['expiration_date'], '%m/%d/%Y')
            if (now > expiration):
                raise Exception('Expired: ' + nb_license_contents['expiration_date'])
        if ('expiration_version' in nb_license_contents):
            version_parts = getNEPIVersion().split('.')
            if len(version_parts) < 3:
                raise Exception("Bad f/w version format")
                            
            expiration_parts = nb_license_contents['expiration_version'].split('.')
            if len(expiration_parts) < 3:
                raise Exception("Bad lic. expiration version format")
            
            print("Debug: " + str(version_parts) + ", " + str(expiration_parts))
            
            if (version_parts[0] >= expiration_parts[0]) or \
            ((version_parts[0] == expiration_parts[0]) and (version_parts[1] > expiration_parts[1])) or \
            ((version_parts[0] == expiration_parts[0]) and (version_parts[1] == expiration_parts[1]) and (version_parts[1] >= expiration_parts[1])):
                raise Exception('Expired: ' + nb_license_contents['expiration_version'])
                
        if os.path.exists(LICENSE_WARNING_FILE):
            os.remove(LICENSE_WARNING_FILE)
        license_contents['licensed_components']['nepi_base']['status'] = 'Valid'
        #print("Debug: License valid: " + str(license_contents))
        return yaml.dump(license_contents)

    except Exception as e:
        with open(LICENSE_WARNING_FILE, 'w') as f:
            f.write("THIS DEVICE IS RUNNING AN UNLICENSED VERSION OF NEPI.\n")
            f.write("-----------------------------------------------------------------------------------\n")
            f.write("Failed to validate commercial license: " + str(e) + "\n")
            #print("Debug: " + str(e))
        exception_license = UNLICENSED_LICENSE_DICT.copy()
        exception_license['licensed_components']['nepi_base']['status'] = str(e)
        #print("Debug: License invalid: " + str(e))
        return yaml.dump(exception_license)

def generateLicenseRequest():
    hardware_id = getHardwareId()
    date = datetime.now().strftime("%m/%d/%Y")
    version = getNEPIVersion()
    request_yaml = "license_request:\n" + "  hardware_key: " + hardware_id + "\n  date: " + date + "\n  version: " + version + \
                   "  instructions: To request a commercial license, email this file to nepi@numurus.com"
    
    if not os.path.exists(NEPI_LICENSE_FOLDER):
        os.mkdir(NEPI_LICENSE_FOLDER, mode=775)

    try:
        detected_key = getHardwareId()
    except:
        detected_key = '_BAD_HARDWARE_ID'

    request_file_full_path = NEPI_LICENSE_REQUEST_BASENAME + detected_key + NEPI_LICENSE_REQUEST_EXTENSION
    with open(request_file_full_path, 'w') as f:
        f.write(request_yaml)

    return request_yaml

async def handleRequests(websocket, path):
    while True:
        try:
            request = await websocket.recv()
            message = ""
            if request == "license_check":
                message = checkLicense()
            elif request == "license_request":
                message = generateLicenseRequest()
                #print("Debug: Responding with " + message)
            else:
                message = "request: unknown"
        except Exception as e:
            message = "failed: " + str(e)
        
        await websocket.send(message)
        await asyncio.sleep(random.random() * 2 + 1)

async def serverMain():
    async with websockets.serve(handleRequests, "0.0.0.0", 9092):
        await asyncio.Future()

if __name__ == "__main__":
    checkLicense()
    loop = asyncio.get_event_loop()
    result = loop.run_until_complete(serverMain())
    



