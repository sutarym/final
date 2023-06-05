import requests
import os
import json
import boto3
import base64

def lambda_handler(event, context):


  payload = event
  request_body_ = {
        "subnet_id": payload['subnet_id'],
        "name": payload['name'],
        "email": payload['email']
    }
    # Convert the payload to JSON
  request_body = json.dumps(request_body_)
 
  request_headers = {
        "Content-Type": "application/json"
    }

  response = requests.post('https://jsonplaceholder.typicode.com/posts',
                             headers=request_headers,
                             data=json.dumps(request_body))

    # Retrieve the base64-encoded response
  base64_response = base64.b64encode(response.content).decode('utf-8')

#     # Add padding to the base64-encoded response
#   padded_response = add_padding(base64_response)

  try:
        # Decode the base64-encoded response
      decoded_response = base64.b64decode(base64_response).decode('utf-8')

        # Print the decoded response
      print("Decoded response:", decoded_response)
  except Exception as e:
      print("Error decoding response:", str(e))
      decoded_response = None

  # Check the response status code
  if response.status_code == 200:
    print(response.status_code)
    print("if")
    return {
      'statusCode': 200,
      'body': json.dumps({'message': 'The request was successful.'}),
      "log_result": decoded_response
    }
  else:
    print(response.status_code)
    print("else")
    return {
      'statusCode': response.status_code,
      'body': json.dumps({'message': 'The request failed.'}),
      "log_result": decoded_response
    }
