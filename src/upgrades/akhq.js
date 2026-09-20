const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'akhq';

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/application.yml`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath = `${newConfigFolder}/application.yml`;

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath, newConfigFilePath);

		const newPort = addPort(`akhq ${newVersion}`);

		let content = fs.readFileSync(newConfigFilePath, 'utf8');
		content = content.replace(/port: .*$/m, `port: ${newPort}`);
		fs.writeFileSync(newConfigFilePath, content);

		await copyInstallFile(program, newVersion);
	}
})();