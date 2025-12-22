import os
import shutil

appId = os.environ.get('APP_ID', '').split('_')[0]
confDir = os.environ.get('XDG_CONFIG_HOME', '/tmp') + '/' + appId
confFile = confDir + '/config.json'

def purgeConfig():
    if os.path.exists(confDir):
        shutil.rmtree(confDir)