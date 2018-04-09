import csv
import os
import sys
with open(sys.argv[1], 'rb') as f:
    reader = csv.reader(f)
    for row in reader:
      if row[0] and row[0].strip() and row[1] and row[1].strip():
        line = 'aws ec2 create-tags --resources ' + row[0] + ' --tags "Key=RunSchedule,Value=' +  row[1] + '"'
        os.system(line);