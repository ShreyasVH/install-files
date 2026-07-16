const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'kafka';

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/server.properties`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath = `${newConfigFolder}/server.properties`;

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath, newConfigFilePath);

		const newPort = addPort(`kafka ${newVersion}`);
		const newControllerPort = addPort(`kafka ${newVersion} controller`);
		const previousPort = addPort(`kafka ${previousVersion}`);
		const previousControllerPort = addPort(`kafka ${previousVersion} controller`);

		let content = fs.readFileSync(newConfigFilePath, 'utf8');
		content = content.replaceAll(`:${previousPort}`, `:${newPort}`);
		content = content.replaceAll(`:${previousControllerPort}`, `:${newControllerPort}`);
		content = content.replaceAll(`${previousVersion}`, `${newVersion}`);
		fs.writeFileSync(newConfigFilePath, content);

		await copyInstallFile(program, newVersion);
	}
})();