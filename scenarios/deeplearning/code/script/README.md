# CycleCloud script

This script is taken from the [community CycleCloud repo](https://github.com/CycleCloudCommunity/cyclecloud_arm).
It needs to be gzipped and encoded in base64 for use in the cloud-init file.

To get the required base64 value, run the following command:

```bash
gzip -c ccloud_install.sh | base64
```
