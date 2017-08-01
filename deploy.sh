#!/usr/bin/env bash

ENV=$1

#AWS_REGION=$(eval "echo \$${ENV}_AWS_REGION")
AWS_ACCESS_KEY_ID=$(eval "echo \$${ENV}_AWS_ACCESS_KEY_ID")
AWS_SECRET_ACCESS_KEY=$(eval "echo \$${ENV}_AWS_SECRET_ACCESS_KEY")
AWS_S3_BUCKET=$(eval "echo \$${ENV}_S3_BUCKET")

configure_aws_cli() {
	aws --version
	aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
	aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
	#aws configure set default.region $AWS_REGION
	aws configure set default.output json
	echo "Configured AWS CLI."
}

deploy_s3bucket() {
        #chmod -R 775 ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist
	result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control private,no-store,no-cache,must-revalidate,max-age=0 --exclude "*.txt" --exclude "*.js"`	
	result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control private,no-store,no-cache,must-revalidate,max-age=0 --exclude "*.txt" --exclude "*.js" --exclude "*.map" --exclude "*.html"`	
	if [ $? -eq 0 ]; then
		#echo $result
		echo "All font, image and media files are Deployed!"
	else
		echo "Deployment Failed  - $result"
		exit 1
	fi
	#result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control private,no-store,no-cache,must-revalidate,max-age=0`
	result=`aws s3 sync ${HOME}/${CIRCLE_PROJECT_REPONAME}/dist s3://${AWS_S3_BUCKET} --cache-control private,no-store,no-cache,must-revalidate,max-age=0 --include "*.txt" --include "*.js" --include "*.map" --include "*.html" --exclude "*"  --content-encoding gzip`	
	if [ $? -eq 0 ]; then
		#echo $result
		echo "All image and media files are Deployed!"
	else
		echo "Deployment Failed  - $result"
		exit 1
	fi
}

#sed -i 's/^application\/x-font-woff.*/application\/font-woff\t\t\t\twoff/' /etc/mime.types
echo -e "application/font-woff\t\t\t\twoff2" >> /etc/mime.types
echo -e "application/font-sfnt\t\t\t\tttf" >> /etc/mime.types
echo -e "application/json\t\t\t\tmap" >> /etc/mime.types
#sed -i 's/^image\/vnd.microsoft.icon.*/image\/vnd.microsoft.icon/' /etc/mime.types
#sed -i 's/^image\/x-icon.*/image\/x-icon\t\t\t\tico/' /etc/mime.types
cat /etc/mime.types  | grep -i woff
cat /etc/mime.types  | grep -i ico
cat /etc/mime.types  | grep -i map
cat /etc/mime.types  | grep -i ttf

configure_aws_cli
deploy_s3bucket