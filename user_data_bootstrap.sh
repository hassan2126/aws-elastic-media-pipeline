#!/bin/bash
# 1. Environment initialization - Deploy Boto3 AWS SDK runtime wrapper
pip3 install boto3

# 2. Localized application delivery - Drop the direct poll consumer execution engine daemon
cat << 'EOF' > /home/ec2-user/processor.py
import boto3
import time
import os

s3 = boto3.client('s3')
BUCKET_NAME = 'company-ingest-bucket-hassan-96'

def process_media():
    while True:
        response = s3.list_objects_v2(Bucket=BUCKET_NAME, MaxKeys=1)
        if 'Contents' in response:
            for obj in response['Contents']:
                key = obj['Key']
                local_path = f"/tmp/{key}"
                try:
                    s3.download_file(BUCKET_NAME, key, local_path)
                    start_time = time.time()
                    while time.time() - start_time < 30:
                        _ = 12345 * 67890
                    s3.delete_object(Bucket=BUCKET_NAME, Key=key)
                except Exception as err:
                    print(f"Error handling task key {key}: {err}")
                finally:
                    if os.path.exists(local_path):
                        os.remove(local_path)
        else:
            time.sleep(10)

if __name__ == "__main__":
    process_media()
EOF

# 3. Establish operating context permissions and spin runtime wrapper loop to persistent background state
chown ec2-user:ec2-user /home/ec2-user/processor.py
nohup python3 /home/ec2-user/processor.py > /home/ec2-user/processor.log 2>&1 &
