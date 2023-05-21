import boto3


def lambda_handler(event, context):
    print(f'INFO: starting process to prune ec2 snapshot nightly!')
    account_id = boto3.client('sts').get_caller_identity().get('Account')
    ec2 = boto3.client('ec2')
    regions = [region['RegionName']
               for region in ec2.describe_regions()['Regions']]

    for region in regions:
        ec2 = boto3.client('ec2', region_name=region)
        response = ec2.describe_snapshots(OwnerIds=[account_id])
        snapshots = response['Snapshots']

        # Sort snapshots by date ascending
        snapshots.sort(key=lambda x: x['StartTime'])

        # Remove snapshots we want to keep (i.e 3 most recent)
        snapshots = snapshots[: -2]
        for snapshot in snapshots:
            tags = snapshot.get('Tags')
            if tags is not None:
                for tag in tags:
                    if tag['Key'] == 'CreatedBy' and tag['Value'] == 'Lambda':
                        snapshot_id = snapshot['SnapshotId']
                        try:
                            print(f'INFO: deleting snapshot id: {snapshot_id}')
                            ec2.delete_snapshot(SnapshotId=snapshot_id)
                        except Exception as e:
                            if 'InvalidSnapshot.InUse' in e.message:
                                print(f'WARN: snapshot {snapshot_id} in use, skipping delete process!')
                                continue

