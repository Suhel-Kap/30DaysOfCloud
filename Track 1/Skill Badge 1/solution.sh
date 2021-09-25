gcloud compute instances create nucleus-jumphost \
 --machine-type=f1-micro \
 --zone=us-east1-b \
 --network=nucleus-vpc

gcloud container clusters create nucleus-server \
 --network=nucleus-vpc \
 --num-nodes=1 \
 --zone us-east1-b

gcloud container clusters get-credentials nucleus-server

kubectl create deployment hello-server --image=gcr.io/google-samples/hello-app:2.0

kubectl expose deployment hello-server --type=LoadBalancer --port 8080

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

gcloud compute instance-templates create nucleus-backend-template \
   --region=us-east1 \
   --machine-type=g1-small \
   --network=nucleus-vpc \
   --metadata-from-file startup-script=startup.sh

gcloud compute instance-groups managed create nucleus-backend-group \
   --template=nucleus-backend-template \
   --size=2 \
   --region=us-east1

gcloud compute firewall-rules create nucleus-web-server-fw \
    --network=nucleus-vpc \
    --allow=tcp:80

gcloud compute health-checks create http http-basic-check

gcloud compute instance-groups managed \
  --set-named-ports nucleus-backend-group \
  --named-ports http:80 \
  --region us-east1

gcloud compute backend-services create nucleus-web-backend-service \
  --protocol=HTTP \
  --health-checks=http-basic-check \
  --global

gcloud compute backend-services add-backend nucleus-web-backend-service \
  --instance-group=nucleus-backend-group \
  --instance-group-region=us-east1 \
  --global

gcloud compute url-maps create web-map-http \
  --default-service nucleus-web-backend-service

gcloud compute target-http-proxies create http-lb-proxy \
  --url-map web-map-http

gcloud compute forwarding-rules create http-content-rule \
  --global \
  --target-http-proxy=http-lb-proxy \
  --ports=80