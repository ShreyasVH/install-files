const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'jenkins';

	const previousVersion = getPreviousVersion(program);

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/jenkins.conf`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath = `${newConfigFolder}/jenkins.conf`;

		// console.log(previousConfigFilePath);
		// console.log(newConfigFilePath);

		const newPort = addPort(`jenkins ${newVersion}`);
		// console.log(newPort);

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath, newConfigFilePath);

		let content = fs.readFileSync(newConfigFilePath, 'utf8');

		content = content.replace(/^port=.*$/m, `port=${newPort}`);

		fs.writeFileSync(newConfigFilePath, content);

		await copyInstallFile(program, newVersion);

		const previousFolder = `${process.env.OS_FOLDER}/${program}/${previousVersion}`;
		const newFolder = `${process.env.OS_FOLDER}/${program}/${newVersion}`
		fs.copyFileSync(`${previousFolder}/createUser.groovy`, `${newFolder}/createUser.groovy`);
		fs.copyFileSync(`${previousFolder}/createCredentials.groovy`, `${newFolder}/createCredentials.groovy`);
		fs.copyFileSync(`${previousFolder}/fetchUpdateCenterData.groovy`, `${newFolder}/fetchUpdateCenterData.groovy`);
		fs.copyFileSync(`${previousFolder}/createMultibranchPipeline.groovy`, `${newFolder}/createMultibranchPipeline.groovy`);
	}
})();