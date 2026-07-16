const { copyInstallFile, getPreviousVersion } = require('./base.js');
const { addPort } = require('../utils.js');
const fs = require('fs');

(async () => {
	const newVersion = process.argv[2];
	const program = 'elasticsearch';

	const previousVersion = getPreviousVersion(program);

	if (newVersion !== previousVersion) {

		const previousConfigFilePath = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${previousVersion}/elasticsearch.yml`;
		const newConfigFolder = `${process.env.HOME}/workspace/myProjects/config-samples/${process.env.OS_FOLDER}/${program}/${newVersion}`;
		const newConfigFilePath = `${newConfigFolder}/elasticsearch.yml`;

		fs.mkdirSync(newConfigFolder);
		fs.copyFileSync(previousConfigFilePath, newConfigFilePath);

		const newHttpPort = addPort(`elasticsearch ${newVersion} http`);
		const newTcpPort = addPort(`elasticsearch ${newVersion} tcp`);

		let content = fs.readFileSync(newConfigFilePath, 'utf8');
		content = content.replace(/^(http.port: .*)$/m, `http.port: ${newHttpPort}`);
		content = content.replace(/^(transport.port: .*)$/m, `transport.port: ${newTcpPort}`);
		content = content.replaceAll(`${previousVersion.replaceAll('.', '_')}`, `${newVersion.replaceAll('.', '_')}`);
		fs.writeFileSync(newConfigFilePath, content);

		await copyInstallFile(program, newVersion);
	}
})();