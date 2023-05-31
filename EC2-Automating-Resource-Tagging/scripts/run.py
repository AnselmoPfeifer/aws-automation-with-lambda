import json
import boto3

ec2 = boto3.resource('ec2')


def lambda_handler(event, context):
    print(f'INFO: event: {str(event)}')
    print(json.dumps(event))

    # Contain all the identifiers of EC2 resources found in a given event.
    # IDs could be EC2 instances, EBS volumes, EBS snapshots, ENIs, or AMIs.
    ids = []
    try:
        region = event['region']
        detail = event['detail']
        event_name = detail['eventName']
        arn = detail['userIdentity']['arn']
        principal = detail['userIdentity']['principalId']
        user_type = detail['userIdentity']['type']

        if user_type == 'IAMUser':
            user = detail['userIdentity']['userName']
        else:
            # Could be a web federated user or assumed roles
            user = principal.split(': ')[1]

        print('arn: ' + arn)
        print('principalId: ' + principal)
        print('region: ' + region)
        print('eventName: ' + event_name)
        print('detail: ' + str(detail))
        print('user: ' + user)

        if not detail['responseElements']:
            print('No responseElements found')
            if detail['errorCode']:
                print('errorCode: ' + detail['errorCode'])
            if detail['errorMessage']:
                print('errorMessage: ' + detail['errorMessage'])
            return False

        if event_name == 'CreateVolume':
            ids.append(detail['responseElements']['volumeId'])
            print(ids)

        elif event_name == 'RunInstances':
            items = detail['responseElements']['instancesSet']['items']
            for item in items:
                ids.append(item['instanceId'])
            print(ids)
            print('number of instances: ' + str(len(ids)))

            base = ec2.instances.filter(InstanceIds=ids)

            # loop through the instances
            for instance in base:
                for vol in instance.volumes.all():
                    ids.append(vol.id)
                for eni in instance.network_interfaces:
                    ids.append(eni.id)

        elif event_name == 'CreateImage':
            ids.append(detail['responseElements']['imageId'])
            print(ids)

        elif event_name == 'CreateSnapshot':
            ids.append(detail['responseElements']['snapshotId'])
            print(ids)
        else:
            print('Not supported action')

        if ids:
            for resourceid in ids:
                print('Tagging resource ' + resourceid)
            ec2.create_tags(Resources=ids, Tags=[
                {'Key': 'Owner', 'Value': user},
                {'Key': 'PrincipalId', 'Value': principal}])

        print('Done tagging.')

        return True
    except Exception as e:
        print('Something went wrong: ' + str(e))
        return False
