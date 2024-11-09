# gost


## gost.sh 

- 69行的`ct_new_ver="2.11.2"`固定死了版本， 如果要下载最新把69行注释掉。 但是最新版本的github文件命名不对

- gost.service如果下载不下来，在脚本执行完成后，参考下面手动

## gost.service
复制到`/usr/lib/systemd/system`

chmod 777 gost.service 

systemctl enable gost 

systemctl restart gost
