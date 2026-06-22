const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'mysql';

	const previousVersion = getPreviousVersion(program);

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/my.cnf`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath = `${newConfigFolder}/my.cnf`;

		// console.log(previousConfigFilePath);
		// console.log(newConfigFilePath);

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath, newConfigFilePath);

		const newPort = addPort(`mysql ${newVersion}`);

		let content = fs.readFileSync(newConfigFilePath, 'utf8');
		content = content.replaceAll(`${previousVersion.replaceAll('.', '_')}`, `${newVersion.replaceAll('.', '_')}`);
		content = content.replace(/^port=.*$/m, `port=${newPort}`);
		fs.writeFileSync(newConfigFilePath, content);

		await copyInstallFile(program, newVersion);
	}
})();