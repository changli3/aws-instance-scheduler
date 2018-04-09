export AWS_DEFAULT_REGION=us-east-1
fullfilename=$1
filename=$(basename "$fullfilename")
fname="${filename%.*}"
ext="${filename##*.}"
curl -O $fullfilename

python tag-csv.py $fname
