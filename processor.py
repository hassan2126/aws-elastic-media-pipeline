import boto3
import time
import os

# Initialize the Amazon S3 client wrapper
s3 = boto3.client('s3')
BUCKET_NAME = 'company-ingest-bucket-hassan-96'

def process_media():
    while True:
        # Atomic polling constraint for compete-and-consume rhythm
        response = s3.list_objects_v2(Bucket=BUCKET_NAME, MaxKeys=1)
        
        if 'Contents' in response:
            for obj in response['Contents']:
                key = obj['Key']
                local_path = f"/tmp/{key}"
                try:
                    # Ingest media object locally onto local ephemeral volume
                    s3.download_file(BUCKET_NAME, key, local_path)
                    
                    # Stress-testing payload: Simulates intensive CPU transcoding logic
                    start_time = time.time()
                    while time.time() - start_time < 30:
                        _ = 12345 * 67890
                        
                    # Release file lock object explicitly at source to clear item upstream
                    s3.delete_object(Bucket=BUCKET_NAME, Key=key)
                except Exception as err:
                    print(f"Error handling task key {key}: {err}")
                finally:
                    if os.path.exists(local_path):
                        os.remove(local_path)
        else:
            # Idle mitigation - Backoff loop avoids generating unnecessary operational cost metrics
            time.sleep(10)

if __name__ == "__main__":
    process_media()
