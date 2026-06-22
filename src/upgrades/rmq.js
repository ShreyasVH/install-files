const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'rmq';

	const previousVersion = getPreviousVersion(program);

	const previousConfigFilePath1 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/rabbitmq.conf`;
	const previousConfigFilePath2 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/rabbitmq-env.conf`;
	const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
	const newConfigFilePath1 = `${newConfigFolder}/rabbitmq.conf`;
	const newConfigFilePath2 = `${newConfigFolder}/rabbitmq-env.conf`;

	// console.log(previousConfigFilePath);
	// console.log(newConfigFilePath);

	fs.mkdirSync(newConfigFolder);
	fs.copyFileSync(previousConfigFilePath1, newConfigFilePath1);
	fs.copyFileSync(previousConfigFilePath2, newConfigFilePath2);

	const newAmqpPort = addPort(`rmq ${newVersion} amqp`);
	const newManagementPort = addPort(`rmq ${newVersion} management`);
	const newDistPort = addPort(`rmq ${newVersion} dist`);
	const newEpmdPort = addPort(`rmq ${newVersion} epmd`);

	let content = fs.readFileSync(newConfigFilePath1, 'utf8');
	content = content.replace(/^listeners.tcp.default = .*$/m, `listeners.tcp.default = ${newAmqpPort}`);
	content = content.replace(/^management.tcp.port = .*$/m, `management.tcp.port = ${newManagementPort}`);
	content = content.replace(/^listeners.tcp.dist = .*$/m, `listeners.tcp.dist = ${newDistPort}`);
	fs.writeFileSync(newConfigFilePath1, content);

	content = fs.readFileSync(newConfigFilePath2, 'utf8');
	content = content.replace(/^RABBITMQ_DIST_PORT=.*$/m, `RABBITMQ_DIST_PORT=${newDistPort}`);
	content = content.replaceAll(`${previousVersion.replaceAll('.', '')}`, `${newVersion.replaceAll('.', '')}`);
	fs.writeFileSync(newConfigFilePath2, content);

	await copyInstallFile(program, newVersion);
})();