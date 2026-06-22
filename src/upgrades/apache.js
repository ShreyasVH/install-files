const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'apache';

	const previousVersion = getPreviousVersion(program);

	const previousConfigFilePath1 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/httpd.conf`;
	const previousConfigFilePath2 = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/httpd-vhosts.conf`;
	const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
	const newConfigFilePath1 = `${newConfigFolder}/httpd.conf`;
	const newConfigFilePath2 = `${newConfigFolder}/httpd-vhosts.conf`;

	// console.log(previousConfigFilePath);
	// console.log(newConfigFilePath);

	fs.mkdirSync(newConfigFolder);
	fs.copyFileSync(previousConfigFilePath1, newConfigFilePath1);
	fs.copyFileSync(previousConfigFilePath2, newConfigFilePath2);

	let content = fs.readFileSync(newConfigFilePath1, 'utf8');
	content = content.replaceAll(`${previousVersion}`, `${newVersion}`);
	fs.writeFileSync(newConfigFilePath1, content);

	content = fs.readFileSync(newConfigFilePath2, 'utf8');
	content = content.replaceAll(`${previousVersion}`, `${newVersion}`);
	fs.writeFileSync(newConfigFilePath2, content);

	await copyInstallFile(program, newVersion);
})();