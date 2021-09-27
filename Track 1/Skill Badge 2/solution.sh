Perform Foundational Infrastructure Tasks in Google Cloud: Challenge Lab

Task 1: Create a bucket

gsutil mb gs://<YOUR-BUCKET-NAME> 
  tip - use your project id for the bucket name 

---------------------------------------------------------------------------------

Task 2: Create a Pub/Sub topic

gcloud pubsub topics create myTopic

---------------------------------------------------------------------------------

Task 3: Create the thumbnail Cloud Function

In the console, click the Navigation menu > Cloud Functions.

2. Click Create function.

3. In the Create function dialog, enter the following values:
Name : GCFunction
Trigger Type : Cloud Storage
Event Type : Finalize/Create
Browse the bucket you have created and click Save.
Click Save
click Next
Set Runtime as Node.js 14
Entry point : thumbnail
Then, from lab instructions, replace code for index.js and package.json
On line 15 of index.js replace the text REPLACE_WITH_YOUR_TOPIC with the topic you created in task 2.
Then, click Deploy
After creating the function, upload an image in a bucket. You will see a thumbnail image appear shortly afterward (use REFRESH BUCKET).

---------------------------------------------------------------------------------

Task 4: Remove the previous cloud engineer

1. Go to IAM & Admin -> IAM
2. Search for Username 2
3. Remove it