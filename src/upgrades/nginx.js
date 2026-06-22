const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'nginx';

	const previousVersion = getPreviousVersion(program);

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/nginx.conf`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath = `${newConfigFolder}/nginx.conf`;

		// console.log(previousConfigFilePath);
		// console.log(newConfigFilePath);

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath, newConfigFilePath);

		await copyInstallFile(program, newVersion);
	}
})();