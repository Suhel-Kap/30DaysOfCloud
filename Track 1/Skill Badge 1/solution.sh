gcloud compute instances create nucleus-jumphost \
 --machine-type=f1-micro \
 --zone=us-east1-b 

gcloud container clusters create nucleus-server \
 --zone us-east1-b

gcloud container clusters get-credentials nucleus-server

kubectl create deployment nucleus-server --image=gcr.io/google-samples/hello-app:2.0

kubectl expose deployment nucleus-server --type=LoadBalancer --port 8080

cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF

gcloud compute instance-templates create nucleus-backend-template \
   --region=us-east1 \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --image-family=debian-9 \
   --image-project=debian-cloud \
   --metadata-from-file startup-script=startup.sh

gcloud compute instance-groups managed create nucleus-backend-group \
   --template=nucleus-backend-template \
   --size=2 \
   --region=us-east1

gcloud compute firewall-rules create nucleus-web-server-fw \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80

gcloud compute health-checks create http http-basic-check

gcloud compute backend-services create nucleus-web-backend-service \
  --protocol=HTTP \
  --port-name=http \
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