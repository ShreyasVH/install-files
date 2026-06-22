const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'mongo';

	const previousVersion = getPreviousVersion(program);

	const previousConfigFilePath = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/mongod.conf`;
	const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
	const newConfigFilePath = `${newConfigFolder}/mongod.conf`;

	// console.log(previousConfigFilePath);
	// console.log(newConfigFilePath);

	fs.mkdirSync(newConfigFolder);
	fs.copyFileSync(previousConfigFilePath, newConfigFilePath);

	const newPort = addPort(`mongo ${newVersion}`);

	let content = fs.readFileSync(newConfigFilePath, 'utf8');
	content = content.replaceAll(`${previousVersion}`, `${newVersion}`);
	content = content.replace(/port:.*$/m, `port: ${newPort}`);
	fs.writeFileSync(newConfigFilePath, content);

	await copyInstallFile(program, newVersion);
})();