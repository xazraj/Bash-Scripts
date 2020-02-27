aws s3 sync --sse --delete /var/local/archives/ s3://bucketname/`uname -n`/ >/tmp/s3sync.out 2>&1 || cat /tmp/s3sync.out
