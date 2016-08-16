#!py

import salt.client

def run():
    '''
    Install the django package
    '''
    #opts = salt.config.client_config('/etc/salt/master')
    #runner = salt.runner.RunnerClient(opts)
    #ret = runner.cmd('queue.list_length', 'prep_complete')
    if False:
        return { 'example': {'cmd.run': [ { 'name': 'echo "Hello"' } ]}}
    else:
        return { 'example': {'cmd.run': [ { 'name': ':' } ]}}
