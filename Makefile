version=1.1.0
rd=java -jar rundeck-cli-${version}-all.jar

# https://rundeck.github.io/rundeck-cli/configuration/
export RD_URL=http://127.0.0.1:4440
# export RD_URL=http://127.0.0.1:4440/api/27
export RD_TOKEN=token_string
export RD_USER=admin
export RD_PASSWORD=admin
# export RD_DEBUG=1,2,3

ensure-not-root-dir:
	if [ `pwd` = "/" ]; then exit 1; fi
create-required-directories: ensure-not-root-dir
	rm -rf `pwd`/tmp
	mkdir -p `pwd`/{input_data,tmp,data}
run-rundeck: create-required-directories
	docker run --publish 4440:4440/tcp \
	--volume=`pwd`/tmp:/tmp:rw \
	--volume=`pwd`/data:/home/rundeck/server/data:rw \
	--volume=`pwd`/tokens.properties:/tokens.properties:ro \
	-ti --rm --name rundeck rundeck/rundeck:SNAPSHOT


add-admin-token-for-rest-api:
	# http://127.0.0.1:4440/menu/systemConfig
	docker exec -ti rundeck sh -c "echo \"rundeck.tokens.file=/tokens.properties\" >> /home/rundeck/etc/framework.properties"
test-rest-api:
	curl "${RD_URL}/api/27/system/info" -H "X-Rundeck-Auth-Token:${RD_TOKEN}"


install-rd-cli:
	curl -L -O https://github.com/rundeck/rundeck-cli/releases/download/v${version}/rundeck-cli-${version}-all.jar
test-cli:
	# https://rundeck.github.io/rundeck-cli/commands/
	${rd} system info
list-infos:
	${rd} system info
	${rd} users list
	${rd} tokens list --user admin
	${rd} system acls list
	# ${rd} nodes list --verbose --project MyProject #--outformat %hostname
	${rd} nodes list --verbose --project MyProject --filter osFamily:unix


create-project:
	${rd} projects create --project MyProject
create-job:
	# --remove-uuids
	${rd} jobs load --verbose --project MyProject --format yaml --file Release/Deploy\ Project/Deploy_Project.yaml
	# http://127.0.0.1:4440/api/27/job/7793dc02-cd90-4035-aaa6-9dfb24e886ee
	# http://127.0.0.1:4440/project/MyProject/job/show/7793dc02-cd90-4035-aaa6-9dfb24e886ee
create-project-and-job: create-project create-job
delete-job:
	# ${rd} jobs list --project MyProject --job "Deploy Project"
	# ${rd} jobs list --project MyProject --group Release --job Deploy\ Project
	${rd} jobs list --project MyProject --group Release --job "Deploy Project"
	# ${rd} jobs purge --verbose --project MyProject --idlist 7793dc02-cd90-4035-aaa6-9dfb24e886ee --format yaml --file Release/Deploy\ Project/Deploy_Project.yaml_bak
	${rd} jobs purge --verbose --project MyProject --group Release --job Deploy\ Project --format yaml --file Release/Deploy\ Project/Deploy_Project.yaml_bak
update-job: delete-job create-job


job-view-as-json:
	cat Release/Deploy\ Project/Deploy_Project.yaml | yq .


cleanup-tmp:
	if [ -f `pwd`/tmp/keepThis.list ] && [ ! -z "$(shell ls `pwd`/tmp | grep -v -f `pwd`/tmp/keepThis.list)" ]; then cd `pwd`/tmp && rm -r $(shell ls `pwd`/tmp | grep -v -f `pwd`/tmp/keepThis.list); fi
	ls `pwd`/tmp > `pwd`/tmp/keepThis.list
copy-files: cleanup-tmp
	cp -R `pwd`/input_data/ `pwd`/tmp/
run-job: copy-files
	# --id -i value
	# --loglevel -l /(verbose|info|warning|error)/
	# --user -u value
	# ${rd} run --project MyProject --job "Release/Deploy Project" --follow -- -Version v1
	${rd} run --project MyProject --job Release/Deploy\ Project --follow -- -Version v1
