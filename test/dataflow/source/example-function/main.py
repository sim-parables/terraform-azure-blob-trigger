""" Azure Functions Application Example

An Azure Functions Application with a Blob Storage Trigger is a 
serverless function that automatically executes in response to changes in a 
specified Cloud Storage bucket. When a new blob (file) is created, modified, 
or deleted in the specified bucket, the Function Application is triggered, allowing 
you to perform custom logic or processing on the blob data. This trigger mechanism 
enables event-driven architecture and allows you to build scalable and event-based 
solutions on Azure.

This example in particular will take JSON data from the Trigger ADLS Bucket,
and store the exact same content with same file name in the Results ADLS Bucket
referred to under ENV Variable OUTPUT_BUCKET.

"""
import azure.functions as func
import logging
import adlfs
import json
import sys
import os
import re

# Environment Variables
INPUT_BUCKET_CONNECTION_STRING=os.getenv('AzureWebJobsStorage', None)
OUTPUT_BUCKET=os.getenv('OUTPUT_BUCKET_NAME')
OUTPUT_BUCKET_KEY=os.getenv('OUTPUT_BUCKET_KEY', None)


# Setup
logging.basicConfig(stream=sys.stdout, level=logging.INFO)

def load_json(fs, file_path):
    """
    Load JSON data from a file.

    Args:
        fs (s3fs.S3Filesystem): File system object.
        file_path (str): (Blob) File path of the JSON file.

    Returns:
        dict: Loaded JSON data.

    """
    logging.info('Loading JSON %s' % file_path)

    with fs.open(file_path, 'rb') as f:
        return json.load(f)

# Triggered by a change in a storage bucket
def main(myblob: func.InputStream):
    """
    Function triggered by an ADLS Storage event.

    Args:
        myblob (funcazure.functions.InputStream): InputStream object containing meta data about blob.

    """
    logging.info('Blob:%s | Initiating ETL trigger' % (myblob.name))

    fs_input = adlfs.AzureBlobFileSystem(connection_string=INPUT_BUCKET_CONNECTION_STRING)
    rs = load_json(fs_input, myblob.name)

    fs_output = adlfs.AzureBlobFileSystem(
        account_name=OUTPUT_BUCKET,
        account_key=OUTPUT_BUCKET_KEY
    )
    with fs_output.open(re.sub('trigger', 'results', myblob.name), 'w') as f:
        f.write(json.dumps(rs))
