""" Unit Test: Azure Blob Trigger

Unit testing Azure Blob Trigger involves verifying the functionality of the 
trigger mechanism responsible for initiating actions upon the creation or 
modification of objects within Azure Data Lake Storage (ADLS) buckets. This 
entails simulating the triggering event, such as the addition of a new 
blob to a specified bucket, and validating that the associated actions, 
like invoking cloud functions or workflows, are executed as expected. Through 
meticulous testing, developers ensure the reliability and accuracy of their 
Azure Blob Trigger implementation, fostering robustness and confidence in their 
cloud-based applications.

Local Testing Steps:
```
terraform init && \
terraform apply -auto-approve

export INPUT_BUCKET_NAME=$(terraform output -raw trigger_bucket)
export OUTPUT_BUCKET_NAME=$(terraform output -raw results_bucket)

python3 -m pytest -m github

terraform destroy -auto-approve
```
"""

from azure.identity import ClientAssertionCredential

import requests
import logging
import base64
import pytest
import adlfs
import json
import uuid
import time
import os

# Environment Variables
INPUT_BUCKET=os.getenv('INPUT_BUCKET_NAME')
OUTPUT_BUCKET=os.getenv('OUTPUT_BUCKET_NAME')
assert not INPUT_BUCKET is None
assert not OUTPUT_BUCKET is None

def client_assertion():
    OIDC_TOKEN=os.getenv('OIDC_TOKEN')
    assert not OIDC_TOKEN is None

    return OIDC_TOKEN

def exchange_oidc_token():
    AZURE_CLIENT_ID=os.getenv('AZURE_CLIENT_ID')
    AZURE_TENANT_ID=os.getenv('AZURE_TENANT_ID')
    assert not AZURE_CLIENT_ID is None
    assert not AZURE_TENANT_ID is None

    return ClientAssertionCredential(
        client_id=AZURE_CLIENT_ID,
        tenant_id=AZURE_TENANT_ID,
        func=client_assertion,
   )


def _write_blob(fs, payload):
    with fs.open('trigger/test.json', 'w') as f:
        f.write(json.dumps(payload))

def _read_blob(fs):
    with fs.open('results/test.json', 'rb') as f:
        return json.loads(f.read())

@pytest.mark.github
@pytest.mark.client_credentials
def test_azure_credentials_blob_trigger(payload={'test_value': str(uuid.uuid4())}):
    logging.info('Pytest | Test Azure Blob Trigger')
    AZURE_CLIENT_ID=os.getenv('AZURE_CLIENT_ID')
    AZURE_CLIENT_SECRET=os.getenv('AZURE_CLIENT_SECRET')
    AZURE_TENANT_ID=os.getenv('AZURE_TENANT_ID')
    assert not AZURE_CLIENT_ID is None
    assert not AZURE_CLIENT_SECRET is None
    assert not AZURE_TENANT_ID is None
    
    fs_input = adlfs.AzureBlobFileSystem(
        account_name=INPUT_BUCKET,
        client_id=AZURE_CLIENT_ID,
        client_secret=AZURE_CLIENT_SECRET,
        tenant_id=AZURE_TENANT_ID
    )
    _write_blob(fs_input, payload)

    time.sleep(10)
    fs_output = adlfs.AzureBlobFileSystem(
        account_name=OUTPUT_BUCKET,
        client_id=AZURE_CLIENT_ID,
        client_secret=AZURE_CLIENT_SECRET,
        tenant_id=AZURE_TENANT_ID
    )
    rs = _read_blob(fs_output)

    assert rs['test_value'] == payload['test_value']

@pytest.mark.github
@pytest.mark.oidc
def test_azure_oidc_blob_trigger(payload={'test_value': str(uuid.uuid4())}):
    logging.info('Pytest | Test Azure Blob Trigger')
    creds = exchange_oidc_token()

    fs_input = adlfs.AzureBlobFileSystem(
        account_name=INPUT_BUCKET,
        credential=creds
    )
    _write_blob(fs_input, payload)

    time.sleep(120)
    
    fs_output = adlfs.AzureBlobFileSystem(
        account_name=OUTPUT_BUCKET,
        credential=creds
    )
    rs = _read_blob(fs_output)

    assert rs['test_value'] == payload['test_value']
